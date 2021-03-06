fs = require 'fs'
logger = require 'logger-sharelatex'
uuid = require 'uuid'
_ = require 'underscore'
Settings = require 'settings-sharelatex'
request = require 'request'

module.exports = FileWriter =
	writeStreamToDisk: (identifier, stream, callback = (error, fsPath) ->) ->
		callback = _.once(callback)
		fsPath = "#{Settings.path.dumpFolder}/#{identifier}_#{uuid.v4()}"

		stream.pause()
		fs.mkdir Settings.path.dumpFolder, (error) ->
			stream.resume()
			if error? and error.code != 'EEXIST'
				# Ignore error about already existing
				return callback(error)

			writeStream = fs.createWriteStream(fsPath)
			stream.pipe(writeStream)

			stream.on 'error', (err)->
				logger.err {err, identifier, fsPath},	"[writeStreamToDisk] something went wrong with incoming stream"
				callback(err)
			writeStream.on 'error', (err)->
				logger.err {err, identifier, fsPath},	"[writeStreamToDisk] something went wrong with writing to disk"
				callback(err)
			writeStream.on "finish", ->
				logger.log {identifier, fsPath}, "[writeStreamToDisk] write stream finished"
				callback null, fsPath

	writeUrlToDisk: (identifier, url, callback = (error, fsPath) ->) ->
		callback = _.once(callback)
		stream = request.get(url)
		stream.on 'response', (response) ->
			if 200 <= response.statusCode < 300
				FileWriter.writeStreamToDisk identifier, stream, callback
			else
				err = new Error("bad response from url: #{response.statusCode}")
				logger.err {err, identifier, url}, err.message
				callback(err)