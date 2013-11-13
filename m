Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759358Ab3KMPcz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 10:32:55 -0500
Date: Wed, 13 Nov 2013 10:35:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH v2 3/3] nfs: check if gssd is running before attempting
 to use krb5i auth in SETCLIENTID call
Message-ID: <20131113103510.6f89a998@corrin.poochiereds.net>
In-Reply-To: <4226B463-0DB1-4847-9C30-252E67B46859@oracle.com>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com>
	<1384353053-30002-4-git-send-email-jlayton@redhat.com>
	<DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com>
	<1CFBCCB6-37CE-4C49-91EE-0FB33D11B57A@netapp.com>
	<4226B463-0DB1-4847-9C30-252E67B46859@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Nov 2013 10:14:30 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 13, 2013, at 9:48 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > 
> > On Nov 13, 2013, at 9:38, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Nov 13, 2013, at 9:30 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> Currently, the client will attempt to use krb5i in the SETCLIENTID call
> >>> even if rpc.gssd is running. If that fails, it'll then fall back to
> >>> RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
> >>> running, and causes warning messages to pop up in the ring buffer.
> >>> 
> >>> Check to see if rpc.gssd is running before even attempting to use krb5i
> >>> auth, and just silently skip trying to do so if it isn't.
> >>> 
> >>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >>> ---
> >>> 
> >>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> >>> index b4a160a..988aebf 100644
> >>> --- a/fs/nfs/nfs4client.c
> >>> +++ b/fs/nfs/nfs4client.c
> >>> @@ -8,6 +8,7 @@
> >>> #include <linux/nfs_mount.h>
> >>> #include <linux/sunrpc/addr.h>
> >>> #include <linux/sunrpc/auth.h>
> >>> +#include <linux/sunrpc/auth_gss.h>
> >>> #include <linux/sunrpc/xprt.h>
> >>> #include <linux/sunrpc/bc_xprt.h>
> >>> #include "internal.h"
> >>> @@ -351,7 +352,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
> >>> */
> >>> struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>> 				    const struct rpc_timeout *timeparms,
> >>> -				    const char *ip_addr)
> >>> +				    const char *ip_addr, struct net *net)
> > 
> > Why the ‘struct net’ argument? clp->cl_net should already be initialized here.
> > 
> >>> {
> >>> 	char buf[INET6_ADDRSTRLEN + 1];
> >>> 	struct nfs_client *old;
> >>> @@ -370,7 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
> >>> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> >>> 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
> >>> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> >>> +
> >>> +	error = -EINVAL;
> >>> +	if (gssd_running(net))
> >>> +		error = nfs_create_rpc_client(clp, timeparms,RPC_AUTH_GSS_KRB5I);
> >>> 	if (error == -EINVAL)
> >>> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
> >> 
> >> This feels like a layering violation.  Why wouldn't you put a gssd_running check in gss_create(), for example, and have rpcauth_create() return -EINVAL?
> >> 
> > 
> > It would be better to put it in the upcall.
> 
> Waiting until the upcall has its benefits.  At that point, GSSD (if it is running) can report other errors, such as that there is no material to form a machine credential.
> 
> My point to Jeff is that, aside from architectural aesthetics, direct calls from RPC consumers to the GSS layer causes a module dependency problem.  The right way to plumb this is to create an RPC client API that invokes gssd_running() but only if auth_rpcgss.ko is loaded.
> 
> However, I don't see why the existing RPC client APIs shouldn't just fail where appropriate if GSSD isn't available.  Is there a strong need to expose gssd_running() as a separate API?
> 

One of the complaints about this whole "use krb5i by default" change is
that we now get the warnings in the ring buffer when gssd isn't
running. That's a good thing if krb5 was explicitly requested, but is
useless and confusing if the user just wants to use AUTH_SYS.

If we wait until gss_create, it's too late to know what the "intent"
was. We'll either fire the warning inappropriately like we do now, or
miss it altogether when we actually should have printed it.

So, that was the main reason for the layering violation here. I do
however get your point on the module dependency, but IIUC...don't we get
that anyway? Now that you try using krb5i by default for SETCLIENTID,
don't we end up loading auth_gss.ko anyway on every nfsv4 mount
regardless?

-- 
Jeff Layton <jlayton@redhat.com>
