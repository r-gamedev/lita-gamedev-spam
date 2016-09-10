require 'common/messaging/message'
require 'htmlentities'

module Lemtzas
  module Common
    module Messaging
      module Reddit
        # Represents a modmail message
        class Comment < Message
          attr_accessor :link_title,        # string
                        :banned_by,         # username
                        :removal_reason,    # string
                        :link_id,           # t3_4zlvhc
                        :link_author,       # username
                        :replies,           # string?
                        :user_reports,      # array
                        :id,                # d6x7mfq
                        :gilded,            # number
                        :archived,          # bool
                        :stickied,          # bool
                        :author,            # username
                        :parent_id,         # t3_4zlvhc
                        :score,             # number
                        :approved_by,       # username
                        :nsfw,              # bool
                        :report_reasons,    # array
                        :controversiality,  # number
                        :body,              # markdown
                        :edited,            # bool (maybe UTC later?)
                        :author_flair_css_class,    # string
                        :author_flair_text,         # string
                        :quarantine,        # bool
                        :subreddit,         # string
                        :score_hidden,      # bool
                        :name,              # t1_d6x7mju
                        :created_utc,       # decimal number
                        :mod_reports,       # array
                        :num_reports,       # number
                        :distinguished,     # nil
                        :kind               # t1

          def shortlink
            link_tag = link_id.split('_')[1]
            "http://reddit.com/r/#{subreddit}/comments/#{link_tag}/-/#{id}"
          end

          def shorttext(length = 40, strip_newlines = true)
            text = body
            text = text.gsub(/\r|\n/, '') if strip_newlines
            short = text[0..length]
            short += ' [...]' if text.length > short.length
            short
          end

          def to_s
            "Comment /r/#{subreddit} /u/#{author} - #{link_title} - #{shorttext} - #{shortlink}"
          end

          # Constructs a modmail from listing data
          def self.from_data(data)
            comment = Comment.new
            html_entities = HTMLEntities.new
            comment.uuid = SecureRandom.uuid
            comment.link_title = html_entities.decode(data.link_title)
            comment.banned_by = data.banned_by
            comment.removal_reason = data.removal_reason
            comment.link_id = data.link_id
            comment.link_author = data.link_author
            comment.replies = data.replies
            comment.user_reports = data.user_reports
            comment.id = data.id
            comment.gilded = data.gilded
            comment.archived = data.archived
            comment.stickied = data.stickied
            comment.author = data.author
            comment.parent_id = data.parent_id
            comment.score = data.score
            comment.approved_by = data.approved_by
            comment.nsfw = data.over_18
            comment.report_reasons = data.report_reasons
            comment.controversiality = data.controversiality
            comment.body = html_entities.decode(data.body)
            comment.edited = data.edited
            comment.author_flair_css_class = data.author_flair_css_class
            comment.author_flair_text = data.author_flair_text
            comment.quarantine = data.quarantine
            comment.subreddit = data.subreddit
            comment.score_hidden = data.score_hidden
            comment.name = data.name
            comment.created_utc = data.created_utc
            comment.mod_reports = data.mod_reports
            comment.num_reports = data.num_reports
            comment.distinguished = data.distinguished
            comment.kind = data.kind
            comment
          end
        end # class Comment
      end # module Reddit
    end # module Messaging
  end # module Common
end # module Lemtzas
