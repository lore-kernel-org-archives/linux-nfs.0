Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47925 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbaFKVRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2014 17:17:43 -0400
Date: Wed, 11 Jun 2014 17:17:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFS4.1: try to clean sessions after testing
Message-ID: <20140611211742.GH19382@fieldses.org>
References: <5396D7FA.4050303@gmail.com>
 <5396F243.8080606@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5396F243.8080606@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tried to apply this, and the ipv6 patch (could we do that for 4.1
too?) and the 3 other patches, but:

	- there are some conflicts with the latest pynfs (e.g. I already
	  added a few acl tests, apologies)
	- I'm getting failures to write to a read-only fs, apparently
	  one of the tests is trying to write to the export root?  I
	  didn't check which one.

Could you look into those and resend your pynfs patches?  Thanks!

--b.


On Tue, Jun 10, 2014 at 07:55:47PM +0800, Kinglong Mee wrote:
> There are many sessions left after testing, they hold drc memory at server.
> This patch tries to clean session after each testcase.
> 
> v2,
> adds empty function of clean_sessions for nfs4.0,
> because they are using the same testmod.py 
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  nfs4.0/servertests/environment.py   | 3 +++
>  nfs4.1/server41tests/environment.py | 7 ++++++-
>  nfs4.1/testmod.py                   | 1 +
>  3 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
> index 993320d..9852178 100644
> --- a/nfs4.0/servertests/environment.py
> +++ b/nfs4.0/servertests/environment.py
> @@ -226,6 +226,9 @@ class Environment(testmod.Environment):
>              cmd += ' ' + args
>              os.system(cmd);
>  
> +    def clean_sessions(self):
> +        return
> +
>  #########################################
>  debug_fail = False
>  
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index b2df732..7632655 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -248,7 +248,12 @@ class Environment(testmod.Environment):
>      def testname(self, t):
>          """Returns a name for the test that is unique between runs"""
>          return "%s_%i" % (t.code, self.timestamp)
> -    
> +
> +    def clean_sessions(self):
> +        """Destroy client name env.c1"""
> +        for sessionid in self.c1.sessions.keys():
> +            self.c1.compound([op.destroy_session(sessionid)])
> +
>  #########################################
>  debug_fail = False
>  
> diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
> index 5908066..661aed0 100644
> --- a/nfs4.1/testmod.py
> +++ b/nfs4.1/testmod.py
> @@ -220,6 +220,7 @@ class Test(object):
>              environment.startUp()
>              self.runtest(self, environment)
>              self.result = self._pass_result
> +	    environment.clean_sessions()
>          except KeyboardInterrupt:
>              raise
>          except TestException, e:
> -- 
> 1.9.3
> 
