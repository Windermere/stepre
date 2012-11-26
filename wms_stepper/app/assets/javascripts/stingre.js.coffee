$ ->
  # Define namespace
  window.Stingre or= {}

  # Create a namespace and local reference
  window.Stingre.Helpers = class Helpers

    @nonajax_submit = (action, method, values) ->
      form = $('<form/>', {
        action: action
        method: method
      })
      $.each values, ->
        form.append $('<input/>', {
          type: 'hidden'
          name: this.name
          value: this.value
        })
      form.appendTo('body').submit();

    # usage:
    # // coffee
    #non_ajax_submit 'http://www.example.com', 'POST', [
    #  {name: 'key1', value: 'value1'}
    #  {name: 'key2', value: 'value2'}
    #  {name: 'key3', value: 'value3'}
    #]
    # // regular
    #Stingre.Helpers.non_ajax_submit('http://www.example.com', 'POST', [
    #  { name: 'key1', value: 'value1' },
    #  { name: 'key2', value: 'value2' },
    #  { name: 'key3', value: 'value3' },
    #]);

    @non_ajax_submit_format= (obj) ->
      array = [] 
      $.each obj, (k,v) -> 
        array.push({name: k, value: v})
      return array

    @populate_form = (hash) ->
      form = $("#" + hash.elem)
      if form_data_raw = form.find("[name='form_data']").val()
        console.log form_data_raw
        form_data = JSON.parse($.base64.decode(form_data_raw))
        hsh = form.serializeObject()
        console.log hsh
        hsh = Stingre.Helpers.data_delete(hsh, ["utf8","authenticity_token", "form_data"])
        $.each hsh, (k,v) ->
          base = k.replace(/\[/, "_").replace(/\]/, "")
          el = "#" + base
          key = base.replace(hash.prefix + "_", "")
          console.log key
          form.find(el).val(form_data[key])

    @cas_submit = (hash) ->
      $("#prev_button").click (e) ->
        $(this).closest("form").append $('<input/>', {
          type: 'hidden'
          name: 'prev_button'
          value: 'true'
        })

      $("#" + hash.elem).submit (e) ->
        form = $(this)
        e.preventDefault()
        hsh = form.serializeObject()
        utf8 = hsh.utf8
        authenticity_token = hsh.authenticity_token
        hsh64 = $.base64.encode(JSON.stringify(Stingre.Helpers.data_delete(hsh, ["utf8","authenticity_token"])))
        form.delete
        $.ajax
          url: hash.url
          type: "POST"
          data: "{\"form_data\":\"#{hsh64}\", \"utf8\":\"#{utf8}\", \"authenticity_token\":\"#{authenticity_token}\"}"
          dataType: "json"
          contentType: "application/json; charset=utf-8"
          success: (res, textStatus, XMLHttpRequest) ->
            # post to cas
            console.log res
            Stingre.Helpers.nonajax_submit XMLHttpRequest.getResponseHeader('Location'), 'POST', Stingre.Helpers.non_ajax_submit_format({form_data: res.form_data, utf8: utf8, authenticity_token: authenticity_token})

          error: (res, textStatus, XMLHttpRequest) ->
            json1 = JSON.parse res.responseText

            # remove prev errors
            form.find(".alert").remove() 
            form.find(".help-inline").remove()
            form.find(".control-group").removeClass("error")

            # add errors to form
            if json1.base
              form.prepend('<div class="alert alert-error">' + json1.base.join() + '</div>')
              delete json1.base
            else
              form.prepend('<div class="alert alert-error">Please review the problems below:</div>')

            $.each json1, (k,v) -> 
              elem2 = $("#" + hash.prefix + "_" + k)
              elem2.closest('.control-group').removeClass('success').addClass('error')
              console.log elem2.parent().prop("tagName")
              if elem2.parent().prop("tagName") is "LABEL"
                elem2.parent().after('<span class="help-inline">' + v.join() + '</span>')
              else if elem2.closest('.control-group').find(".help-block").length
                elem2.closest('.control-group').append('<span class="help-inline">' + v.join() + '</span>')
              else
                elem2.after('<span class="help-inline">' + v.join(" ") + '</span>')

      @data_delete = (obj, keys_array) ->
        $.each keys_array, (i,v) ->
          delete obj[v]
        return obj
              

      @validate_mlsagent = ->
        url = "/api/valid/mlsagent.json?user[company_companypublickey]=" + $("#user_company_companypublickey").val() + "&[user]user_mlsid=" + $("#user_user_mlsid").val() + "&[user]user_mlsagent=" + $("#user_user_mlsagent").val()

        $.getJSON url, (result) ->
          $(".mls_info .help-inline").remove()

          if result.valid_mlsagent.valid
            $(".validate_status").show().text("valid MLS info").removeClass("label-important").addClass("label-success")

            $(".mls_info .control-group").removeClass("error")
            $(".mls_info .control-group").addClass("success")
            $(".account_details input").prop('disabled', false)
            $(".account_details select").prop('disabled', false)
            $("[name=commit]").prop('disabled', false)


            #if $("#user_user_firstname_display").val() is ""
            _el = $("#user_user_firstname_display")
            _el.attr("value", result.valid_mlsagent.firstname)
            _el.closest('.control-group').removeClass('error')
            _el.closest('.control-group').find(".help-block").remove()

            #if $("#user_user_lastname_display").val() is ""
            _el = $("#user_user_lastname_display")
            _el.attr("value", result.valid_mlsagent.lastname)
            _el.closest('.control-group').removeClass('error')
            _el.closest('.control-group').find(".help-block").remove()

          else
            $(".validate_status").show().text("invalid MLS info").removeClass("label-success").addClass("label-important")
            $(".mls_info .control-group").removeClass("success")
            $(".mls_info .control-group").addClass("error")
            $("#user_user_firstname_display").removeAttr("value")
            $("#user_user_lastname_display").removeAttr("value")
        
            #if !$(".account_details .control-group").hasClass("error")
            #  $(".account_details input").prop('disabled', true)
            #  $(".account_details select").prop('disabled', true)
            #  $("[name=commit]").prop('disabled', true)

      @_init = ->
        #focus on first field with error
        $(".control-group[class*=error] input").first().focus()

        $("#user_user_mlsagent").keypress (event) ->
          # http://bugs.jquery.com/ticket/2338
          event = $.event.fix(event)

          if event.which is 13
            event.preventDefault()
            #RJH - possible hack - grabbing the first fieldset of data for validating mls agent data
            url = "/api/valid/mlsagent.json?" + $("fieldset :first").serialize()
            Stingre.Helpers.validate_mlsagent(url)

        $("#validate_mlsagent").on "click", ->
          #RJH - possible hack - grabbing the first fieldset of data for validating mls agent data
          Stingre.Helpers.validate_mlsagent()

        # event
        elem_2 = $("[id$=_user_mlsid]")
        elem_2.on "change", ->
          Stingre.Helpers.toggle_agent_mls_id($(this))

        # init
        @toggle_agent_mls_id(elem_2)


      @toggle_agent_mls_id = (elem) ->
        # enable second after selection of first
        elem_1 = $("[id$=_user_mlsagent]")
        #elem_2 = $("[id$=_user_mlsid]")

        $(".mls_info .control-group").removeClass("success")
        $(".validate_status").hide()

        if elem.val() is ""
          elem_1.val("").attr('disabled', 'disabled')
        else
          elem_1.removeAttr('disabled')


    $.fn.serializeObject = ->
      o = {}
      a = this.serializeArray()
      $.each a, ->
        if o[this.name]
          if !o[this.name].push
            o[this.name] = [o[this.name]]
          o[this.name].push(this.value || "")
        else
          o[this.name] = this.value || ""
      #console.log o
      return o

