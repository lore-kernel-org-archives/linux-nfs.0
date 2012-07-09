Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:33499 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab2GIUZj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 16:25:39 -0400
Subject: Re: [PATCH 06/14] NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <C8C49406-3B7A-4CB5-9C26-D2A568352E1F@oracle.com>
Date: Mon, 9 Jul 2012 16:25:35 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <106F83FD-D4DC-481C-AB3F-5EBD0ACAD007@oracle.com>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net> <20120709154435.1604.50788.stgit@degas.1015granger.net> <1341864627.15267.19.camel@lade.trondhjem.org> <C8C49406-3B7A-4CB5-9C26-D2A568352E1F@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 9, 2012, at 4:12 PM, Chuck Lever wrote:

> 
> On Jul 9, 2012, at 4:10 PM, Myklebust, Trond wrote:
> 
>> On Mon, 2012-07-09 at 11:44 -0400, Chuck Lever wrote:
>>> For NFSv4 minor version 0, currently the cl_id_uniquifier allows the
>>> Linux client to generate a unique nfs_client_id4 string whenever a
>>> server replies with NFS4ERR_CLID_INUSE.
>>> 
>>> This implementation seems to be based on a flawed reading of RFC
>>> 3530.  NFS4ERR_CLID_INUSE actually means that the client has presented
>>> this nfs_client_id4 string with a different principal at some time in
>>> the past, and that lease is still in use on the server.
>>> 
>>> For a Linux client this might be rather difficult to achieve: the
>>> authentication flavor is named right in the nfs_client_id4.id
>>> string.  If we change flavors, we change strings automatically.
>>> 
>>> So, practically speaking, NFS4ERR_CLID_INUSE means there is some other
>>> client using our string.  There is not much that can be done to
>>> recover automatically.  Let's make it a permanent error.
>>> 
>>> Remove the recovery logic in nfs4_proc_setclientid(), and remove the
>>> cl_id_uniquifier field from the nfs_client data structure.  And,
>>> remove the authentication flavor from the nfs_client_id4 string.
>>> 
>>> Keeping the authentication flavor in the nfs_client_id4.id string
>>> means that we could have a separate lease for each authentication
>>> flavor used by mounts on the client.  But we want just one lease for
>>> all the mounts on this client.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> 
>>> fs/nfs/nfs4proc.c         |   54 ++++++++++++++++++---------------------------
>>> fs/nfs/nfs4state.c        |    7 +++++-
>>> include/linux/nfs_fs_sb.h |    3 +--
>>> 3 files changed, 29 insertions(+), 35 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 7adb705..63a3cf0 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -259,7 +259,12 @@ static int nfs4_wait_clnt_recover(struct nfs_client *clp)
>>> 
>>> 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
>>> 			nfs_wait_bit_killable, TASK_KILLABLE);
>>> -	return res;
>>> +	if (res)
>>> +		return res;
>>> +
>>> +	if (clp->cl_cons_state < 0)
>>> +		return clp->cl_cons_state;
>>> +	return 0;
>>> }
>> 
>> A) This should be a separate patch.
> 
> OK.
> 
>> 
>> B) Why is it needed in the first place? All places that call
>> nfs4_wait_clnt_recover lie outside the mount code path.
> 
> The problem is that is no longer the case once we have trunking discovery in the mount path.

Alright, that's not the problem.  The problem is we decided to make CLID_INUSE a permanent error during state recovery.  If the state manager doesn't cause waiting operations to fail, then we get an infinite loop, right?

> We discussed this.  This is what you told me to do.
> 
>>> static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
>>> @@ -4038,42 +4043,28 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>>> 		.rpc_resp = res,
>>> 		.rpc_cred = cred,
>>> 	};
>>> -	int loop = 0;
>>> -	int status;
>>> 
>>> +	/* nfs_client_id4 */
>>> 	nfs4_init_boot_verifier(clp, &sc_verifier);
>>> -
>>> -	for(;;) {
>>> -		rcu_read_lock();
>>> -		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
>>> -				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
>>> -				clp->cl_ipaddr,
>>> -				rpc_peeraddr2str(clp->cl_rpcclient,
>>> -							RPC_DISPLAY_ADDR),
>>> -				rpc_peeraddr2str(clp->cl_rpcclient,
>>> -							RPC_DISPLAY_PROTO),
>>> -				clp->cl_rpcclient->cl_auth->au_ops->au_name,
>>> -				clp->cl_id_uniquifier);
>>> -		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
>>> +	rcu_read_lock();
>>> +	setclientid.sc_name_len = scnprintf(setclientid.sc_name,
>>> +			sizeof(setclientid.sc_name), "%s/%s %s",
>>> +			clp->cl_ipaddr,
>>> +			rpc_peeraddr2str(clp->cl_rpcclient,
>>> +						RPC_DISPLAY_ADDR),
>>> +			rpc_peeraddr2str(clp->cl_rpcclient,
>>> +						RPC_DISPLAY_PROTO));
>>> +	/* cb_client4 */
>>> +	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
>>> 				sizeof(setclientid.sc_netid),
>>> 				rpc_peeraddr2str(clp->cl_rpcclient,
>>> 							RPC_DISPLAY_NETID));
>>> -		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
>>> +	rcu_read_unlock();
>>> +	setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
>>> 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
>>> 				clp->cl_ipaddr, port >> 8, port & 255);
>>> -		rcu_read_unlock();
>>> 
>>> -		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>>> -		if (status != -NFS4ERR_CLID_INUSE)
>>> -			break;
>>> -		if (loop != 0) {
>>> -			++clp->cl_id_uniquifier;
>>> -			break;
>>> -		}
>>> -		++loop;
>>> -		ssleep(clp->cl_lease_time / HZ + 1);
>>> -	}
>>> -	return status;
>>> +	return rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>>> }
>>> 
>>> int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
>>> @@ -5275,10 +5266,9 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>>> 	nfs4_init_boot_verifier(clp, &verifier);
>>> 
>>> 	args.id_len = scnprintf(args.id, sizeof(args.id),
>>> -				"%s/%s/%u",
>>> +				"%s/%s",
>>> 				clp->cl_ipaddr,
>>> -				clp->cl_rpcclient->cl_nodename,
>>> -				clp->cl_rpcclient->cl_auth->au_flavor);
>>> +				clp->cl_rpcclient->cl_nodename);
>>> 
>>> 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
>>> 					GFP_NOFS);
>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>> index f38300e..a2c1153 100644
>>> --- a/fs/nfs/nfs4state.c
>>> +++ b/fs/nfs/nfs4state.c
>>> @@ -1606,10 +1606,15 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>>> 			return -ESERVERFAULT;
>>> 		/* Lease confirmation error: retry after purging the lease */
>>> 		ssleep(1);
>>> -	case -NFS4ERR_CLID_INUSE:
>>> 	case -NFS4ERR_STALE_CLIENTID:
>>> 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>>> 		break;
>>> +	case -NFS4ERR_CLID_INUSE:
>>> +		printk(KERN_ERR "NFS: Server %s: client ID already in use\n",
>>> +			clp->cl_hostname);
>>> +		nfs_mark_client_ready(clp, -EPERM);
>>> +		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>>> +		return -EPERM;
>> 
>> How do we guarantee that this won't occur on an existing mount?
>> 
>>> 	case -EACCES:
>>> 		if (clp->cl_machine_cred == NULL)
>>> 			return -EACCES;
>>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>>> index f58325a..6532765 100644
>>> --- a/include/linux/nfs_fs_sb.h
>>> +++ b/include/linux/nfs_fs_sb.h
>>> @@ -69,10 +69,9 @@ struct nfs_client {
>>> 	struct idmap *		cl_idmap;
>>> 
>>> 	/* Our own IP address, as a null-terminated string.
>>> -	 * This is used to generate the clientid, and the callback address.
>>> +	 * This is used to generate the mv0 callback address.
>>> 	 */
>>> 	char			cl_ipaddr[48];
>>> -	unsigned char		cl_id_uniquifier;
>>> 	u32			cl_cb_ident;	/* v4.0 callback identifier */
>>> 	const struct nfs4_minor_version_ops *cl_mvops;
>>> 
>>> 
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




