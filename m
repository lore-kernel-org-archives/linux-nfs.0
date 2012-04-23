Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:40611 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab2DWVoE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 17:44:04 -0400
Subject: Re: [PATCH 18/20] NFS: Detect NFSv4 server trunking when mounting
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335216465.11427.34.camel@lade.trondhjem.org>
Date: Mon, 23 Apr 2012 17:43:59 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <6FC87D57-EAB3-4743-A8E4-6FA8E86DF6E1@oracle.com>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net> <20120423205552.11446.58714.stgit@degas.1015granger.net> <1335216465.11427.34.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2012, at 5:27 PM, Myklebust, Trond wrote:

> On Mon, 2012-04-23 at 16:55 -0400, Chuck Lever wrote:
>> Currently the Linux NFS client waits to perform a SETCLIENTID until
>> just before an application wants to open a file.  Quite a bit of
>> activity can occur before any state is needed.
>> 
>> If the client cares about server trunking, however, no NFSv4
>> operations can proceed until the client determines who it is talking
>> to.  Thus server IP trunking detection must be done when the client
>> first encounters an unfamiliar server IP address.
>> 
>> The nfs_get_client() function walks the nfs_client_list and matches on
>> server IP address.  The outcome of that walk tells us immediately if
>> we have an unfamiliar server IP address.  It invokes an init_client()
>> method in this case.
>> 
>> Thus, nfs4_init_client() can establish a fresh client ID, and perform
>> trunking detection with it.  The exact process for detecting trunking
>> is different for NFSv4.0 and NFSv4.1, so a minorversion-specific
>> init_client callout is introduced.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/client.c    |  223 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>> fs/nfs/internal.h  |    6 +
>> fs/nfs/nfs4_fs.h   |    7 ++
>> fs/nfs/nfs4proc.c  |    2 
>> fs/nfs/nfs4state.c |  131 ++++++++++++++++++++++++++++++-
>> 5 files changed, 367 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 920abbc..7330673 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -566,7 +566,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
>> 			return nfs_found_client(cl_init, clp);
>> 		}
>> 		if (new) {
>> -			list_add(&new->cl_share_link, &nn->nfs_client_list);
>> +			list_add_tail(&new->cl_share_link,
>> +					&nn->nfs_client_list);
>> 			spin_unlock(&nn->nfs_client_lock);
>> 			new->cl_flags = cl_init->init_flags;
>> 			return cl_init->rpc_ops->init_client(new,
>> @@ -584,6 +585,210 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
>> 	return new;
>> }
>> 
>> +#ifdef CONFIG_NFS_V4
>> +/*
>> + * Returns true if the client IDs match
>> + */
>> +static bool
>> +nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
>> +{
>> +	if (a->cl_clientid != b->cl_clientid) {
>> +		dprintk("NFS: --> %s client ID %llx does not match %llx\n",
>> +			__func__, a->cl_clientid, b->cl_clientid);
>> +		return false;
>> +	}
>> +	dprintk("NFS: --> %s client ID %llx matches %llx\n",
>> +		__func__, a->cl_clientid, b->cl_clientid);
>> +	return true;
>> +}
>> +
>> +/**
>> + * nfs40_walk_client_list - Find server that recognizes a client ID
>> + *
>> + * @new: nfs_client with client ID to test
>> + * @result: OUT: found nfs_client, or new
>> + * @cred: credential to use for trunking test
>> + *
>> + * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
>> + * If NFS4_OK is returned, an nfs_client pointer is planted in "result."
>> + *
>> + * NB: nfs40_walk_client_list() relies on the new nfs_client being
>> + *     the last nfs_client on the list.
>> + */
>> +int nfs40_walk_client_list(struct nfs_client *new,
>> +			   struct nfs_client **result,
>> +			   struct rpc_cred *cred)
>> +{
>> +	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
>> +	struct nfs_client *pos, *prev = NULL;
>> +	struct nfs4_setclientid_res clid = {
>> +		.clientid	= new->cl_clientid,
>> +		.confirm	= new->cl_confirm,
>> +	};
>> +	int status;
>> +
>> +	dprintk("NFS: --> %s nfs_client = %p\n", __func__, new);
>> +
>> +	spin_lock(&nn->nfs_client_lock);
>> +
>> +	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
>> +		if (pos->cl_cons_state < 0)
>> +			continue;
>> +
>> +		if (pos->rpc_ops != new->rpc_ops)
>> +			continue;
>> +
>> +		if (pos->cl_proto != new->cl_proto)
>> +			continue;
>> +
>> +		if (pos->cl_minorversion != new->cl_minorversion)
>> +			continue;
>> +
>> +		dprintk("NFS: --> %s comparing %llx and %llx\n", __func__,
>> +			new->cl_clientid, pos->cl_clientid);
>> +		if (pos->cl_clientid != new->cl_clientid)
>> +			continue;
>> +
>> +		atomic_inc(&pos->cl_count);
>> +		dprintk("%s nfs_client = %p ({%d})\n",
>> +			__func__, pos, atomic_read(&pos->cl_count));
>> +		spin_unlock(&nn->nfs_client_lock);
>> +
>> +		dprintk("NFS: --> %s confirming %llx\n",
>> +			__func__, new->cl_clientid);
>> +
>> +		if (prev)
>> +			nfs_put_client(prev);
>> +
>> +		status = nfs4_proc_setclientid_confirm(pos, &clid, cred);
> 
> How are you protecting against NFS4CLNT_PURGE_STATE?

My design is that the clid_init_mutex is held by nfs4_reclaim_lease() and while we are in this code.  Whether that made it out of my head and into the source code is another question.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




