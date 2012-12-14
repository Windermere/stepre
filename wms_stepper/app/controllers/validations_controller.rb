class ValidationsController < ApplicationController
  before_filter :setup

  def setup
    @attr = Attr.find params[:attr_id]
    @step = @attr.step
    @form = @step.form
    add_crumb "Forms", forms_path
    add_crumb @form.name, form_path(@form)
    add_crumb "Steps", form_steps_path(@form)
    add_crumb @step.name, form_step_path(@form, @step)
    add_crumb "Attrs", step_attrs_path(@step)
    add_crumb @attr.name, step_attr_path(@step, @attr)
    add_crumb "Validations", attr_validations_path(@step)
  end

  def add
    @validations = Validation.attrs_except(@attr.id)
   # @validations = Validation.without_attrs
  end

  def add_create
    if @validation = Validation.find(params[:id])
      @attr_validation = @attr.attr_validations.new(:validation_id => @validation.id)
    end

    respond_to do |format|
      if @validation && @attr_validation.save
        #format.html { redirect_to [@attr, @validation], notice: 'Validation was successfully added.' }
        format.html { redirect_to attr_validations_url(@attr) }
        format.json { render json: @attr_validation || @validation, status: :created, location: @validation }
      else
        format.html { render action: "add" }
        format.json { render json: @attr_validation.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def add_destroy
    @attr_validation = @attr.attr_validations.where(:validation_id => params[:id]).first
    @attr_validation.destroy

    respond_to do |format|
      format.html { redirect_to attr_validations_url(@attr) }
      format.json { head :no_content }
    end
  end
  
  # GET /validations
  # GET /validations.json
  def index
    @validations = @attr.validations

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @validations }
    end
  end

  # GET /validations/1
  # GET /validations/1.json
  def show
    @validation = @attr.validations.find(params[:id])
    add_crumb @validation.name, attr_validation_path(@step, @validation)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @validation }
    end
  end

  # GET /validations/new
  # GET /validations/new.json
  def new
    @validation = @attr.validations.new
    add_crumb "New", new_attr_validation_path(@step)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @validation }
    end
  end

  # GET /validations/1/edit
  def edit
    @validation = @attr.validations.find(params[:id])
    add_crumb @validation.name, attr_validation_path(@step, @validation)
    add_crumb "Edit", edit_attr_validation_path(@step, @validation)
  end

  # POST /validations
  # POST /validations.json
  def create
    @attr_validation = @attr.attr_validations.new
    @validation = Validation.new(params[:validation])

    respond_to do |format|
      if @validation.save && (@attr_validation.validation_id = @validation.id) && @attr_validation.save
        format.html { redirect_to [@attr, @validation], notice: 'Validation was successfully created.' }
        format.json { render json: @validation, status: :created, location: @validation }
      else
        @validation.delete
        format.html { render action: "new" }
        format.json { render json: @validation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /validations/1
  # PUT /validations/1.json
  def update
    @validation = @attr.validations.find(params[:id])

    respond_to do |format|
      if @validation.update_attributes(params[:validation])
        format.html { redirect_to [@attr, @validation], notice: 'Validation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @validation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /validations/1
  # DELETE /validations/1.json
  def destroy
    @validation = @attr.validations.find(params[:id])
    @validation.destroy

    respond_to do |format|
      format.html { redirect_to attr_validations_url(@attr) }
      format.json { head :no_content }
    end
  end
end
