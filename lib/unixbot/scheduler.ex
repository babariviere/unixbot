# FIXME: there is only one issue left with this code.
# When I register, then unregister and then register, the job will be scheduled 2 times.
# Potential fix: I register the pid and kill it on unregister.
# Drawback: We have to modify state so the schedule job function will not be able to be run in parallel.

defmodule Unixbot.Scheduler do
  @moduledoc """
  A job scheduler.

  For our bot context, it is used to schedule post fetching.
  """

  use GenServer

  alias Crontab.Scheduler, as: CS

  defmodule Job do
    @moduledoc """
    A function scheduled by her cron job expression.
    """

    alias Crontab.CronExpression, as: Expr

    defstruct [:name, :expr, :func]

    @type name :: String.t() | atom()

    @type t :: %__MODULE__{
            name: name,
            expr: Expr.t(),
            func: function()
          }

    @spec set_name(t(), name()) :: t()
    def set_name(job, name) do
      %{job | name: name}
    end

    @spec set_expr(t(), Expr.t()) :: t()
    def set_expr(job, expr) do
      %{job | expr: expr}
    end

    @spec set_func(t(), function()) :: t()
    def set_func(job, func) do
      %{job | func: func}
    end

    @spec valid?(t()) :: boolean()
    def valid?(job) do
      job.name != nil && job.expr != nil && job.func != nil
    end
  end

  @server __MODULE__

  @spec start_link(map()) :: GenServer.on_start()
  def start_link(state \\ %{}) do
    GenServer.start_link(@server, state, name: @server)
  end

  @doc """
  Register a job for running.

  If job is not valid, it will not be ignored. See `Unixbot.Scheduler.Job.valid?()`.
  """
  @spec register(Job.t()) :: :ok
  def register(job) do
    GenServer.cast(@server, {:register, job})
  end

  @doc """
  Unregister a job from being run.
  """
  @spec unregister(Job.name()) :: :ok
  def unregister(name) do
    GenServer.cast(@server, {:unregister, name})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:register, job}, state) do
    if Job.valid?(job) do
      # Schedule only if does not exists (avoid duplicates)
      if not Map.has_key?(state, job.name) do
        schedule_job(job)
      end

      {:noreply, Map.put(state, job.name, job)}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:unregister, name}, state) do
    {:noreply, Map.delete(state, name)}
  end

  @impl true
  def handle_info({:schedule, name}, state) do
    job = Map.get(state, name)

    if job do
      schedule_job(job)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:run, name}, state) do
    job = Map.get(state, name)

    if job do
      spawn(fn ->
        job.func.()
        schedule_job(job)
      end)
    end

    {:noreply, state}
  end

  @spec schedule_job(Job.t()) :: reference()
  defp schedule_job(job) do
    now = NaiveDateTime.utc_now()
    date = CS.get_next_run_date!(job.expr, now)
    diff = NaiveDateTime.diff(date, now, :millisecond)
    Process.send_after(@server, {:run, job.name}, diff)
  end
end
