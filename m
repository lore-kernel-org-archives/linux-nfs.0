Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36198 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbaHDVSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 17:18:53 -0400
Date: Mon, 4 Aug 2014 17:18:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 09/37] nfsd: Add lockdep assertions to document the
 nfs4_client/session locking
Message-ID: <20140804211845.GI23341@fieldses.org>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
 <1406723258-8512-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406723258-8512-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have these queued for 3.17 up through this patch; I'll continue
working through these tomorrow.

(In my git tree, anything in the for-3.17 branch I consider committed,
anything in nfsd-next is stuff I'm still considering for this merge
window but may not really have reviewed yet.)

--b.

On Wed, Jul 30, 2014 at 08:27:10AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f9d077d800ee..e7dfd4e9d942 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -139,6 +139,10 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
>  
>  static __be32 get_client_locked(struct nfs4_client *clp)
>  {
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	if (is_client_expired(clp))
>  		return nfserr_expired;
>  	atomic_inc(&clp->cl_refcount);
> @@ -179,6 +183,10 @@ renew_client(struct nfs4_client *clp)
>  
>  static void put_client_renew_locked(struct nfs4_client *clp)
>  {
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	if (!atomic_dec_and_test(&clp->cl_refcount))
>  		return;
>  	if (!is_client_expired(clp))
> @@ -212,6 +220,9 @@ static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
>  static void nfsd4_put_session_locked(struct nfsd4_session *ses)
>  {
>  	struct nfs4_client *clp = ses->se_client;
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	lockdep_assert_held(&nn->client_lock);
>  
>  	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
>  		free_session(ses);
> @@ -1453,6 +1464,8 @@ __find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
>  	int idx;
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	dump_sessionid(__func__, sessionid);
>  	idx = hash_sessionid(sessionid);
>  	/* Search in the appropriate list */
> @@ -1489,6 +1502,11 @@ out:
>  static void
>  unhash_session(struct nfsd4_session *ses)
>  {
> +	struct nfs4_client *clp = ses->se_client;
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	list_del(&ses->se_hash);
>  	spin_lock(&ses->se_client->cl_lock);
>  	list_del(&ses->se_perclnt);
> @@ -1575,6 +1593,8 @@ unhash_client_locked(struct nfs4_client *clp)
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  	struct nfsd4_session *ses;
>  
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	/* Mark the client as expired! */
>  	clp->cl_time = 0;
>  	/* Make it invisible */
> @@ -1906,6 +1926,8 @@ add_to_unconfirmed(struct nfs4_client *clp)
>  	unsigned int idhashval;
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	clear_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
>  	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
>  	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
> @@ -1919,6 +1941,8 @@ move_to_confirmed(struct nfs4_client *clp)
>  	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
>  	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
>  	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
> @@ -1949,6 +1973,7 @@ find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
>  {
>  	struct list_head *tbl = nn->conf_id_hashtbl;
>  
> +	lockdep_assert_held(&nn->client_lock);
>  	return find_client_in_id_table(tbl, clid, sessions);
>  }
>  
> @@ -1957,6 +1982,7 @@ find_unconfirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
>  {
>  	struct list_head *tbl = nn->unconf_id_hashtbl;
>  
> +	lockdep_assert_held(&nn->client_lock);
>  	return find_client_in_id_table(tbl, clid, sessions);
>  }
>  
> @@ -1968,12 +1994,14 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
>  static struct nfs4_client *
>  find_confirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
>  {
> +	lockdep_assert_held(&nn->client_lock);
>  	return find_clp_in_name_tree(name, &nn->conf_name_tree);
>  }
>  
>  static struct nfs4_client *
>  find_unconfirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
>  {
> +	lockdep_assert_held(&nn->client_lock);
>  	return find_clp_in_name_tree(name, &nn->unconf_name_tree);
>  }
>  
> @@ -4907,6 +4935,8 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
>  	unsigned int strhashval = ownerstr_hashval(owner);
>  	struct nfs4_stateowner *so;
>  
> +	lockdep_assert_held(&clp->cl_lock);
> +
>  	list_for_each_entry(so, &clp->cl_ownerstr_hashtbl[strhashval],
>  			    so_strhash) {
>  		if (so->so_is_open_owner)
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
