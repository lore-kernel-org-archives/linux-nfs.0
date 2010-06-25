Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274Ab0FYQHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 12:07:25 -0400
Date: Fri, 25 Jun 2010 12:07:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@fys.uio.no,
        Staubach_Peter@emc.com, bfields@fieldses.org
Subject: Re: [PATCH 1/2] sunrpc: split the vs_hidden flag into TCP and UDP
 variants (try #2)
Message-ID: <20100625120710.2ead8998@tlielax.poochiereds.net>
In-Reply-To: <4C24D057.4090403@oracle.com>
References: <1277480946-23844-1-git-send-email-jlayton@redhat.com>
	<4C24D057.4090403@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 25 Jun 2010 11:50:47 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> So this may be a dumb question, but why can't you just change the NFSv4 
> server not to create an RPC listener for UDP?
> 

Unless I'm misunderstanding the code, it's not really structured to do
what you suggest. We don't really create version-specific listeners. We
create listeners for nfsd. We then hook a svc_program to nfsd that has
multiple svc_version structs attached to it. Requests come into nfsd,
it parses them and dispatches them to the appropriate version handlers.

Now that I think about it though...it may be a little cleaner to create
a nfsd4_dispatch routine that does this check and then calls the generic
nfsd_dispatch. That way we wouldn't penalize NFSv2/3 with this check. I
may respin this patch and do it that way once others have a chance to
comment.

> 
> On 06/25/10 11:49 AM, Jeff Layton wrote:
> > RFC3530 states:
> >
> >     Where an NFS version 4 implementation supports operation over the IP
> >     network protocol, the supported transports between NFS and IP MUST be
> >     among the IETF-approved congestion control transport protocols, which
> >     include TCP and SCTP
> >
> > The NFS server currently registers the NFSv4 UDP port with the
> > portmapper, which it really shouldn't do. This patch splits the
> > vs_hidden flag into TCP and UDP variants. A later patch will make
> > the NFS server skip NFSv4+UDP registration with rpcbind.
> >
> > Reported-by: Sachin Prabhu<sprabhu@redhat.com>
> > Signed-off-by: Jeff Layton<jlayton@redhat.com>
> > ---
> >   fs/nfs/callback_xdr.c      |    3 ++-
> >   fs/nfsd/nfs2acl.c          |    1 -
> >   fs/nfsd/nfs3acl.c          |    1 -
> >   include/linux/sunrpc/svc.h |    5 +++--
> >   net/sunrpc/svc.c           |   15 +++++++++++----
> >   5 files changed, 16 insertions(+), 9 deletions(-)
> >
> > diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> > index 05af212..30baf97 100644
> > --- a/fs/nfs/callback_xdr.c
> > +++ b/fs/nfs/callback_xdr.c
> > @@ -783,7 +783,8 @@ struct svc_version nfs4_callback_version1 = {
> >   	.vs_proc = nfs4_callback_procedures1,
> >   	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
> >   	.vs_dispatch = NULL,
> > -	.vs_hidden = 1,
> > +	.vs_hidden_tcp = true,
> > +	.vs_hidden_udp = true,
> >   };
> >
> >   struct svc_version nfs4_callback_version4 = {
> > diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> > index 6aa5590..ec602b4 100644
> > --- a/fs/nfsd/nfs2acl.c
> > +++ b/fs/nfsd/nfs2acl.c
> > @@ -352,5 +352,4 @@ struct svc_version	nfsd_acl_version2 = {
> >   		.vs_proc	= nfsd_acl_procedures2,
> >   		.vs_dispatch	= nfsd_dispatch,
> >   		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
> > -		.vs_hidden	= 0,
> >   };
> > diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
> > index a596e9d..1949a4c 100644
> > --- a/fs/nfsd/nfs3acl.c
> > +++ b/fs/nfsd/nfs3acl.c
> > @@ -262,6 +262,5 @@ struct svc_version	nfsd_acl_version3 = {
> >   		.vs_proc	= nfsd_acl_procedures3,
> >   		.vs_dispatch	= nfsd_dispatch,
> >   		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
> > -		.vs_hidden	= 0,
> >   };
> >
> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> > index 5a3085b..27ff713 100644
> > --- a/include/linux/sunrpc/svc.h
> > +++ b/include/linux/sunrpc/svc.h
> > @@ -370,8 +370,9 @@ struct svc_version {
> >   	struct svc_procedure *	vs_proc;	/* per-procedure info */
> >   	u32			vs_xdrsize;	/* xdrsize needed for this version */
> >
> > -	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
> > -						 * Only used for nfsacl so far. */
> > +	/* these flags control whether program is registered with rpcbind */
> > +	bool			vs_hidden_tcp;
> > +	bool			vs_hidden_udp;
> >
> >   	/* Override dispatch function (e.g. when caching replies).
> >   	 * A return value of 0 means drop the request.
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index d9017d6..487792c 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -868,6 +868,7 @@ int svc_register(const struct svc_serv *serv, const int family,
> >   	struct svc_program	*progp;
> >   	unsigned int		i;
> >   	int			error = 0;
> > +	bool			vs_hidden;
> >
> >   	BUG_ON(proto == 0&&  port == 0);
> >
> > @@ -876,16 +877,20 @@ int svc_register(const struct svc_serv *serv, const int family,
> >   			if (progp->pg_vers[i] == NULL)
> >   				continue;
> >
> > +			vs_hidden = (proto == IPPROTO_UDP) ?
> > +				    progp->pg_vers[i]->vs_hidden_udp :
> > +				    progp->pg_vers[i]->vs_hidden_tcp;
> > +
> >   			dprintk("svc: svc_register(%sv%d, %s, %u, %u)%s\n",
> >   					progp->pg_name,
> >   					i,
> > -					proto == IPPROTO_UDP?  "udp" : "tcp",
> > +					proto == IPPROTO_UDP ?  "udp" : "tcp",
> >   					port,
> >   					family,
> > -					progp->pg_vers[i]->vs_hidden?
> > +					vs_hidden ?
> >   						" (but not telling portmap)" : "");
> >
> > -			if (progp->pg_vers[i]->vs_hidden)
> > +			if (vs_hidden)
> >   				continue;
> >
> >   			error = __svc_register(progp->pg_name, progp->pg_prog,
> > @@ -943,7 +948,9 @@ static void svc_unregister(const struct svc_serv *serv)
> >   		for (i = 0; i<  progp->pg_nvers; i++) {
> >   			if (progp->pg_vers[i] == NULL)
> >   				continue;
> > -			if (progp->pg_vers[i]->vs_hidden)
> > +
> > +			if (progp->pg_vers[i]->vs_hidden_tcp&&
> > +			    progp->pg_vers[i]->vs_hidden_udp)
> >   				continue;
> >
> >   			__svc_unregister(progp->pg_prog, i, progp->pg_name);
> 


-- 
Jeff Layton <jlayton@redhat.com>
