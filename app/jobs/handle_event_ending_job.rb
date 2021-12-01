class HandleEventEndingJob < ApplicationJob
  queue_as :default

  def perform(event)
    puts("Handling event ended for: #{event}")
    # event.waiting_approval = true
  end
end
