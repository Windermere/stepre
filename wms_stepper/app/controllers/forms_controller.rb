class FormsController < ApplicationController
  add_crumb "Forms", "/forms"

  def config_yaml
    Form.find(params[:id]).write_config_yaml!

    respond_to do |format|
      format.html {render :text => "<pre>#{Form.find(params[:id]).to_config_hash.to_yaml}</pre>"}
      format.yaml {render :text => Form.find(params[:id]).to_config_hash.to_yaml}
      format.json {render :json => Form.find(params[:id]).to_config_hash}
    end
  end

  # (perform algorithm on form_data)
  # processes posted data and returns json only
  def processor_api
    @form = Form.find(params[:id])

    # returns struct to be applied to view
    obj = @form.process_form_data(params) #[:form_data], params[:utf8], params[:authenticity_token])
  
    respond_to do |format|
      if obj.valid
        format.json {render json: obj.json, status: :created, location: processor_form_url(@form)}
      else
        format.json {render json: obj.json, status: :unprocessable_entity}
      end
    end
  end

  # (renderer)
  def processor
    logger.info "\n###                 params[:form_data] => #{params[:form_data]}"
    logger.info "### Base64.decode64 params[:form_data] => #{Base64.decode64(params[:form_data] || "")}\n"

    @form = Form.find(params[:id])
    hash = Form.read_form_data(params[:form_data])
    hash.merge!(Form.read_form_data(hash.delete(:form_data)))
    @step = @form.steps.find(hash.fetch("step_id", @form.first_step_id))
    @form_data = Form.write_form_data(hash.merge(:step_id => @step.id))

    logger.info "\n###                 @form_data => #{@form_data}"
    logger.info "### Base64.decode64 @form_data => #{Base64.decode64 @form_data}\n"
    redirect_to hash["redirect_to"] and return if hash["redirect_to"]

    #render @step.template
    render "forms/processor"
  end

  # (perform algorithm on form_data)
  # processes posted data and returns json only
  def processor_api_remote
    @remote = true

    # service defined form to yaml config for remote form
    Form.find(params[:id]).write_config_yaml!

    file = "#{Rails.root}/config/config_yaml.yaml"
    #file = "http://localhost:3000/forms/1/config_yaml.yaml"
    @form = Stepper::Form.new(file, params[:id].to_i)

    # returns struct to be applied to view
    obj = @form.process_form_data(params) #[:form_data], params[:utf8], params[:authenticity_token])
  
    respond_to do |format|
      if obj.valid
        format.json {render json: obj.json, status: :created, location: processor_remote_form_url(@form.id)}
      else
        format.json {render json: obj.json, status: :unprocessable_entity}
      end
    end
  end

  # (renderer)
  def processor_remote
    logger.info "\n###                 params[:form_data] => #{params[:form_data]}"
    logger.info "### Base64.decode64 params[:form_data] => #{Base64.decode64(params[:form_data] || "")}\n"
    @remote = true

    # service defined form to yaml config for remote form
    Form.find(params[:id]).write_config_yaml!

    file = "#{Rails.root}/config/config_yaml.yaml"
    #file = "http://localhost:3000/forms/1/config_yaml.json"
    @form = Stepper::Form.new(file, params[:id].to_i)

    hash = Form.read_form_data(params[:form_data])
    hash.merge!(Form.read_form_data(hash.delete(:form_data)))
    @step = @form.steps.find(hash.fetch("step_id", @form.first_step_id))
    @form_data = Form.write_form_data(hash.merge(:step_id => @step.id))

    logger.info "\n###                 @form_data => #{@form_data}"
    logger.info "### Base64.decode64 @form_data => #{Base64.decode64 @form_data}\n"
    redirect_to hash["redirect_to"] and return if hash["redirect_to"]
    
    #render (@step.template || "forms/processor"), :layout => (@form.template || "ecomm_processor/steps")
    #render @step.template, :layout => "ecomm_processor/steps"
    @partial = @step.template
    render "stepper/ecomm_processor/steps"
  end

  def index_attrs
    @form = Form.find(params[:form_id])
    @attrs = @form.attrs
    add_crumb @form.name, form_path(@form)
    add_crumb "Attrs"
  end

  def show_attr
    @form = Form.find(params[:form_id])
    @attr = @form.attrs.find params[:id]
    add_crumb @form.name, form_path(@form)
    add_crumb "Attrs", form_attrs_path(@form)
    add_crumb @attr.name
  end

  # GET /forms
  # GET /forms.json
  def index
    @forms = Form.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @forms }
    end
  end

  # GET /forms/1
  # GET /forms/1.json
  def show
    @form = Form.find(params[:id])
    add_crumb @form.name, form_path(@form)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @form }
    end
  end

  # GET /forms/new
  # GET /forms/new.json
  def new
    @form = Form.new
    add_crumb "New", new_form_path

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @form }
    end
  end

  # GET /forms/1/edit
  def edit
    @form = Form.find(params[:id])
    add_crumb @form.name, form_path(@form)
    add_crumb "Edit", edit_form_path(@form)
  end

  # POST /forms
  # POST /forms.json
  def create
    @form = Form.new(params[:form])

    respond_to do |format|
      if @form.save
        format.html { redirect_to @form, notice: 'Form was successfully created.' }
        format.json { render json: @form, status: :created, location: @form }
      else
        format.html { render action: "new" }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /forms/1
  # PUT /forms/1.json
  def update
    @form = Form.find(params[:id])

    respond_to do |format|
      if @form.update_attributes(params[:form])
        format.html { redirect_to @form, notice: 'Form was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forms/1
  # DELETE /forms/1.json
  def destroy
    @form = Form.find(params[:id])
    @form.destroy

    respond_to do |format|
      format.html { redirect_to forms_url }
      format.json { head :no_content }
    end
  end
end
