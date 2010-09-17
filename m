Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:32884 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0IQQ22 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:28:28 -0400
Received: by ywh1 with SMTP id 1so789286ywh.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:28:28 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/22] NFS: Replace old NFSv3 encoder functions with
	xdr_stream-based ones
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:28:25 -0400
Message-ID: <20100917162824.19761.51527.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The naming scheme of the new encoder functions, which follows the
NFSv4 XDR encoder functions, is slightly different than the scheme
used for the old functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |   58 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 6b84691..b1b6465 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -46,10 +46,11 @@
 #define NFS3_fsinfo_sz		
 #define NFS3_pathconf_sz		
 #define NFS3_entry_sz		(NFS3_filename_sz+3)
-
-#define NFS3_sattrargs_sz	(NFS3_fh_sz+NFS3_sattr_sz+3)
 #define NFS3_diropargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
-#define NFS3_removeargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
+
+#define NFS3_getattrargs_sz	(NFS3_fh_sz)
+#define NFS3_setattrargs_sz	(NFS3_fh_sz+NFS3_sattr_sz+3)
+#define NFS3_lookupargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
 #define NFS3_accessargs_sz	(NFS3_fh_sz+1)
 #define NFS3_readlinkargs_sz	(NFS3_fh_sz)
 #define NFS3_readargs_sz	(NFS3_fh_sz+3)
@@ -58,6 +59,7 @@
 #define NFS3_mkdirargs_sz	(NFS3_diropargs_sz+NFS3_sattr_sz)
 #define NFS3_symlinkargs_sz	(NFS3_diropargs_sz+1+NFS3_sattr_sz)
 #define NFS3_mknodargs_sz	(NFS3_diropargs_sz+2+NFS3_sattr_sz)
+#define NFS3_removeargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
 #define NFS3_renameargs_sz	(NFS3_diropargs_sz+NFS3_diropargs_sz)
 #define NFS3_linkargs_sz		(NFS3_fh_sz+NFS3_diropargs_sz)
 #define NFS3_readdirargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+3)
@@ -1959,9 +1961,9 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
+	.p_encode    = (kxdrproc_t) nfs3_xdr_enc_##argtype##3args,	\
 	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
-	.p_arglen    = NFS3_##argtype##_sz,				\
+	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##_sz,				\
 	.p_timer     = timer,						\
 	.p_statidx   = NFS3PROC_##proc,					\
@@ -1969,27 +1971,27 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	}
 
 struct rpc_procinfo	nfs3_procedures[] = {
-  PROC(GETATTR,		fhandle,	attrstat, 1),
-  PROC(SETATTR, 	sattrargs,	wccstat, 0),
-  PROC(LOOKUP,		diropargs,	lookupres, 2),
-  PROC(ACCESS,		accessargs,	accessres, 1),
-  PROC(READLINK,	readlinkargs,	readlinkres, 3),
-  PROC(READ,		readargs,	readres, 3),
-  PROC(WRITE,		writeargs,	writeres, 4),
-  PROC(CREATE,		createargs,	createres, 0),
-  PROC(MKDIR,		mkdirargs,	createres, 0),
-  PROC(SYMLINK,		symlinkargs,	createres, 0),
-  PROC(MKNOD,		mknodargs,	createres, 0),
-  PROC(REMOVE,		removeargs,	removeres, 0),
-  PROC(RMDIR,		diropargs,	wccstat, 0),
-  PROC(RENAME,		renameargs,	renameres, 0),
-  PROC(LINK,		linkargs,	linkres, 0),
-  PROC(READDIR,		readdirargs,	readdirres, 3),
-  PROC(READDIRPLUS,	readdirargs,	readdirres, 3),
-  PROC(FSSTAT,		fhandle,	fsstatres, 0),
-  PROC(FSINFO,  	fhandle,	fsinfores, 0),
-  PROC(PATHCONF,	fhandle,	pathconfres, 0),
-  PROC(COMMIT,		commitargs,	commitres, 5),
+  PROC(GETATTR,		getattr,	attrstat, 1),
+  PROC(SETATTR,		setattr,	wccstat, 0),
+  PROC(LOOKUP,		lookup,		lookupres, 2),
+  PROC(ACCESS,		access,		accessres, 1),
+  PROC(READLINK,	readlink,	readlinkres, 3),
+  PROC(READ,		read,		readres, 3),
+  PROC(WRITE,		write,		writeres, 4),
+  PROC(CREATE,		create,		createres, 0),
+  PROC(MKDIR,		mkdir,		createres, 0),
+  PROC(SYMLINK,		symlink,	createres, 0),
+  PROC(MKNOD,		mknod,		createres, 0),
+  PROC(REMOVE,		remove,		removeres, 0),
+  PROC(RMDIR,		lookup,		wccstat, 0),
+  PROC(RENAME,		rename,		renameres, 0),
+  PROC(LINK,		link,		linkres, 0),
+  PROC(READDIR,		readdir,	readdirres, 3),
+  PROC(READDIRPLUS,	readdirplus,	readdirres, 3),
+  PROC(FSSTAT,		getattr,	fsstatres, 0),
+  PROC(FSINFO,		getattr,	fsinfores, 0),
+  PROC(PATHCONF,	getattr,	pathconfres, 0),
+  PROC(COMMIT,		commit,		commitres, 5),
 };
 
 struct rpc_version		nfs_version3 = {
@@ -2002,7 +2004,7 @@ struct rpc_version		nfs_version3 = {
 static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
-		.p_encode = (kxdrproc_t) nfs3_xdr_getaclargs,
+		.p_encode = (kxdrproc_t) nfs3_xdr_enc_getacl3args,
 		.p_decode = (kxdrproc_t) nfs3_xdr_getaclres,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
@@ -2011,7 +2013,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
-		.p_encode = (kxdrproc_t) nfs3_xdr_setaclargs,
+		.p_encode = (kxdrproc_t) nfs3_xdr_enc_setacl3args,
 		.p_decode = (kxdrproc_t) nfs3_xdr_setaclres,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,

