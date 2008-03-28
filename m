From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Fri, 28 Mar 2008 13:05:06 -0400
Message-ID: <0C9B72D2-FA8E-4400-9D00-FD8E54DB26C3@oracle.com>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080328153253.GB30169@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24611 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbYC1RHF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2008 13:07:05 -0400
In-Reply-To: <20080328153253.GB30169@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 28, 2008, at 11:32 AM, J. Bruce Fields wrote:
> On Thu, Mar 13, 2008 at 01:48:08PM -0400, Trond Myklebust wrote:
>> The current RPCAUTH_LOOKUP_ROOTCREDS flag only works for AUTH_SYS
>> authentication, and then only as a special case in the code. This  
>> patch
>> removes the auth_sys special casing, and replaces it with generic  
>> code.
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>
>>  include/linux/sunrpc/auth.h |    4 ++-
>>  net/sunrpc/auth.c           |   35 +++++++++++++++------------
>>  net/sunrpc/auth_unix.c      |   56 +++++++++++++++++ 
>> +-------------------------
>>  net/sunrpc/sched.c          |    4 ++-
>>  4 files changed, 49 insertions(+), 50 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/ 
>> auth.h
>> index 84d5f3a..012566a 100644
>> --- a/include/linux/sunrpc/auth.h
>> +++ b/include/linux/sunrpc/auth.h
>> @@ -89,7 +89,6 @@ struct rpc_auth {
>>
>>  /* Flags for rpcauth_lookupcred() */
>>  #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
>> -#define RPCAUTH_LOOKUP_ROOTCREDS	0x02	/* This really ought to go! */
>>
>>  /*
>>   * Client authentication ops
>> @@ -136,7 +135,8 @@ void			rpcauth_release(struct rpc_auth *);
>>  struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *,  
>> struct auth_cred *, int);
>>  void			rpcauth_init_cred(struct rpc_cred *, const struct  
>> auth_cred *, struct rpc_auth *, const struct rpc_credops *);
>>  struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
>> -struct rpc_cred *	rpcauth_bindcred(struct rpc_task *);
>> +void			rpcauth_bindcred(struct rpc_task *);
>> +void			rpcauth_bind_root_cred(struct rpc_task *);
>>  void			rpcauth_holdcred(struct rpc_task *);
>>  void			put_rpccred(struct rpc_cred *);
>>  void			rpcauth_unbindcred(struct rpc_task *);
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index b38f6ee..b0f2b2e 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -285,9 +285,6 @@ rpcauth_lookup_credcache(struct rpc_auth  
>> *auth, struct auth_cred * acred,
>>
>>  	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
>>
>> -	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
>> -		nr = acred->uid & RPC_CREDCACHE_MASK;
>> -
>>  	rcu_read_lock();
>>  	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr],  
>> cr_hash) {
>>  		if (!entry->cr_ops->crmatch(acred, entry, flags))
>> @@ -378,30 +375,38 @@ rpcauth_init_cred(struct rpc_cred *cred,  
>> const struct auth_cred *acred,
>>  }
>>  EXPORT_SYMBOL_GPL(rpcauth_init_cred);
>>
>> -struct rpc_cred *
>> -rpcauth_bindcred(struct rpc_task *task)
>> +void
>> +rpcauth_bind_root_cred(struct rpc_task *task)
>>  {
>>  	struct rpc_auth *auth = task->tk_client->cl_auth;
>>  	struct auth_cred acred = {
>> -		.uid = current->fsuid,
>> -		.gid = current->fsgid,
>> -		.group_info = current->group_info,
>> +		.uid = 0,
>> +		.gid = 0,
>>  	};
>>  	struct rpc_cred *ret;
>> -	int flags = 0;
>>
>>  	dprintk("RPC: %5u looking up %s cred\n",
>>  		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
>> -	get_group_info(acred.group_info);
>> -	if (task->tk_flags & RPC_TASK_ROOTCREDS)
>> -		flags |= RPCAUTH_LOOKUP_ROOTCREDS;
>> -	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
>> +	ret = auth->au_ops->lookup_cred(auth, &acred, 0);
>> +	if (!IS_ERR(ret))
>> +		task->tk_msg.rpc_cred = ret;
>> +	else
>> +		task->tk_status = PTR_ERR(ret);
>> +}
>> +
>> +void
>> +rpcauth_bindcred(struct rpc_task *task)
>> +{
>> +	struct rpc_auth *auth = task->tk_client->cl_auth;
>> +	struct rpc_cred *ret;
>> +
>> +	dprintk("RPC: %5u looking up %s cred\n",
>> +		task->tk_pid, auth->au_ops->au_name);
>> +	ret = rpcauth_lookupcred(auth, 0);
>>  	if (!IS_ERR(ret))
>>  		task->tk_msg.rpc_cred = ret;
>>  	else
>>  		task->tk_status = PTR_ERR(ret);
>> -	put_group_info(acred.group_info);
>> -	return ret;
>>  }
>>
>>  void
>> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
>> index 5ed91e5..b763710 100644
>> --- a/net/sunrpc/auth_unix.c
>> +++ b/net/sunrpc/auth_unix.c
>> @@ -60,7 +60,8 @@ static struct rpc_cred *
>>  unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred,  
>> int flags)
>>  {
>>  	struct unx_cred	*cred;
>> -	int		i;
>> +	unsigned int groups = 0;
>> +	unsigned int i;
>
> I don't really care, I'm just curious: why bother to make small  
> counter
> variables unsigned?

If the counter is being compared to an unsigned somewhere, it's  
cleaner to make the counter unsigned as well.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
