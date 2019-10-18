# frozen_string_literal: true

module Locations
  class Archiver
    attr_reader :filename, :pick_up_path, :archive_path,
                :sftp_host, :sftp_username, :sftp_password

    def initialize(attributes = {})
      @filename = attributes[:filename]
      @pick_up_path = attributes[:pick_up_path]
      @archive_path = attributes[:archive_path]
      @sftp_host = attributes[:sftp_host]
      @sftp_username = attributes[:sftp_username]
      @sftp_password = attributes[:sftp_password]
    end

    def move_file
      archive
    end

    private

    def archive
      logger.info 'Archiving processed files ...'
      logger.debug "Searching file matching: #{filename}"
      return unless filename.is_a? Regexp

      begin
        sftp.lstat!(archive_path) # check if directory exists
      rescue StandardError
        logger.info "CREATING DIRECTORY: #{archive_path}"
        sftp.mkdir!(archive_path) # create directory if !exist
      end

      files = retrieve_files
      logger.info "FILES FOUND: #{files}"

      files.each do |file|
        logger.debug "Archiving file: #{file} commenced ..."
        rename_file(pick_up_path, archive_path, file)
        logger.info "Remote file #{file} archived to #{remote_file_path(archive_path, file)}"
      end

      logger.debug 'Archiving file COMPLETED.'
    end

    def sftp
      @sftp = Net::SFTP.start(sftp_host, sftp_username, password: sftp_password)
    end

    def logger
      Rails.logger
    end

    def remote_file_path(file)
      File.join(pick_up_path, file)
    end

    def rename_file
      old_name = remote_file_path(pick_up_path, file)
      new_name = remote_file_path(archive_path, file)

      begin
        logger.debug "RENAMING #{old_name} -> #{new_name}"
        sftp.rename!(old_name, new_name)
      rescue Net::SFTP::StatusException => e
        logger.error "ERROR CODE [RENAME!]: #{e.code}"
        logger.error "ERROR DESCRIPTION [RENAME!]: #{e.description}"
        raise e
      end
    end

    def retrieve_files
      files = []
      logger.info 'Parsing locations data...'

      sftp.dir.foreach(pick_up_path) do |file|
        # skip the first items on the list: ['.', '..']
        next unless file.name

        logger.info "Searching file matching: #{filename}"
        next unless filename.match?(file.name)

        logger.debug "Location file found >>>> #{file.name}"
        files << file.name
      end

      files
    end
  end
end
