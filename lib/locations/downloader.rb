# frozen_string_literal: true

module Locations
  class Downloader
    attr_reader :filename, :pick_up_path,
                :sftp_host, :sftp_username, :sftp_password

    def initialize(attributes = {})
      @filename = attributes[:filename]
      @pick_up_path = attributes[:pick_up_path]
      @sftp_host = attributes[:sftp_host]
      @sftp_username = attributes[:sftp_username]
      @sftp_password = attributes[:sftp_password]
    end

    def create_db
      refresh_locations_db
      create_new_locations
    end

    private

    def refresh_locations_db
      Location.destroy_all
    end

    def create_new_locations
      locations = download
      logger.info "About to save #{locations.count} locations to DB"

      # iterate over the huge list and save individual items as records
      locations.each do |location|
        Location.create!(location)
      end
    end

    def download
      locations = []

      return unless filename.is_a? Regexp

      sftp.dir.foreach(pick_up_path) do |file|
        # skip the first items on the list: ['.', '..']
        next unless file.name

        logger.info "Searching for file matching: #{filename}"
        next unless filename.match?(file.name)

        logger.info "File found: #{file.name}"

        begin
          logger.info "Downloading >>> #{file.name}"
          data = sftp.download!(remote_file_path(file), io.puts, read_size: 16000)
          locations = generate_locations(data)
        rescue Net::SFTP::StatusException => e
          logger.error "Error while downloading data: #{e.description}"
          raise unless e.code == 2 # no such file error code.
        end
      end

      # return the list of locations
      locations
    end

    def sftp
      @sftp = Net::SFTP.start(sftp_host, sftp_username, password: sftp_password)
    end

    def io
      StringIO.new
    end

    def logger
      Rails.logger
    end

    def remote_file_path(file)
      File.join(pick_up_path, file)
    end

    def generate_locations(data)
      locations = []
      logger.info 'Parsing locations data...'

      # strip any empty lines since we're dealing with a string (IO)
      CSV.parse(data.strip, csv_options) do |row|
        # change these fields to suit your needs :)
        location = {
          name: row[1],
          city: row[2],
          address: row[3],
          postal_code: row[4],
          latitude: row[5],
          longitude: row[6]
        }

        locations << location
      end

      locations
    end

    def csv_options
      {
        col_sep: ',',
        row_sep: :auto,
        headers: true
      }
    end
  end
end
