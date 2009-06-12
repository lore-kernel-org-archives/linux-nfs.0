From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] SUNRPC: Use AUTH_NULL for GETPORT/GETADDR requests
Date: Fri, 12 Jun 2009 17:17:54 -0400
Message-ID: <49BC11A9-3E49-4D41-9C25-8214BFADFE3C@oracle.com>
References: <20090515153111.17053.3822.stgit@ingres.1015granger.net> <20090515153309.17053.44496.stgit@ingres.1015granger.net> <1244840937.32257.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:22130 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbZFLVR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2009 17:17:58 -0400
In-Reply-To: <1244840937.32257.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 12, 2009, at 5:08 PM, Trond Myklebust wrote:

> On Fri, 2009-05-15 at 11:33 -0400, Chuck Lever wrote:
>> rpcbind servers do not require RPC authentication, so AUTH_NULL is  
>> all
>> that is needed.  This saves a few bytes on the wire, and a bit of
>> computational expense on both ends.
>
> This certainly isn't the case for all portmap implementations.

What implementations require AUTH_SYS ?  The libtirpc and glibc  
rpcb_getaddr/pmap_getport implementations use NULL, as far as I can  
tell.  libtirpc rpcb_set uses a local socket, which does local  
authentication.  pmap_set in glib uses NULL, I think.

> Are you
> sure this change is safe?

We can hold off if you like.

>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/rpcb_clnt.c |    4 ++--
>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index beee6da..3083597 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -141,7 +141,7 @@ static struct rpc_clnt  
>> *rpcb_create_local(struct sockaddr *addr,
>> 		.servername	= "localhost",
>> 		.program	= &rpcb_program,
>> 		.version	= version,
>> -		.authflavor	= RPC_AUTH_UNIX,
>> +		.authflavor	= RPC_AUTH_NULL,
>> 		.flags		= RPC_CLNT_CREATE_NOPING,
>> 	};
>>
>> @@ -158,7 +158,7 @@ static struct rpc_clnt *rpcb_create(char  
>> *hostname, struct sockaddr *srvaddr,
>> 		.servername	= hostname,
>> 		.program	= &rpcb_program,
>> 		.version	= version,
>> -		.authflavor	= RPC_AUTH_UNIX,
>> +		.authflavor	= RPC_AUTH_NULL,
>> 		.flags		= (RPC_CLNT_CREATE_NOPING |
>> 					RPC_CLNT_CREATE_NONPRIVPORT),
>> 	};
>>
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



