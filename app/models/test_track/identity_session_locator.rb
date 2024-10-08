class TestTrack::IdentitySessionLocator
  attr_reader :identity

  def initialize(identity)
    @identity = identity
  end

  def with_visitor(&block) # rubocop:disable Metrics/AbcSize
    raise ArgumentError, "must provide block to `with_visitor`" unless block_given?

    if web_session.present?
      yield web_session.visitor_dsl_for(identity)
    elsif job_session.present?
      yield job_session.visitor_dsl_for(identity)
    else
      TestTrack::OfflineSession.with_visitor_for(identity.test_track_identifier_type, identity.test_track_identifier_value, &block)
    end
  end

  def with_session
    raise ArgumentError, "must provide block to `with_session`" unless block_given?

    if web_session.present?
      yield web_session
    else
      raise "#with_session called outside of web session"
    end
  end

  private

  def web_session
    @web_session ||= RequestStore[:test_track_web_session]
  end

  def job_session
    @job_session ||= RequestStore[:test_track_job_session]
  end
end
