From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
	generic
Date: Wed, 24 Sep 2008 17:57:42 -0400
Message-ID: <20080924215742.GG10841@fieldses.org>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114AbYIXV5n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 17:57:43 -0400
In-Reply-To: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2008 at 09:12:07AM -0400, Jeff Layton wrote:
> I got a bug report from a user who got this message in his logs:
> 
>     lockd: too many open TCP sockets, consider increasing number of nfsd
>            threads.
> 
> ...lockd also started refusing connections at this point. He was
> apparently doing some testing with a highly contended lock. lockd
> started refusing connections after the first 80 and started printing
> this warning. He tried increasing the number of nfsd threads, which of
> course didn't do any good. This patch removes the "nfsd" from the
> message to make this a little less confusing.
> 
> There is still an artificial limit of 80 concurrent clients with lockd.
> svc_check_conn_limits has this hardcoded check:
> 
>     if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
> 
> ...my feeling is that we need to either raise the number or eliminate
> this check for single-threaded services like lockd. I'd first like to
> understand the rationale for setting the limit here, however. Can anyone
> clarify?

No idea, but yes, this is a problem.

Brainstorming other options:

	- add a new sv_maxconnections field, give it a better default,
	  and maybe make it tunable some day?  (Oh goody, another knob
	  to twiddle).
	- implement the suggestion in the comment above this function
	  and limit connections per ip address.  I guess the idea would
	  be to prevent a single buggy client from bringing everyone
	  down.  Is that really likely?  Results in the presence of NAT
	  could be hard to debug.
	- Base the limit on available memory instead of number of
	  threads?
	- Kill the check entirely?  It'd help to know whether it was
	  originally prompted by some specific situation....

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/svc_xprt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index bf5b5cd..340f549 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -536,7 +536,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
>  				/* Try to help the admin */
>  				printk(KERN_NOTICE "%s: too many open  "
>  				       "connections, consider increasing the "
> -				       "number of nfsd threads\n",
> +				       "number of threads\n",
>  				       serv->sv_name);
>  			}
>  			/*
> -- 
> 1.5.5.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
