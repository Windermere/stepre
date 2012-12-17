#  # processes posted data and returns json only
#  def new_api_remote
#    #file = "#{Rails.root}/../stepre/wms_stepper/config/config_yaml.yaml"
#    file = "#{Rails.root}/config/stepre/signin.yaml"
#    @form = Stepre::Form.new(file, 3)
#
#    # returns struct to be applied to view
#    obj = @form.process_form_data(params)
#
#    location = new_auth_sessions_url(:company_uuid => @current_company._id)
#  
#    respond_to do |format|
#      if obj.valid
#        format.json {render :json => obj.json, :status => :created, :location => obj.location || location}
#      else
#        format.json {render :json => obj.json, :status => :unprocessable_entity}
#      end
#    end
#  end
#
#  # (renderer)
#  def new_remote
#    logger.info "\n###                 params[:form_data] => #{params[:form_data]}"
#    logger.info "### Base64.decode64 params[:form_data] => #{Base64.decode64(params[:form_data] || "")}\n"
#
#    #file = "#{Rails.root}/../stepre/wms_stepper/config/config_yaml.yaml"
#    file = "#{Rails.root}/config/stepre/signin.yaml"
#    @form = Stepre::Form.new(file, 3)
#
#    hash = Stepre::Form.read_form_data(params[:form_data])
#    hash.merge!(Stepre::Form.read_form_data(hash.delete(:form_data)))
#    @step = @form.steps.find(hash.fetch("step_id", @form.first_step_id))
#    hash.merge!(:step_id => @step.id)
#
#    @obj = OpenStruct.new hash # => read only form_data obj
#    @form_data = Stepre::Form.write_form_data(hash)
#
#    logger.info "\n###                 @form_data => #{@form_data}"
#    logger.info "### Base64.decode64 @form_data => #{Base64.decode64 @form_data}\n"
#
#    redirect_to hash["redirect_to"] and return if hash["redirect_to"]
#
#    # if custom => should be set in config
#    # this will do for now:
#    #custom = !!(@step.template =~ /custom/i)
#    custom = true
#
#    # don't render form template wrapped around template partial if custom => ONLY render custom template (which should include form elements)
#    if custom 
#      render @step.template
#    else
#      @partial = @step.template
#      #render "processor/steps"
#    end
#  end
