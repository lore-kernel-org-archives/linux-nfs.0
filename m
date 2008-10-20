From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] SUNRPC add deferral processing callbacks
Date: Mon, 20 Oct 2008 14:42:19 -0400
Message-ID: <20081020184219.GA25796@fieldses.org>
References: <1224104426-12293-1-git-send-email-andros@netapp.com> <1224104426-12293-2-git-send-email-andros@netapp.com> <RTPCLUEXC1-PRDf3sll000001cb@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34724 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556AbYJTSmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 14:42:21 -0400
In-Reply-To: <RTPCLUEXC1-PRDf3sll000001cb-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 04:35:28PM -0400, Talpey, Thomas wrote:
> >diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> >index dc69068..46a4097 100644
> >--- a/include/linux/sunrpc/svc.h
> >+++ b/include/linux/sunrpc/svc.h
> >@@ -215,6 +215,9 @@ struct svc_rqst {
> > 	struct svc_cred		rq_cred;	/* auth info */
> > 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
> > 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
> >+	/* callback to save deferred request state */
> >+	void (*rq_save_state)(struct svc_rqst *, struct svc_deferred_req *);
> >+	void			*rq_defer_data; /* defer state data to save */
> > 
> > 	size_t			rq_xprt_hlen;	/* xprt header len */
> > 	struct xdr_buf		rq_arg;
> >@@ -323,6 +326,13 @@ struct svc_deferred_req {
> > 	union svc_addr_u	daddr;	/* where reply must come from */
> > 	struct cache_deferred_req handle;
> > 	size_t			xprt_hlen;
> >+	/* callbacks to restore and release deferred request state
> >+	* set in rq_save_state */
> >+	void (*restore_state)(struct svc_rqst *, struct svc_deferred_req *);
> >+	void (*release_state)(struct svc_deferred_req *);
> >+	void			*defer_data; /* defer state data */
> >+	struct page		*respages[RPCSVC_MAXPAGES];
> 
> Is it worthwhile to make this a dynamically allocated pointer? If the max
> pages size is large (1MB means 256),

So that's a 1k array with 32 bit pointers, a 2k array with 64.  We
currently allow a  maximum of 300 deferred requests (DFR_MAX in
net/sunrpc/cache.c).

It'd be nice to not turn that into two allocations if the typical case
only requires one page, so we'd probably want to allow either a single
page pointer or a dynamically-allocated array.

I don't know how much to care.

--b.

> it's quite a large array for something
> that may rarely be so full.
