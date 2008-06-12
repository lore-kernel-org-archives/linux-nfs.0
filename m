From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] NFS: use documenting macro constants for initializing
	ac{reg, dir}{min, max}
Date: Thu, 12 Jun 2008 12:38:05 -0400
Message-ID: <20080612163804.13197.30391.stgit@manray.1015granger.net>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:2428 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbYFLQjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 12:39:09 -0400
Received: by py-out-1112.google.com with SMTP id p76so1685836pyb.10
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 09:39:06 -0700 (PDT)
In-Reply-To: <20080612163416.13197.92911.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c       |    8 ++++----
 fs/nfs/super.c         |   24 ++++++++++++------------
 include/linux/nfs_fs.h |    5 +++++
 3 files changed, 21 insertions(+), 16 deletions(-)


diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 531379d..811ac22 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -297,10 +297,10 @@ static int __init root_nfs_name(char *name)
 	nfs_data.flags    = NFS_MOUNT_NONLM;	/* No lockd in nfs root yet */
 	nfs_data.rsize    = NFS_DEF_FILE_IO_SIZE;
 	nfs_data.wsize    = NFS_DEF_FILE_IO_SIZE;
-	nfs_data.acregmin = 3;
-	nfs_data.acregmax = 60;
-	nfs_data.acdirmin = 30;
-	nfs_data.acdirmax = 60;
+	nfs_data.acregmin = NFS_DEF_ACREGMIN;
+	nfs_data.acregmax = NFS_DEF_ACREGMAX;
+	nfs_data.acdirmin = NFS_DEF_ACDIRMIN;
+	nfs_data.acdirmax = NFS_DEF_ACDIRMAX;
 	strcpy(buf, NFS_ROOT);
 
 	/* Process options received from the remote server */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 964b17b..eba5d0d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -514,13 +514,13 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	if (nfss->bsize != 0)
 		seq_printf(m, ",bsize=%u", nfss->bsize);
 	seq_printf(m, ",namlen=%u", nfss->namelen);
-	if (nfss->acregmin != 3*HZ || showdefaults)
+	if (nfss->acregmin != NFS_DEF_ACREGMIN*HZ || showdefaults)
 		seq_printf(m, ",acregmin=%u", nfss->acregmin/HZ);
-	if (nfss->acregmax != 60*HZ || showdefaults)
+	if (nfss->acregmax != NFS_DEF_ACREGMAX*HZ || showdefaults)
 		seq_printf(m, ",acregmax=%u", nfss->acregmax/HZ);
-	if (nfss->acdirmin != 30*HZ || showdefaults)
+	if (nfss->acdirmin != NFS_DEF_ACDIRMIN*HZ || showdefaults)
 		seq_printf(m, ",acdirmin=%u", nfss->acdirmin/HZ);
-	if (nfss->acdirmax != 60*HZ || showdefaults)
+	if (nfss->acdirmax != NFS_DEF_ACDIRMAX*HZ || showdefaults)
 		seq_printf(m, ",acdirmax=%u", nfss->acdirmax/HZ);
 	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
 		if (nfss->flags & nfs_infop->flag)
@@ -1241,10 +1241,10 @@ static int nfs_validate_mount_data(void *options,
 	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->acregmin		= 3;
-	args->acregmax		= 60;
-	args->acdirmin		= 30;
-	args->acdirmax		= 60;
+	args->acregmin		= NFS_DEF_ACREGMIN;
+	args->acregmax		= NFS_DEF_ACREGMAX;
+	args->acdirmin		= NFS_DEF_ACDIRMIN;
+	args->acdirmax		= NFS_DEF_ACDIRMAX;
 	args->mount_server.port	= 0;	/* autobind unless user sets port */
 	args->nfs_server.port	= 0;	/* autobind unless user sets port */
 
@@ -1820,10 +1820,10 @@ static int nfs4_validate_mount_data(void *options,
 
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->acregmin		= 3;
-	args->acregmax		= 60;
-	args->acdirmin		= 30;
-	args->acdirmax		= 60;
+	args->acregmin		= NFS_DEF_ACREGMIN;
+	args->acregmax		= NFS_DEF_ACREGMAX;
+	args->acdirmin		= NFS_DEF_ACDIRMIN;
+	args->acdirmax		= NFS_DEF_ACDIRMAX;
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 
 	switch (data->version) {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index afc3956..3c4078e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -20,6 +20,11 @@
 #define NFS_MAX_UDP_TIMEOUT	(60*HZ)
 #define NFS_MAX_TCP_TIMEOUT	(600*HZ)
 
+#define NFS_DEF_ACREGMIN	(3)
+#define NFS_DEF_ACREGMAX	(60)
+#define NFS_DEF_ACDIRMIN	(30)
+#define NFS_DEF_ACDIRMAX	(60)
+
 /*
  * When flushing a cluster of dirty pages, there can be different
  * strategies:

