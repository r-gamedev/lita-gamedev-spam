require 'common/messaging/message'
require 'htmlentities'

module Lemtzas
  module Common
    module Messaging
      module Reddit
        # Represents a submission
        class Submission < Message
          attr_accessor :name,
                        :id,
                        :author,
                        :title,
                        :selftext,
                        :subreddit,
                        :media,
                        :link_flair_text,
                        :link_flair_css_class,
                        :author_flair_text,
                        :author_flair_css_class,
                        :user_reports,
                        :report_reasons,
                        :mod_reports,
                        :gilded,
                        :banned_by,
                        :approved_by,
                        :score,
                        :nsfw,
                        :removal_reason,
                        :stickied,
                        :is_self,
                        :url,
                        :permalink,
                        :author_flair_text,
                        :created_utc,
                        :distinguished,
                        :num_reports

          def shortlink
            "https://redd.it/#{id}"
          end

          def shorttext(length = 40, strip_newlines = true)
            text = body
            text = text.gsub(/\r\n|\r|\n/, ' ') if strip_newlines
            text[0..length]
          end

          def to_s
            "Submission /r/#{subreddit} /u/#{author} - [#{link_flair_text}] #{title} - #{shortlink}"
          end

          # Constructs a submission from listing data
          # rubocop:disable MethodLength
          # rubocop:disable AbcSize
          def self.from_data(data)
            submission = Submission.new
            html_entities = HTMLEntities.new
            submission.uuid = SecureRandom.uuid
            submission.name = data.name
            submission.id = data.id
            submission.author = data.author
            submission.title = html_entities.decode(data.title)
            submission.selftext = html_entities.decode(data.selftext)
            submission.subreddit = data.subreddit
            submission.media = data.media
            submission.link_flair_text = data.link_flair_text
            submission.link_flair_css_class = data.link_flair_css_class
            submission.author_flair_text = data.author_flair_text
            submission.author_flair_css_class = data.author_flair_css_class
            submission.user_reports = data.user_reports
            submission.report_reasons = data.report_reasons
            submission.mod_reports = data.mod_reports
            submission.gilded = data.gilded
            submission.banned_by = data.banned_by
            submission.approved_by = data.approved_by
            submission.score = data.score
            submission.nsfw = data.over_18
            submission.removal_reason = data.removal_reason
            submission.stickied = data.stickied
            submission.is_self = data.is_self
            submission.url = data.url
            submission.permalink = data.permalink
            submission.author_flair_text = data.author_flair_text
            submission.created_utc = data.created_utc
            submission.distinguished = data.distinguished
            submission.num_reports = data.num_reports
            submission
          rescue
            puts data.inspect
          end
        end # class Submission
      end # module Reddit
    end # module Messaging
  end # module Common
end # module Lemtzas
