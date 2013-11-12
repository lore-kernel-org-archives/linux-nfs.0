Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60862 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614Ab3KLWRo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:17:44 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: don't retry detect_trunking with RPC_AUTH_UNIX
 more than once
Date: Tue, 12 Nov 2013 22:17:41 +0000
Message-ID: <6BD3F476-A74C-42FD-9A20-B8028BA26155@netapp.com>
References: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tested-by/Acked-by: Weston Andros Adamson <dros@netapp.com>

I can’t reproduce the BUG() with this patch applied.

Besides the patch making complete sense to me, I have more evidence to back your explanation of the bug:

Without this patch I can run a ton of mount/umounts and eventually hit the crash. Before the crash there will be *many* (10s of thousands) pipes in /var/lib/nfs/rpc_pipefs/nfs/, which kills gssd (too many fds).

-dros


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

