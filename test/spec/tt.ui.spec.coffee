describe "UI interactions", ->

  beforeEach ->
    TT.Init.init()

  describe "Settings", ->
    mockPivotalToken = 'my_new_token'

    say "I open the settings dialog", ->
      beforeEach ->
        $('#account-settings-link').click()

      it "should have an empty token field", ->
        expect($('#pivotal-token-input').val()).toBe 'abc123'
        expect($.cookie('pivotalToken')).toBe 'abc123'

      also "I update the token", ->
        beforeEach ->
          $('#pivotal-token-input').val(mockPivotalToken)
          $('#account-settings .form-action a.action').click()

        it "should save the token", ->
          expect($.cookie('pivotalToken')).toBe mockPivotalToken

        it "should close the dialog", ->
          expect($('#account-settings').length).toBe 0

        also "I re-open the settings dialog", ->
          beforeEach ->
            $('#account-settings-link').click()

          it "should display the saved token", ->
            expect($('#pivotal-token-input').val()).toBe mockPivotalToken

  describe "Tags", ->
    tagName = 'blocked'

    say "I click on a tag", ->
      beforeEach ->
        $('.story .tag:contains("' + tagName + '")').eq(0).click()

      it "should now show up in the filter list", ->
        expect($('#filters .filter').text()).toContain tagName

      it "should only show stories with that matching tag", ->
        expect(visibleStoriesWithoutTag(tagName)).toBe 0
        expect(visibleStoriesWithTag(tagName)).toBe 1

      also "I click on an active tag in a story", ->
        beforeEach ->
          $('.story .tag:contains("' + tagName + '")').eq(0).click()

        it "should do nothing", ->
          expect($('#filters .filter:contains("' + tagName + '")').hasClass('inactive')).toBe false

      also "I click on an active tag in the tag list", ->
        beforeEach ->
          $('#filters .filter:contains("' + tagName + '")').eq(0).click()

        it "should disable that filter", ->
          expect($('#filters .filter:contains("' + tagName + '")').hasClass('inactive')).toBe true

        it "should show stories without the matching tag", ->
          expect(visibleStoriesWithoutTag(tagName)).not.toBe 0

  describe "Users", ->
    owner = null

    beforeEach ->
      owner = $('.story .story-owner').eq(0).data('username')

    say "I click on a user in a story", ->
      beforeEach ->
        $('.story .story-owner').eq(0).click()

      it "should show up in the filter list", ->
        expect($('#filters .filter').text()).toContain owner

      it "should only show stories with that matching user", ->
        expect(visibleStoriesWithoutOwner(owner)).toBe 0

      also "I click on an active user in the filter list", ->
        beforeEach ->
          $('#filters .filter:contains("' + owner + '")').eq(0).click()

        it "should disable that filter", ->
          expect($('#filters .filter:contains("' + owner + '")').hasClass('inactive')).toBe true

        it "should show stories without the matching user", ->
          expect(visibleStoriesWithoutOwner(owner)).not.toBe 0

  describe "Columns", ->
    columnName = 'Started'

    say "I click the close button on a column", ->
      beforeEach ->
        $('#columns .column .column-title:contains("' + columnName + '") span').eq(0).click()

      it "should now look disabled in the column list", ->
        expect($('#columnList .column-selector:contains("' + columnName + '")').hasClass('active')).toBe false

      it "should no longer be visible in the main content area", ->
        expect($('#columns .column .column-title:contains("' + columnName + '")').length).toBe 0

      also "I click on the disabled column in the column list", ->
        beforeEach ->
          $('#columnList .column-selector:contains("' + columnName + '")').eq(0).click()

        it "should now look enabled in the column list", ->
          expect($('#columnList .column-selector:contains("' + columnName + '")').hasClass('active')).toBe true

        it "should once again be visible in the main content area", ->
          expect($('#columns .column .column-title:contains("' + columnName + '")').length).toBe 1

  describe "Projects", ->
    id = null

    beforeEach ->
      id = $('.story a.project-name').data('project-id')

    say "I click the project initials in a story", ->
      beforeEach ->
        $('.story a.project-name').eq(0).click()

      it "should only display that project as active in the project list", ->
        expect($('#project-' + id).siblings('.project').hasClass('inactive')).toBe true
        expect($('#project-' + id).hasClass('inactive')).toBe false

      it "should be the only project visible in the main content area", ->
        expect(visibleStoriesWithProjectID(id)).not.toBe 0
        expect(visibleStoriesWithoutProjectID(id)).toBe 0

    say "I click an enabled project in the project list", ->
      beforeEach ->
        $('#project-' + id).click()

      it "should now look disabled in the project list", ->
        expect($('#project-' + id).hasClass('inactive')).toBe true

      it "should hide the project stories in the main content area", ->
        expect(visibleStoriesWithProjectID(id)).toBe 0

      also "I click a disabled project in the project list", ->
        beforeEach ->
          $('#project-' + id).click()

        it "should now look enabled in the project list", ->
          expect($('#project-' + id).hasClass('inactive')).toBe false

        it "should make the project stories visible in the main content area", ->
          expect(visibleStoriesWithProjectID(id)).not.toBe 0

  describe "Labels Column", ->
    tagName = 'used_by_one_story'
    story = null

    say "I open the labels column", ->
      beforeEach ->
        $('#columnList .column-selector[data-name="Labels"]').click()

      it "should display the active labels only", ->
        expect(labelDisplayedInColumn('unused_label')).toBe false
        expect(labelDisplayedInColumn(tagName)).toBe true

      also "I remove a label from a story, making the label unused", ->
        beforeEach ->
          story = $('.story .tag:contains("' + tagName + '")').closest('.story')
          story.find('.toggle-arrow').click()
          story.find('.details .tag:contains("' + tagName + '") .delete').click()

        it "should no longer display the label in the column", ->
          expect(labelDisplayedInColumn(tagName)).toBe false

        xalso "I add the label back to the story, making the label used", ->
          beforeEach ->
            story.find('.details .labels.textfield').click()
            $('#autocomplete .item:contains("' + tagName + '")').click()

          it "should display the label in the labels column", ->
            expect(labelDisplayedInColumn(tagName)).toBe true
