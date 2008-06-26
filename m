From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFS: use documenting macro constants for initializing
	ac{reg, dir}{min, max}
Date: Thu, 26 Jun 2008 17:47:12 -0400
Message-ID: <20080626214712.3129.76593.stgit@ellison.1015granger.net>
References: <20080626214451.3129.85650.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23489 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbYFZVry (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 17:47:54 -0400
In-Reply-To: <20080626214451.3129.85650.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index 15afe3a..46763d1 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -295,10 +295,10 @@ static int __init root_nfs_name(char *name)
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
index d3be1fa..2de6a37 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -518,13 +518,13 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
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
@@ -1461,10 +1461,10 @@ static int nfs_validate_mount_data(void *options,
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
 
@@ -2119,10 +2119,10 @@ static int nfs4_validate_mount_data(void *options,
 
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

