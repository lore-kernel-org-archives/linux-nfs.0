Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391Ab3KLWou (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 17:44:50 -0500
Date: Tue, 12 Nov 2013 17:44:43 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, dros@netapp.com
Subject: Re: [PATCH] nfs: don't retry detect_trunking with RPC_AUTH_UNIX
 more than once
Message-ID: <20131112174443.2a045812@tlielax.poochiereds.net>
In-Reply-To: <B8BE037C-F0E9-4900-A218-67EE146E9BED@oracle.com>
References: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
	<B8BE037C-F0E9-4900-A218-67EE146E9BED@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Nov 2013 17:08:53 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 12, 2013, at 4:30 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Currently, when we try to mount and get back NFS4ERR_CLID_IN_USE or
> > NFS4ERR_WRONGSEC, we create a new rpc_clnt and then try the call again.
> > There is no guarantee that doing so will work however, so we can end up
> > retrying the call in an infinite loop.
> > 
> > Worse yet, we create the new client using rpc_clone_client_set_auth,
> > which creates the new client as a child of the old one. Thus, we can end
> > up with a *very* long lineage of rpc_clnts. When we go to put all of the
> > references to them, we can end up with a long call chain that can smash
> > the stack as each rpc_free_client() call can recurse back into itself.
> > 
> > This patch fixes this by simply ensuring that the SETCLIENTID call will
> > only be retried in this situation if the last attempt did not use
> > RPC_AUTH_UNIX.
> > 
> > Cc: stable@vger.kernel.org # v3.10+
> > Cc: Weston Andros Adamson <dros@netapp.com>
> > Cc: Chuck Lever <chuck.lever@oracle.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs4state.c | 5 +++++
> > 1 file changed, 5 insertions(+)
> > 
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index c8e729d..4c26c01 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -2097,6 +2097,11 @@ again:
> > 			break;
> 
> Note that the -EACCES case falls through.  I guess it is safe to use the new logic for that case?
> 
> There is an "i++" in the EACCES case that is supposed to prevent the looping you describe.  Maybe that should just be removed, now that there is a more robust test here.
> 

Ahh thanks, I didn't notice that. I'll fix and resend...

Is it kosher to turn -EACCES into -EPERM there, or do we need to
preserve it?

> > 	case -NFS4ERR_CLID_INUSE:
> > 	case -NFS4ERR_WRONGSEC:
> > +		/* No point in retrying if we already used RPC_AUTH_UNIX */
> > +		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX) {
> > +			status = -EPERM;
> > +			break;
> > +		}
> > 		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
> > 		if (IS_ERR(clnt)) {
> > 			status = PTR_ERR(clnt);
> 


-- 
Jeff Layton <jlayton@redhat.com>
