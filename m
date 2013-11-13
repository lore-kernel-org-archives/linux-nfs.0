Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18559 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab3KMOsS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 09:48:18 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Charles Edward Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH v2 3/3] nfs: check if gssd is running before attempting
 to use krb5i auth in SETCLIENTID call
Date: Wed, 13 Nov 2013 14:48:12 +0000
Message-ID: <1CFBCCB6-37CE-4C49-91EE-0FB33D11B57A@netapp.com>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com>
 <1384353053-30002-4-git-send-email-jlayton@redhat.com>
 <DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com>
In-Reply-To: <DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 9:38, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 13, 2013, at 9:30 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
>> Currently, the client will attempt to use krb5i in the SETCLIENTID call
>> even if rpc.gssd is running. If that fails, it'll then fall back to
>> RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
>> running, and causes warning messages to pop up in the ring buffer.
>> 
>> Check to see if rpc.gssd is running before even attempting to use krb5i
>> auth, and just silently skip trying to do so if it isn't.
>> 
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>> 
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index b4a160a..988aebf 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -8,6 +8,7 @@
>> #include <linux/nfs_mount.h>
>> #include <linux/sunrpc/addr.h>
>> #include <linux/sunrpc/auth.h>
>> +#include <linux/sunrpc/auth_gss.h>
>> #include <linux/sunrpc/xprt.h>
>> #include <linux/sunrpc/bc_xprt.h>
>> #include "internal.h"
>> @@ -351,7 +352,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
>> */
>> struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>> 				    const struct rpc_timeout *timeparms,
>> -				    const char *ip_addr)
>> +				    const char *ip_addr, struct net *net)

Why the ‘struct net’ argument? clp->cl_net should already be initialized here.

>> {
>> 	char buf[INET6_ADDRSTRLEN + 1];
>> 	struct nfs_client *old;
>> @@ -370,7 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
>> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
>> 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
>> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
>> +
>> +	error = -EINVAL;
>> +	if (gssd_running(net))
>> +		error = nfs_create_rpc_client(clp, timeparms,RPC_AUTH_GSS_KRB5I);
>> 	if (error == -EINVAL)
>> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
> 
> This feels like a layering violation.  Why wouldn't you put a gssd_running check in gss_create(), for example, and have rpcauth_create() return -EINVAL?
> 

It would be better to put it in the upcall.

Cheers
  Trond