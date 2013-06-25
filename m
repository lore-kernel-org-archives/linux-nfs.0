Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f44.google.com ([209.85.213.44]:50613 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab3FYQ3N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:29:13 -0400
Received: by mail-yh0-f44.google.com with SMTP id t59so5858561yho.3
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 09:29:13 -0700 (PDT)
Subject: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Jun 2013 12:24:05 -0400
Message-ID: <20130625162405.36416.83658.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save each FSID's root file handle in the FSID's nfs_server structure
on the client.  This is needed for NFSv4 migration recovery.

nfs_create_server() (used for NFSv2/3) is also updated for
completeness.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/client.c           |    8 ++++++++
 fs/nfs/internal.h         |   12 ++++++++++++
 fs/nfs/nfs4client.c       |    5 +++++
 include/linux/nfs_fs_sb.h |    1 +
 4 files changed, 26 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbb65fb..29cf2b9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1028,6 +1028,7 @@ void nfs_free_server(struct nfs_server *server)
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
 	bdi_destroy(&server->backing_dev_info);
+	nfs_free_fhandle(server->rootfh);
 	kfree(server);
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
@@ -1053,6 +1054,9 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
 		goto error;
+	nfs_save_root_fh(server, mount_info->mntfh);
+	if (server->rootfh == NULL)
+		goto error;
 
 	/* Get a client representation */
 	error = nfs_init_server(server, mount_info->parsed, nfs_mod);
@@ -1122,6 +1126,9 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	fattr_fsinfo = nfs_alloc_fattr();
 	if (fattr_fsinfo == NULL)
 		goto out_free_server;
+	nfs_save_root_fh(server, fh);
+	if (server->rootfh == NULL)
+		goto out_free_server;
 
 	/* Copy data from the source */
 	server->nfs_client = source->nfs_client;
@@ -1161,6 +1168,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	return server;
 
 out_free_server:
+	nfs_free_fhandle(server->rootfh);
 	nfs_free_fattr(fattr_fsinfo);
 	nfs_free_server(server);
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 91e59a3..10a3327 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -574,3 +574,15 @@ u64 nfs_timespec_to_change_attr(const struct timespec *ts)
 {
 	return ((u64)ts->tv_sec << 30) + ts->tv_nsec;
 }
+
+/*
+ * Save a copy of the root FH
+ */
+static inline
+void nfs_save_root_fh(struct nfs_server *server, const struct nfs_fh *fh)
+{
+	server->rootfh = nfs_alloc_fhandle();
+	if (server->rootfh == NULL)
+		return;
+	nfs_copy_fh(server->rootfh, fh);
+}
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 3aec2de..18c2154 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -731,6 +731,11 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	if (fattr == NULL)
 		return -ENOMEM;
 
+	error = -ENOMEM;
+	nfs_save_root_fh(server, mntfh);
+	if (server->rootfh == NULL)
+		goto out;
+
 	/* We must ensure the session is initialised first */
 	error = nfs4_init_session(server);
 	if (error < 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3b7fa2a..df4df80 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -170,6 +170,7 @@ struct nfs_server {
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

