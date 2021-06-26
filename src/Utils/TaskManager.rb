class TaskManager

  def initialize
    super
    @tasks = {}
  end

  def self.add_task(cl)
    @tasks[cl] = {}
  end

  def self.get_tasks
    @tasks
  end

end
