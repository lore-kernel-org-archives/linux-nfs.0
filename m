Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:48619 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:40 -0400
Received: by mail-qe0-f45.google.com with SMTP id 6so1099819qea.4
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:39 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 26/49] pnfsd: layout state per file tracking
Date: Thu, 26 Sep 2013 14:41:37 -0400
Message-Id: <1380220897-13872-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 15 +++++++++++----
 fs/nfsd/nfs4state.c |  3 +++
 fs/nfsd/pnfsd.h     |  2 ++
 fs/nfsd/state.h     |  3 +++
 4 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2d5ddf7..2c5d30d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -120,7 +120,8 @@ struct sbid_tracker {
  * Note: must be called under the state lock
  */
 static struct nfs4_layout_state *
-alloc_init_layout_state(struct nfs4_client *clp, stateid_t *stateid)
+alloc_init_layout_state(struct nfs4_client *clp, struct nfs4_file *fp,
+			stateid_t *stateid)
 {
 	struct nfs4_layout_state *new;
 
@@ -131,9 +132,13 @@ struct sbid_tracker {
 	kref_init(&new->ls_ref);
 	new->ls_stid.sc_type = NFS4_LAYOUT_STID;
 	INIT_LIST_HEAD(&new->ls_perclnt);
+	INIT_LIST_HEAD(&new->ls_perfile);
 	new->ls_client = clp;
+	get_nfs4_file(fp);	/* released on destroy_layout_state */
+	new->ls_file = fp;
 	spin_lock(&layout_lock);
 	list_add(&new->ls_perclnt, &clp->cl_lo_states);
+	list_add(&new->ls_perfile, &fp->fi_lo_states);
 	spin_unlock(&layout_lock);
 	return new;
 }
@@ -149,6 +154,7 @@ struct sbid_tracker {
 {
 	ASSERT_LAYOUT_LOCKED();
 	list_del_init(&ls->ls_perclnt);
+	list_del_init(&ls->ls_perfile);
 }
 
 /*
@@ -166,6 +172,7 @@ struct sbid_tracker {
 		unhash_layout_state(ls);
 		spin_unlock(&layout_lock);
 	}
+	put_nfs4_file(ls->ls_file);
 	nfsd4_free_stid(layout_state_slab, &ls->ls_stid);
 }
 
@@ -212,7 +219,7 @@ struct sbid_tracker {
 
 	/* Is this the first use of this layout ? */
 	if (stid->sc_type != NFS4_LAYOUT_STID) {
-		ls = alloc_init_layout_state(clp, stateid);
+		ls = alloc_init_layout_state(clp, fp, stateid);
 		if (!ls) {
 			status = nfserr_jukebox;
 			goto out;
@@ -266,8 +273,8 @@ static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t
 	    struct nfsd4_layout_seg *seg,
 	    stateid_t *stateid)
 {
-	dprintk("pNFS %s: lp %p ls %p\n", __func__,
-		lp, ls);
+	dprintk("pNFS %s: lp %p ls %p ino %lu\n", __func__,
+		lp, ls, ls->ls_file->fi_inode->i_ino);
 
 	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
 	get_layout_state(ls);		/* put on destroy_layout */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0e2266f..e11d96f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2509,6 +2509,9 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
+#if defined(CONFIG_PNFSD)
+	INIT_LIST_HEAD(&fp->fi_lo_states);
+#endif /* CONFIG_PNFSD */
 	spin_lock(&recall_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
 	spin_unlock(&recall_lock);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index a0363a7..852c250 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -46,6 +46,8 @@ struct nfs4_layout_state {
 	struct kref		ls_ref;
 	struct list_head	ls_perclnt;
 	struct nfs4_client	*ls_client;
+	struct list_head	ls_perfile;
+	struct nfs4_file	*ls_file;
 };
 
 /* outstanding layout */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 187d169..1ef09ae 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -405,6 +405,9 @@ struct nfs4_file {
 	atomic_t		fi_delegees;
 	struct inode		*fi_inode;
 	bool			fi_had_conflict;
+#if defined(CONFIG_PNFSD)
+	struct list_head	fi_lo_states;
+#endif /* CONFIG_PNFSD */
 };
 
 /* XXX: for first cut may fall back on returning file that doesn't work
-- 
1.8.3.1

