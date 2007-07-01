From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/21] NFS: Clean up in-kernel NFS mount
Date: Sun, 01 Jul 2007 12:13:33 -0400
Message-ID: <20070701161332.2786.66834.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52iY-00007Q-9V
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:10 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52ib-0007Pp-If
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:13 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up white space and coding conventions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   83 +++++++++++++++++++++++----------------------------
 1 files changed, 37 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index ee4899d..8138886 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -1,7 +1,5 @@
 /*
- * linux/fs/nfs/mount_clnt.c
- *
- * MOUNT client to support NFSroot.
+ * In-kernel MOUNT protocol client
  *
  * Copyright (C) 1997, Olaf Kirch <okir@monad.swb.de>
  */
@@ -21,18 +19,11 @@
 # define NFSDBG_FACILITY	NFSDBG_MOUNT
 #endif
 
-/*
-#define MOUNT_PROGRAM		100005
-#define MOUNT_VERSION		1
-#define MOUNT_MNT		1
-#define MOUNT_UMNT		3
- */
-
 static struct rpc_program	mnt_program;
 
 struct mnt_fhstatus {
-	unsigned int		status;
-	struct nfs_fh *		fh;
+	u32 status;
+	struct nfs_fh *fh;
 };
 
 /**
@@ -90,8 +81,8 @@ int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
 /*
  * XDR encode/decode functions for MOUNT
  */
-static int
-xdr_encode_dirpath(struct rpc_rqst *req, __be32 *p, const char *path)
+static int xdr_encode_dirpath(struct rpc_rqst *req, __be32 *p,
+			      const char *path)
 {
 	p = xdr_encode_string(p, path);
 
@@ -99,8 +90,8 @@ xdr_encode_dirpath(struct rpc_rqst *req, __be32 *p, const char *path)
 	return 0;
 }
 
-static int
-xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p, struct mnt_fhstatus *res)
+static int xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p,
+			       struct mnt_fhstatus *res)
 {
 	struct nfs_fh *fh = res->fh;
 
@@ -111,8 +102,8 @@ xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p, struct mnt_fhstatus *res)
 	return 0;
 }
 
-static int
-xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p, struct mnt_fhstatus *res)
+static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
+				struct mnt_fhstatus *res)
 {
 	struct nfs_fh *fh = res->fh;
 
@@ -131,53 +122,53 @@ xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p, struct mnt_fhstatus *res)
 #define MNT_fhstatus_sz		(1 + 8)
 #define MNT_fhstatus3_sz	(1 + 16)
 
-static struct rpc_procinfo	mnt_procedures[] = {
-[MNTPROC_MNT] = {
-	  .p_proc		= MNTPROC_MNT,
-	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,	
-	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus,
-	  .p_arglen		= MNT_dirpath_sz,
-	  .p_replen		= MNT_fhstatus_sz,
-	  .p_statidx		= MNTPROC_MNT,
-	  .p_name		= "MOUNT",
+static struct rpc_procinfo mnt_procedures[] = {
+	[MNTPROC_MNT] = {
+		.p_proc		= MNTPROC_MNT,
+		.p_encode	= (kxdrproc_t) xdr_encode_dirpath,	
+		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus,
+		.p_arglen	= MNT_dirpath_sz,
+		.p_replen	= MNT_fhstatus_sz,
+		.p_statidx	= MNTPROC_MNT,
+		.p_name		= "MOUNT",
 	},
 };
 
 static struct rpc_procinfo mnt3_procedures[] = {
-[MOUNTPROC3_MNT] = {
-	  .p_proc		= MOUNTPROC3_MNT,
-	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,
-	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus3,
-	  .p_arglen		= MNT_dirpath_sz,
-	  .p_replen		= MNT_fhstatus3_sz,
-	  .p_statidx		= MOUNTPROC3_MNT,
-	  .p_name		= "MOUNT",
+	[MOUNTPROC3_MNT] = {
+		.p_proc		= MOUNTPROC3_MNT,
+		.p_encode	= (kxdrproc_t) xdr_encode_dirpath,
+		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus3,
+		.p_arglen	= MNT_dirpath_sz,
+		.p_replen	= MNT_fhstatus3_sz,
+		.p_statidx	= MOUNTPROC3_MNT,
+		.p_name		= "MOUNT",
 	},
 };
 
 
-static struct rpc_version	mnt_version1 = {
-		.number		= 1,
-		.nrprocs 	= 2,
-		.procs 		= mnt_procedures
+static struct rpc_version mnt_version1 = {
+	.number		= 1,
+	.nrprocs	= 2,
+	.procs		= mnt_procedures,
 };
 
-static struct rpc_version       mnt_version3 = {
-		.number		= 3,
-		.nrprocs	= 2,
-		.procs		= mnt3_procedures
+static struct rpc_version mnt_version3 = {
+	.number		= 3,
+	.nrprocs	= 2,
+	.procs		= mnt3_procedures,
 };
 
-static struct rpc_version *	mnt_version[] = {
+static struct rpc_version *mnt_version[] = {
 	NULL,
 	&mnt_version1,
 	NULL,
 	&mnt_version3,
 };
 
-static struct rpc_stat		mnt_stats;
+static struct rpc_stat mnt_stats;
 
-static struct rpc_program	mnt_program = {
+static struct rpc_program mnt_program = {
 	.name		= "mount",
 	.number		= NFS_MNT_PROGRAM,
 	.nrvers		= ARRAY_SIZE(mnt_version),


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
