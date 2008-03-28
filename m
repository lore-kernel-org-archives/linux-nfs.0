From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/6] SUNRPC: Add a generic RPC credential
Date: Fri, 28 Mar 2008 15:15:31 -0400
Message-ID: <1206731731.15567.12.camel@heimdal.trondhjem.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080313174809.13840.50790.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080328153544.GC30169@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754521AbYC1TPd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 15:15:33 -0400
In-Reply-To: <20080328153544.GC30169@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-28 at 11:35 -0400, J. Bruce Fields wrote:
> On Thu, Mar 13, 2008 at 01:48:09PM -0400, Trond Myklebust wrote:
> > Add an rpc credential that is not tied to any particular auth mechanism,
> > but that can be cached by NFS, and later used to look up a cred for
> > whichever auth mechanism that turns out to be valid when the RPC call is
> > being made.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  include/linux/sunrpc/auth.h |    3 +
> >  net/sunrpc/Makefile         |    2 -
> >  net/sunrpc/auth.c           |    1 
> >  net/sunrpc/auth_generic.c   |  142 +++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 147 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> > index 348546c..70644ed 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -125,9 +125,12 @@ extern const struct rpc_authops	authunix_ops;
> >  extern const struct rpc_authops	authnull_ops;
> >  
> >  void __init		rpc_init_authunix(void);
> > +void __init		rpc_init_generic_auth(void);
> >  void __init		rpcauth_init_module(void);
> >  void __exit		rpcauth_remove_module(void);
> > +void __exit		rpc_destroy_generic_auth(void);
> >  
> > +struct rpc_cred *	rpc_lookup_cred(void);
> >  int			rpcauth_register(const struct rpc_authops *);
> >  int			rpcauth_unregister(const struct rpc_authops *);
> >  struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
> > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > index 92e1dbe..5369aa3 100644
> > --- a/net/sunrpc/Makefile
> > +++ b/net/sunrpc/Makefile
> > @@ -8,7 +8,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
> >  obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
> >  
> >  sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
> > -	    auth.o auth_null.o auth_unix.o \
> > +	    auth.o auth_null.o auth_unix.o auth_generic.o \
> >  	    svc.o svcsock.o svcauth.o svcauth_unix.o \
> >  	    rpcb_clnt.o timer.o xdr.o \
> >  	    sunrpc_syms.o cache.o rpc_pipe.o \
> > diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> > index 1cdb163..012f2a3 100644
> > --- a/net/sunrpc/auth.c
> > +++ b/net/sunrpc/auth.c
> > @@ -566,6 +566,7 @@ static struct shrinker rpc_cred_shrinker = {
> >  void __init rpcauth_init_module(void)
> >  {
> >  	rpc_init_authunix();
> > +	rpc_init_generic_auth();
> >  	register_shrinker(&rpc_cred_shrinker);
> >  }
> >  
> > diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> > new file mode 100644
> > index 0000000..6f129b1
> > --- /dev/null
> > +++ b/net/sunrpc/auth_generic.c
> > @@ -0,0 +1,142 @@
> > +/*
> > + * Generic RPC credential
> > + *
> > + * Copyright (C) 2008, Trond Myklebust <Trond.Myklebust@netapp.com>
> > + */
> > +
> > +#include <linux/err.h>
> > +#include <linux/types.h>
> > +#include <linux/module.h>
> > +#include <linux/sched.h>
> > +#include <linux/sunrpc/auth.h>
> > +#include <linux/sunrpc/clnt.h>
> > +#include <linux/sunrpc/debug.h>
> > +#include <linux/sunrpc/sched.h>
> > +
> > +#ifdef RPC_DEBUG
> > +# define RPCDBG_FACILITY	RPCDBG_AUTH
> > +#endif
> > +
> > +struct generic_cred {
> > +	struct rpc_cred gc_base;
> > +	struct auth_cred acred;
> > +};
> 
> Does generic_cred need both gc_base.cr_uid and acred.uid?  Will those
> ever disagree?

cr_uid is still used by some of the other creds, so I can't remove it
from the rpc_cred yet. It will take a couple more cleanups before we can
do that.

> --b.
> 
> > +
> > +static struct rpc_auth generic_auth;
> > +static struct rpc_cred_cache generic_cred_cache;
> > +static const struct rpc_credops generic_credops;
> > +
> > +/*
> > + * Public call interface
> > + */
> > +struct rpc_cred *rpc_lookup_cred(void)
> > +{
> > +	return rpcauth_lookupcred(&generic_auth, 0);
> > +}
> > +EXPORT_SYMBOL_GPL(rpc_lookup_cred);
> > +
> > +/*
> > + * Lookup generic creds for current process
> > + */
> > +static struct rpc_cred *
> > +generic_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> > +{
> > +	return rpcauth_lookup_credcache(&generic_auth, acred, flags);
> > +}
> > +
> > +static struct rpc_cred *
> > +generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> > +{
> > +	struct generic_cred *gcred;
> > +
> > +	gcred = kmalloc(sizeof(*gcred), GFP_KERNEL);
> > +	if (gcred == NULL)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	rpcauth_init_cred(&gcred->gc_base, acred, &generic_auth, &generic_credops);
> > +	gcred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
> > +
> > +	gcred->acred.uid = acred->uid;
> > +	gcred->acred.gid = acred->gid;
> > +	gcred->acred.group_info = acred->group_info;
> > +	if (gcred->acred.group_info != NULL)
> > +		get_group_info(gcred->acred.group_info);
> > +
> > +	dprintk("RPC:       allocated generic cred %p for uid %d gid %d\n",
> > +			gcred, acred->uid, acred->gid);
> > +	return &gcred->gc_base;
> > +}
> > +
> > +static void
> > +generic_free_cred(struct rpc_cred *cred)
> > +{
> > +	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
> > +
> > +	dprintk("RPC:       generic_free_cred %p\n", gcred);
> > +	if (gcred->acred.group_info != NULL)
> > +		put_group_info(gcred->acred.group_info);
> > +	kfree(gcred);
> > +}
> > +
> > +static void
> > +generic_free_cred_callback(struct rcu_head *head)
> > +{
> > +	struct rpc_cred *cred = container_of(head, struct rpc_cred, cr_rcu);
> > +	generic_free_cred(cred);
> > +}
> > +
> > +static void
> > +generic_destroy_cred(struct rpc_cred *cred)
> > +{
> > +	call_rcu(&cred->cr_rcu, generic_free_cred_callback);
> > +}
> > +
> > +/*
> > + * Match credentials against current process creds.
> > + */
> > +static int
> > +generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
> > +{
> > +	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
> > +
> > +	if (gcred->acred.uid != acred->uid ||
> > +	    gcred->acred.gid != acred->gid ||
> > +	    gcred->acred.group_info != acred->group_info)
> > +		return 0;
> > +	return 1;
> > +}
> > +
> > +void __init rpc_init_generic_auth(void)
> > +{
> > +	spin_lock_init(&generic_cred_cache.lock);
> > +}
> > +
> > +void __exit rpc_destroy_generic_auth(void)
> > +{
> > +	rpcauth_clear_credcache(&generic_cred_cache);
> > +}
> > +
> > +static struct rpc_cred_cache generic_cred_cache = {
> > +	{{ NULL, },},
> > +};
> > +
> > +static const struct rpc_authops generic_auth_ops = {
> > +	.owner = THIS_MODULE,
> > +#ifdef RPC_DEBUG
> > +	.au_name = "Generic",
> > +#endif
> > +	.lookup_cred = generic_lookup_cred,
> > +	.crcreate = generic_create_cred,
> > +};
> > +
> > +static struct rpc_auth generic_auth = {
> > +	.au_ops = &generic_auth_ops,
> > +	.au_count = ATOMIC_INIT(0),
> > +	.au_credcache = &generic_cred_cache,
> > +};
> > +
> > +static const struct rpc_credops generic_credops = {
> > +	.cr_name = "Generic cred",
> > +	.crdestroy = generic_destroy_cred,
> > +	.crmatch = generic_match,
> > +};
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
