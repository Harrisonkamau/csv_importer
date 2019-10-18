# frozen_string_literal: true

require_relative 'locations/downloader'

module LocationsProcessor
  module_function

  def run
    downloader_params = downloader_attributes
                        .merge(filename_attributes, sftp_attributes)
    archiver_params = archiver_attributes
                      .merge(filename_attributes, sftp_attributes)

    generator = Locations::Downloader.new(downloader_params)
    archiver = Locations::Archiver.new(archiver_params)

    generator.create_db
    archiver.move_file
  end

  def downloader_attributes
    {
      pick_up_path: ENV.fetch('PICK_UP_PATH')
    }
  end

  def archiver_attributes
    {
      archive_path: ENV.fetch('ARCHIVE_PATH'),
      pick_up_path: ENV.fetch('PICK_UP_PATH')
    }
  end

  def filename_attributes
    source_file_regex = ENV.fetch('SRC_FILE_REGEX')
    { filename: Regexp.new(source_file_regex) }
  end

  def sftp_attributes
    {
      sftp_host: ENV.fetch('SFTP_HOST'),
      sftp_username: ENV.fetch('SFTP_USERNAME'),
      sftp_password: ENV.fetch('SFTP_PASSWORD')
    }
  end
end
