Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:54871 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:32 -0400
Received: by mail-qe0-f45.google.com with SMTP id 6so1088064qea.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:31 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 24/49] pnfsd: process the layout stateid
Date: Thu, 26 Sep 2013 14:41:29 -0400
Message-Id: <1380220889-13778-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@umich.edu>

Common function for LAYOUTGET and LAYOUTRETURN layout stateid processing.

The 'first open, delegation, or lock stateid' presented by the client is
looked up for verification.

Both initial and non-initial parallel LAYOUTGET operations and parallel
LAYOUTRETURN operations are supported.

Note: layout stateid seqid checking is more lax than that specified in
draft-ietf-nfsv4-minorversion1-22 for Connectathon.

Take a reference count whenever the pointer to the layout state
is kept, in particular when the layout structure is listed on the
state's ls_layouts.  On dequeue_layout the layout state if being put
and its reference count will drop to zero if the list empties
unless someone's holding a reference transiently within the scope
of teh calling function, in which case the layout state is dereferenced
before the function exits.

Note: the layout stateid must be updated by layout get only
on success upon changing the actual state, otherwise,
a parallel layout_recall will send the wrong stateid.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: nfs4_process_layout_stateid print result stateid conditionally]
[pnfsd: use STATEID_FMT and STATEID_VAL for printing stateids]
[pnfsd: debug print layout stateid before putting the layout_state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: fix layout state reference count]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[used nfs4_check_stateid in nfs4_process_layout_stateid]
[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: use a spinlock for layout state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Move pnfsd code out of nfs4state.c/h]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[moved defs back into state.h]
[verify_stateid's return status is __be32]
[update layout stateid properly]
[convert to using 3.2 layout state infrastructure]
[squashed Helper functions for layout stateid processing]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Update the reference of nfs4_layout_state properly]
Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
[pnfsd: use nfsd_net for layoutget starting v3.8]
[do not hang layouts on lo_state yet]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
[pnfsd: LAYOUTGET layout stateid processing]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: nfs4_process_layout_stateid: replace do_alloc with typemask]
Signed-off-by: Nadav Shemer <nadav@primarydata.com>
Massaged-by: Lev Solomonov <solo@primarydata.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c | 14 +++++------
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/state.h     |  2 ++
 4 files changed, 79 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 82b6a7d..e28c396 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -164,6 +164,64 @@ struct sbid_tracker {
 	kref_put(&ls->ls_ref, destroy_layout_state);
 }
 
+/*
+ * We have looked up the nfs4_file corresponding to the current_fh, and
+ * confirmed the clientid. Pull the few tests from nfs4_preprocess_stateid_op()
+ * that make sense with a layout stateid.
+ *
+ * If the layout state was found in cache, grab a reference count on it;
+ * otherwise, allocate a new layout state if "do_alloc" is set.
+ *
+ * Called with the state_lock held
+ * Returns zero and stateid is updated, or error.
+ */
+static __be32
+nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+			    stateid_t *stateid, unsigned char typemask,
+			    struct nfs4_layout_state **lsp)
+{
+	struct nfs4_layout_state *ls = NULL;
+	__be32 status = 0;
+	struct nfs4_stid *stid;
+
+	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
+		__func__, clp, fp, STATEID_VAL(stateid));
+
+	nfs4_assert_state_locked();
+	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
+				      net_generic(clp->net, nfsd_net_id));
+	if (status)
+		goto out;
+
+	/* Is this the first use of this layout ? */
+	if (stid->sc_type != NFS4_LAYOUT_STID) {
+		ls = alloc_init_layout_state(clp, stateid);
+		if (!ls) {
+			status = nfserr_jukebox;
+			goto out;
+		}
+	} else {
+		ls = container_of(stid, struct nfs4_layout_state, ls_stid);
+
+		/* BAD STATEID */
+		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
+			dprintk("%s bad stateid 1\n", __func__);
+			status = nfserr_bad_stateid;
+			goto out;
+		}
+		get_layout_state(ls);
+	}
+	status = 0;
+
+	*lsp = ls;
+	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
+		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
+out:
+	dprintk("<-- %s status %d\n", __func__, htonl(status));
+
+	return status;
+}
+
 static struct nfs4_layout *
 alloc_layout(void)
 {
@@ -275,6 +333,7 @@ struct super_block *
 	struct nfs4_file *fp;
 	struct nfs4_client *clp;
 	struct nfs4_layout *lp = NULL;
+	struct nfs4_layout_state *ls = NULL;
 	struct nfsd4_pnfs_layoutget_arg args = {
 		.lg_minlength = lgp->lg_minlength,
 		.lg_fh = &lgp->lg_fhp->fh_handle,
@@ -320,6 +379,14 @@ struct super_block *
 		goto out_unlock;
 	}
 
+	/* Check decoded layout stateid */
+	nfserr = nfs4_process_layout_stateid(clp, fp, &lgp->lg_sid,
+					     (NFS4_OPEN_STID | NFS4_LOCK_STID |
+					      NFS4_DELEG_STID | NFS4_LAYOUT_STID),
+					     &ls);
+	if (nfserr)
+		goto out_unlock;
+
 	lp = alloc_layout();
 	if (!lp) {
 		nfserr = nfserr_layouttrylater;
@@ -378,6 +445,8 @@ struct super_block *
 
 	init_layout(lp, &res.lg_seg);
 out_unlock:
+	if (ls)
+		put_layout_state(ls);
 	nfs4_unlock_state();
 	if (fp)
 		put_nfs4_file(fp);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6e251fb..fa292bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1313,7 +1313,7 @@ static void gen_confirm(struct nfs4_client *clp)
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+struct nfs4_stid *nfsd4_find_stateid(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
@@ -1328,7 +1328,7 @@ static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t
 {
 	struct nfs4_stid *s;
 
-	s = find_stateid(cl, t);
+	s = nfsd4_find_stateid(cl, t);
 	if (!s)
 		return NULL;
 	if (typemask & s->sc_type)
@@ -3617,7 +3617,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 					"with incorrect client ID\n", addr_str);
 		return nfserr_bad_stateid;
 	}
-	s = find_stateid(cl, stateid);
+	s = nfsd4_find_stateid(cl, stateid);
 	if (!s)
 		return nfserr_bad_stateid;
 	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
@@ -3643,9 +3643,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	}
 }
 
-static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
-				   struct nfs4_stid **s, bool sessions,
-				   struct nfsd_net *nn)
+__be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
+			    struct nfs4_stid **s, bool sessions,
+			    struct nfsd_net *nn)
 {
 	struct nfs4_client *cl;
 	__be32 status;
@@ -3779,7 +3779,7 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 	__be32 ret = nfserr_bad_stateid;
 
 	nfs4_lock_state();
-	s = find_stateid(cl, stateid);
+	s = nfsd4_find_stateid(cl, stateid);
 	if (!s)
 		goto out;
 	switch (s->sc_type) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1cc19cd..b9c4417 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3829,7 +3829,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	if (xdr.end - xdr.p > exp_xdr_qwords(maxcount & ~3))
 		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
 
-	/* Retrieve, encode, and merge layout */
+	/* Retrieve, encode, and merge layout; process stateid */
 	nfserr = nfs4_pnfs_get_layout(resp->rqstp, lgp, &xdr);
 	if (nfserr)
 		goto err;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 18a64c4..8c6e097 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -490,6 +490,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern struct nfs4_stid *nfsd4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
 extern void nfsd4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s);
 extern void nfsd4_remove_stid(struct nfs4_stid *s);
+extern struct nfs4_stid *nfsd4_find_stateid(struct nfs4_client *, stateid_t *);
+extern __be32 nfsd4_lookup_stateid(stateid_t *, unsigned char typemask, struct nfs4_stid **, bool sessions, struct nfsd_net *);
 
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
-- 
1.8.3.1

