Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:25682 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab2FZVfo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 17:35:44 -0400
Subject: Re: [PATCH] NFS: Check if rpcauth_create() returns an error code
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FEA06E3.9060109@netapp.com>
Date: Tue, 26 Jun 2012 17:34:36 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0B660C97-1E4E-4032-8791-66A26275E7F1@oracle.com>
References: <1340734373-5596-1-git-send-email-bjschuma@netapp.com> <9ED25AEF-945E-4908-8D78-4CC040D9A26A@oracle.com> <4FEA06E3.9060109@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 26, 2012, at 3:00 PM, Bryan Schumaker wrote:

> On 06/26/2012 02:23 PM, Chuck Lever wrote:
>> 
>> On Jun 26, 2012, at 2:12 PM, bjschuma@netapp.com wrote:
>> 
>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>> 
>>> I was treating a NULL return value as an error, but this function will
>>> instead return an ERR_PTR().  Now that I'm checking if the function
>>> returns an error, I should also pass the error up the call stack.
>> 
>> 
>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>> ---
>>> fs/nfs/nfs4namespace.c |  4 ++--
>>> fs/nfs/nfs4proc.c      | 15 ++++-----------
>>> 2 files changed, 6 insertions(+), 13 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>>> index 017b4b0..a8aafc6 100644
>>> --- a/fs/nfs/nfs4namespace.c
>>> +++ b/fs/nfs/nfs4namespace.c
>>> @@ -205,9 +205,9 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
>>> 		return clone;
>>> 
>>> 	auth = rpcauth_create(flavor, clone);
>>> -	if (!auth) {
>>> +	if (IS_ERR(auth)) {
>>> 		rpc_shutdown_client(clone);
>>> -		clone = ERR_PTR(-EIO);
>>> +		clone = ERR_CAST(auth);
>>> 	}
>> 
>> This echoes nfs_init_server_rpcclient(), so it should be adequate.
>> 
>>> 
>>> 	return clone;
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 5a7b372..f817587 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2356,17 +2356,10 @@ out:
>>> static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>>> 				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
>>> {
>>> -	struct rpc_auth *auth;
>>> -	int ret;
>>> -
>>> -	auth = rpcauth_create(flavor, server->client);
>>> -	if (!auth) {
>>> -		ret = -EIO;
>>> -		goto out;
>>> -	}
>>> -	ret = nfs4_lookup_root(server, fhandle, info);
>>> -out:
>>> -	return ret;
>>> +	struct rpc_auth *auth = rpcauth_create(flavor, server->client);
>>> +	if (IS_ERR(auth))
>>> +		return PTR_ERR(auth);
>>> +	return nfs4_lookup_root(server, fhandle, info);
>>> }
>>> 
>>> static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
>> 
>> This logic calls rpcauth_create() in a loop, correct?  The expectation is that rpcauth_create() should simply replace the nfs_client's rpc_auth with the next flavor each time it is called?
>> 
> 
> Yeah, that's what I'm expecting to happen.
> 
>> With the current code in nfs4_find_root_sec(), rpcauth_create() with a GSS flavor fails the second time you call it because (I suspect) there's a pipe dentry left over from the previous call.  So there's no way to walk an entire list returned from gss_mech_list_flavors(), it will fail on the second GSS flavor every time.
> 
> rpcauth_create() has this bit of code in it:
> 
> 	if (clnt->cl_auth)
> 		rpcauth_release(clnt->cl_auth);
> 	clnt->cl_auth = auth;
> 
> 
> I guess I figured rpcauth_release() was already doing the necessary cleanup.

The problem is that all GSS pseudoflavors use the same "gssd" upcall pipe, but the RPC client does not appear to be prepared to share that pipe amongst pseudoflavors that exist concurrently.

So if rpcauth_create() is called to substitute one GSS pseudoflavor for another, it will always fail because the "gssd" pipe already exists.

It appears this bug has been around since late 2008 when the new GSS upcall mechanism was added.  We've never hit it because we've never tried to use rpcauth_create() to replace an rpc_auth before.  Any caller who is setting up a fresh rpc_clnt can handle a failure from rpcauth_create() reasonably well.

But a caller who is attempting to retry an rpcauth_create() with a list of different flavors is SOL; at least the current code leaves the rpc_clnt with the original, working rpc_auth, but it won't allow a caller to replace a GSS flavor with another.

How hard would it be to enable the gssd upcall pipe to be shared?

> - Bryan
>> 
>> We could:
>> 
>>  a)  have gss_pipes_dentries_create_net() ignore -EEXIST and return zero instead, or
>> 
>>  b)  make sure rpcauth_create() releases the old rpc_auth before calling op->create()
>> 
>>  c)  ??
>> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




