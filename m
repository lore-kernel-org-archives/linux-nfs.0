From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/11] SUNRPC: Use a cached RPC client and transport for rpcbind upcalls
Date: Fri, 20 Nov 2009 15:19:32 -0500
Message-ID: <7894188C-5BAF-4E7A-9A58-F9617CF8E29A@oracle.com>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net> <20091105182319.2796.62305.stgit@matisse.1015granger.net> <1258748285.2494.84.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59667 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbZKTUUE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2009 15:20:04 -0500
In-Reply-To: <1258748285.2494.84.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 20, 2009, at 3:18 PM, Trond Myklebust wrote:

> On Thu, 2009-11-05 at 13:23 -0500, Chuck Lever wrote:
>> The kernel's rpcbind client creates and deletes an rpc_clnt and its
>> underlying transport socket for every upcall to the local rpcbind
>> daemon.
>>
>> When starting a typical NFS server on IPv4 and IPv6, the NFS service
>> itself does three upcalls (one per version) times two upcalls (one
>> per transport) times two upcalls (one per address family), making 12,
>> plus another one for the initial call to unregister previous NFS
>> services.  Starting the NLM service adds an additional 13 upcalls,
>> for similar reasons.
>>
>> (Currently the NFS service doesn't start IPv6 listeners, but it will
>> soon enough).
>>
>> Instead, let's create an rpc_clnt for rpcbind upcalls during the
>> first local rpcbind query, and cache it.  This saves the overhead of
>> creating and destroying an rpc_clnt and a socket for every upcall.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/rpcb_clnt.c   |   78 ++++++++++++++++++++++++++++++++++++ 
>> +---------
>> net/sunrpc/sunrpc_syms.c |    3 ++
>> 2 files changed, 65 insertions(+), 16 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index 28f50da..1ec4a1a 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -20,6 +20,7 @@
>> #include <linux/in6.h>
>> #include <linux/kernel.h>
>> #include <linux/errno.h>
>> +#include <linux/spinlock.h>
>> #include <net/ipv6.h>
>>
>> #include <linux/sunrpc/clnt.h>
>> @@ -110,6 +111,9 @@ static void			rpcb_getport_done(struct rpc_task  
>> *, void *);
>> static void			rpcb_map_release(void *data);
>> static struct rpc_program	rpcb_program;
>>
>> +static struct rpc_clnt *	rpcb_local_clnt;
>> +static struct rpc_clnt *	rpcb_local_clnt4;
>> +
>> struct rpcbind_args {
>> 	struct rpc_xprt *	r_xprt;
>>
>> @@ -163,7 +167,7 @@ static const struct sockaddr_in  
>> rpcb_inaddr_loopback = {
>> 	.sin_port		= htons(RPCBIND_PORT),
>> };
>>
>> -static struct rpc_clnt *rpcb_create_local(u32 version)
>> +static int rpcb_create_local(void)
>> {
>> 	struct rpc_create_args args = {
>> 		.protocol	= XPRT_TRANSPORT_UDP,
>> @@ -171,12 +175,37 @@ static struct rpc_clnt *rpcb_create_local(u32  
>> version)
>> 		.addrsize	= sizeof(rpcb_inaddr_loopback),
>> 		.servername	= "localhost",
>> 		.program	= &rpcb_program,
>> -		.version	= version,
>> +		.version	= RPCBVERS_2,
>> 		.authflavor	= RPC_AUTH_UNIX,
>> 		.flags		= RPC_CLNT_CREATE_NOPING,
>> 	};
>> +	static DEFINE_SPINLOCK(rpcb_create_local_lock);
>> +	struct rpc_clnt *clnt, *clnt4;
>> +	int result = 0;
>> +
>> +	spin_lock(&rpcb_create_local_lock);
>> +	if (rpcb_local_clnt)
>> +		goto out;
>> +
>> +	clnt = rpc_create(&args);
>> +	if (IS_ERR(clnt)) {
>> +		result = -PTR_ERR(clnt);
>> +		goto out;
>> +	}
>>
>> -	return rpc_create(&args);
>> +	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
>> +	if (IS_ERR(clnt4)) {
>> +		result = -PTR_ERR(clnt4);
>> +		rpc_shutdown_client(clnt);
>> +		goto out;
>> +	}
>> +
>> +	rpcb_local_clnt = clnt;
>> +	rpcb_local_clnt4 = clnt4;
>> +
>> +out:
>> +	spin_unlock(&rpcb_create_local_lock);
>> +	return result;
>> }
>
> You can't have tested this. At the very least you cannot have done so
> with spinlock debugging enabled...

I did test it, but not with spinlock debugging.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



