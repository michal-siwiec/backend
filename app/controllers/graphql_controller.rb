# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    context = ::Graphql::PrepareContextService.call(params: params, session: session)
    result = ::Graphql::ExecuteQueryService.call(context: context)
    render json: result
  rescue Errors::CustomGraphqlError => e
    handle_custom_error(e)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def handle_custom_error(e)
    render json: { errors: [{ message: e.message, extensions: { error_code: e.error_code } }], data: {} }, status: 200
  end

  def handle_error(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    Rollbar.error(e)

    if Rails.env.development? || Rails.env.test?
      render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
    else
      render json: { errors: [{ message: 'Something went wrong! Please try again later.' }], data: {} }, status: 500
    end
  end
end
