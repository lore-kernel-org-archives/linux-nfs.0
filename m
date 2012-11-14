Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422711Ab2KNNC5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 08:02:57 -0500
Date: Wed, 14 Nov 2012 08:02:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 03/15] nfsd: make reclaim_str_hashtbl allocated per net
Message-ID: <20121114080247.67cd6b45@tlielax.poochiereds.net>
In-Reply-To: <20121113154833.12577.8139.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
	<20121113154833.12577.8139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Nov 2012 18:48:33 +0300
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> This hash holds nfs4_clients info, which are network namespace aware.
> So let's make it allocated per network namespace.
> 
> Note: this hash is used only by legacy tracker. So let's allocate hash in
> tracker init.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/netns.h       |   12 +++++++++
>  fs/nfsd/nfs4recover.c |   64 ++++++++++++++++++++++++++++++++++++++++---------
>  fs/nfsd/nfs4state.c   |   32 ++++++++-----------------
>  fs/nfsd/state.h       |    4 ++-
>  4 files changed, 77 insertions(+), 35 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 65c2431..49e5479 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -24,6 +24,11 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  
> +/* Hash tables for nfs4_clientid state */
> +#define CLIENT_HASH_BITS                 4
> +#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
> +#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
> +
>  struct cld_net;
>  
>  struct nfsd_net {
> @@ -38,6 +43,13 @@ struct nfsd_net {
>  	struct lock_manager nfsd4_manager;
>  	bool grace_ended;
>  	time_t boot_time;
> +
> +	/*
> +	 * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
> +	 * used in reboot/reset lease grace period processing
> +	 */
> +	struct list_head *reclaim_str_hashtbl;
> +	int reclaim_str_hashtbl_size;
>  };
>  
>  extern int nfsd_net_id;
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 83d2669..fc782b5 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -193,7 +193,7 @@ out_unlock:
>  	nfs4_reset_creds(original_cred);
>  }
>  
> -typedef int (recdir_func)(struct dentry *, struct dentry *);
> +typedef int (recdir_func)(struct dentry *, struct dentry *, struct nfsd_net *);
>  
>  struct name_list {
>  	char name[HEXDIR_LEN];
> @@ -219,7 +219,7 @@ nfsd4_build_namelist(void *arg, const char *name, int namlen,
>  }
>  
>  static int
> -nfsd4_list_rec_dir(recdir_func *f)
> +nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
>  {
>  	const struct cred *original_cred;
>  	struct dentry *dir = rec_file->f_path.dentry;
> @@ -248,7 +248,7 @@ nfsd4_list_rec_dir(recdir_func *f)
>  				status = PTR_ERR(dentry);
>  				break;
>  			}
> -			status = f(dir, dentry);
> +			status = f(dir, dentry, nn);
>  			dput(dentry);
>  		}
>  		list_del(&entry->list);
> @@ -316,7 +316,7 @@ out:
>  }
>  
>  static int
> -purge_old(struct dentry *parent, struct dentry *child)
> +purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
>  {
>  	int status;
>  
> @@ -335,13 +335,14 @@ static void
>  nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
>  {
>  	int status;
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
>  	if (!rec_file)
>  		return;
>  	status = mnt_want_write_file(rec_file);
>  	if (status)
>  		goto out;
> -	status = nfsd4_list_rec_dir(purge_old);
> +	status = nfsd4_list_rec_dir(purge_old, nn);
>  	if (status == 0)
>  		vfs_fsync(rec_file, 0);
>  	mnt_drop_write_file(rec_file);
> @@ -352,7 +353,7 @@ out:
>  }
>  
>  static int
> -load_recdir(struct dentry *parent, struct dentry *child)
> +load_recdir(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
>  {
>  	if (child->d_name.len != HEXDIR_LEN - 1) {
>  		printk("nfsd4: illegal name %s in recovery directory\n",
> @@ -360,18 +361,19 @@ load_recdir(struct dentry *parent, struct dentry *child)
>  		/* Keep trying; maybe the others are OK: */
>  		return 0;
>  	}
> -	nfs4_client_to_reclaim(child->d_name.name);
> +	nfs4_client_to_reclaim(child->d_name.name, nn);
>  	return 0;
>  }
>  
>  static int
> -nfsd4_recdir_load(void) {
> +nfsd4_recdir_load(struct net *net) {
>  	int status;
> +	struct nfsd_net *nn =  net_generic(net, nfsd_net_id);
>  
>  	if (!rec_file)
>  		return 0;
>  
> -	status = nfsd4_list_rec_dir(load_recdir);
> +	status = nfsd4_list_rec_dir(load_recdir, nn);
>  	if (status)
>  		printk("nfsd4: failed loading clients from recovery"
>  			" directory %s\n", rec_file->f_path.dentry->d_name.name);
> @@ -413,6 +415,33 @@ nfsd4_init_recdir(void)
>  	return status;
>  }
>  
> +
> +static int
> +nfs4_legacy_state_init(struct net *net)
> +{
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +	int i;
> +
> +	nn->reclaim_str_hashtbl = kmalloc(sizeof(struct list_head) *
> +					  CLIENT_HASH_SIZE, GFP_KERNEL);
> +	if (!nn->reclaim_str_hashtbl)
> +		return -ENOMEM;
> +
> +	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> +		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
> +	nn->reclaim_str_hashtbl_size = 0;
> +
> +	return 0;
> +}
> +
> +static void
> +nfs4_legacy_state_shutdown(struct net *net)
> +{
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +
> +	kfree(nn->reclaim_str_hashtbl);
> +}
> +
>  static int
>  nfsd4_load_reboot_recovery_data(struct net *net)
>  {
> @@ -425,13 +454,23 @@ nfsd4_load_reboot_recovery_data(struct net *net)
>  		return -EINVAL;
>  	}
>  
> +	status = nfs4_legacy_state_init(net);
> +	if (status)
> +		return status;
> +

nit: might be clearer to create a new legacy ->init function and have
it call the state_init and then load the recovery data.

>  	nfs4_lock_state();
>  	status = nfsd4_init_recdir();
>  	if (!status)
> -		status = nfsd4_recdir_load();
> +		status = nfsd4_recdir_load(net);
>  	nfs4_unlock_state();
> -	if (status)
> +	if (status) {
>  		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
> +		goto err;
> +	}
> +	return 0;
> +
> +err:
> +	nfs4_legacy_state_shutdown(net);
>  	return status;
>  }
>  
> @@ -447,8 +486,9 @@ nfsd4_shutdown_recdir(void)
>  static void
>  nfsd4_legacy_tracking_exit(struct net *net)
>  {
> -	nfs4_release_reclaim();
> +	nfs4_release_reclaim(net);
>  	nfsd4_shutdown_recdir();
> +	nfs4_legacy_state_shutdown(net);
>  }
>  
>  /*
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 865a793..dc818f4 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -393,11 +393,6 @@ unhash_delegation(struct nfs4_delegation *dp)
>  /* client_lock protects the client lru list and session hash table */
>  static DEFINE_SPINLOCK(client_lock);
>  
> -/* Hash tables for nfs4_clientid state */
> -#define CLIENT_HASH_BITS                 4
> -#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
> -#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
> -
>  static unsigned int clientid_hashval(u32 id)
>  {
>  	return id & CLIENT_HASH_MASK;
> @@ -409,9 +404,6 @@ static unsigned int clientstr_hashval(const char *name)
>  }
>  
>  /*
> - * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
> - * used in reboot/reset lease grace period processing
> - *
>   * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
>   * setclientid_confirmed info. 
>   *
> @@ -424,8 +416,6 @@ static unsigned int clientstr_hashval(const char *name)
>   * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
>   * for last close replay.
>   */
> -static struct list_head	reclaim_str_hashtbl[CLIENT_HASH_SIZE];
> -static int reclaim_str_hashtbl_size = 0;
>  static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
> @@ -4502,7 +4492,7 @@ nfs4_has_reclaimed_state(const char *name)
>   * failure => all reset bets are off, nfserr_no_grace...
>   */
>  int
> -nfs4_client_to_reclaim(const char *name)
> +nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn)
>  {
>  	unsigned int strhashval;
>  	struct nfs4_client_reclaim *crp = NULL;
> @@ -4513,28 +4503,29 @@ nfs4_client_to_reclaim(const char *name)
>  		return 0;
>  	strhashval = clientstr_hashval(name);
>  	INIT_LIST_HEAD(&crp->cr_strhash);
> -	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
> +	list_add(&crp->cr_strhash, &nn->reclaim_str_hashtbl[strhashval]);
>  	memcpy(crp->cr_recdir, name, HEXDIR_LEN);
> -	reclaim_str_hashtbl_size++;
> +	nn->reclaim_str_hashtbl_size++;
>  	return 1;
>  }
>  
>  void
> -nfs4_release_reclaim(void)
> +nfs4_release_reclaim(struct net *net)
>  {
>  	struct nfs4_client_reclaim *crp = NULL;
>  	int i;
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
> -		while (!list_empty(&reclaim_str_hashtbl[i])) {
> -			crp = list_entry(reclaim_str_hashtbl[i].next,
> +		while (!list_empty(&nn->reclaim_str_hashtbl[i])) {
> +			crp = list_entry(nn->reclaim_str_hashtbl[i].next,
>  			                struct nfs4_client_reclaim, cr_strhash);
>  			list_del(&crp->cr_strhash);
>  			kfree(crp);
> -			reclaim_str_hashtbl_size--;
> +			nn->reclaim_str_hashtbl_size--;
>  		}
>  	}
> -	BUG_ON(reclaim_str_hashtbl_size);
> +	BUG_ON(nn->reclaim_str_hashtbl_size);
>  }
>  
>  /*
> @@ -4544,6 +4535,7 @@ nfsd4_find_reclaim_client(struct nfs4_client *clp)
>  {
>  	unsigned int strhashval;
>  	struct nfs4_client_reclaim *crp = NULL;
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  
>  	dprintk("NFSD: nfs4_find_reclaim_client for %.*s with recdir %s\n",
>  		            clp->cl_name.len, clp->cl_name.data,
> @@ -4551,7 +4543,7 @@ nfsd4_find_reclaim_client(struct nfs4_client *clp)
>  
>  	/* find clp->cl_name in reclaim_str_hashtbl */
>  	strhashval = clientstr_hashval(clp->cl_recdir);
> -	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
> +	list_for_each_entry(crp, &nn->reclaim_str_hashtbl[strhashval], cr_strhash) {
>  		if (same_name(crp->cr_recdir, clp->cl_recdir)) {
>  			return crp;
>  		}
> @@ -4711,7 +4703,6 @@ nfs4_state_init(void)
>  		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
> -		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
>  	}
>  	for (i = 0; i < SESSION_HASH_SIZE; i++)
>  		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
> @@ -4726,7 +4717,6 @@ nfs4_state_init(void)
>  	INIT_LIST_HEAD(&close_lru);
>  	INIT_LIST_HEAD(&client_lru);
>  	INIT_LIST_HEAD(&del_recall_lru);
> -	reclaim_str_hashtbl_size = 0;
>  }
>  
>  /*
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index b064577..da78804 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -466,7 +466,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
>  extern void nfs4_lock_state(void);
>  extern void nfs4_unlock_state(void);
>  extern int nfs4_in_grace(void);
> -extern void nfs4_release_reclaim(void);
> +extern void nfs4_release_reclaim(struct net *net);
>  extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct nfs4_client *crp);
>  extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
>  extern void nfs4_free_openowner(struct nfs4_openowner *);
> @@ -482,7 +482,7 @@ extern void nfsd4_destroy_callback_queue(void);
>  extern void nfsd4_shutdown_callback(struct nfs4_client *);
>  extern void nfs4_put_delegation(struct nfs4_delegation *dp);
>  extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
> -extern int nfs4_client_to_reclaim(const char *name);
> +extern int nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn);
>  extern int nfs4_has_reclaimed_state(const char *name);
>  extern void release_session_client(struct nfsd4_session *);
>  extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
> 

Looks like a reasonable and good change, but may need reconciling with
the patches from me that Bruce merged recently into his for-next tree.

-- 
Jeff Layton <jlayton@redhat.com>
