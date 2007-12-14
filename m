From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 11/38] svc: Add xpo_accept transport function
Date: Fri, 14 Dec 2007 14:01:41 -0500
Message-ID: <20071214190141.GC23121@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233217.15718.14380.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755765AbXLNTBq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2007 14:01:46 -0500
In-Reply-To: <20071211233217.15718.14380.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:32:17PM -0600, Tom Tucker wrote:
> 
> Previously, the accept logic looked into the socket state to determine
> whether to call accept or recv when data-ready was indicated on an endpoint. 
> Since some transports don't use sockets, this logic was changed to use a flag 
> bit (SK_LISTENER) to identify listening endpoints. A transport function 
> (xpo_accept) was added to allow each transport to define its own accept 
> processing.

Nit: I'd put description of what this patch does in the present tense.

...
> The code that poaches connections when the connection
> limit is hit was moved to a subroutine to make the accept logic path
> easier to follow. Since this is in the new connection path, it should 
> not be a performance issue.

Makes sense.  I'd have done that in a separate patch.

> +static void svc_check_conn_limits(struct svc_serv *serv)
> +{
> +	char	buf[RPC_MAX_ADDRBUFLEN];
> +
> +	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
> +		struct svc_sock *svsk = NULL;
> +		spin_lock_bh(&serv->sv_lock);
> +		if (!list_empty(&serv->sv_tempsocks)) {
> +			if (net_ratelimit()) {
> +				/* Try to help the admin */
> +				printk(KERN_NOTICE "%s: too many open TCP "
> +					"sockets, consider increasing the "
> +					"number of nfsd threads\n",
> +						   serv->sv_name);
> +				printk(KERN_NOTICE
> +				       "%s: last TCP connect from %s\n",
> +				       serv->sv_name, buf);

It looks like the content of "buf" is unitialized here?

--b.

> +			}
> +			/*
> +			 * Always select the oldest socket. It's not fair,
> +			 * but so is life
> +			 */
> +			svsk = list_entry(serv->sv_tempsocks.prev,
> +					  struct svc_sock,
> +					  sk_list);
> +			set_bit(SK_CLOSE, &svsk->sk_flags);
> +			atomic_inc(&svsk->sk_inuse);
> +		}
> +		spin_unlock_bh(&serv->sv_lock);
> +
> +		if (svsk) {
> +			svc_sock_enqueue(svsk);
> +			svc_sock_put(svsk);
> +		}
> +	}
> +}
> +
> +/*
