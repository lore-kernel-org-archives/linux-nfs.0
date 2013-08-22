Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:49014 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab3HVMt2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Aug 2013 08:49:28 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 3/6] NFSv4: Deal with some more sparse warnings
From: Chuck Lever <Chuck.Lever@oracle.com>
In-Reply-To: <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 22 Aug 2013 08:49:23 -0400
Cc: <linux-nfs@vger.kernel.org>
Message-Id: <9554DA28-1BE7-423C-9ECA-3EDD65681908@oracle.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com> <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com> <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 21, 2013, at 8:26 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Technically, we don't really need to convert these time stamps,
> since they are actually cookies.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Chuck Lever <Chuck.Lever@oracle.com>

Acked-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfs/nfs4proc.c | 12 ++++++------
> fs/nfs/nfs4xdr.c  |  2 +-
> 2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 155c2fa..b577ebb 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1099,7 +1099,7 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
> 		goto no_delegation;
> 
> 	spin_lock(&deleg_cur->lock);
> -	if (nfsi->delegation != deleg_cur ||
> +	if (rcu_dereference(nfsi->delegation) != deleg_cur ||
> 	   test_bit(NFS_DELEGATION_RETURNING, &deleg_cur->flags) ||
> 	    (deleg_cur->type & fmode) != fmode)
> 		goto no_delegation_unlock;
> @@ -4628,11 +4628,11 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
> 		/* An impossible timestamp guarantees this value
> 		 * will never match a generated boot time. */
> 		verf[0] = 0;
> -		verf[1] = (__be32)(NSEC_PER_SEC + 1);
> +		verf[1] = cpu_to_be32(NSEC_PER_SEC + 1);
> 	} else {
> 		struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
> -		verf[0] = (__be32)nn->boot_time.tv_sec;
> -		verf[1] = (__be32)nn->boot_time.tv_nsec;
> +		verf[0] = cpu_to_be32(nn->boot_time.tv_sec);
> +		verf[1] = cpu_to_be32(nn->boot_time.tv_nsec);
> 	}
> 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
> }
> @@ -7259,7 +7259,7 @@ static void nfs41_free_stateid_release(void *calldata)
> 	kfree(calldata);
> }
> 
> -const struct rpc_call_ops nfs41_free_stateid_ops = {
> +static const struct rpc_call_ops nfs41_free_stateid_ops = {
> 	.rpc_call_prepare = nfs41_free_stateid_prepare,
> 	.rpc_call_done = nfs41_free_stateid_done,
> 	.rpc_release = nfs41_free_stateid_release,
> @@ -7479,7 +7479,7 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
> #endif
> };
> 
> -const struct inode_operations nfs4_dir_inode_operations = {
> +static const struct inode_operations nfs4_dir_inode_operations = {
> 	.create		= nfs_create,
> 	.lookup		= nfs_lookup,
> 	.atomic_open	= nfs_atomic_open,
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 1a4a3bd..1336263 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1816,7 +1816,7 @@ static void encode_create_session(struct xdr_stream *xdr,
> 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
> 
> 	/* authsys_parms rfc1831 */
> -	*p++ = (__be32)nn->boot_time.tv_nsec;		/* stamp */
> +	*p++ = cpu_to_be32(nn->boot_time.tv_nsec);	/* stamp */
> 	p = xdr_encode_opaque(p, machine_name, len);
> 	*p++ = cpu_to_be32(0);				/* UID */
> 	*p++ = cpu_to_be32(0);				/* GID */
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




