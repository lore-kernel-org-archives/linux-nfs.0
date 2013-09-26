Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:35416 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3IZSnO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:43:14 -0400
Received: by mail-qa0-f49.google.com with SMTP id k15so1106524qaq.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:43:13 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 48/49] pnfsd: return on close
Date: Thu, 26 Sep 2013 14:43:10 -0400
Message-Id: <1380220990-14898-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simulate layout_return and remove all layouts held by the client closing the file.

pnfs_return_file_layouts is used as if the client returned its layout for the
file with RETURN_FILE and <IOMODE_ANY, offset=0, length=NFS4_MAX_UINT64>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c |  2 ++
 fs/nfsd/pnfsd.h     |  1 +
 fs/nfsd/state.h     |  2 ++
 4 files changed, 52 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d18e2a1..57ca89f 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -137,6 +137,7 @@ struct sbid_tracker {
 	new->ls_client = clp;
 	get_nfs4_file(fp);	/* released on destroy_layout_state */
 	new->ls_file = fp;
+	new->ls_roc = false;
 	spin_lock(&layout_lock);
 	list_add(&new->ls_perclnt, &clp->cl_lo_states);
 	list_add(&new->ls_perfile, &fp->fi_lo_states);
@@ -269,6 +270,15 @@ static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t
 		__func__, sid->si_generation, ls);
 }
 
+static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
+{
+	if (roc) {
+		ls->ls_roc = true;
+		dprintk("%s: Marked return_on_close on layoutstate %p\n",
+			__func__, ls);
+	}
+}
+
 static void
 init_layout(struct nfs4_layout *lp,
 	    struct nfs4_layout_state *ls,
@@ -631,6 +641,7 @@ struct super_block *
 
 	lgp->lg_seg = res.lg_seg;
 	lgp->lg_roc = res.lg_return_on_close;
+	update_layout_roc(ls, res.lg_return_on_close);
 
 	/* SUCCESS!
 	 * Can the new layout be merged into an existing one?
@@ -884,3 +895,39 @@ void pnfs_expire_client(struct nfs4_client *clp)
 
 	destroy_layout_list(&lo_destroy_list);
 }
+
+/* Return On Close:
+ *   Look for all layouts of @fp that belong to @clp, remove
+ *   the layout and simulate a layout_return. Surly the client has forgotten
+ *   these layouts or it would return them before the close.
+ *
+ * Note: must be called under the state lock
+ */
+void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
+{
+	struct nfsd4_pnfs_layoutreturn lr = {
+		.args.lr_return_type = RETURN_FILE,
+		.args.lr_seg = {
+			.iomode = IOMODE_ANY,
+			.offset = 0,
+			.length = NFS4_MAX_UINT64,
+		},
+	};
+	LIST_HEAD(lo_destroy_list);
+	struct nfs4_layout_state *ls;
+
+	nfs4_assert_state_locked();
+
+	spin_lock(&layout_lock);
+	list_for_each_entry (ls, &fp->fi_lo_states, ls_perfile) {
+		if (ls->ls_client != clp)
+			continue;
+		spin_unlock(&layout_lock);
+		pnfs_return_file_layouts(&lr, ls, &lo_destroy_list);
+		goto out;
+	}
+	spin_unlock(&layout_lock);
+
+out:
+	destroy_layout_list(&lo_destroy_list);
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 600edbc..5568f3d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4081,6 +4081,8 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
+	pnfsd_roc(stp->st_stateowner->so_client, stp->st_file);
+
 	nfsd4_close_open_stateid(stp);
 
 	if (cstate->minorversion)
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 7ced4f3..af6842e 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -49,6 +49,7 @@ struct nfs4_layout_state {
 	struct list_head	ls_perfile;
 	struct nfs4_file	*ls_file;
 	struct list_head	ls_layouts;
+	bool			ls_roc;
 };
 
 /* outstanding layout */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 90ec8b9..7d9c724 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -507,10 +507,12 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern int nfsd4_init_pnfs_slabs(void);
 extern void nfsd4_free_pnfs_slabs(void);
 extern void pnfs_expire_client(struct nfs4_client *);
+extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
 static inline void pnfs_expire_client(struct nfs4_client *clp) {}
+static inline void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp) {}
 #endif /* CONFIG_PNFSD */
 
 static inline u64
-- 
1.8.3.1

