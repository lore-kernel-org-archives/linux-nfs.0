Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:64762 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594Ab0LNO4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:56:03 -0500
Received: by mail-gw0-f42.google.com with SMTP id 20so538996gwb.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:56:03 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/31] NFS: Replace old NFSv3 encoder functions with
	xdr_stream-based ones
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:56:01 -0500
Message-ID: <20101214145600.2293.10471.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The naming scheme of the new encoder functions, which follows the
NFSv4 XDR encoder functions, is slightly different than the scheme
used for the old functions.  Rename the functions as a separate
step to keep the patches clean.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c |   58 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 3d1043f..bbda890 100644
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
@@ -1969,9 +1971,9 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
+	.p_encode    = (kxdrproc_t)nfs3_xdr_enc_##argtype##3args,	\
 	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
-	.p_arglen    = NFS3_##argtype##_sz,				\
+	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##_sz,				\
 	.p_timer     = timer,						\
 	.p_statidx   = NFS3PROC_##proc,					\
@@ -1979,27 +1981,27 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
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
+	PROC(GETATTR,		getattr,	attrstat,	1),
+	PROC(SETATTR,		setattr,	wccstat,	0),
+	PROC(LOOKUP,		lookup,		lookupres,	2),
+	PROC(ACCESS,		access,		accessres,	1),
+	PROC(READLINK,		readlink,	readlinkres,	3),
+	PROC(READ,		read,		readres,	3),
+	PROC(WRITE,		write,		writeres,	4),
+	PROC(CREATE,		create,		createres,	0),
+	PROC(MKDIR,		mkdir,		createres,	0),
+	PROC(SYMLINK,		symlink,	createres,	0),
+	PROC(MKNOD,		mknod,		createres,	0),
+	PROC(REMOVE,		remove,		removeres,	0),
+	PROC(RMDIR,		lookup,		wccstat,	0),
+	PROC(RENAME,		rename,		renameres,	0),
+	PROC(LINK,		link,		linkres,	0),
+	PROC(READDIR,		readdir,	readdirres,	3),
+	PROC(READDIRPLUS,	readdirplus,	readdirres,	3),
+	PROC(FSSTAT,		getattr,	fsstatres,	0),
+	PROC(FSINFO,		getattr,	fsinfores,	0),
+	PROC(PATHCONF,		getattr,	pathconfres,	0),
+	PROC(COMMIT,		commit,		commitres,	5),
 };
 
 struct rpc_version		nfs_version3 = {
@@ -2012,7 +2014,7 @@ struct rpc_version		nfs_version3 = {
 static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
-		.p_encode = (kxdrproc_t) nfs3_xdr_getaclargs,
+		.p_encode = (kxdrproc_t)nfs3_xdr_enc_getacl3args,
 		.p_decode = (kxdrproc_t) nfs3_xdr_getaclres,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
@@ -2021,7 +2023,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
-		.p_encode = (kxdrproc_t) nfs3_xdr_setaclargs,
+		.p_encode = (kxdrproc_t)nfs3_xdr_enc_setacl3args,
 		.p_decode = (kxdrproc_t) nfs3_xdr_setaclres,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,

