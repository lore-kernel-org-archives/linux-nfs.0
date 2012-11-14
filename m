Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422847Ab2KNNEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 08:04:52 -0500
Date: Wed, 14 Nov 2012 08:04:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 05/15] nfsd: make conf_str_hashtbl allocated per net
Message-ID: <20121114080447.7a65ba3a@tlielax.poochiereds.net>
In-Reply-To: <20121113154844.12577.71736.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
	<20121113154844.12577.71736.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Nov 2012 18:48:44 +0300
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> This hash holds nfs4_clients info, which are network namespace aware.
> So let's make it allocated per network namespace.
> 
> Note: this hash can be allocated in per-net operations. But it looks
> better to allocate it on nfsd state start and thus don't waste resources if
> server is not running.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/netns.h       |    5 +++++
>  fs/nfsd/nfs4recover.c |    2 +-
>  fs/nfsd/nfs4state.c   |   40 ++++++++++++++++++++++++----------------
>  fs/nfsd/state.h       |    2 +-
>  4 files changed, 31 insertions(+), 18 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 0cc85e9..61f41c0 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -47,10 +47,15 @@ struct nfsd_net {
>  	/*
>  	 * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
>  	 * used in reboot/reset lease grace period processing
> +	 *
> +	 * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
> +	 * setclientid_confirmed info.
> +	 *
>  	 */
>  	struct list_head *reclaim_str_hashtbl;
>  	int reclaim_str_hashtbl_size;
>  	struct list_head *conf_id_hashtbl;
> +	struct list_head *conf_str_hashtbl;
>  };
>  
>  extern int nfsd_net_id;
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index fc782b5..ac79dd7 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -320,7 +320,7 @@ purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
>  {
>  	int status;
>  
> -	if (nfs4_has_reclaimed_state(child->d_name.name))
> +	if (nfs4_has_reclaimed_state(child->d_name.name, nn))
>  		return 0;
>  
>  	status = vfs_rmdir(parent->d_inode, child);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 74d047e..a709dd2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -404,9 +404,6 @@ static unsigned int clientstr_hashval(const char *name)
>  }
>  
>  /*
> - * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
> - * setclientid_confirmed info. 
> - *
>   * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
>   * setclientid info.
>   *
> @@ -416,7 +413,6 @@ static unsigned int clientstr_hashval(const char *name)
>   * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
>   * for last close replay.
>   */
> -static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head client_lru;
> @@ -1335,7 +1331,7 @@ move_to_confirmed(struct nfs4_client *clp)
>  	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
>  	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
>  	strhashval = clientstr_hashval(clp->cl_recdir);
> -	list_move(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
> +	list_move(&clp->cl_strhash, &nn->conf_str_hashtbl[strhashval]);
>  	renew_client(clp);
>  }
>  
> @@ -1378,11 +1374,12 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
>  } 
>  
>  static struct nfs4_client *
> -find_confirmed_client_by_str(const char *dname, unsigned int hashval)
> +find_confirmed_client_by_str(const char *dname, unsigned int hashval,
> +			     struct nfsd_net *nn)
>  {
>  	struct nfs4_client *clp;
>  
> -	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
> +	list_for_each_entry(clp, &nn->conf_str_hashtbl[hashval], cl_strhash) {
>  		if (same_name(clp->cl_recdir, dname))
>  			return clp;
>  	}
> @@ -1601,7 +1598,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  
>  	/* Cases below refer to rfc 5661 section 18.35.4: */
>  	nfs4_lock_state();
> -	conf = find_confirmed_client_by_str(dname, strhashval);
> +	conf = find_confirmed_client_by_str(dname, strhashval, nn);
>  	if (conf) {
>  		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
>  		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
> @@ -1797,7 +1794,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			goto out_free_conn;
>  		}
>  		hash = clientstr_hashval(unconf->cl_recdir);
> -		old = find_confirmed_client_by_str(unconf->cl_recdir, hash);
> +		old = find_confirmed_client_by_str(unconf->cl_recdir, hash, nn);
>  		if (old)
>  			expire_client(old);
>  		move_to_confirmed(unconf);
> @@ -2203,7 +2200,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  
>  	/* Cases below refer to rfc 3530 section 14.2.33: */
>  	nfs4_lock_state();
> -	conf = find_confirmed_client_by_str(dname, strhashval);
> +	conf = find_confirmed_client_by_str(dname, strhashval, nn);
>  	if (conf) {
>  		/* case 0: */
>  		status = nfserr_clid_inuse;
> @@ -2287,7 +2284,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  	} else { /* case 3: normal case; new or rebooted client */
>  		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
>  
> -		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash);
> +		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash, nn);
>  		if (conf)
>  			expire_client(conf);
>  		move_to_confirmed(unconf);
> @@ -4480,12 +4477,12 @@ alloc_reclaim(void)
>  }
>  
>  int
> -nfs4_has_reclaimed_state(const char *name)
> +nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
>  {
>  	unsigned int strhashval = clientstr_hashval(name);
>  	struct nfs4_client *clp;
>  
> -	clp = find_confirmed_client_by_str(name, strhashval);
> +	clp = find_confirmed_client_by_str(name, strhashval, nn);
>  	if (!clp)
>  		return 0;
>  	return test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> @@ -4703,7 +4700,6 @@ nfs4_state_init(void)
>  	int i;
>  
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
> -		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
>  	}
> @@ -4751,12 +4747,23 @@ static int nfs4_state_start_net(struct net *net)
>  	nn->conf_id_hashtbl = kmalloc(sizeof(struct list_head) *
>  			CLIENT_HASH_SIZE, GFP_KERNEL);
>  	if (!nn->conf_id_hashtbl)
> -		return -ENOMEM;
> +		goto err;
> +	nn->conf_str_hashtbl = kmalloc(sizeof(struct list_head) *
> +			CLIENT_HASH_SIZE, GFP_KERNEL);
> +	if (!nn->conf_str_hashtbl)
> +		goto err_conf_str;
>  
> -	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> +	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
>  		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
> +		INIT_LIST_HEAD(&nn->conf_str_hashtbl[i]);
> +	}
>  
>  	return 0;
> +
> +err_conf_str:
> +	kfree(nn->conf_id_hashtbl);
> +err:
> +	return -ENOMEM;
>  }
>  
>  static void
> @@ -4772,6 +4779,7 @@ __nfs4_state_shutdown_net(struct net *net)
>  			destroy_client(clp);
>  		}
>  	}
> +	kfree(nn->conf_str_hashtbl);
>  	kfree(nn->conf_id_hashtbl);
>  }
>  
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index da78804..f350805 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -483,7 +483,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_client *);
>  extern void nfs4_put_delegation(struct nfs4_delegation *dp);
>  extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
>  extern int nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn);
> -extern int nfs4_has_reclaimed_state(const char *name);
> +extern int nfs4_has_reclaimed_state(const char *name, struct nfsd_net *);
>  extern void release_session_client(struct nfsd4_session *);
>  extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
>  
> 

This too will need to be respun on top of the patches that I recently
sent to Bruce. This hash table has been turned into an rbtree as part
of a scheme to get rid of the need to do md5 hashing here. Shouldn't be
too hard to make those rbtrees per-net though.

-- 
Jeff Layton <jlayton@redhat.com>
