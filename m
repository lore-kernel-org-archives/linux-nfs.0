Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:37149 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759066Ab2HITGM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 15:06:12 -0400
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120809183557.GA10591@fieldses.org>
Date: Thu, 9 Aug 2012 15:06:00 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com>
References: <20120809183557.GA10591@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 9, 2012, at 2:35 PM, J. Bruce Fields wrote:

> Sorry not to notice this before--the below causes a regression against
> the Linux server; something like:
> 
> 	# mount -osec=krb5i pip1:/exports /mnt/
> 	# echo "test" >/mnt/test
> 	# umount /mnt/
> 	# mount -osec=krb5 pip1:/exports /mnt/
> 	# echo "test" >/mnt/test
> 	bash: /mnt/test: Operation not permitted
> 
> This fails after the below commit on the client, but not before, thanks
> to the server rejecting the second setclientid with CLID_INUSE due to a
> different security flavor.

This was part of a series where the last few patches got dropped for other problems.  Testing with this patch by itself was never done since it was part of a series of patches that implement a particular feature.

One thought is to put the authentication flavor name back into nfs_client_id4.id string temporarily until we have worked through the issues with full UCS support.  That would prevent the regression, but we'd still have clients who use multiple authentication flavors maintaining multiple leases.

> I haven't really thought through who's at fault here.  The second
> setclientid does lack some level of security that the former had, so I
> think the server's within its rights to complain.

I don't think the second _lacks_ a level of security: I think the second is using a _different_ security flavor with the same nfs_client_id4.id string.  NFS4ERR_CLID_INUSE is the correct server response in this case.

> --b.
> 
> commit de734831224e74fcaf8917386e33644c4243db95
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Wed Jul 11 16:30:50 2012 -0400
> 
>    NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
> 
>    For NFSv4 minor version 0, currently the cl_id_uniquifier allows the
>    Linux client to generate a unique nfs_client_id4 string whenever a
>    server replies with NFS4ERR_CLID_INUSE.
> 
>    This implementation seems to be based on a flawed reading of RFC
>    3530.  NFS4ERR_CLID_INUSE actually means that the client has presented
>    this nfs_client_id4 string with a different principal at some time in
>    the past, and that lease is still in use on the server.
> 
>    For a Linux client this might be rather difficult to achieve: the
>    authentication flavor is named right in the nfs_client_id4.id
>    string.  If we change flavors, we change strings automatically.
> 
>    So, practically speaking, NFS4ERR_CLID_INUSE means there is some other
>    client using our string.  There is not much that can be done to
>    recover automatically.  Let's make it a permanent error.
> 
>    Remove the recovery logic in nfs4_proc_setclientid(), and remove the
>    cl_id_uniquifier field from the nfs_client data structure.  And,
>    remove the authentication flavor from the nfs_client_id4 string.
> 
>    Keeping the authentication flavor in the nfs_client_id4.id string
>    means that we could have a separate lease for each authentication
>    flavor used by mounts on the client.  But we want just one lease for
>    all the mounts on this client.
> 
>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 74dcd85..1148081 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4029,42 +4029,28 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
> 		.rpc_resp = res,
> 		.rpc_cred = cred,
> 	};
> -	int loop = 0;
> -	int status;
> 
> +	/* nfs_client_id4 */
> 	nfs4_init_boot_verifier(clp, &sc_verifier);
> -
> -	for(;;) {
> -		rcu_read_lock();
> -		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
> -				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
> -				clp->cl_ipaddr,
> -				rpc_peeraddr2str(clp->cl_rpcclient,
> -							RPC_DISPLAY_ADDR),
> -				rpc_peeraddr2str(clp->cl_rpcclient,
> -							RPC_DISPLAY_PROTO),
> -				clp->cl_rpcclient->cl_auth->au_ops->au_name,
> -				clp->cl_id_uniquifier);
> -		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
> +	rcu_read_lock();
> +	setclientid.sc_name_len = scnprintf(setclientid.sc_name,
> +			sizeof(setclientid.sc_name), "%s/%s %s",
> +			clp->cl_ipaddr,
> +			rpc_peeraddr2str(clp->cl_rpcclient,
> +						RPC_DISPLAY_ADDR),
> +			rpc_peeraddr2str(clp->cl_rpcclient,
> +						RPC_DISPLAY_PROTO));
> +	/* cb_client4 */
> +	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
> 				sizeof(setclientid.sc_netid),
> 				rpc_peeraddr2str(clp->cl_rpcclient,
> 							RPC_DISPLAY_NETID));
> -		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
> +	rcu_read_unlock();
> +	setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
> 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
> 				clp->cl_ipaddr, port >> 8, port & 255);
> -		rcu_read_unlock();
> 
> -		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> -		if (status != -NFS4ERR_CLID_INUSE)
> -			break;
> -		if (loop != 0) {
> -			++clp->cl_id_uniquifier;
> -			break;
> -		}
> -		++loop;
> -		ssleep(clp->cl_lease_time / HZ + 1);
> -	}
> -	return status;
> +	return rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> }
> 
> int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
> @@ -5262,10 +5248,9 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> 	nfs4_init_boot_verifier(clp, &verifier);
> 
> 	args.id_len = scnprintf(args.id, sizeof(args.id),
> -				"%s/%s/%u",
> +				"%s/%s",
> 				clp->cl_ipaddr,
> -				clp->cl_rpcclient->cl_nodename,
> -				clp->cl_rpcclient->cl_auth->au_flavor);
> +				clp->cl_rpcclient->cl_nodename);
> 
> 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
> 					GFP_NOFS);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 1cfc460..81eabcd 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1606,10 +1606,15 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
> 			return -ESERVERFAULT;
> 		/* Lease confirmation error: retry after purging the lease */
> 		ssleep(1);
> -	case -NFS4ERR_CLID_INUSE:
> 	case -NFS4ERR_STALE_CLIENTID:
> 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
> 		break;
> +	case -NFS4ERR_CLID_INUSE:
> +		pr_err("NFS: Server %s reports our clientid is in use\n",
> +			clp->cl_hostname);
> +		nfs_mark_client_ready(clp, -EPERM);
> +		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
> +		return -EPERM;
> 	case -EACCES:
> 		if (clp->cl_machine_cred == NULL)
> 			return -EACCES;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index f58325a..6532765 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -69,10 +69,9 @@ struct nfs_client {
> 	struct idmap *		cl_idmap;
> 
> 	/* Our own IP address, as a null-terminated string.
> -	 * This is used to generate the clientid, and the callback address.
> +	 * This is used to generate the mv0 callback address.
> 	 */
> 	char			cl_ipaddr[48];
> -	unsigned char		cl_id_uniquifier;
> 	u32			cl_cb_ident;	/* v4.0 callback identifier */
> 	const struct nfs4_minor_version_ops *cl_mvops;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




