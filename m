Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:42854 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab2EUPTU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:19:20 -0400
Subject: Re: [PATCH 05/14] NFS: Clean up return code checking in nfs4_proc_exchange_id()
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <540BBC20-D78C-4E60-8AEB-BF4125705363@netapp.com>
Date: Mon, 21 May 2012 11:19:14 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Message-Id: <1A893277-45B1-4EBD-AECC-C53381C7CDFC@oracle.com>
References: <20120518220145.774.53741.stgit@degas.1015granger.net> <20120518220558.774.61431.stgit@degas.1015granger.net> <540BBC20-D78C-4E60-8AEB-BF4125705363@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 21, 2012, at 11:10 AM, Adamson, Dros wrote:

> On May 18, 2012, at 6:05 PM, Chuck Lever wrote:
> 
>> Clean up: prefer using the proper types in "if" expressions.
> 
> Is that the preferred style?

Arguable, I suppose.  It has been, lately.

>  I certainly prefer it (being raised on openbsd style(9)) , but when I wrote the code below I was trying to follow the style of most of fs/nfs.

There is always a question of whether to follow the existing style in a file, or introduce the latest style preferences.  Since I'm going to add a "significant" amount of new logic here, I thought I would update the style first.  I usually like to have consistent style at least within a particular function.

So, perhaps the description should read "Clean up: update to use matching types in "if" expressions" ?

> -dros

Thanks for the review.

> 
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/nfs4proc.c |   16 ++++++++--------
>> 1 files changed, 8 insertions(+), 8 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 386a756..db7b76a 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5130,30 +5130,30 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>> 
>> 	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
>> 					GFP_KERNEL);
>> -	if (unlikely(!res.server_scope)) {
>> +	if (unlikely(res.server_scope == NULL)) {
>> 		status = -ENOMEM;
>> 		goto out;
>> 	}
>> 
>> 	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_KERNEL);
>> -	if (unlikely(!res.impl_id)) {
>> +	if (unlikely(res.impl_id == NULL)) {
>> 		status = -ENOMEM;
>> 		goto out_server_scope;
>> 	}
>> 
>> 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> -	if (!status)
>> +	if (status == 0)
>> 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
>> 
>> -	if (!status) {
>> +	if (status == 0) {
>> 		/* use the most recent implementation id */
>> 		kfree(clp->cl_implid);
>> 		clp->cl_implid = res.impl_id;
>> 	} else
>> 		kfree(res.impl_id);
>> 
>> -	if (!status) {
>> -		if (clp->cl_serverscope &&
>> +	if (status == 0) {
>> +		if (clp->cl_serverscope != NULL &&
>> 		    !nfs41_same_server_scope(clp->cl_serverscope,
>> 					     res.server_scope)) {
>> 			dprintk("%s: server_scope mismatch detected\n",
>> @@ -5163,7 +5163,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>> 			clp->cl_serverscope = NULL;
>> 		}
>> 
>> -		if (!clp->cl_serverscope) {
>> +		if (clp->cl_serverscope == NULL) {
>> 			clp->cl_serverscope = res.server_scope;
>> 			goto out;
>> 		}
>> @@ -5172,7 +5172,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>> out_server_scope:
>> 	kfree(res.server_scope);
>> out:
>> -	if (clp->cl_implid)
>> +	if (clp->cl_implid != NULL)
>> 		dprintk("%s: Server Implementation ID: "
>> 			"domain: %s, name: %s, date: %llu,%u\n",
>> 			__func__, clp->cl_implid->domain, clp->cl_implid->name,
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




