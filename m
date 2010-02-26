From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: remove unnecessary svc_xprt_put
Date: Fri, 26 Feb 2010 17:44:41 -0500
Message-ID: <20100226224441.GE26598@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966477Ab0BZWnk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Feb 2010 17:43:40 -0500
In-Reply-To: <19336.19524.469529.431210-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 27, 2010 at 09:33:40AM +1100, Neil Brown wrote:
> 
> [I found this while looking for the current refcount problem
>  that triggers a warning in svc_recv.  This isn't that bug
>  but is a different refcount bug - NB]
> 
> The 'struct svc_deferred_req's on the xpt_deferred queue do not
> own a reference to the owning xprt.  This is seen in svc_revisit
> which is where things are added to this queue.  dr->xprt is set to
> NULL and the reference to the xprt it put.
> 
> So when this list is cleaned up in svc_delete_xprt, we mustn't
> put the reference.
> 
> Also, replace the 'for' with a 'while' which is arguably
> simpler and more likely to compile efficiently.

OK, thanks, queuing up for 2.6.34 and stable.

--b.

> 
> Cc: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 7d1f9e9..4f30336 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -889,11 +889,8 @@ void svc_delete_xprt(struct svc_xprt *xprt)
>  	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
>  		serv->sv_tmpcnt--;
>  
> -	for (dr = svc_deferred_dequeue(xprt); dr;
> -	     dr = svc_deferred_dequeue(xprt)) {
> -		svc_xprt_put(xprt);
> +	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
>  		kfree(dr);
> -	}
>  
>  	svc_xprt_put(xprt);
>  	spin_unlock_bh(&serv->sv_lock);
