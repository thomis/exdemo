defmodule DemoTask do
  def run do
    total_time = Enum.random(5..15) * 1000  # Randomize between 5 and 10 seconds
    update_interval = div(total_time, 4)         # Divide total time by 4 for updates

    # Start the task asynchronously
    Task.async(fn -> perform_task(total_time, update_interval) end)
  end

  defp perform_task(total_time, update_interval) do
    IO.puts("Task started...")

    # Loop until the total time is reached
    1..4
    |> Enum.each(fn i ->
      :timer.sleep(update_interval)
      # Send an update message each quarter
      IO.puts("Update #{i}: Task is in progress... (Time elapsed: #{i * update_interval / 1000} seconds)")
    end)

    # Final completion message
    IO.puts("Task completed after #{total_time / 1000} seconds.")
  end
end
