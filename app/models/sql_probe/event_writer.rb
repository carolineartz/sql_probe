module SqlProbe
  module EventWriter
    module_function

    # Helper to write out raw events to an output location
    def write_to_file_system(name:, events:, output_base_path:, duration:, params: nil)
      # ignore all Rails introspection noise
      events.reject! { |e| e.payload[:name] == 'SCHEMA' }
      return if events.empty?

      # reformat event to be more "readable"
      events.map! { |e| flatten_event_payload(e) }

      file_id = Time.now.to_f
      output_dir = File.join(output_base_path, name)
      FileUtils.mkdir_p(output_dir)
      full_path = File.join(output_dir, "#{file_id}.yml")

      # write contents
      File.open(full_path, 'w') do |file|
        file << {
          'name' => name,
          'duration' => duration,
          'params' => params,
          'events' => events
        }.to_yaml
      end
    end

    def flatten_event_payload(event)
      e = event.as_json
      e.merge!(e.delete('payload'))
    end
  end
end
