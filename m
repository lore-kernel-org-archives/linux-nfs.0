Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10299 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932765Ab2AMULj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:39 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 39/44] NFS: Create accessor functions for the nfs_client_list()
Date: Fri, 13 Jan 2012 15:10:48 -0500
Message-Id: <1326485453-1350-40-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This list is used by nfs4_find_no_client_ident(), and needs to be locked
before traversing.  Since this function is about to move to a different
file, I created functions to get a pointer to the list head and manage
the lock.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c |   26 ++++++++++++++++++++------
 fs/nfs/nfs.h    |    2 ++
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 778ef62..56da3b6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1177,17 +1177,18 @@ struct nfs_client *
 nfs4_find_client_no_ident(const struct sockaddr *addr)
 {
 	struct nfs_client *clp;
+	struct list_head *cl_list = nfs_client_list_start();
 
-	spin_lock(&nfs_client_lock);
-	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+	list_for_each_entry(clp, cl_list, cl_share_link) {
 		if (nfs4_cb_match_client(addr, clp, 0) == false)
 			continue;
 		atomic_inc(&clp->cl_count);
-		spin_unlock(&nfs_client_lock);
-		return clp;
+		goto out;
 	}
-	spin_unlock(&nfs_client_lock);
-	return NULL;
+	clp = NULL;
+out:
+	nfs_client_list_end();
+	return clp;
 }
 
 /*
@@ -1850,6 +1851,19 @@ static void nfs_server_list_stop(struct seq_file *p, void *v)
 	spin_unlock(&nfs_client_lock);
 }
 
+struct list_head *nfs_client_list_start(void)
+{
+	spin_lock(&nfs_client_lock);
+	return &nfs_client_list;
+}
+EXPORT_SYMBOL_GPL(nfs_client_list_start);
+
+void nfs_client_list_end(void)
+{
+	spin_unlock(&nfs_client_lock);
+}
+EXPORT_SYMBOL_GPL(nfs_client_list_end);
+
 /*
  * display a header line followed by a load of call lines
  */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 13321fd..5f2d632 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -66,6 +66,8 @@ void unregister_nfs_version(struct nfs_subversion *);
 struct nfs_server *nfs_alloc_server(void);
 struct nfs_server *do_nfs_clone_server(struct nfs_server *, struct nfs_server *,
 				       struct nfs_fh *, struct nfs_fattr *);
+struct list_head *nfs_client_list_start(void);
+void nfs_client_list_end(void);
 
 /* Exported in dir.c */
 int nfs_lookup_revalidate(struct dentry *, struct nameidata *);
-- 
1.7.8.3

