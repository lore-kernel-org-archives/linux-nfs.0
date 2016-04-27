Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35658 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbcD0SgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 14:36:24 -0400
Received: by mail-qg0-f41.google.com with SMTP id f74so20848062qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 11:36:23 -0700 (PDT)
Message-ID: <1461782179.27487.23.camel@poochiereds.net>
Subject: Re: [PATCH v2 1/7] sunrpc: plumb gfp_t parm into crcreate operation
From: Jeff Layton <jlayton@poochiereds.net>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Michal Hocko <mhocko@kernel.org>
Date: Wed, 27 Apr 2016 14:36:19 -0400
In-Reply-To: <65f39930-a1cb-27d2-6c1c-7cf02eee4783@Netapp.com>
References: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
	 <1461286320-24601-2-git-send-email-jeff.layton@primarydata.com>
	 <65f39930-a1cb-27d2-6c1c-7cf02eee4783@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-04-27 at 14:00 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> On 04/21/2016 08:51 PM, Jeff Layton wrote:
> > 
> > We need to be able to call the generic_cred creator from different
> > contexts. Add a gfp_t parm to the crcreate operation and to
> > rpcauth_lookup_credcache. For now, we just push the gfp_t parms up
> > one level to the *_lookup_cred functions.
> > 
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  include/linux/sunrpc/auth.h    | 4 ++--
> >  net/sunrpc/auth.c              | 4 ++--
> >  net/sunrpc/auth_generic.c      | 6 +++---
> >  net/sunrpc/auth_gss/auth_gss.c | 6 +++---
> >  net/sunrpc/auth_unix.c         | 6 +++---
> >  5 files changed, 13 insertions(+), 13 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> > index 6a241a277249..3b616aa7e4d2 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -127,7 +127,7 @@ struct rpc_authops {
> >  	void			(*destroy)(struct rpc_auth *);
> >  
> >  	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct auth_cred *, int);
> > -	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int);
> > +	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int, gfp_t);
> >  	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
> >  	rpc_authflavor_t	(*info2flavor)(struct rpcsec_gss_info *);
> >  	int			(*flavor2info)(rpc_authflavor_t,
> > @@ -178,7 +178,7 @@ rpc_authflavor_t	rpcauth_get_pseudoflavor(rpc_authflavor_t,
> >  int			rpcauth_get_gssinfo(rpc_authflavor_t,
> >  				struct rpcsec_gss_info *);
> >  int			rpcauth_list_flavors(rpc_authflavor_t *, int);
> > -struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
> > +struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int, gfp_t);
> >  void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
> >  struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
> >  struct rpc_cred *	rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *, int);
> > diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> > index 02f53674dc39..e0bb30fd2ed3 100644
> > --- a/net/sunrpc/auth.c
> > +++ b/net/sunrpc/auth.c
> > @@ -543,7 +543,7 @@ rpcauth_cache_enforce_limit(void)
> >   */
> >  struct rpc_cred *
> >  rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
> > -		int flags)
> > +		int flags, gfp_t gfp)
> >  {
> >  	LIST_HEAD(free);
> >  	struct rpc_cred_cache *cache = auth->au_credcache;
> > @@ -580,7 +580,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
> >  	if (flags & RPCAUTH_LOOKUP_RCU)
> >  		return ERR_PTR(-ECHILD);
> >  
> > -	new = auth->au_ops->crcreate(auth, acred, flags);
> > +	new = auth->au_ops->crcreate(auth, acred, flags, gfp);
> >  	if (IS_ERR(new)) {
> >  		cred = new;
> >  		goto out;
> > diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> > index 41248b1820c7..6ed3e3df43e9 100644
> > --- a/net/sunrpc/auth_generic.c
> > +++ b/net/sunrpc/auth_generic.c
> > @@ -77,15 +77,15 @@ static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
> >  static struct rpc_cred *
> >  generic_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  {
> > -	return rpcauth_lookup_credcache(&generic_auth, acred, flags);
> > +	return rpcauth_lookup_credcache(&generic_auth, acred, flags, GFP_KERNEL);
> >  }
> >  
> >  static struct rpc_cred *
> > -generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> > +generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t gfp)
> >  {
> >  	struct generic_cred *gcred;
> >  
> > -	gcred = kmalloc(sizeof(*gcred), GFP_KERNEL);
> > +	gcred = kmalloc(sizeof(*gcred), gfp);
> >  	if (gcred == NULL)
> >  		return ERR_PTR(-ENOMEM);
> >  
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 15612ffa8d57..e64ae93d5b4f 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -1299,11 +1299,11 @@ gss_destroy_cred(struct rpc_cred *cred)
> >  static struct rpc_cred *
> >  gss_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  {
> > -	return rpcauth_lookup_credcache(auth, acred, flags);
> > +	return rpcauth_lookup_credcache(auth, acred, flags, GFP_NOFS);
> >  }
> I know you're just preserving the original flags here, but with all the GFP_NOFS talk recently I was wondering just how important it is to keep using GFP_NOFS here?
> 
> Thanks,
> Anna
> 

(cc'ing Michal in case he has thoughts...)

TBH, I rolled this patch before the summit, so I hadn't considered it. 

AFAIK, it's using GFP_NOFS there to ensure that the cred allocations
don't recurse back into NFS writeback. I don't see anything that would
prevent that if we switched these to GFP_KERNEL without making other
changes.

Note too that I think the NFS case will be quite a bit more complex
than something like XFS. We offload most of the processing to the RPC
state machine, which runs in workqueue context. So even if you set
something like PF_MEMALLOC in at the time you call writepages, you
likely won't have it set when the state machine is actually running.

I think if we want to stop using GFP_NOFS, then we'll need a more
comprehensive plan for NFS/RPC. I don't think we should embark down
that path until the direction is a bit more clear.

> > 
> >  
> >  static struct rpc_cred *
> > -gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> > +gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t gfp)
> >  {
> >  	struct gss_auth *gss_auth = container_of(auth, struct gss_auth, rpc_auth);
> >  	struct gss_cred	*cred = NULL;
> > @@ -1313,7 +1313,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  		__func__, from_kuid(&init_user_ns, acred->uid),
> >  		auth->au_flavor);
> >  
> > -	if (!(cred = kzalloc(sizeof(*cred), GFP_NOFS)))
> > +	if (!(cred = kzalloc(sizeof(*cred), gfp)))
> >  		goto out_err;
> >  
> >  	rpcauth_init_cred(&cred->gc_base, acred, auth, &gss_credops);
> > diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
> > index 0d3dd364c22f..9f65452b7cbc 100644
> > --- a/net/sunrpc/auth_unix.c
> > +++ b/net/sunrpc/auth_unix.c
> > @@ -52,11 +52,11 @@ unx_destroy(struct rpc_auth *auth)
> >  static struct rpc_cred *
> >  unx_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  {
> > -	return rpcauth_lookup_credcache(auth, acred, flags);
> > +	return rpcauth_lookup_credcache(auth, acred, flags, GFP_NOFS);
> >  }
> >  
> >  static struct rpc_cred *
> > -unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> > +unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t gfp)
> >  {
> >  	struct unx_cred	*cred;
> >  	unsigned int groups = 0;
> > @@ -66,7 +66,7 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  			from_kuid(&init_user_ns, acred->uid),
> >  			from_kgid(&init_user_ns, acred->gid));
> >  
> > -	if (!(cred = kmalloc(sizeof(*cred), GFP_NOFS)))
> > +	if (!(cred = kmalloc(sizeof(*cred), gfp)))
> >  		return ERR_PTR(-ENOMEM);
> >  
> >  	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@poochiereds.net>
