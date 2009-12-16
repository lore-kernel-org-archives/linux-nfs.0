From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 04/11] nfsd: mark client for renew
Date: Wed, 16 Dec 2009 17:06:00 -0500
Message-ID: <20091216220600.GG28822@fieldses.org>
References: <4B291B4C.3060603@panasas.com> <1260985272-21481-1-git-send-email-bhalevy@panasas.com> <20091216204839.GA28822@fieldses.org> <20091216205301.GB28822@fieldses.org> <4B295775.1000301@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44707 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932434AbZLPWF5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2009 17:05:57 -0500
In-Reply-To: <4B295775.1000301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2009 at 11:56:05PM +0200, Benny Halevy wrote:
> On Dec. 16, 2009, 22:53 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Wed, Dec 16, 2009 at 03:48:39PM -0500,  J. Bruce Fields wrote:
> >> On Wed, Dec 16, 2009 at 07:41:12PM +0200, Benny Halevy wrote:
> >>> Mark the nfs4_client for renew on operations holding a stateid (or nfs41
> >>> OP_SEQUENCE).
> >>> Do the actual lru list update when the compound processing is complete.
> >>> This will prevents the client from being expired by the laundromat while
> >>> the compound is in progress.
> >>>
> >>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >>> ---
> >>>  fs/nfsd/nfs4proc.c  |    5 +++++
> >>>  fs/nfsd/nfs4state.c |   39 +++++++++++++++++++++++++++++++++++----
> >>>  fs/nfsd/state.h     |    1 +
> >>>  fs/nfsd/xdr4.h      |    1 +
> >>>  4 files changed, 42 insertions(+), 4 deletions(-)
> >>>
> >>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >>> index 37514c4..a8e9731 100644
> >>> --- a/fs/nfsd/nfs4proc.c
> >>> +++ b/fs/nfsd/nfs4proc.c
> >>> @@ -1010,6 +1010,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> >>>  	resp->opcnt = 0;
> >>>  	resp->rqstp = rqstp;
> >>>  	resp->cstate.minorversion = args->minorversion;
> >>> +	resp->cstate.renew_client = NULL;
> >>>  	resp->cstate.replay_owner = NULL;
> >>>  	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
> >>>  	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
> >>> @@ -1114,6 +1115,10 @@ encode_op:
> >>>  	fh_put(&resp->cstate.current_fh);
> >>>  	fh_put(&resp->cstate.save_fh);
> >>>  	BUG_ON(resp->cstate.replay_owner);
> >>> +	if (resp->cstate.renew_client) {
> >>> +		renew_client(resp->cstate.renew_client);
> >>> +		put_nfs4_client(resp->cstate.renew_client);
> >>> +	}
> >>>  out:
> >>>  	nfsd4_release_compoundargs(args);
> >>>  	/* Reset deferral mechanism for RPC deferrals */
> >>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>> index c456551..16ccab3 100644
> >>> --- a/fs/nfsd/nfs4state.c
> >>> +++ b/fs/nfsd/nfs4state.c
> >>> @@ -634,8 +634,39 @@ free_session(struct kref *kref)
> >>>  }
> >>>  
> >>>  static inline void
> >>> +mark_client_for_renew(struct nfsd4_compound_state *cstate,
> >>> +		      struct nfs4_client *clp)
> >>> +{
> >>> +	int old_state = atomic_cmpxchg(&clp->cl_state, CL_STATE_NORMAL,
> >>> +				       CL_STATE_RENEW);
> >>> +
> >>> +	if (old_state != CL_STATE_EXPIRED) {
> >>> +		cstate->renew_client = clp;
> >>> +		get_nfs4_client(clp);
> >> If cstate->renew_client is already set, then we may leak a reference
> >> count here, right?
> >>
> >> Also: at least in the v4 case, I don't think there's anything preventing
> >> cstate->renew_client being already set to a different client.  (With
> >> sessions hopefully that's not possible.)
> >>
> 
> Yeah.  That's a valid point.  So if it is already set then
> if it is the same client we can do nothing, else we can renew
> the previous one here put it and replace cstate->renew_client.

I'm not sure if that can only happen if someone's intentionally messing
with us, or if maybe there's a legitimate case where it can happen
(maybe when a new client is created by some op in the compound?) But,
yes, that sounds like a safe way to handle it.

--b.
