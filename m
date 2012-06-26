Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001Ab2FZTAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jun 2012 15:00:54 -0400
Message-ID: <4FEA06E3.9060109@netapp.com>
Date: Tue, 26 Jun 2012 15:00:51 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Check if rpcauth_create() returns an error code
References: <1340734373-5596-1-git-send-email-bjschuma@netapp.com> <9ED25AEF-945E-4908-8D78-4CC040D9A26A@oracle.com>
In-Reply-To: <9ED25AEF-945E-4908-8D78-4CC040D9A26A@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/26/2012 02:23 PM, Chuck Lever wrote:
> 
> On Jun 26, 2012, at 2:12 PM, bjschuma@netapp.com wrote:
> 
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> I was treating a NULL return value as an error, but this function will
>> instead return an ERR_PTR().  Now that I'm checking if the function
>> returns an error, I should also pass the error up the call stack.
> 
> 
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> fs/nfs/nfs4namespace.c |  4 ++--
>> fs/nfs/nfs4proc.c      | 15 ++++-----------
>> 2 files changed, 6 insertions(+), 13 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>> index 017b4b0..a8aafc6 100644
>> --- a/fs/nfs/nfs4namespace.c
>> +++ b/fs/nfs/nfs4namespace.c
>> @@ -205,9 +205,9 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
>> 		return clone;
>>
>> 	auth = rpcauth_create(flavor, clone);
>> -	if (!auth) {
>> +	if (IS_ERR(auth)) {
>> 		rpc_shutdown_client(clone);
>> -		clone = ERR_PTR(-EIO);
>> +		clone = ERR_CAST(auth);
>> 	}
> 
> This echoes nfs_init_server_rpcclient(), so it should be adequate.
> 
>>
>> 	return clone;
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 5a7b372..f817587 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2356,17 +2356,10 @@ out:
>> static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>> 				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
>> {
>> -	struct rpc_auth *auth;
>> -	int ret;
>> -
>> -	auth = rpcauth_create(flavor, server->client);
>> -	if (!auth) {
>> -		ret = -EIO;
>> -		goto out;
>> -	}
>> -	ret = nfs4_lookup_root(server, fhandle, info);
>> -out:
>> -	return ret;
>> +	struct rpc_auth *auth = rpcauth_create(flavor, server->client);
>> +	if (IS_ERR(auth))
>> +		return PTR_ERR(auth);
>> +	return nfs4_lookup_root(server, fhandle, info);
>> }
>>
>> static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> 
> This logic calls rpcauth_create() in a loop, correct?  The expectation is that rpcauth_create() should simply replace the nfs_client's rpc_auth with the next flavor each time it is called?
> 

Yeah, that's what I'm expecting to happen.

> With the current code in nfs4_find_root_sec(), rpcauth_create() with a GSS flavor fails the second time you call it because (I suspect) there's a pipe dentry left over from the previous call.  So there's no way to walk an entire list returned from gss_mech_list_flavors(), it will fail on the second GSS flavor every time.

rpcauth_create() has this bit of code in it:

	if (clnt->cl_auth)
		rpcauth_release(clnt->cl_auth);
	clnt->cl_auth = auth;


I guess I figured rpcauth_release() was already doing the necessary cleanup.

- Bryan
> 
> We could:
> 
>   a)  have gss_pipes_dentries_create_net() ignore -EEXIST and return zero instead, or
> 
>   b)  make sure rpcauth_create() releases the old rpc_auth before calling op->create()
> 
>   c)  ??
> 


