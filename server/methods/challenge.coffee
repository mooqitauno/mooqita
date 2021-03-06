################################################################
#
# Markus 1/23/2017
#
################################################################

###############################################
Meteor.methods
	add_challenge: (job_id) ->
		check(job_id,Match.Optional(String))
		user = Meteor.user()

		if not user
			throw new Meteor.Error('Not permitted.')

		return gen_challenge user, job_id

	make_challenge: (title,content,link,origin,job_id) ->
		check(title,String)
		check(content,String)
		check(link,String)
		check(origin,String)
		check(job_id,Match.Maybe(String))

		user = Meteor.user()

		if not user
			throw new Meteor.Error('Not permitted.')

		return bake_challenge user, title, content, link, origin, job_id

	finish_challenge: (challenge_id) ->
		user = Meteor.user()
		if not can_edit Challenges, challenge_id, user
			throw new Meteor.Error("Not permitted.")

		item = get_document_unprotected Challenges, challenge_id
		return finish_challenge item, user

	send_message_to_challenge_learners: (challenge_id, subject, message) ->
		#TODO: move to logic

		user = Meteor.user()

		if not user
			throw new Meteor.Error('Not permitted.')

		if not has_permission Challenges, challenge_id, user, SEND_MAIL
			throw new Meteor.Error('Not permitted.')

		# we need to know who is registered for a course.
		filter =
			challenge_id: challenge_id

		solutions = Solutions.find filter

		solutions.forEach (solution) ->
			owner_id = get_document_owner "solutions", solution
			name = get_profile_name_by_user_id owner_id, true, false
			subject =	subject.replace("<<name>>", name)
			message =	message.replace("<<name>>", name)
			send_mail user, subject, message

		return solutions.count()
