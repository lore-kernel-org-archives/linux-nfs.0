Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:6277 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab3KMUsF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 15:48:05 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2] nfs: don't retry detect_trunking with RPC_AUTH_UNIX
 more than once
Date: Wed, 13 Nov 2013 20:48:04 +0000
Message-ID: <EBCF8527-3031-4BFE-9559-9CAF50C4633D@netapp.com>
References: <1384351701-29572-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384351701-29572-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tested v2 and everything looks good.

Also, it seems like I’m no longer able to reproduce the "NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO” dmesg.

-dros

On Nov 13, 2013, at 9:08 AM, Jeff Layton <jlayton@redhat.com> wrote:

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
> Note too that with this change, we don't need the (i > 2) check in the
> -EACCES case since we now have a more reliable test as to whether we
> should reattempt.
> 
> Cc: stable@vger.kernel.org # v3.10+
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Tested-by/Acked-by: Weston Andros Adamson <dros@netapp.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/nfs4state.c | 7 ++++++-
> 1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index c8e729d..6f04706 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2093,10 +2093,15 @@ again:
> 			nfs4_root_machine_cred(clp);
> 			goto again;
> 		}
> -		if (i > 2)
> +		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX)
> 			break;
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
> -- 
> 1.8.3.1
> 

