From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] SUNRPC: Provide an API to determine what auth flavors are supported
Date: Tue, 8 Sep 2009 20:52:43 -0400
Message-ID: <1BB48175-9E3E-4566-8BDA-5DFE8EC75854@oracle.com>
References: <20090908223433.23375.40342.stgit@matisse.1015granger.net> <20090908223624.23375.28359.stgit@matisse.1015granger.net> <1252451892.8099.93.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47014 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZIIAxI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 20:53:08 -0400
In-Reply-To: <1252451892.8099.93.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 8, 2009, at 7:18 PM, Trond Myklebust wrote:
> On Tue, 2009-09-08 at 18:36 -0400, Chuck Lever wrote:
>> Introduce an external function call that can report whether sunrpc.ko
>> can support an authentication flavor or not.
>>
>> A new optional rpc_authops hook is added.  If the hook is not  
>> present,
>> then the flavor is assumed to be supported.  If the hook is present,
>> it is passed the pseudoflavor to check, and returns an indication of
>> whether the pseudoflavor is supported or not.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> include/linux/sunrpc/auth.h    |    2 ++
>> net/sunrpc/auth.c              |   33 ++++++++++++++++++++++++++++++ 
>> +++
>> net/sunrpc/auth_gss/auth_gss.c |   18 +++++++++++++++++-
>> 3 files changed, 52 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/ 
>> auth.h
>> index 3f63218..ad9bc97 100644
>> --- a/include/linux/sunrpc/auth.h
>> +++ b/include/linux/sunrpc/auth.h
>> @@ -103,6 +103,7 @@ struct rpc_authops {
>>
>> 	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct  
>> auth_cred *, int);
>> 	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred  
>> *, int);
>> +	int			(*is_supported)(const rpc_authflavor_t);
>> };
>>
>> struct rpc_credops {
>> @@ -134,6 +135,7 @@ struct rpc_cred *	rpc_lookup_cred(void);
>> struct rpc_cred *	rpc_lookup_machine_cred(void);
>> int			rpcauth_register(const struct rpc_authops *);
>> int			rpcauth_unregister(const struct rpc_authops *);
>> +int			rpcauth_is_supported(rpc_authflavor_t pseudoflavor);
>> struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt  
>> *);
>> void			rpcauth_release(struct rpc_auth *);
>> struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *,  
>> struct auth_cred *, int);
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index 0c431c2..ef31ff6 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -72,6 +72,39 @@ rpcauth_unregister(const struct rpc_authops *ops)
>> }
>> EXPORT_SYMBOL_GPL(rpcauth_unregister);
>>
>> +/**
>> + * rpcauth_is_supported - report whether a particular flavor is  
>> supported
>> + * @pseudoflavor: RPC authentication flavor to check
>> + *
>> + * Returns 1 if there is built-in support, or a loaded module,  
>> which can
>> + * handle @pseudoflavor.  Otherwise, zero is returned.
>> + */
>> +int
>> +rpcauth_is_supported(rpc_authflavor_t pseudoflavor)
>> +{
>> +	const rpc_authflavor_t flavor =  
>> pseudoflavor_to_flavor(pseudoflavor);
>> +	const struct rpc_authops *ops;
>> +	int ret = 0;
>> +
>> +	spin_lock(&rpc_authflavor_lock);
>> +	ops = auth_flavors[flavor];
>> +	if (ops == NULL || !try_module_get(ops->owner)) {
>> +		spin_unlock(&rpc_authflavor_lock);
>> +		goto out;
>> +	}
>> +	spin_unlock(&rpc_authflavor_lock);
>> +
>> +	ret = 1;
>> +	if (ops->is_supported)
>> +		ret = ops->is_supported(pseudoflavor);
>> +
>> +	module_put(ops->owner);
>> +
>> +out:
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(rpcauth_is_supported);
>> +
>
> This doesn't look like the right interface to me. NFSv3's mount code,
> and the legacy binary mount interface may indeed use pseudoflavours,  
> but
> the text based mount code uses pseudoflavour name strings,

Code in fs/nfs/super.c maps those strings to pseudoflavors.  I used a  
text-based mount to test this new API, so I know it works.

Are you proposing to sink that super.c string mapping logic into the  
RPC client?  It seems to me that mount options (ie the mapping of  
flavor names to pseudo flavors using the mount option interface) are  
wholly a problem of the client's upper layer.

> whereas NFSv4
> SECINFO uses the ordinary flavour together with the RPCSEC_GSS
> <oid,qop,service> triplet.

In which case we can provide another API (or a function in the NFS  
client) to map that tuple to a pseudoflavor.

> I think we'd be better off with an interface that could handle all  
> three
> types of request...

Perhaps, but I don't think we have a complete taxonomy of uses for  
this yet.  I'm more in favor of coding these up separately, then  
seeing what commonalities emerge, rather than trying to overdesign a  
single API from the start.

But if you have a less rough idea of what you're looking for (or could  
point at some existing code samples), I'm still open.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



