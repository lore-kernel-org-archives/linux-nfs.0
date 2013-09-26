Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:60123 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3IZSmy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:54 -0400
Received: by mail-qe0-f45.google.com with SMTP id 6so1115822qea.32
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:53 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in put_nfs4_file
Date: Thu, 26 Sep 2013 14:42:48 -0400
Message-Id: <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

we don't want to hold the state_lock while the file system may block

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c |  4 +++-
 fs/nfsd/nfs4state.c | 34 +++++++++++++++++++++++++++++++---
 fs/nfsd/state.h     |  1 +
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 8d16b85..1807455 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -166,6 +166,7 @@ struct sbid_tracker {
 {
 	struct nfs4_layout_state *ls =
 			container_of(kref, struct nfs4_layout_state, ls_ref);
+	struct nfs4_file *fp;
 
 	nfsd4_remove_stid(&ls->ls_stid);
 	if (!list_empty(&ls->ls_perclnt)) {
@@ -173,8 +174,9 @@ struct sbid_tracker {
 		unhash_layout_state(ls);
 		spin_unlock(&layout_lock);
 	}
-	put_nfs4_file(ls->ls_file);
+	fp = ls->ls_file;
 	nfsd4_free_stid(layout_state_slab, &ls->ls_stid);
+	put_nfs4_file_locked(fp);
 }
 
 /*
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e11d96f..5d5dead 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -239,14 +239,42 @@ static void nfsd4_free_file(struct nfs4_file *f)
 	kmem_cache_free(file_slab, f);
 }
 
-void
-put_nfs4_file(struct nfs4_file *fi)
+static struct inode *put_nfs4_file_common(struct nfs4_file *fi)
 {
 	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
+		struct inode *ino;
+
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&recall_lock);
-		iput(fi->fi_inode);
+		ino = fi->fi_inode;
 		nfsd4_free_file(fi);
+
+		return ino;
+	}
+	return NULL;
+}
+
+void
+put_nfs4_file(struct nfs4_file *fi)
+{
+	struct inode *ino;
+
+	ino = put_nfs4_file_common(fi);
+	if (ino)
+		iput(ino);
+}
+
+void
+put_nfs4_file_locked(struct nfs4_file *fi)
+{
+	struct inode *ino;
+
+	nfs4_assert_state_locked();
+	ino = put_nfs4_file_common(fi);
+	if (ino) {
+		nfs4_unlock_state();
+		iput(ino);
+		nfs4_lock_state();
 	}
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1ef09ae..3be7507 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -491,6 +491,7 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern void nfsd4_free_slab(struct kmem_cache **);
 extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
 extern void put_nfs4_file(struct nfs4_file *);
+extern void put_nfs4_file_locked(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
 extern struct nfs4_client *find_confirmed_client(clientid_t *, bool sessions, struct nfsd_net *);
 extern struct nfs4_stid *nfsd4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
-- 
1.8.3.1

