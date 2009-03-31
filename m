From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 16/47] nfsd41: match clientid establishment method
Date: Mon, 30 Mar 2009 23:04:18 -0400
Message-ID: <20090331030418.GC7653@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229137-10764-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56745 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426AbZCaDEU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 23:04:20 -0400
In-Reply-To: <1238229137-10764-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:32:17AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> We need to distinguish between client names provided by NFSv4.0 clients
> SETCLIENTID and those provided by NFSv4.1 via EXCHANGE_ID when looking
> up the clientid by string.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [nfsd41: use boolean values for use_exchange_id argument]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4recover.c      |    3 ++-
>  fs/nfsd/nfs4state.c        |   41 ++++++++++++++++++++++++++++++-----------
>  include/linux/nfsd/state.h |    2 +-
>  3 files changed, 33 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index b11cf8d..3444c00 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -344,7 +344,8 @@ purge_old(struct dentry *parent, struct dentry *child)
>  {
>  	int status;
>  
> -	if (nfs4_has_reclaimed_state(child->d_name.name))
> +	/* note: we currently use this path only for minorversion 0 */

Why is that?

> +	if (nfs4_has_reclaimed_state(child->d_name.name, false))
>  		return 0;
>  
>  	status = nfsd4_clear_clid_dir(parent, child);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 09c63ff..0c39376 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -723,25 +723,44 @@ find_unconfirmed_client(clientid_t *clid)
>  	return NULL;
>  }
>  
> +/*
> + * Return 1 iff clp's clientid establishment method matches the use_exchange_id
> + * parameter. Matching is based on the fact the at least one of the
> + * EXCHGID4_FLAG_USE_{NON_PNFS,PNFS_MDS,PNFS_DS} flags must be set for v4.1
> + */
> +static inline int
> +match_clientid_establishment(struct nfs4_client *clp, bool use_exchange_id)
> +{
> +#if defined(CONFIG_NFSD_V4_1)
> +	return (clp->cl_exchange_flags != 0) == (use_exchange_id != false);
> +#else  /* CONFIG_NFSD_V4_1 */
> +	return 1;
> +#endif /* CONFIG_NFSD_V4_1 */
> +}

If the point is just to ensure that clients only match clients of the
same minorversion, why not just call this match_client_minorversion()?
You could still use cl_exchange_flags as the way to distinguish 4.0 from
4.1, but hide that detail away here.  In which case clearer might be:

	static inline u32 client_minorversion(struct nfs4_client *clp)
	{
		/*
		 * Note 4.1 clients always have one of
		 * EXCHGID4_FLAG_USE{NON_PNFS,PNFS_MDS,PNFS_DS} set.
		 */
		return clp->cl_exchange_flags != 0;
	}

	static inline int client_same_minorversion(nfs4_client *clp, u32 minorversion)
	{
		return client_minorversion(clp) == minorversion;
	}

or even just open-code the latter.

But: are the 4.0 and 4.1 client owner-name namespaces actually meant to
be distinct?  2.4.1 has me a bit confused here.

--b.

> +
>  static struct nfs4_client *
> -find_confirmed_client_by_str(const char *dname, unsigned int hashval)
> +find_confirmed_client_by_str(const char *dname, unsigned int hashval,
> +			     bool use_exchange_id)
>  {
>  	struct nfs4_client *clp;
>  
>  	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
> -		if (same_name(clp->cl_recdir, dname))
> +		if (same_name(clp->cl_recdir, dname) &&
> +		    match_clientid_establishment(clp, use_exchange_id))
>  			return clp;
>  	}
>  	return NULL;
>  }
>  
>  static struct nfs4_client *
> -find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
> +find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
> +			       bool use_exchange_id)
>  {
>  	struct nfs4_client *clp;
>  
>  	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
> -		if (same_name(clp->cl_recdir, dname))
> +		if (same_name(clp->cl_recdir, dname) &&
> +		    match_clientid_establishment(clp, use_exchange_id))
>  			return clp;
>  	}
>  	return NULL;
> @@ -895,7 +914,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  	nfs4_lock_state();
>  	status = nfs_ok;
>  
> -	conf = find_confirmed_client_by_str(dname, strhashval);
> +	conf = find_confirmed_client_by_str(dname, strhashval, true);
>  	if (conf) {
>  		if (!same_verf(&verf, &conf->cl_verifier)) {
>  			/* 18.35.4 case 8 */
> @@ -943,7 +962,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		}
>  	}
>  
> -	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
> +	unconf  = find_unconfirmed_client_by_str(dname, strhashval, true);
>  	if (unconf) {
>  		/*
>  		 * Possible retry or client restart.  Per 18.35.4 case 4,
> @@ -1041,7 +1060,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	strhashval = clientstr_hashval(dname);
>  
>  	nfs4_lock_state();
> -	conf = find_confirmed_client_by_str(dname, strhashval);
> +	conf = find_confirmed_client_by_str(dname, strhashval, false);
>  	if (conf) {
>  		/* RFC 3530 14.2.33 CASE 0: */
>  		status = nfserr_clid_inuse;
> @@ -1056,7 +1075,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	 * has a description of SETCLIENTID request processing consisting
>  	 * of 5 bullet points, labeled as CASE0 - CASE4 below.
>  	 */
> -	unconf = find_unconfirmed_client_by_str(dname, strhashval);
> +	unconf = find_unconfirmed_client_by_str(dname, strhashval, false);
>  	status = nfserr_resource;
>  	if (!conf) {
>  		/*
> @@ -1211,7 +1230,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  			unsigned int hash =
>  				clientstr_hashval(unconf->cl_recdir);
>  			conf = find_confirmed_client_by_str(unconf->cl_recdir,
> -									hash);
> +							    hash, false);
>  			if (conf) {
>  				nfsd4_remove_clid_dir(conf);
>  				expire_client(conf);
> @@ -3332,12 +3351,12 @@ alloc_reclaim(void)
>  }
>  
>  int
> -nfs4_has_reclaimed_state(const char *name)
> +nfs4_has_reclaimed_state(const char *name, bool use_exchange_id)
>  {
>  	unsigned int strhashval = clientstr_hashval(name);
>  	struct nfs4_client *clp;
>  
> -	clp = find_confirmed_client_by_str(name, strhashval);
> +	clp = find_confirmed_client_by_str(name, strhashval, use_exchange_id);
>  	return clp ? 1 : 0;
>  }
>  
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 5de36a7..feab6ec 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -331,7 +331,7 @@ extern void nfsd4_init_recdir(char *recdir_name);
>  extern int nfsd4_recdir_load(void);
>  extern void nfsd4_shutdown_recdir(void);
>  extern int nfs4_client_to_reclaim(const char *name);
> -extern int nfs4_has_reclaimed_state(const char *name);
> +extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
>  extern void nfsd4_recdir_purge_old(void);
>  extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
>  extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
> -- 
> 1.6.2.1
> 
