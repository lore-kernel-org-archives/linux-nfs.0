Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42920 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030248AbbD1Qbo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 12:31:44 -0400
Date: Tue, 28 Apr 2015 12:31:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: two odstate optimizations
Message-ID: <20150428163143.GO4083@fieldses.org>
References: <1430222449-3921-1-git-send-email-hch@lst.de>
 <20150428085006.7d4b9708@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150428085006.7d4b9708@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 08:50:06AM -0400, Jeff Layton wrote:
> On Tue, 28 Apr 2015 14:00:47 +0200
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > Two small optimizations for the odstate handling.  Feel free to squash them
> > into "nfsd: fix pNFS return on close semantics" if you need to rebase anyway.
> > 
> 
> Both look good to me!
> 
> Acked-by: Jeff Layton <jeff.layton@primarydata.com>

Thanks, I've currently got the following.--b.

commit 31f354f575ac
Author: Sachin Bhamare <sachin.bhamare@primarydata.com>
Date:   Mon Apr 27 14:50:14 2015 +0200

    nfsd: fix pNFS return on close semantics
    
    For the sake of forgetful clients, the server should return the layouts
    to the file system on 'last close' of a file (assuming that there are no
    delegations outstanding to that particular client) or on delegreturn
    (assuming that there are no opens on a file from that particular
    client).
    
    In theory the information is all there in current data structures, but
    it's not efficiently available; nfs4_file->fi_ref includes references on
    the file across all clients, but we need a per-(client, file) count.
    Walking through lots of stateid's to calculate this on each close or
    delegreturn would be painful.
    
    This patch introduces infrastructure to maintain per-client opens and
    delegation counters on a per-file basis.
    
    [hch: ported to the mainline pNFS support, merged various fixes from Jeff]
    Signed-off-by: Sachin Bhamare <sachin.bhamare@primarydata.com>
    Signed-off-by: Jeff Layton <jlayton@primarydata.com>
    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 38f2d7abe3a7..907296476846 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -94,6 +94,7 @@ static struct kmem_cache *lockowner_slab;
 static struct kmem_cache *file_slab;
 static struct kmem_cache *stateid_slab;
 static struct kmem_cache *deleg_slab;
+static struct kmem_cache *odstate_slab;
 
 static void free_session(struct nfsd4_session *);
 
@@ -281,6 +282,7 @@ put_nfs4_file(struct nfs4_file *fi)
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del_rcu(&fi->fi_hash);
 		spin_unlock(&state_lock);
+		WARN_ON_ONCE(!list_empty(&fi->fi_clnt_odstate));
 		WARN_ON_ONCE(!list_empty(&fi->fi_delegations));
 		call_rcu(&fi->fi_rcu, nfsd4_free_file_rcu);
 	}
@@ -471,6 +473,86 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_put_access(fp, O_RDONLY);
 }
 
+/*
+ * Allocate a new open/delegation state counter. This is needed for
+ * pNFS for proper return on close semantics.
+ *
+ * Note that we only allocate it for pNFS-enabled exports, otherwise
+ * all pointers to struct nfs4_clnt_odstate are always NULL.
+ */
+static struct nfs4_clnt_odstate *
+alloc_clnt_odstate(struct nfs4_client *clp)
+{
+	struct nfs4_clnt_odstate *co;
+
+	co = kmem_cache_zalloc(odstate_slab, GFP_KERNEL);
+	if (co) {
+		co->co_client = clp;
+		atomic_set(&co->co_odcount, 1);
+	}
+	return co;
+}
+
+static void
+hash_clnt_odstate_locked(struct nfs4_clnt_odstate *co)
+{
+	struct nfs4_file *fp = co->co_file;
+
+	lockdep_assert_held(&fp->fi_lock);
+	list_add(&co->co_perfile, &fp->fi_clnt_odstate);
+}
+
+static inline void
+get_clnt_odstate(struct nfs4_clnt_odstate *co)
+{
+	if (co)
+		atomic_inc(&co->co_odcount);
+}
+
+static void
+put_clnt_odstate(struct nfs4_clnt_odstate *co)
+{
+	struct nfs4_file *fp;
+
+	if (!co)
+		return;
+
+	fp = co->co_file;
+	if (atomic_dec_and_lock(&co->co_odcount, &fp->fi_lock)) {
+		list_del(&co->co_perfile);
+		spin_unlock(&fp->fi_lock);
+
+		nfsd4_return_all_file_layouts(co->co_client, fp);
+		kmem_cache_free(odstate_slab, co);
+	}
+}
+
+static struct nfs4_clnt_odstate *
+find_or_hash_clnt_odstate(struct nfs4_file *fp, struct nfs4_clnt_odstate *new)
+{
+	struct nfs4_clnt_odstate *co;
+	struct nfs4_client *cl;
+
+	if (!new)
+		return NULL;
+
+	cl = new->co_client;
+
+	spin_lock(&fp->fi_lock);
+	list_for_each_entry(co, &fp->fi_clnt_odstate, co_perfile) {
+		if (co->co_client == cl) {
+			get_clnt_odstate(co);
+			goto out;
+		}
+	}
+	co = new;
+	co->co_file = fp;
+	hash_clnt_odstate_locked(new);
+out:
+	spin_unlock(&fp->fi_lock);
+	return co;
+}
+
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 					 struct kmem_cache *slab)
 {
@@ -606,7 +688,8 @@ static void block_delegations(struct knfsd_fh *fh)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
+alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh,
+		 struct nfs4_clnt_odstate *odstate)
 {
 	struct nfs4_delegation *dp;
 	long n;
@@ -631,6 +714,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
+	dp->dl_clnt_odstate = odstate;
+	get_clnt_odstate(odstate);
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	dp->dl_retries = 1;
 	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
@@ -714,6 +799,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	spin_lock(&state_lock);
 	unhash_delegation_locked(dp);
 	spin_unlock(&state_lock);
+	put_clnt_odstate(dp->dl_clnt_odstate);
 	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 	nfs4_put_stid(&dp->dl_stid);
 }
@@ -724,6 +810,7 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 
 	WARN_ON(!list_empty(&dp->dl_recall_lru));
 
+	put_clnt_odstate(dp->dl_clnt_odstate);
 	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 
 	if (clp->cl_minorversion == 0)
@@ -933,6 +1020,7 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 {
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
+	put_clnt_odstate(stp->st_clnt_odstate);
 	release_all_access(stp);
 	if (stp->st_stateowner)
 		nfs4_put_stateowner(stp->st_stateowner);
@@ -1634,6 +1722,7 @@ __destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
+		put_clnt_odstate(dp->dl_clnt_odstate);
 		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 		nfs4_put_stid(&dp->dl_stid);
 	}
@@ -3057,6 +3146,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
+	INIT_LIST_HEAD(&fp->fi_clnt_odstate);
 	fh_copy_shallow(&fp->fi_fhandle, fh);
 	fp->fi_deleg_file = NULL;
 	fp->fi_had_conflict = false;
@@ -3073,6 +3163,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 void
 nfsd4_free_slabs(void)
 {
+	kmem_cache_destroy(odstate_slab);
 	kmem_cache_destroy(openowner_slab);
 	kmem_cache_destroy(lockowner_slab);
 	kmem_cache_destroy(file_slab);
@@ -3103,8 +3194,14 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
 		goto out_free_stateid_slab;
+	odstate_slab = kmem_cache_create("nfsd4_odstate",
+			sizeof(struct nfs4_clnt_odstate), 0, 0, NULL);
+	if (odstate_slab == NULL)
+		goto out_free_deleg_slab;
 	return 0;
 
+out_free_deleg_slab:
+	kmem_cache_destroy(deleg_slab);
 out_free_stateid_slab:
 	kmem_cache_destroy(stateid_slab);
 out_free_file_slab:
@@ -3581,6 +3678,14 @@ alloc_stateid:
 	open->op_stp = nfs4_alloc_open_stateid(clp);
 	if (!open->op_stp)
 		return nfserr_jukebox;
+
+	if (nfsd4_has_session(cstate) &&
+	    (cstate->current_fh.fh_export->ex_flags & NFSEXP_PNFS)) {
+		open->op_odstate = alloc_clnt_odstate(clp);
+		if (!open->op_odstate)
+			return nfserr_jukebox;
+	}
+
 	return nfs_ok;
 }
 
@@ -3869,7 +3974,7 @@ out_fput:
 
 static struct nfs4_delegation *
 nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
-		    struct nfs4_file *fp)
+		    struct nfs4_file *fp, struct nfs4_clnt_odstate *odstate)
 {
 	int status;
 	struct nfs4_delegation *dp;
@@ -3877,7 +3982,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 	if (fp->fi_had_conflict)
 		return ERR_PTR(-EAGAIN);
 
-	dp = alloc_init_deleg(clp, fh);
+	dp = alloc_init_deleg(clp, fh, odstate);
 	if (!dp)
 		return ERR_PTR(-ENOMEM);
 
@@ -3903,6 +4008,7 @@ out_unlock:
 	spin_unlock(&state_lock);
 out:
 	if (status) {
+		put_clnt_odstate(dp->dl_clnt_odstate);
 		nfs4_put_stid(&dp->dl_stid);
 		return ERR_PTR(status);
 	}
@@ -3980,7 +4086,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file);
+	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file, stp->st_clnt_odstate);
 	if (IS_ERR(dp))
 		goto out_no_deleg;
 
@@ -4069,6 +4175,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			release_open_stateid(stp);
 			goto out;
 		}
+
+		stp->st_clnt_odstate = find_or_hash_clnt_odstate(fp,
+							open->op_odstate);
+		if (stp->st_clnt_odstate == open->op_odstate)
+			open->op_odstate = NULL;
 	}
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
@@ -4129,6 +4240,8 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 		kmem_cache_free(file_slab, open->op_file);
 	if (open->op_stp)
 		nfs4_put_stid(&open->op_stp->st_stid);
+	if (open->op_odstate)
+		kmem_cache_free(odstate_slab, open->op_odstate);
 }
 
 __be32
@@ -4852,9 +4965,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-	nfsd4_return_all_file_layouts(stp->st_stateowner->so_client,
-				      stp->st_stid.sc_file);
-
 	nfsd4_close_open_stateid(stp);
 
 	/* put reference from nfs4_preprocess_seqid_op */
@@ -6488,6 +6598,7 @@ nfs4_state_shutdown_net(struct net *net)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
+		put_clnt_odstate(dp->dl_clnt_odstate);
 		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 		nfs4_put_stid(&dp->dl_stid);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4f3bfeb11766..bde45d90b746 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -126,6 +126,7 @@ struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
+	struct nfs4_clnt_odstate *dl_clnt_odstate;
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
@@ -465,6 +466,17 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 }
 
 /*
+ * Per-client state indicating no. of opens and outstanding delegations
+ * on a file from a particular client.'od' stands for 'open & delegation'
+ */
+struct nfs4_clnt_odstate {
+	struct nfs4_client	*co_client;
+	struct nfs4_file	*co_file;
+	struct list_head	co_perfile;
+	atomic_t		co_odcount;
+};
+
+/*
  * nfs4_file: a file opened by some number of (open) nfs4_stateowners.
  *
  * These objects are global. nfsd keeps one instance of a nfs4_file per
@@ -485,6 +497,7 @@ struct nfs4_file {
 		struct list_head	fi_delegations;
 		struct rcu_head		fi_rcu;
 	};
+	struct list_head	fi_clnt_odstate;
 	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
 	struct file *		fi_fds[3];
 	/*
@@ -526,6 +539,7 @@ struct nfs4_ol_stateid {
 	struct list_head              st_perstateowner;
 	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
+	struct nfs4_clnt_odstate    * st_clnt_odstate;
 	unsigned char                 st_access_bmap;
 	unsigned char                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index f982ae84f0cd..2f8c092be2b3 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -247,6 +247,7 @@ struct nfsd4_open {
 	struct nfs4_openowner *op_openowner; /* used during processing */
 	struct nfs4_file *op_file;          /* used during processing */
 	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
+	struct nfs4_clnt_odstate *op_odstate; /* used during processing */
 	struct nfs4_acl *op_acl;
 	struct xdr_netobj op_label;
 };
