Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22381 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3KLWI7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:08:59 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfs: don't retry detect_trunking with RPC_AUTH_UNIX more than once
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
Date: Tue, 12 Nov 2013 17:08:53 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, dros@netapp.com
Message-Id: <B8BE037C-F0E9-4900-A218-67EE146E9BED@oracle.com>
References: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2013, at 4:30 PM, Jeff Layton <jlayton@redhat.com> wrote:

> Currently, when we try to mount and get back NFS4ERR_CLID_IN_USE or
> NFS4ERR_WRONGSEC, we create a new rpc_clnt and then try the call again.
> There is no guarantee that doing so will work however, so we can end up
> retrying the call in an infinite loop.
> 
> Worse yet, we create the new client using rpc_clone_client_set_auth,
> which creates the new client as a child of the old one. Thus, we can end
> up with a *very* long lineage of rpc_clnts. When we go to put all of the
> references to them, we can end up with a long call chain that can smash
> the stack as each rpc_free_client() call can recurse back into itself.
> 
> This patch fixes this by simply ensuring that the SETCLIENTID call will
> only be retried in this situation if the last attempt did not use
> RPC_AUTH_UNIX.
> 
> Cc: stable@vger.kernel.org # v3.10+
> Cc: Weston Andros Adamson <dros@netapp.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/nfs4state.c | 5 +++++
> 1 file changed, 5 insertions(+)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index c8e729d..4c26c01 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2097,6 +2097,11 @@ again:
> 			break;

Note that the -EACCES case falls through.  I guess it is safe to use the new logic for that case?

There is an "i++" in the EACCES case that is supposed to prevent the looping you describe.  Maybe that should just be removed, now that there is a more robust test here.

> 	case -NFS4ERR_CLID_INUSE:
> 	case -NFS4ERR_WRONGSEC:
> +		/* No point in retrying if we already used RPC_AUTH_UNIX */
> +		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX) {
> +			status = -EPERM;
> +			break;
> +		}
> 		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
> 		if (IS_ERR(clnt)) {
> 			status = PTR_ERR(clnt);

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




