class AttrsController < ApplicationController
  before_filter :find_step

  def find_step
    @step = Step.find params[:step_id]
    @form = @step.form
    add_crumb "Forms", forms_path
    add_crumb @form.name, form_path(@form)
    add_crumb "Steps", form_steps_path(@form)
    add_crumb @step.name, form_step_path(@form, @step)
    add_crumb "Attrs", step_attrs_path(@step)
  end

  # GET /attrs
  # GET /attrs.json
  def index
    @attrs = @step.attrs.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attrs }
    end
  end

  # GET /attrs/1
  # GET /attrs/1.json
  def show
    @attr = @step.attrs.find(params[:id])
    add_crumb @attr.name, step_attr_path(@step, @attr)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attr }
    end
  end

  # GET /attrs/new
  # GET /attrs/new.json
  def new
    @attr = @step.attrs.new
    add_crumb "New", new_step_attr_path(@step)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attr }
    end
  end

  # GET /attrs/1/edit
  def edit
    @attr = @step.attrs.find(params[:id])
    add_crumb @attr.name, step_attr_path(@step, @attr)
    add_crumb "Edit", edit_step_attr_path(@step, @attr)
  end

  # POST /attrs
  # POST /attrs.json
  def create
    @attr = @step.attrs.new(params[:attr].merge(:form_id => @step.form_id))

    respond_to do |format|
      if @attr.save
        format.html { redirect_to [@step, @attr], notice: '@step.attrs was successfully created.' }
        format.json { render json: @attr, status: :created, location: @attr }
      else
        format.html { render action: "new" }
        format.json { render json: @attr.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /attrs/1
  # PUT /attrs/1.json
  def update
    @attr = @step.attrs.find(params[:id])

    respond_to do |format|
      if @attr.update_attributes(params[:attr])
        format.html { redirect_to [@step, @attr], notice: '@step.attrs was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attr.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attrs/1
  # DELETE /attrs/1.json
  def destroy
    @attr = @step.attrs.find(params[:id])
    @attr.destroy

    respond_to do |format|
      format.html { redirect_to step_attrs_url(@step) }
      format.json { head :no_content }
    end
  end
end
