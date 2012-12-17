class StepsController < ApplicationController
  before_filter :find_form
  before_filter :view_defaults, :except => [:processor, :renderer]

  def find_form
    @form = Form.find params[:form_id]
  end

  def view_defaults
    add_crumb "Forms", forms_path
    add_crumb @form.name, form_path(@form)
    add_crumb "Steps", form_steps_path(@form)
  end

  
  # GET /steps
  # GET /steps.json
  def index
    @steps = @form.steps

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @steps }
    end
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
    @step = @form.steps.find(params[:id])
    add_crumb @step.name, form_step_path(@form, @step)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @step }
    end
  end

  # GET /steps/new
  # GET /steps/new.json
  def new
    @step = @form.steps.new
    add_crumb "New", new_form_step_path(@form)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @step }
    end
  end

  # GET /steps/1/edit
  def edit
    @step = @form.steps.find(params[:id])
    add_crumb @step.name, form_step_path(@form, @step)
    add_crumb "Edit", edit_form_step_path(@form, @step)
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = @form.steps.new(params[:step])

    respond_to do |format|
      if @step.save
        format.html { redirect_to [@form, @step], notice: 'Step was successfully created.' }
        format.json { render json: @step, status: :created, location: @step }
      else
        format.html { render action: "new" }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /steps/1
  # PUT /steps/1.json
  def update
    @step = @form.steps.find(params[:id])

    respond_to do |format|
      if @step.update_attributes(params[:step])
        format.html { redirect_to [@form, @step], notice: 'Step was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /steps/1
  # DELETE /steps/1.json
  def destroy
    @step = @form.steps.find(params[:id])
    @step.destroy

    respond_to do |format|
      format.html { redirect_to form_steps_url(@form) }
      format.json { head :no_content }
    end
  end
end
