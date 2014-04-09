Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933256AbaDIPU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2014 11:20:56 -0400
Date: Wed, 9 Apr 2014 11:20:55 -0400
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: commit 1bc49d83c37c (nfsd4: fix nfs4err_resource in 4.1 case)
Message-ID: <20140409152055.GB22938@fieldses.org>
References: <ED8FB66B-E2A5-4BD5-95DE-160C9717D9AB@primarydata.com>
 <20140409135625.GA22938@fieldses.org>
 <924781E0-38DB-4623-821C-4FB7C9AF52C8@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <924781E0-38DB-4623-821C-4FB7C9AF52C8@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 09, 2014 at 10:12:58AM -0400, Trond Myklebust wrote:
> 
> On Apr 9, 2014, at 9:56, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> 
> > On Wed, Apr 09, 2014 at 09:41:28AM -0400, Trond Myklebust wrote:
> >> According to RFC5661, NFS4ERR_REP_TOO_BIG/NFS4ERR_REP_TOO_BIG_TO_CACHE
> >> are only appropriate if "The reply to a Compound would exceed the
> >> channel's negotiated maximum response size.”.  Given that the callers
> >> of nfsd4_encode_fattr appear to all pass in ‘buffer’ and ‘buflen’
> >> arguments that are limited to single page, doesn’t this mean that you
> >> can end up returning nfs4err_resource in cases where
> >> nfserr_rep_too_big/nfserr_rep_too_big_to_cache are simply not
> >> appropriate?
> > 
> > Yes, you're right.  This will be fixed by later patches which remove
> > those arbitrary single-page limits, but for now it's a bug.
> > 
> > This was probably a bad way to sequence those patches.
> > 
> > That said, all that patch is doing in those cases is replacing one
> > useless error by another, so in practice I don't think reverting the
> > patch would help anyone--so I'm inclined to leave this alone and wait
> > for the real bug to be fixed (which is that we're imposing limits other
> > than the session limits).
> > 
> > Is this causing some problem right now?
> > 
> 
> I’m not aware of any bug reports yet, but I did want to make sure that it was on your radar.
> 
> That said, one immediate consequence of this patch will be that NFSv4.1 clients will now report EIO instead of EREMOTEIO if they hit the problem. That may make debugging a little less obvious.
> Another consequence will be that if we ever do try to add client side handling of NFS4ERR_REP_TOO_BIG, then we now have to deal with the “handle existing buggy server” syndrome.

Yeah, OK, I can see it would be annoying; maybe it's worth something
like the following for 3.15?

And then for 3.16 I'll delay this change till later in the xdr-encoding
series.

--b.

commit a675223424673a6393fd291280af51fddd6a97ec
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Apr 9 11:07:01 2014 -0400

    Revert "nfsd4: fix nfs4err_resource in 4.1 case"
    
    Since we're still limiting attributes to a page, the result here is that
    a large getattr result will return NFS4ERR_REP_TOO_BIG/TOO_BIG_TO_CACHE
    instead of NFS4ERR_RESOURCE.
    
    Both error returns are wrong, and the real bug here is the arbitrary
    limit on getattr results, fixed by as-yet out-of-tree patches.  But at a
    minimum we can make life easier for clients by sticking to one broken
    behavior in released kernels instead of two....
    
    Trond says:
    
    	one immediate consequence of this patch will be that NFSv4.1
    	clients will now report EIO instead of EREMOTEIO if they hit the
    	problem. That may make debugging a little less obvious.
    
    	Another consequence will be that if we ever do try to add client
    	side handling of NFS4ERR_REP_TOO_BIG, then we now have to deal
    	with the “handle existing buggy server” syndrome.
    
    Reported-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2723c1b..18881f3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3627,14 +3627,6 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	/* nfsd4_check_resp_size guarantees enough room for error status */
 	if (!op->status)
 		op->status = nfsd4_check_resp_size(resp, 0);
-	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
-		struct nfsd4_slot *slot = resp->cstate.slot;
-
-		if (slot->sl_flags & NFSD4_SLOT_CACHETHIS)
-			op->status = nfserr_rep_too_big_to_cache;
-		else
-			op->status = nfserr_rep_too_big;
-	}
 	if (so) {
 		so->so_replay.rp_status = op->status;
 		so->so_replay.rp_buflen = (char *)resp->p - (char *)(statp+1);
