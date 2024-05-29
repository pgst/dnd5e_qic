RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  # UserモデルとExaminationモデルとUserAnswerモデルを管理画面に表示
  config.included_models = ['User', "Examination", "UserAnswer"]

  # BASIC認証を設定
  config.authenticate_with do
    authenticate_or_request_with_http_basic('Site Message') do |username, password|
      username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end
end
