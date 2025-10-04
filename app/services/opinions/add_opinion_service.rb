module Opinions
  class AddOpinionService
    extend Utils::CallableObject

    def initialize(params:)
      super()
      @params = params
    end

    def call
      create_opinion
    end

    private

    def create_opinion
      Opinion.create!(content: @params.fetch(:content),
                      mark: @params.fetch(:mark),
                      user_id: @params.fetch(:user_id))
    end
  end
end
