persistency = require '../lib/persistency.iced'

messageBus = require '../lib/messagebus.iced'

int64 = require 'int64-native'

module.exports =
	handleAuthReply: (state, result, npid, token) ->
		# if auth is successful
		if npid
			# get int64 for the npid
			npid64 = new int64(npid[0], npid[1])

			# set the connection field for npid/token
			await persistency.setConnField state, 'npid', npid64.toString(), defer err
			await persistency.setConnField state, 'sessionToken', token.toString(), defer err

			await persistency.client.lpush persistency.getUserKey(npid, 'conns'), state.token, defer err

			messageBus.broadcast 'user_authenticated',
				npid: npid64.toString(),
				source: state.source
				token: state.token

		# set default values if not passed
		npid = npid or [ 0, 0 ]
		token = token or new Buffer(16)

		# and send a reply to the state
		state.reply 'RPCAuthenticateResultMessage',
			result: result
			npid: npid
			sessionToken: token