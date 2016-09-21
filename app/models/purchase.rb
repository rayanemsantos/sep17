class Purchase < ActiveRecord::Base
	belongs_to :event
  belongs_to :buyer, class_name: 'User'

  validate :validate_limit, :validate_event_schedules

  def self.delete_purchases(current_user, id_event)
  	self.destroy_all(buyer_id:current_user.id, event_id:id_event)
  end

  private
  def check_limit
    self.event.remaining == 0 ? false : true
  end

  def check_event_schedules
    check_schedules = []
    conflit_schedules = []

    check_schedules = self.buyer.events.where.not(id: self.event.id).collect { |e| e.schedules }
    self.event.schedules.each do |schedule|
      conflit_schedules << schedule.start_time_between
    end

    byebug
    conflit_schedules.flatten & check_schedules.flatten
  end

  def validate_limit
    errors.add("Limit", "is invalid.") unless check_limit
  end

  def validate_event_schedules
    errors.add("Evento possui horários", "conflitantes") unless check_event_schedules.empty?
  end



end
