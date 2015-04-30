Job.create! image: "andrerocker/veryslowjob", time: Time.now
Job.create! image: "andrerocker/brokecaptcha", time: Time.now, payload: "RETRY=3"
Job.create! image: "andrerocker/seti", time: Time.now
