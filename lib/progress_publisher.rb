# progress_publisher.rb

# Gives the user progress updates when files are processed.
class ProgressPublisher
  attr_writer :count, :file_total, :mb_count, :mb_total,
              :num_pushed, :redis_list_name

  def initialize(file_total, mb_total, redis_list_name)
    @count = 0
    @file_total = file_total
    @mb_count = 0
    @mb_total = mb_total
    @num_pushed = 0
    @redis_list_name = redis_list_name

    print "Progress: initializing...\r"
  end

  def update(_, file)
    @count += 1
    @mb_count += file.size
    finished = (@count == @file_total)

    percent = (@count.to_f / @file_total.to_f * 100.0).round
    end_line = (finished ? "\n" : "\r")
    print "Progress: #{@count}/#{@file_total} files | "
    print "#{@mb_count.round}MB/#{@mb_total.round}MB | "
    print "#{percent}%#{end_line}"

    print_redis_push_count if finished
  end

  def print_redis_push_count
    print "Results: Pushed #{@num_pushed} "
    puts  "XML files to #{@redis_list_name}."
  end

  def update_from_redis_pusher(num_pushed)
    @num_pushed += num_pushed
  end
end
