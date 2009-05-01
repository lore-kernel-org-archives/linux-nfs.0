From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: Clean up MNT program definitions
Date: Fri, 01 May 2009 12:36:29 -0400
Message-ID: <20090501163628.25681.87784.stgit@ingres.1015granger.net>
References: <20090501163507.25681.14463.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:62744 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbZEAQgl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 12:36:41 -0400
In-Reply-To: <20090501163507.25681.14463.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Relocate MNT program procedure number definitions to the
only file that uses them.  Relocate the version number definitions,
which are shared, to nfs.h.  Remove duplicate program number
definitions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c  |   32 ++++++++++++++++++++++++++++----
 fs/nfs/nfsroot.c     |    3 +++
 include/linux/nfs.h  |    5 +++--
 include/linux/nfs2.h |    7 -------
 include/linux/nfs3.h |    5 -----
 5 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index ca905a5..af45a37 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -20,6 +20,30 @@
 # define NFSDBG_FACILITY	NFSDBG_MOUNT
 #endif
 
+/*
+ * Defined by RFC 1094, section A.5
+ */
+enum {
+	MOUNTPROC_NULL		= 0,
+	MOUNTPROC_MNT		= 1,
+	MOUNTPROC_DUMP		= 2,
+	MOUNTPROC_UMNT		= 3,
+	MOUNTPROC_UMNTALL	= 4,
+	MOUNTPROC_EXPORT	= 5,
+};
+
+/*
+ * Defined by RFC 1813, section 5.2
+ */
+enum {
+	MOUNTPROC3_NULL		= 0,
+	MOUNTPROC3_MNT		= 1,
+	MOUNTPROC3_DUMP		= 2,
+	MOUNTPROC3_UMNT		= 3,
+	MOUNTPROC3_UMNTALL	= 4,
+	MOUNTPROC3_EXPORT	= 5,
+};
+
 static struct rpc_program	mnt_program;
 
 struct mnt_fhstatus {
@@ -68,7 +92,7 @@ int nfs_mount(struct nfs_mount_request *info)
 	if (info->version == NFS_MNT3_VERSION)
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MOUNTPROC3_MNT];
 	else
-		msg.rpc_proc = &mnt_clnt->cl_procinfo[MNTPROC_MNT];
+		msg.rpc_proc = &mnt_clnt->cl_procinfo[MOUNTPROC_MNT];
 
 	status = rpc_call_sync(mnt_clnt, &msg, 0);
 	rpc_shutdown_client(mnt_clnt);
@@ -145,13 +169,13 @@ static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 #define MNT_fhstatus3_sz	(1 + 16)
 
 static struct rpc_procinfo mnt_procedures[] = {
-	[MNTPROC_MNT] = {
-		.p_proc		= MNTPROC_MNT,
+	[MOUNTPROC_MNT] = {
+		.p_proc		= MOUNTPROC_MNT,
 		.p_encode	= (kxdrproc_t) xdr_encode_dirpath,
 		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus,
 		.p_arglen	= MNT_dirpath_sz,
 		.p_replen	= MNT_fhstatus_sz,
-		.p_statidx	= MNTPROC_MNT,
+		.p_statidx	= MOUNTPROC_MNT,
 		.p_name		= "MOUNT",
 	},
 };
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index d9ef602..0388c25 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -92,6 +92,9 @@
 #undef NFSROOT_DEBUG
 #define NFSDBG_FACILITY NFSDBG_ROOT
 
+/* Default port to use if server is not running a portmapper */
+#define NFS_MNT_PORT	627
+
 /* Default path we try to mount. "%s" gets replaced by our IP address */
 #define NFS_ROOT		"/tftpboot/%s"
 
diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 214d499..f387919 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -25,8 +25,9 @@
 #define NFSMODE_SOCK	0140000
 #define NFSMODE_FIFO	0010000
 
-#define NFS_MNT_PROGRAM	100005
-#define NFS_MNT_PORT	627
+#define NFS_MNT_PROGRAM		100005
+#define NFS_MNT_VERSION		1
+#define NFS_MNT3_VERSION	3
 
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
diff --git a/include/linux/nfs2.h b/include/linux/nfs2.h
index 0ed9517..fde24b3 100644
--- a/include/linux/nfs2.h
+++ b/include/linux/nfs2.h
@@ -64,11 +64,4 @@ struct nfs2_fh {
 #define NFSPROC_READDIR		16
 #define NFSPROC_STATFS		17
 
-#define NFS_MNT_PROGRAM		100005
-#define NFS_MNT_VERSION		1
-#define MNTPROC_NULL		0
-#define MNTPROC_MNT		1
-#define MNTPROC_UMNT		3
-#define MNTPROC_UMNTALL		4
-
 #endif /* _LINUX_NFS2_H */
diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index 539f3b5..ac33806 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -88,12 +88,7 @@ struct nfs3_fh {
 #define NFS3PROC_PATHCONF	20
 #define NFS3PROC_COMMIT		21
 
-#define NFS_MNT3_PROGRAM	100005
 #define NFS_MNT3_VERSION	3
-#define MOUNTPROC3_NULL		0
-#define MOUNTPROC3_MNT		1
-#define MOUNTPROC3_UMNT		3
-#define MOUNTPROC3_UMNTALL	4
  
 
 #if defined(__KERNEL__)

