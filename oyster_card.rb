class OysterCard
  attr_reader :balance, :entry_station

  STATION_ZONES = {
    holburn: [1],
    chelsea: [1],
    earls_court: [1,2],
    wimbledon: [3],
    hammersmith: [2]
  }.freeze
  BUS_FARE = 1.8.freeze
  TUBE_FARES = {
    tier1: 2.5,
    tier2: 2.0,
    tier3: 3.0,
    tier4: 2.25,
    tier5: 3.2
  }.freeze
  MAX_TUBE_FARE = TUBE_FARES.values.max.freeze

  def initialize(balance: 0)
    @balance = balance
    @entry_station
  end

  def load_card(amount)
    raise 'Amount to add must be a positive number' unless amount.is_a?(Numeric) && amount.positive?
    @balance += amount
  end

  def tap_on(mode, entry_station=nil)
    case mode
    when 'tube'
      raise 'Zone name must be valid' unless STATION_ZONES.keys.include?(entry_station)
      deduct_fare(MAX_TUBE_FARE)
      @entry_station = entry_station
    when 'bus'
      deduct_fare(BUS_FARE)
    else
      raise "Mode #{mode} not implemented"
    end
  end

  def calculate_fare(traveled_zones)
    zone_crossings = traveled_zones.reduce(:-).abs

    case zone_crossings
    when 0
      traveled_zones.include?(1) ? TUBE_FARES[:tier1] : TUBE_FARES[:tier2]
    when 1
      traveled_zones.include?(1) ? TUBE_FARES[:tier3] : TUBE_FARES[:tier4]
    when 2
      TUBE_FARES[:tier5]
    else
      raise "Logic for this trip has not been implemented"
    end
  end

  def tap_off(exit_station)
    raise 'Tube trips must record entry station' unless @entry_station

    entry_zones = STATION_ZONES[@entry_station.to_sym]
    exit_zones = STATION_ZONES[exit_station.to_sym]

    starting_and_ending_zones = calculate_traveled_zones(entry_zones, exit_zones)

    reimbursement = MAX_TUBE_FARE - calculate_fare(starting_and_ending_zones)

    load_card(reimbursement) if reimbursement > 0
    @entry_station = nil
  end

  def calculate_traveled_zones(entry_zones, exit_zones)
    # I'd make a note to look into refactoring this ugliness, but since we know 
    # that the zone arrays will each have 2 elements max, because geography, 
    # I'm ok with this as a first pass.
    closest_zones = []
    entry_zones.each do |entry_zone|
      exit_zones.each do |exit_zone|
        diff = (entry_zone - exit_zone).abs
        closest_zones = [diff, [entry_zone, exit_zone]] if closest_zones.empty? || diff < closest_zones[0]
      end
    end

    closest_zones[1]
  end

  def deduct_fare(fare)
    @balance -= fare
  end
end

card = OysterCard.new
puts card.balance
card.load_card(30)
puts card.balance
card.tap_on('tube', :holburn)
puts card.balance
card.tap_off(:earls_court)
puts card.balance
card.tap_on('bus')
puts card.balance
card.tap_on('tube', :chelsea)
puts card.balance
card.tap_off(:wimbledon)
puts card.balance
card.tap_on('tube', :wimbledon)
puts card.balance