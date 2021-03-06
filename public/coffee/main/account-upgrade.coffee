define [
	"base"
], (App) ->
	App.controller "FreeTrialModalController", ($scope, abTestManager, sixpack, event_tracking)->

		$scope.buttonClass = "btn-primary"

		$scope.startFreeTrial = (source, couponCode) ->
			plan = 'collaborator_free_trial_7_days'

			w = window.open()
			go = () ->
				ga?('send', 'event', 'subscription-funnel', 'upgraded-free-trial', source)
				if window.redirectToOLFreeTrialUrl?
					url = window.redirectToOLFreeTrialUrl
				else
					url = "/user/subscription/new?planCode=#{plan}&ssp=true"
					if couponCode?
						url = "#{url}&cc=#{couponCode}"
				$scope.startedFreeTrial = true

				event_tracking.sendMB "subscription-start-trial", { source, plan }

				w.location = url

			go()
