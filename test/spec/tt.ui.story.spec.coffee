describe "UI interactions", ->

  beforeEach ->
    TT.Init.init()

  describe "Stories", ->
    id = null
    project_id = null
    original_description = null
    edited_description = 'my edited description'

    beforeEach ->
      id = $('.story').eq(0).data('id')
      project_id = TT.Model.Story.get({ id: id }).project_id

    say "I open a story", ->
      beforeEach ->
        $('.story-' + id).find('.toggle-arrow').click()
        original_description = $('.story-' + id).find('.description').text()

      it "should display the story details", ->
        expect($('.story-' + id).find('.description').is(':visible')).toBe true

      also "I close the same story", ->
        beforeEach ->
          $('.story-' + id).find('.toggle-arrow').click()

        it "should hide the story details", ->
          expect($('.story-' + id).find('.description').is(':visible')).toBe false

      also "I start editing the story description", ->
        beforeEach ->
          $('.story-' + id).find('.description').click()
          $('.story-' + id).find('.description-container textarea').val(edited_description).blur()

        also "I trigger a redraw of the stories", ->
          beforeEach ->
            TT.View.drawStories()

          it "should restore the edited description", ->
            expect($('.story-' + id).find('.description-container textarea').val()).toBe edited_description

          also "I cancel the edit", ->
            beforeEach ->
              $('.story-' + id).find('.description-container .actions a.cancel').click()

            it "should restore the original description", ->
              expect($('.story-' + id).find('.description').text()).toContain original_description

        also "I save the edited description", ->
          beforeEach ->
            $('.story-' + id).find('.description-container .actions a.save').click()

          it "should save the description on the client-side", ->
            expect(TT.Model.Story.get({ id: id }).description).toBe edited_description

          it "should try to save the description on the server-side", ->
            expect($.ajax).toHaveBeenCalledWith {
              url: '/updateStory',
              type: 'POST',
              data: {
                projectID: project_id,
                storyID: id,
                data: {
                  description: edited_description
                }
              },
              success: jasmine.any(Function),
              complete: jasmine.any(Function)
            }

          it "should display the new description", ->
            expect($('.story-' + id).find('.description').text()).toContain edited_description

      also "I click the delete button on a tag", ->
        tagName = 'blocked'

        beforeEach ->
          $('.story-' + id).find('.details .tag:contains("' + tagName + '") .delete').eq(0).click()

        it "should delete the tag on the client-side", ->
          expect($('.story-' + id).find('.details .tag:contains("' + tagName + '")').length).toBe 0

        it "should delete the tag on the server-side", ->
          expect($.ajax).toHaveBeenCalledWith {
            url: '/updateStory',
            type: 'POST',
            data: {
              projectID: project_id,
              storyID: id,
              data: {
                labels: getLabelsString($('.story-' + id).find('.details .tag'))
              }
            },
            success: jasmine.any(Function),
            complete: jasmine.any(Function)
          }

      also "I start writing a note", ->
        my_note = 'Here is my note'

        beforeEach ->
          $('.story-' + id).find('.add-note').click()
          $('.story-' + id).find('.notes textarea').val(my_note).blur()

        also "I trigger a redraw of the stories", ->
          beforeEach ->
            TT.View.drawStories()

          it "should restore the note", ->
            expect($('.story-' + id).find('.notes textarea').val()).toBe my_note

        also "I cancel the note", ->
          beforeEach ->
            $('.story-' + id).find('.notes .actions a.cancel').click()

          it "should remove the note form", ->
            expect($('.story-' + id).find('.notes textarea').length).toBe 0
            expect($('.story-' + id).find('.add-note').length).toBe 1

        also "I save the note", ->
          beforeEach ->
            $('.story-' + id).find('.notes .actions a.save').click()

          it "should save the note on the client-side", ->
            expect(TT.Model.Story.get({ id: id }).notes[0].text).toBe my_note

          it "should save the note on the server-side", ->
            expect($.ajax).toHaveBeenCalledWith {
              url: '/addStoryComment',
              type: 'POST',
              data: {
                projectID: project_id,
                storyID: id,
                comment: my_note
              },
              success: jasmine.any(Function),
              complete: jasmine.any(Function)
            }
