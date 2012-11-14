Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422805Ab2KNNVH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 08:21:07 -0500
Date: Wed, 14 Nov 2012 08:20:44 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/15] nfsd: make unconf_str_hashtbl allocated per net
Message-ID: <20121114082044.2a4ba128@tlielax.poochiereds.net>
In-Reply-To: <20121113154849.12577.37390.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
	<20121113154849.12577.37390.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Nov 2012 18:48:49 +0300
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> This hash holds nfs4_clients info, which are network namespace aware.
> So let's make it allocated per network namespace.
> 
> Note: this hash can be allocated in per-net operations. But it looks
> better to allocate it on nfsd state start and thus don't waste resources
> if server is not running.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfsd/netns.h     |    1 +
>  fs/nfsd/nfs4state.c |   34 +++++++++++++++++++---------------
>  2 files changed, 20 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 61f41c0..0577780 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -56,6 +56,7 @@ struct nfsd_net {
>  	int reclaim_str_hashtbl_size;
>  	struct list_head *conf_id_hashtbl;
>  	struct list_head *conf_str_hashtbl;
> +	struct list_head *unconf_str_hashtbl;
>  };
>  
>  extern int nfsd_net_id;
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a709dd2..7e44015 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -413,7 +413,6 @@ static unsigned int clientstr_hashval(const char *name)
>   * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
>   * for last close replay.
>   */
> -static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head client_lru;
>  static struct list_head close_lru;
> @@ -1314,8 +1313,9 @@ static void
>  add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
>  {
>  	unsigned int idhashval;
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  
> -	list_add(&clp->cl_strhash, &unconf_str_hashtbl[strhashval]);
> +	list_add(&clp->cl_strhash, &nn->unconf_str_hashtbl[strhashval]);
>  	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
>  	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
>  	renew_client(clp);
> @@ -1387,11 +1387,12 @@ find_confirmed_client_by_str(const char *dname, unsigned int hashval,
>  }
>  
>  static struct nfs4_client *
> -find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
> +find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
> +			       struct nfsd_net *nn)
>  {
>  	struct nfs4_client *clp;
>  
> -	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
> +	list_for_each_entry(clp, &nn->unconf_str_hashtbl[hashval], cl_strhash) {
>  		if (same_name(clp->cl_recdir, dname))
>  			return clp;
>  	}
> @@ -1643,7 +1644,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		goto out;
>  	}
>  
> -	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
> +	unconf  = find_unconfirmed_client_by_str(dname, strhashval, nn);
>  	if (unconf) /* case 4, possible retry or client restart */
>  		expire_client(unconf);
>  
> @@ -2215,7 +2216,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  			goto out;
>  		}
>  	}
> -	unconf = find_unconfirmed_client_by_str(dname, strhashval);
> +	unconf = find_unconfirmed_client_by_str(dname, strhashval, nn);
>  	if (unconf)
>  		expire_client(unconf);
>  	status = nfserr_jukebox;
> @@ -4700,7 +4701,6 @@ nfs4_state_init(void)
>  	int i;
>  
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
> -		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
>  	}
>  	for (i = 0; i < SESSION_HASH_SIZE; i++)
> @@ -4752,14 +4752,21 @@ static int nfs4_state_start_net(struct net *net)
>  			CLIENT_HASH_SIZE, GFP_KERNEL);
>  	if (!nn->conf_str_hashtbl)
>  		goto err_conf_str;
> +	nn->unconf_str_hashtbl = kmalloc(sizeof(struct list_head) *
> +			CLIENT_HASH_SIZE, GFP_KERNEL);
> +	if (!nn->unconf_str_hashtbl)
> +		goto err_unconf_str;
>  
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
>  		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
>  		INIT_LIST_HEAD(&nn->conf_str_hashtbl[i]);
> +		INIT_LIST_HEAD(&nn->unconf_str_hashtbl[i]);
>  	}
>  
>  	return 0;
>  
> +err_unconf_str:
> +	kfree(nn->conf_str_hashtbl);
>  err_conf_str:
>  	kfree(nn->conf_id_hashtbl);
>  err:
> @@ -4778,7 +4785,12 @@ __nfs4_state_shutdown_net(struct net *net)
>  			clp = list_entry(nn->conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
>  			destroy_client(clp);
>  		}
> +		while (!list_empty(&nn->unconf_str_hashtbl[i])) {
> +			clp = list_entry(nn->unconf_str_hashtbl[i].next, struct nfs4_client, cl_strhash);
> +			destroy_client(clp);
> +		}
>  	}
> +	kfree(nn->unconf_str_hashtbl);
>  	kfree(nn->conf_str_hashtbl);
>  	kfree(nn->conf_id_hashtbl);
>  }
> @@ -4837,19 +4849,11 @@ out_recovery:
>  static void
>  __nfs4_state_shutdown(struct net *net)
>  {
> -	int i;
> -	struct nfs4_client *clp = NULL;
>  	struct nfs4_delegation *dp = NULL;
>  	struct list_head *pos, *next, reaplist;
>  
>  	__nfs4_state_shutdown_net(net);
>  
> -	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
> -		while (!list_empty(&unconf_str_hashtbl[i])) {
> -			clp = list_entry(unconf_str_hashtbl[i].next, struct nfs4_client, cl_strhash);
> -			destroy_client(clp);
> -		}
> -	}
>  	INIT_LIST_HEAD(&reaplist);
>  	spin_lock(&recall_lock);
>  	list_for_each_safe(pos, next, &del_recall_lru) {
> 

This too will need to be rebased on top of nfsd-next tree. This
hashtable has also been turned into a rbtree for the same reasons as the
conf_str_hashtbl.

-- 
Jeff Layton <jlayton@redhat.com>
