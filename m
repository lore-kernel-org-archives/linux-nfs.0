Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19578 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910Ab3ICSRL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 14:17:11 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v2 16/33] SUNRPC: Modify synopsis of rpc_client_register()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1378231471.6410.18.camel@leira.trondhjem.org>
Date: Tue, 3 Sep 2013 14:16:18 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Message-Id: <6022E033-F121-48E1-860D-E163AF7A3CC3@oracle.com>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net> <20130809165005.5362.34943.stgit@seurat.1015granger.net> <1378231471.6410.18.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2013, at 2:04 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-08-09 at 12:50 -0400, Chuck Lever wrote:
>> The rpc_client_register() helper was added in commit e73f4cc0,
>> "SUNRPC: split client creation routine into setup and registration,"
>> Mon Jun 24 11:52:52 2013.
>> 
>> I'd like to invoke rpc_client_register() from a context where a
>> struct rpc_create_args is not available.  There appear to be only
>> two fields of interest in struct rpc_create_args: .program and
>> .authflavor .
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> ---
>> net/sunrpc/clnt.c |   12 ++++++------
>> 1 file changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 74f6a70..f9e3926 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -279,10 +279,10 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
>> 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
>> }
>> 
>> -static int rpc_client_register(const struct rpc_create_args *args,
>> -			       struct rpc_clnt *clnt)
>> +static int rpc_client_register(struct rpc_clnt *clnt,
>> +			       rpc_authflavor_t pseudoflavor)
>> {
>> -	const struct rpc_program *program = args->program;
>> +	const struct rpc_program *program = clnt->cl_program;
>> 	struct rpc_auth *auth;
>> 	struct net *net = rpc_net_ns(clnt);
>> 	struct super_block *pipefs_sb;
>> @@ -299,10 +299,10 @@ static int rpc_client_register(const struct rpc_create_args *args,
>> 	if (pipefs_sb)
>> 		rpc_put_sb_net(net);
>> 
>> -	auth = rpcauth_create(args->authflavor, clnt);
>> +	auth = rpcauth_create(pseudoflavor, clnt);
>> 	if (IS_ERR(auth)) {
>> 		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
>> -				args->authflavor);
>> +				pseudoflavor);
>> 		err = PTR_ERR(auth);
>> 		goto err_auth;
>> 	}
>> @@ -384,7 +384,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
>> 	/* save the nodename */
>> 	rpc_clnt_set_nodename(clnt, utsname()->nodename);
>> 
>> -	err = rpc_client_register(args, clnt);
>> +	err = rpc_client_register(clnt, args->authflavor);
>> 	if (err)
>> 		goto out_no_path;
>> 	return clnt;
>> 
> 
> This conflicts a bit with the new management code for the rpc_clnt's
> rpc_pipefs. The fixup above is trivial, but I think that you might want
> to look into whether or not the new code changes anything for your
> rpc_auth strategy.

Agreed.

> In particular note that the new code uses the rpc_clnt->cl_parent chain
> in order to implement sharing of the RPCSEC_GSS caches and pipe upcalls.

This might be a problem when swapping in a transport to a destination server, for example.

How would you like to proceed with merging these?  Hold off until 3.13, take up to 15/33 now and the rest in 3.13, or take the whole series now and fix it up after the window closes?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




