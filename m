Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47840 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758652Ab3EOQE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 12:04:26 -0400
Date: Wed, 15 May 2013 12:04:24 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
Message-ID: <20130515160424.GK16811@fieldses.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
 <20130513162528.1942.64673.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130513162528.1942.64673.stgit@seurat.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 13, 2013 at 12:25:28PM -0400, Chuck Lever wrote:
> Now that commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state
> whenever possible" is reverted...
> 
> NFSv4 server trunking detection was added with commit 05f4c350 "NFS:
> Discover NFSv4 server trunking when mounting" in v3.7.  One of the
> issues that the reverted commit 4edaa308 tried to address was that
> when server trunking detection was added, we broke the ability to
> mount krb5 exports when the client has no keytab.

And that happened because we started asking gssd explicitly for a
context for a machine principal instead of for uid=0?  Or for some other
reason?

> We still need to
> address that regression.
> 
> Let's try a narrow approach to re-enabling sec=krb5 mounts without a
> local system keytab, and worry about the other issues when we can
> plan concomitant user space and kernel changes.
> 
> When a GSS security flavor is used on a mount, allow the security
> flavor for state management to fall back to AUTH_SYS if there is
> a problem setting up a GSS context for it.

This brings back the delay in the case gssd isn't running, doesn't it?
Or am I missing something?

--b.

> The existing situation is that the first NFSv4 mount of a server
> determines the state management security flavor.  So, if a sec=sys
> mount occurs first, all subsequent mounts will continue to use
> AUTH_SYS for state management, even if they specified sec=krb5 or
> higher.  The risk is allowing a malicious or broken client to purge
> this client's open and lock state on the server; data is not
> exposed.
> 
> Falling back if any error occurs while establishing a GSS context
> for state management has its own risks.  A network intermediary can
> prevent the establishment of a GSS context for state management,
> forcing the client to use AUTH_SYS for this task.
> 
> However, given that the order of NFS mounts is non-deterministic
> anyway, we already fail to provide robust security guarantees for
> state management.
> 
> This will be remedied eventually, but changes co-ordinated with user
> space are required for that.  When a gssd upcall fails, it currently
> does not distinguish between "I don't have a keytab" and "some other
> problem occurred".  To close this security hole, the kernel must
> fall back only when there is no local keytab.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org [>=3.7]
> ---
>  fs/nfs/nfs4state.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index b5137c9..a2482c6 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1911,11 +1911,23 @@ again:
>  	switch (status) {
>  	case 0:
>  		break;
> -
> +	case -ENOKEY:
>  	case -EACCES:
>  		if (clp->cl_machine_cred == NULL)
>  			break;
>  		/* Handle case where the user hasn't set up machine creds */
> +		if (clnt->cl_auth->au_flavor > RPC_AUTH_MAXFLAVOR) {
> +			clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
> +			if (IS_ERR(clnt)) {
> +				status = PTR_ERR(clnt);
> +				break;
> +			}
> +			clnt = xchg(&clp->cl_rpcclient, clnt);
> +			rpc_shutdown_client(clnt);
> +			clnt = clp->cl_rpcclient;
> +			dprintk("NFS: retrying trunking detection with AUTH_SYS\n");
> +			goto again;
> +		}
>  		nfs4_clear_machine_cred(clp);
>  	case -NFS4ERR_DELAY:
>  	case -ETIMEDOUT:
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
