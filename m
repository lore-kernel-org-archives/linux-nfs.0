Return-Path: <SRS0=YXm+=OP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27D3DC04EB9
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 01:23:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC3A720892
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 01:23:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC3A720892
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727679AbeLFBXC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 20:23:02 -0500
Received: from fieldses.org ([173.255.197.46]:50992 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727575AbeLFBXC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 20:23:02 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 2DBAD1C1F; Wed,  5 Dec 2018 20:23:01 -0500 (EST)
Date:   Wed, 5 Dec 2018 20:23:01 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 2/4] nfsd: make nfs4_client_reclaim use an xdr_netobj
 instead of a fixed char array
Message-ID: <20181206012301.GB8539@fieldses.org>
References: <20181106183511.17836-1-smayhew@redhat.com>
 <20181106183511.17836-3-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106183511.17836-3-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Nov 06, 2018 at 01:35:09PM -0500, Scott Mayhew wrote:
> This will allow the reclaim_str_hashtbl to store either the recovery
> directory names used by the legacy client tracking code or the full
> client strings used by the nfsdcld client tracking code.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 79 +++++++++++++++++++++++++++++++++++++------
>  fs/nfsd/nfs4state.c   | 30 ++++++++--------
>  fs/nfsd/state.h       |  8 ++---
>  3 files changed, 87 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 5188f9f70c78..b288b14273ff 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -178,6 +178,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  	struct nfs4_client_reclaim *crp;
>  	int status;
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +	struct xdr_netobj name;
>  
>  	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
>  		return;
> @@ -222,9 +223,18 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  	inode_unlock(d_inode(dir));
>  	if (status == 0) {
>  		if (nn->in_grace) {
> -			crp = nfs4_client_to_reclaim(dname, nn);
> -			if (crp)
> -				crp->cr_clp = clp;
> +			name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
> +			if (name.data) {
> +				name.len = HEXDIR_LEN;
> +				crp = nfs4_client_to_reclaim(name, nn);
> +				if (crp)
> +					crp->cr_clp = clp;
> +				else
> +					kfree(name.data);
> +			} else {
> +				dprintk("%s: failed to allocate memory for name.data!\n",
> +					__func__);
> +			}

The usual pattern for error handling is

	try_something
	if failed
		goto error cleanup
	try_something_else
	if failed
		goto error cleanup
		...

and I find that a little easier to follow than this sort of:

	try_something
	if succeeded
		try something_else
		if succeeded
			...

Also, nfsd4_create_clid is getting a little long.

But, I don't know, I haven't tried, if the alternatives don't look like
clear improvements then I can live with it.

The basic idea of the patch looks fine to me.

--b.

>  		}
>  		vfs_fsync(nn->rec_file, 0);
>  	} else {
> @@ -353,6 +363,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
>  	char dname[HEXDIR_LEN];
>  	int status;
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +	struct xdr_netobj name;
>  
>  	if (!nn->rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
>  		return;
> @@ -376,9 +387,17 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
>  		vfs_fsync(nn->rec_file, 0);
>  		if (nn->in_grace) {
>  			/* remove reclaim record */
> -			crp = nfsd4_find_reclaim_client(dname, nn);
> -			if (crp)
> -				nfs4_remove_reclaim_record(crp, nn);
> +			name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
> +			if (name.data) {
> +				name.len = HEXDIR_LEN;
> +				crp = nfsd4_find_reclaim_client(name, nn);
> +				kfree(name.data);
> +				if (crp)
> +					nfs4_remove_reclaim_record(crp, nn);
> +			} else {
> +				dprintk("%s: failed to allocate memory for name.data!\n",
> +					__func__);
> +			}
>  		}
>  	}
>  out_drop_write:
> @@ -393,14 +412,31 @@ static int
>  purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
>  {
>  	int status;
> +	struct xdr_netobj name;
>  
> -	if (nfs4_has_reclaimed_state(child->d_name.name, nn))
> +	if (child->d_name.len != HEXDIR_LEN - 1) {
> +		printk("%s: illegal name %pd in recovery directory\n",
> +				__func__, child);
> +		/* Keep trying; maybe the others are OK: */
>  		return 0;
> +	}
> +	name.data = kmemdup_nul(child->d_name.name, child->d_name.len, GFP_KERNEL);
> +	if (!name.data) {
> +		dprintk("%s: failed to allocate memory for name.data!\n",
> +			__func__);
> +		goto out;
> +	}
> +	name.len = HEXDIR_LEN;
> +	if (nfs4_has_reclaimed_state(name, nn))
> +		goto out_free;
>  
>  	status = vfs_rmdir(d_inode(parent), child);
>  	if (status)
>  		printk("failed to remove client recovery directory %pd\n",
>  				child);
> +out_free:
> +	kfree(name.data);
> +out:
>  	/* Keep trying, success or failure: */
>  	return 0;
>  }
> @@ -430,13 +466,24 @@ nfsd4_recdir_purge_old(struct nfsd_net *nn)
>  static int
>  load_recdir(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
>  {
> +	struct xdr_netobj name;
> +
>  	if (child->d_name.len != HEXDIR_LEN - 1) {
> -		printk("nfsd4: illegal name %pd in recovery directory\n",
> -				child);
> +		printk("%s: illegal name %pd in recovery directory\n",
> +				__func__, child);
>  		/* Keep trying; maybe the others are OK: */
>  		return 0;
>  	}
> -	nfs4_client_to_reclaim(child->d_name.name, nn);
> +	name.data = kmemdup_nul(child->d_name.name, child->d_name.len, GFP_KERNEL);
> +	if (!name.data) {
> +		dprintk("%s: failed to allocate memory for name.data!\n",
> +			__func__);
> +		goto out;
> +	}
> +	name.len = HEXDIR_LEN;
> +	if (!nfs4_client_to_reclaim(name, nn))
> +		kfree(name.data);
> +out:
>  	return 0;
>  }
>  
> @@ -616,6 +663,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
>  	char dname[HEXDIR_LEN];
>  	struct nfs4_client_reclaim *crp;
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +	struct xdr_netobj name;
>  
>  	/* did we already find that this client is stable? */
>  	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> @@ -628,13 +676,22 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
>  	}
>  
>  	/* look for it in the reclaim hashtable otherwise */
> -	crp = nfsd4_find_reclaim_client(dname, nn);
> +	name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
> +	if (!name.data) {
> +		dprintk("%s: failed to allocate memory for name.data!\n",
> +			__func__);
> +		goto out_enoent;
> +	}
> +	name.len = HEXDIR_LEN;
> +	crp = nfsd4_find_reclaim_client(name, nn);
> +	kfree(name.data);
>  	if (crp) {
>  		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
>  		crp->cr_clp = clp;
>  		return 0;
>  	}
>  
> +out_enoent:
>  	return -ENOENT;
>  }
>  
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f093fbe47133..777fbb0d2761 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1058,9 +1058,9 @@ static unsigned int clientid_hashval(u32 id)
>  	return id & CLIENT_HASH_MASK;
>  }
>  
> -static unsigned int clientstr_hashval(const char *name)
> +static unsigned int clientstr_hashval(struct xdr_netobj name)
>  {
> -	return opaque_hashval(name, 8) & CLIENT_HASH_MASK;
> +	return opaque_hashval(name.data, 8) & CLIENT_HASH_MASK;
>  }
>  
>  /*
> @@ -2039,11 +2039,6 @@ compare_blob(const struct xdr_netobj *o1, const struct xdr_netobj *o2)
>  	return memcmp(o1->data, o2->data, o1->len);
>  }
>  
> -static int same_name(const char *n1, const char *n2)
> -{
> -	return 0 == memcmp(n1, n2, HEXDIR_LEN);
> -}
> -
>  static int
>  same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
>  {
> @@ -6449,7 +6444,7 @@ alloc_reclaim(void)
>  }
>  
>  bool
> -nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
> +nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn)
>  {
>  	struct nfs4_client_reclaim *crp;
>  
> @@ -6459,20 +6454,24 @@ nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
>  
>  /*
>   * failure => all reset bets are off, nfserr_no_grace...
> + *
> + * The caller is responsible for freeing name.data if NULL is returned (it
> + * will be freed in nfs4_remove_reclaim_record in the normal case).
>   */
>  struct nfs4_client_reclaim *
> -nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn)
> +nfs4_client_to_reclaim(struct xdr_netobj name, struct nfsd_net *nn)
>  {
>  	unsigned int strhashval;
>  	struct nfs4_client_reclaim *crp;
>  
> -	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", HEXDIR_LEN, name);
> +	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", name.len, name.data);
>  	crp = alloc_reclaim();
>  	if (crp) {
>  		strhashval = clientstr_hashval(name);
>  		INIT_LIST_HEAD(&crp->cr_strhash);
>  		list_add(&crp->cr_strhash, &nn->reclaim_str_hashtbl[strhashval]);
> -		memcpy(crp->cr_recdir, name, HEXDIR_LEN);
> +		crp->cr_name.data = name.data;
> +		crp->cr_name.len = name.len;
>  		crp->cr_clp = NULL;
>  		nn->reclaim_str_hashtbl_size++;
>  	}
> @@ -6483,6 +6482,7 @@ void
>  nfs4_remove_reclaim_record(struct nfs4_client_reclaim *crp, struct nfsd_net *nn)
>  {
>  	list_del(&crp->cr_strhash);
> +	kfree(crp->cr_name.data);
>  	kfree(crp);
>  	nn->reclaim_str_hashtbl_size--;
>  }
> @@ -6506,16 +6506,16 @@ nfs4_release_reclaim(struct nfsd_net *nn)
>  /*
>   * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
>  struct nfs4_client_reclaim *
> -nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
> +nfsd4_find_reclaim_client(struct xdr_netobj name, struct nfsd_net *nn)
>  {
>  	unsigned int strhashval;
>  	struct nfs4_client_reclaim *crp = NULL;
>  
> -	dprintk("NFSD: nfs4_find_reclaim_client for recdir %s\n", recdir);
> +	dprintk("NFSD: nfs4_find_reclaim_client for name %.*s\n", name.len, name.data);
>  
> -	strhashval = clientstr_hashval(recdir);
> +	strhashval = clientstr_hashval(name);
>  	list_for_each_entry(crp, &nn->reclaim_str_hashtbl[strhashval], cr_strhash) {
> -		if (same_name(crp->cr_recdir, recdir)) {
> +		if (compare_blob(&crp->cr_name, &name) == 0) {
>  			return crp;
>  		}
>  	}
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 6aacb325b6a0..95dd298c4620 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -367,7 +367,7 @@ struct nfs4_client {
>  struct nfs4_client_reclaim {
>  	struct list_head	cr_strhash;	/* hash by cr_name */
>  	struct nfs4_client	*cr_clp;	/* pointer to associated clp */
> -	char			cr_recdir[HEXDIR_LEN]; /* recover dir */
> +	struct xdr_netobj	cr_name;	/* recovery dir name */
>  };
>  
>  /* A reasonable value for REPLAY_ISIZE was estimated as follows:  
> @@ -619,7 +619,7 @@ void nfs4_put_stid(struct nfs4_stid *s);
>  void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
>  void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
>  extern void nfs4_release_reclaim(struct nfsd_net *);
> -extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
> +extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct xdr_netobj name,
>  							struct nfsd_net *nn);
>  extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
>  		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
> @@ -634,9 +634,9 @@ extern void nfsd4_destroy_callback_queue(void);
>  extern void nfsd4_shutdown_callback(struct nfs4_client *);
>  extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
>  extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
> -extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
> +extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name,
>  							struct nfsd_net *nn);
> -extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
> +extern bool nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn);
>  
>  struct nfs4_file *find_file(struct knfsd_fh *fh);
>  void put_nfs4_file(struct nfs4_file *fi);
> -- 
> 2.17.1
