Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273AbcA0QDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2016 11:03:37 -0500
Subject: Re: [Linux-cachefs] [PATCH 1/2] cachefilesd can spin when disk space
 is short.
To: David Howells <dhowells@redhat.com>, linux-cachefs@redhat.com
References: <20160125164111.9466.79976.stgit@warthog.procyon.org.uk>
 <20160125164930.9670.46763.stgit@warthog.procyon.org.uk>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de, linux-fsdevel@vger.kernel.org,
        jlayton@poochiereds.net, jsnow@redhat.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56A8EA56.1020304@RedHat.com>
Date: Wed, 27 Jan 2016 11:03:34 -0500
MIME-Version: 1.0
In-Reply-To: <20160125164930.9670.46763.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/25/2016 11:49 AM, David Howells wrote:
> From: NeilBrown <neilb@suse.de>
> 
> When cachefilesd finds that it needs to cull, but that culling doesn't
> achieve anything, it sets an alarm to wake it in 30 seconds to try again.
> But as read_cache_state() will detect that culling is still needed, it will
> immediately try again anyway.
> 
> This results in 100% cpu usage of no value.
> 
> This patch causes culling to be blocked until the 30 second alarm goes off.
> 
> It also changes the test to decide whether to enter poll() after blocking
> signals to test exactly those values that might be changed by a signal.
> Testing these is important, testing anything else is pointless.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Steve Dickson <steved@redhat.com>

steved.

> ---
> 
>  cachefilesd.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/cachefilesd.c b/cachefilesd.c
> index 6658ba5..eaa1bb0 100644
> --- a/cachefilesd.c
> +++ b/cachefilesd.c
> @@ -99,6 +99,7 @@ static struct object **cullready;
>  static unsigned nr_in_build_table;
>  static unsigned nr_in_ready_table;
>  static int ncullable;
> +static bool cull_delayed;
>  
>  
>  static const char *configfile = "/etc/cachefilesd.conf";
> @@ -246,6 +247,7 @@ static void sigio(int sig)
>  static void sigalrm(int sig)
>  {
>  	jumpstart_scan = true;
> +	cull_delayed = false;
>  }
>  
>  /*****************************************************************************/
> @@ -613,11 +615,11 @@ static void cachefilesd(void)
>  
>  		/* sleep without racing on reap and cull with the signal
>  		 * handlers */
> -		if (!scan && !reap && !cull) {
> +		if (!scan && !reap && !(cull && !cull_delayed)) {
>  			if (sigprocmask(SIG_BLOCK, &sigs, &osigs) < 0)
>  				oserror("Unable to block signals");
>  
> -			if (!reap && !cull) {
> +			if (!reap && !stop && !jumpstart_scan) {
>  				if (ppoll(pollfds, 1, NULL, &osigs) < 0 &&
>  				    errno != EINTR)
>  					oserror("Unable to suspend process");
> @@ -644,7 +646,7 @@ static void cachefilesd(void)
>  			if (cull) {
>  				if (nr_in_ready_table > 0)
>  					cull_objects();
> -				else if (nr_in_build_table == 0)
> +				else if (nr_in_build_table == 0 && !cull_delayed)
>  					jumpstart_scan = true;
>  			}
>  
> @@ -1364,6 +1366,7 @@ static void decant_cull_table(void)
>  
>  	/* if nothing there, scan again in a short while */
>  	if (nr_in_build_table == 0) {
> +		cull_delayed = true;
>  		signal(SIGALRM, sigalrm);
>  		alarm(30);
>  		return;
> 
