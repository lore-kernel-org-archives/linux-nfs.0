From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/9] sunrpc/cache: retry cache lookups that return
	-ETIMEDOUT
Date: Fri, 4 Dec 2009 20:17:42 -0500
Message-ID: <20091205011742.GH22497@fieldses.org>
References: <20090909062539.20462.67466.stgit@notabene.brown> <20090909063254.20462.41616.stgit@notabene.brown> <20091202221127.GB18690@fieldses.org> <20091203165729.GB1393@fieldses.org> <20091204153845.1ec83de5@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58862 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757482AbZLEBQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 20:16:33 -0500
In-Reply-To: <20091204153845.1ec83de5-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 04, 2009 at 03:38:45PM +1100, Neil Brown wrote:
> On Thu, 3 Dec 2009 11:57:29 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Dec 02, 2009 at 05:11:27PM -0500, J. Bruce Fields wrote:
> > > On Wed, Sep 09, 2009 at 04:32:54PM +1000, NeilBrown wrote:
> > > > @@ -793,9 +793,18 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
> > > >  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
> > > >  
> > > >  	ek = svc_expkey_lookup(&key);
> > > > + again:
> > > >  	if (ek == NULL)
> > > >  		return ERR_PTR(-ENOMEM);
> > > >  	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
> > > > +	if (err == -ETIMEDOUT) {
> > > > +		struct svc_expkey *prev_ek = ek;
> > > > +		ek = svc_expkey_lookup(&key);
> > > > +		if (ek != prev_ek)
> > > > +			goto again;
> > > > +		if (ek)
> > > > +			cache_put(&ek->h, &svc_expkey_cache);
> > > > +	}
> > > 
> > > This is very subtle.  (We're comparing to a pointer which may not
> > > actually point to anything any more.)  And it's repeated in every
> > > caller.  Is there any simpler way to handle this?
> > 
> > Actually, is it even right?  After the cache_check:
> > 
> > > >  	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
> > 
> > we no longer hold a reference on ek, so it could be freed.  There's no
> > reason that address couldn't then be reused for something else.  It's
> > even possible that a new entry could be created at the same address
> > here.  So:
> > 
> > > > +	if (err == -ETIMEDOUT) {
> > > > +		struct svc_expkey *prev_ek = ek;
> > > > +		ek = svc_expkey_lookup(&key);
> > 
> > the "ek" that's returned might well equal prev_ek,
> > 
> > > > +		if (ek != prev_ek)
> > > > +			goto again;
> > 
> > but that doesn't necessarily imply that this is the same object that
> > used to exist at that address.  So we could still return an ek which
> > isn't actually a positive cache entry.
> > 
> > Am I missing something?
> 
> No, I don't think so.
> 
> How about this as an alternate.  I have only compile tested it, nothing more.
> But if it looks good to you I'll make sure it really works.

Well, without having really thinking about it:

	- If this were two separate patches, I'd have an easier time
	  sorting out the interesting stuff from the trivial (though
	  nevertheless good) hash-function reshuffling.
	- Adding code to the common lookup_and_check() instead of to
	  every caller certainly seems better, but too bad about the
	  special cases that remain.
	- Something still seems odd here: we shouldn't ever have
	  duplicate cache entries with the same key, because during
	  their lifetimes cache entries are always kept in the hash.  So
	  why do we need extra code to check for that case?  I may just
	  be forgetting what we're doing here.  Should I go reread the
	  rest of the series?

--b.

> 
> I don't much like the way that the ipmap lookups came out, but they are a bit
> awkward because the previous value is cached for improved performance.
> 
> Thanks for the review.
> NeilBrown
> 
> From 6eb6129ee478951ba1f77cdef0f13cf5a7e3f2cd Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.de>
> Date: Wed, 9 Sep 2009 16:22:53 +1000
> Subject: [PATCH] sunrpc/cache: retry cache lookups that return -ETIMEDOUT
> 
> If cache_check returns -ETIMEDOUT, then the cache item is not
> up-to-date, but there is no pending upcall.
> This could mean the data is not available, or it could mean that the
> good data has been stored in a new cache item.
> 
> So re-do the lookup and if that returns a new item, proceed using that
> item.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfsd/export.c                  |   74 ++++++++++++++++++++----------------
>  include/linux/sunrpc/cache.h      |    5 ++
>  net/sunrpc/auth_gss/svcauth_gss.c |   50 +++++++++++++------------
>  net/sunrpc/cache.c                |   30 +++++++++++++++
>  net/sunrpc/svcauth_unix.c         |   47 +++++++++++++++++++----
>  5 files changed, 140 insertions(+), 66 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 984a5eb..99144d5 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -273,10 +273,9 @@ static struct cache_detail svc_expkey_cache = {
>  	.alloc		= expkey_alloc,
>  };
>  
> -static struct svc_expkey *
> -svc_expkey_lookup(struct svc_expkey *item)
> +static int
> +svc_expkey_hash(struct svc_expkey *item)
>  {
> -	struct cache_head *ch;
>  	int hash = item->ek_fsidtype;
>  	char * cp = (char*)item->ek_fsid;
>  	int len = key_len(item->ek_fsidtype);
> @@ -284,6 +283,14 @@ svc_expkey_lookup(struct svc_expkey *item)
>  	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
>  	hash ^= hash_ptr(item->ek_client, EXPKEY_HASHBITS);
>  	hash &= EXPKEY_HASHMASK;
> +	return hash;
> +}
> +
> +static struct svc_expkey *
> +svc_expkey_lookup(struct svc_expkey *item)
> +{
> +	struct cache_head *ch;
> +	int hash = svc_expkey_hash(item);
>  
>  	ch = sunrpc_cache_lookup(&svc_expkey_cache, &item->h,
>  				 hash);
> @@ -297,13 +304,7 @@ static struct svc_expkey *
>  svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old)
>  {
>  	struct cache_head *ch;
> -	int hash = new->ek_fsidtype;
> -	char * cp = (char*)new->ek_fsid;
> -	int len = key_len(new->ek_fsidtype);
> -
> -	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
> -	hash ^= hash_ptr(new->ek_client, EXPKEY_HASHBITS);
> -	hash &= EXPKEY_HASHMASK;
> +	int hash = svc_expkey_hash(new);
>  
>  	ch = sunrpc_cache_update(&svc_expkey_cache, &new->h,
>  				 &old->h, hash);
> @@ -743,14 +744,22 @@ struct cache_detail svc_export_cache = {
>  	.alloc		= svc_export_alloc,
>  };
>  
> -static struct svc_export *
> -svc_export_lookup(struct svc_export *exp)
> +static int
> +svc_export_hash(struct svc_export *exp)
>  {
> -	struct cache_head *ch;
>  	int hash;
> +
>  	hash = hash_ptr(exp->ex_client, EXPORT_HASHBITS);
>  	hash ^= hash_ptr(exp->ex_path.dentry, EXPORT_HASHBITS);
>  	hash ^= hash_ptr(exp->ex_path.mnt, EXPORT_HASHBITS);
> +	return hash;
> +}
> +
> +static struct svc_export *
> +svc_export_lookup(struct svc_export *exp)
> +{
> +	struct cache_head *ch;
> +	int hash = svc_export_hash(exp);
>  
>  	ch = sunrpc_cache_lookup(&svc_export_cache, &exp->h,
>  				 hash);
> @@ -764,10 +773,7 @@ static struct svc_export *
>  svc_export_update(struct svc_export *new, struct svc_export *old)
>  {
>  	struct cache_head *ch;
> -	int hash;
> -	hash = hash_ptr(old->ex_client, EXPORT_HASHBITS);
> -	hash ^= hash_ptr(old->ex_path.dentry, EXPORT_HASHBITS);
> -	hash ^= hash_ptr(old->ex_path.mnt, EXPORT_HASHBITS);
> +	int hash = svc_export_hash(old);
>  
>  	ch = sunrpc_cache_update(&svc_export_cache, &new->h,
>  				 &old->h,
> @@ -782,8 +788,8 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
>  static struct svc_expkey *
>  exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
>  {
> -	struct svc_expkey key, *ek;
> -	int err;
> +	struct svc_expkey key;
> +	struct cache_head *h;
>  	
>  	if (!clp)
>  		return ERR_PTR(-ENOENT);
> @@ -792,13 +798,14 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
>  	key.ek_fsidtype = fsid_type;
>  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
>  
> -	ek = svc_expkey_lookup(&key);
> -	if (ek == NULL)
> +	h = sunrpc_lookup_check(&svc_expkey_cache, &key.h,
> +				reqp, svc_expkey_hash(&key));
> +
> +	if (h == NULL)
>  		return ERR_PTR(-ENOMEM);
> -	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
> -	if (err)
> -		return ERR_PTR(err);
> -	return ek;
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	return container_of(h, struct svc_expkey, h);
>  }
>  
>  static int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv,
> @@ -855,8 +862,8 @@ exp_get_fsid_key(svc_client *clp, int fsid)
>  static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
>  				     struct cache_req *reqp)
>  {
> -	struct svc_export *exp, key;
> -	int err;
> +	struct svc_export key;
> +	struct cache_head *h;
>  
>  	if (!clp)
>  		return ERR_PTR(-ENOENT);
> @@ -864,13 +871,14 @@ static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
>  	key.ex_client = clp;
>  	key.ex_path = *path;
>  
> -	exp = svc_export_lookup(&key);
> -	if (exp == NULL)
> +	h = sunrpc_lookup_check(&svc_export_cache, &key.h,
> +				reqp, svc_export_hash(&key));
> +	if (h == NULL)
>  		return ERR_PTR(-ENOMEM);
> -	err = cache_check(&svc_export_cache, &exp->h, reqp);
> -	if (err)
> -		return ERR_PTR(err);
> -	return exp;
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +
> +	return container_of(h, struct svc_export, h);
>  }
>  
>  /*
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index ef3db11..31d1687 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -154,6 +154,11 @@ extern struct cache_head *
>  sunrpc_cache_update(struct cache_detail *detail,
>  		    struct cache_head *new, struct cache_head *old, int hash);
>  
> +extern struct cache_head *
> +sunrpc_lookup_check(struct cache_detail *detail,
> +		    struct cache_head *item,
> +		    struct cache_req *rqstp,
> +		    int hash);
>  extern int
>  sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
>  		void (*cache_request)(struct cache_detail *,
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index f6c51e5..ab05580 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1000,6 +1000,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>  	struct kvec *resv = &rqstp->rq_res.head[0];
>  	struct xdr_netobj tmpobj;
>  	struct rsi *rsip, rsikey;
> +	struct cache_head *h;
>  	int ret;
>  
>  	/* Read the verifier; should be NULL: */
> @@ -1029,34 +1030,35 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>  	}
>  
>  	/* Perform upcall, or find upcall result: */
> -	rsip = rsi_lookup(&rsikey);
> +	h = sunrpc_lookup_check(&rsi_cache, &rsikey.h, &rqstp->rq_chandle,
> +				rsi_hash(&rsikey));
>  	rsi_free(&rsikey);
> -	if (!rsip)
> +
> +	if (!h)
>  		return SVC_DROP;
> -	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
> -	case -EAGAIN:
> -	case -ETIMEDOUT:
> -	case -ENOENT:
> +
> +	if (IS_ERR(h))
>  		/* No upcall result: */
>  		return SVC_DROP;
> -	case 0:
> -		ret = SVC_DROP;
> -		/* Got an answer to the upcall; use it: */
> -		if (gss_write_init_verf(rqstp, rsip))
> -			goto out;
> -		if (resv->iov_len + 4 > PAGE_SIZE)
> -			goto out;
> -		svc_putnl(resv, RPC_SUCCESS);
> -		if (svc_safe_putnetobj(resv, &rsip->out_handle))
> -			goto out;
> -		if (resv->iov_len + 3 * 4 > PAGE_SIZE)
> -			goto out;
> -		svc_putnl(resv, rsip->major_status);
> -		svc_putnl(resv, rsip->minor_status);
> -		svc_putnl(resv, GSS_SEQ_WIN);
> -		if (svc_safe_putnetobj(resv, &rsip->out_token))
> -			goto out;
> -	}
> +
> +	rsip = container_of(h, struct rsi, h);
> +	ret = SVC_DROP;
> +	/* Got an answer to the upcall; use it: */
> +	if (gss_write_init_verf(rqstp, rsip))
> +		goto out;
> +	if (resv->iov_len + 4 > PAGE_SIZE)
> +		goto out;
> +	svc_putnl(resv, RPC_SUCCESS);
> +	if (svc_safe_putnetobj(resv, &rsip->out_handle))
> +		goto out;
> +	if (resv->iov_len + 3 * 4 > PAGE_SIZE)
> +		goto out;
> +	svc_putnl(resv, rsip->major_status);
> +	svc_putnl(resv, rsip->minor_status);
> +	svc_putnl(resv, GSS_SEQ_WIN);
> +	if (svc_safe_putnetobj(resv, &rsip->out_token))
> +		goto out;
> +
>  	ret = SVC_COMPLETE;
>  out:
>  	cache_put(&rsip->h, &rsi_cache);
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 46e9e2b..fbd38d4 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -265,6 +265,36 @@ int cache_check(struct cache_detail *detail,
>  }
>  EXPORT_SYMBOL_GPL(cache_check);
>  
> +struct cache_head *sunrpc_lookup_check(struct cache_detail *detail,
> +				       struct cache_head *item,
> +				       struct cache_req *rqstp,
> +				       int hash)
> +{
> +	struct cache_head *rv;
> +	struct cache_head *prev = NULL;
> +	int err = -ETIMEDOUT;
> +
> +	while (err == -ETIMEDOUT) {
> +		rv = sunrpc_cache_lookup(detail, item, hash);
> +		if (rv && rv == prev)
> +			break;
> +		if (prev)
> +			cache_put(prev, detail);
> +		if (rv == NULL)
> +			return NULL;
> +
> +		prev = cache_get(rv);
> +		err = cache_check(detail, rv, rqstp);
> +	}
> +
> +
> +	if (prev)
> +		cache_put(prev, detail);
> +	if (err)
> +		return PTR_ERR(err);
> +	return rv;
> +}
> +EXPORT_SYMBOL_GPL(sunrpc_lookup_check);
>  /*
>   * caches need to be periodically cleaned.
>   * For this we maintain a list of cache_detail and
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 117f68a..f4e5908 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -658,18 +658,27 @@ static struct unix_gid *unix_gid_lookup(uid_t uid)
>  static int unix_gid_find(uid_t uid, struct group_info **gip,
>  			 struct svc_rqst *rqstp)
>  {
> -	struct unix_gid *ug = unix_gid_lookup(uid);
> -	if (!ug)
> +	struct unix_gid ugid;
> +	struct cache_head *h;
> +
> +	ugid.uid = uid;
> +	h = sunrpc_lookup_check(&unix_gid_cache, &ugid.h, 
> +				&rqstp->rq_chandle, hash_long(uid, GID_HASHBITS));
> +
> +	if (!h)
>  		return -EAGAIN;
> -	switch (cache_check(&unix_gid_cache, &ug->h, &rqstp->rq_chandle)) {
> -	case -ENOENT:
> -		*gip = NULL;
> -		return 0;
> -	case 0:
> +	if (!IS_ERR(h)) {
> +		struct unix_gid *ug = container_of(h, struct unix_gid, h);
>  		*gip = ug->gi;
>  		get_group_info(*gip);
>  		cache_put(&ug->h, &unix_gid_cache);
>  		return 0;
> +	}
> +
> +	switch (PTR_ERR(h)) {
> +	case -ENOENT:
> +		*gip = NULL;
> +		return 0;
>  	default:
>  		return -EAGAIN;
>  	}
> @@ -681,6 +690,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
>  	struct sockaddr_in *sin;
>  	struct sockaddr_in6 *sin6, sin6_storage;
>  	struct ip_map *ipm;
> +	int err;
>  
>  	switch (rqstp->rq_addr.ss_family) {
>  	case AF_INET:
> @@ -708,11 +718,30 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
>  	if (ipm == NULL)
>  		return SVC_DENIED;
>  
> -	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
> +	err = cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle);
> +
> +	if (err == -ETIMEDOUT) {
> +		struct ip_map ip;
> +		struct cache_head *h;
> +
> +		strcpy(ip.m_class, rqstp->rq_server->sv_program->pg_class);
> +		ipv6_addr_copy(&ip.m_addr, &sin6->sin6_addr);
> +
> +		h = sunrpc_lookup_check(&ip_map_cache, &ip.h,
> +					&rqstp->rq_chandle, hash_ip6(sin6->sin6_addr));
> +		if (h == NULL)
> +			return SVC_DENIED;
> +		if (IS_ERR(h))
> +			err = PTR_ERR(h);
> +		else {
> +			err = 0;
> +			ipm = container_of(h, struct ip_map, h);
> +		}
> +	}
> +	switch(err) {
>  		default:
>  			BUG();
>  		case -EAGAIN:
> -		case -ETIMEDOUT:
>  			return SVC_DROP;
>  		case -ENOENT:
>  			return SVC_DENIED;
> -- 
> 1.6.5.3
> 
