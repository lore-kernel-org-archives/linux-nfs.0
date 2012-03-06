Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965259Ab2CFUf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 15:35:28 -0500
Date: Tue, 6 Mar 2012 15:35:17 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: convert nfs4_client->cl_cb_flags to a generic
 flags field
Message-ID: <20120306153517.3ae63733@tlielax.poochiereds.net>
In-Reply-To: <20120306201438.GB24741@fieldses.org>
References: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
	<1330965756-24180-2-git-send-email-jlayton@redhat.com>
	<20120306201119.GA24741@fieldses.org>
	<20120306201438.GB24741@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Mar 2012 15:14:38 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Mar 06, 2012 at 03:11:19PM -0500, J. Bruce Fields wrote:
> > On Mon, Mar 05, 2012 at 11:42:35AM -0500, Jeff Layton wrote:
> > > We'll need a way to flag the nfs4_client as already being recorded on
> > > stable storage so that we don't continually upcall. Currently, that's
> > > recorded in the cl_firststate field of the client struct. Using an
> > > entire u32 to store a flag is rather wasteful though.
> > > 
> > > The cl_cb_flags field is only using 2 bits right now, so repurpose that
> > > to a generic flags field. Rename NFSD4_CLIENT_KILL to
> > > NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
> > > flags. Add a mask that we can use for existing checks that look to see
> > > whether any flags are set, so that the new flags don't interfere.
> > > 
> > > Convert all references to cl_firstate to the NFSD4_CLIENT_STABLE flag,
> > > and add a new NFSD4_CLIENT_RECLAIM_COMPLETE flag. I believe there's an
> > > existing bug here too that this should fix:
> > > 
> > > nfs4_set_claim_prev sets cl_firststate on the first CLAIM_PREV open.
> > > nfsd4_reclaim_complete looks for that flag though, and returns
> > > NFS4ERR_COMPLETE_ALREADY if it's set. The upshot here is that once a
> > > client does a CLAIM_PREV open, the RECLAIM_COMPLETE call will fail.
> > > Let's fix this by adding a new RECLAIM_COMPLETE flag on the client to
> > > indicate that that's already been done.
> > 
> > I think this is right, and agree that flags make more sense.  But as a
> > quick bugfix only, how about this?
> 
> Also I think there's another preexisting bug here.  Yuch.
> 
> commit e02c696c47958adb0a2f5499aa6032288c5b475b
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Mar 6 14:43:36 2012 -0500
> 
>     nfsd4: purge stable client records with insufficient state
>     
>     To escape having your stable storage record purged at the end of the
>     grace period, it's not sufficient to simply have performed a
>     setclientid_confirm; you also need to meet the same requirements as
>     someone creating a new record: either you should have done an open or
>     open reclaim (in the 4.0 case) or a reclaim_complete (in the 4.1 case).
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 207c3bd..c9c446d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4415,7 +4415,9 @@ nfs4_has_reclaimed_state(const char *name, bool use_exchange_id)
>  	struct nfs4_client *clp;
>  
>  	clp = find_confirmed_client_by_str(name, strhashval);
> -	return clp ? 1 : 0;
> +	if (!clp)
> +		return 0;
> +	return clp->cl_firststate;
>  }
>  
>  /*

This patch and the previous one look fine to me. Let me know when you
get them committed and I'll plan to rebase my set on top of them. It
might be a little while before I can get to it though...

-- 
Jeff Layton <jlayton@redhat.com>
