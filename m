Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab0LVWS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 17:18:28 -0500
Date: Wed, 22 Dec 2010 17:18:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <andros@netapp.com>
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 01/11] SUNRPC move svc_drop to caller of
 svc_process_common
Message-ID: <20101222221826.GC13243@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <20101221182305.GA19349@fieldses.org>
 <C591F94F-FFFA-4C4B-AF0A-F70A0FC890AD@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C591F94F-FFFA-4C4B-AF0A-F70A0FC890AD@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 22, 2010 at 05:00:05PM -0500, Andy Adamson wrote:
> 
> On Dec 21, 2010, at 1:23 PM, J. Bruce Fields wrote:
> 
> > On Mon, Dec 20, 2010 at 04:04:38PM -0500, andros@netapp.com wrote:
> >> @@ -1292,12 +1291,15 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> >> 	svc_getu32(argv);	/* XID */
> >> 	svc_getnl(argv);	/* CALLDIR */
> >> 
> >> -	error = svc_process_common(rqstp, argv, resv);
> >> -	if (error <= 0)
> >> -		return error;
> >> -
> >> -	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
> >> -	return bc_send(req);
> >> +	/* Returns 1 for send, 0 for drop */
> >> +	if (svc_process_common(rqstp, argv, resv)) {
> >> +		memcpy(&req->rq_snd_buf, &rqstp->rq_res,
> >> +						sizeof(req->rq_snd_buf));
> >> +		return bc_send(req);
> >> +	} else {
> >> +		/* Nothing to do to drop request */
> >> +		return 0;
> > 
> > The one thing that bothers me is the svc_reserve stuff.  Which you have
> > no use for, I guess.  But svc_reserve_auth() is called from
> > svc_process_common(); I wonder if that can get us into trouble?  I'll
> > look a little closer.
> 
> Hmmm. This is triggered by the svc_proceedure pc_xdrressize being set. It's my guess we can set this to 0 and avoid the svc_reserve call.

Yipes.  That's ugly, but you're right, this is the only place where I
can see xdrressize actually used.  Maybe that's the right thing to do.

In any case, this particular patch doesn't make that reserved-space
accounting any worse that I can see--it was already broken before, if in
a slightly different patch.  So

	Acked-by: J. Bruce Fields <bfields@redhat.com>

for this patch, and then give the callback server a way to opt out of
the reserved-space accounting (possibly but just setting pc_xdrressize
to 0, OK) in another patch.

--b.
