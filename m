From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Thu, 13 Dec 2007 13:45:06 -0500
Message-ID: <20071213184506.GA29496@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233152.15718.44241.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33720 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760654AbXLMSpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 13:45:10 -0500
In-Reply-To: <20071211233152.15718.44241.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for joining in a little late....

On Tue, Dec 11, 2007 at 05:31:54PM -0600, Tom Tucker wrote:
> +int svc_reg_xprt_class(struct svc_xprt_class *xcl)

None of the callers appear to check the return value, so this should
probably be a void return.

> +{
> +	struct svc_xprt_class *cl;
> +	int res = -EEXIST;
> +
> +	dprintk("svc: Adding svc transport class '%s'\n",
> +		xcl->xcl_name);
> +
> +	INIT_LIST_HEAD(&xcl->xcl_list);

Unless we care how xcl_list is set in the error case, this is
unnecessary.

> +	spin_lock(&svc_xprt_class_lock);
> +	list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
> +		if (xcl == cl)
> +			goto out;

Is this even worth checking?  Accidentally registering the identical
struct svc_xprt_class * seems an unlikely mistake for a transport-class
coder to make, given that they only need call this function once per
transport, in the module initialization.  Maybe make this a BUG()?  Or
check for duplicate xcl_name's if that seems a more likely error?

> +	}
> +	list_add_tail(&xcl->xcl_list, &svc_xprt_class_list);
> +	res = 0;
> +out:
> +	spin_unlock(&svc_xprt_class_lock);
> +	return res;
> +}
> +EXPORT_SYMBOL_GPL(svc_reg_xprt_class);
> +
> +int svc_unreg_xprt_class(struct svc_xprt_class *xcl)
> +{
> +	struct svc_xprt_class *cl;
> +	int res = 0;
> +
> +	dprintk("svc: Removing svc transport class '%s'\n", xcl->xcl_name);
> +
> +	spin_lock(&svc_xprt_class_lock);
> +	list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
> +		if (xcl == cl) {
> +			list_del_init(&cl->xcl_list);
> +			goto out;
> +		}
> +	}
> +	res = -ENOENT;

Again, nobody checks this error return, and it seems like an unlikely
programmer error anyway. If we really need the check I'd be inclined
just to ditche the for loop and BUG_ON(list_empty(&cl->xcl_list)), which
will catch double-unregistrations (thanks to the list_del_init()).

> + out:
> +	spin_unlock(&svc_xprt_class_lock);
> +	return res;
> +}
> +EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
> +
> +/*
> + * Called by transport drivers to initialize the transport independent
> + * portion of the transport instance.
> + */
> +void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
> +{
> +	memset(xprt, 0, sizeof(*xprt));
> +	xprt->xpt_class = xcl;
> +	xprt->xpt_ops = xcl->xcl_ops;
> +}
> +EXPORT_SYMBOL_GPL(svc_xprt_init);

Seems fine otherwise.

--b.
