Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:35191 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab0KQRqB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:46:01 -0500
Received: by pwj1 with SMTP id 1so275059pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:46:00 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/17] NFS: Switch in new NFSv3 decoder functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:45:56 -0500
Message-ID: <20101117174556.29177.90013.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The naming scheme of the new decoder functions, which follows the
NFSv4 XDR decoder functions, is slightly different than the scheme
used for the old functions.  Rename the functions as a separate
step to keep the patches clean.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c |   64 +++++++++++++++++++++++++-----------------------------
 1 files changed, 30 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 570f04b..d7e7d5f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -38,14 +38,10 @@
 #define NFS3_path_sz		(1+(NFS3_MAXPATHLEN>>2))
 #define NFS3_fattr_sz		(21)
 #define NFS3_cookieverf_sz	(NFS3_COOKIEVERFSIZE>>2)
-#define NFS3_wcc_attr_sz		(6)
+#define NFS3_wcc_attr_sz	(6)
 #define NFS3_pre_op_attr_sz	(1+NFS3_wcc_attr_sz)
 #define NFS3_post_op_attr_sz	(1+NFS3_fattr_sz)
-#define NFS3_wcc_data_sz		(NFS3_pre_op_attr_sz+NFS3_post_op_attr_sz)
-#define NFS3_fsstat_sz		
-#define NFS3_fsinfo_sz		
-#define NFS3_pathconf_sz		
-#define NFS3_entry_sz		(NFS3_filename_sz+3)
+#define NFS3_wcc_data_sz	(NFS3_pre_op_attr_sz+NFS3_post_op_attr_sz)
 #define NFS3_diropargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
 
 #define NFS3_getattrargs_sz	(NFS3_fh_sz)
@@ -66,9 +62,9 @@
 #define NFS3_readdirplusargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+4)
 #define NFS3_commitargs_sz	(NFS3_fh_sz+3)
 
-#define NFS3_attrstat_sz	(1+NFS3_fattr_sz)
-#define NFS3_wccstat_sz		(1+NFS3_wcc_data_sz)
-#define NFS3_removeres_sz	(NFS3_wccstat_sz)
+#define NFS3_getattrres_sz	(1+NFS3_fattr_sz)
+#define NFS3_setattrres_sz	(1+NFS3_wcc_data_sz)
+#define NFS3_removeres_sz	(NFS3_setattrres_sz)
 #define NFS3_lookupres_sz	(1+NFS3_fh_sz+(2 * NFS3_post_op_attr_sz))
 #define NFS3_accessres_sz	(1+NFS3_post_op_attr_sz+1)
 #define NFS3_readlinkres_sz	(1+NFS3_post_op_attr_sz+1)
@@ -3013,36 +3009,36 @@ out_default:
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = (kxdrproc_t)nfs3_xdr_enc_##argtype##3args,	\
-	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
+	.p_decode    = (kxdrproc_t)nfs3_xdr_dec_##restype##3res,	\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
-	.p_replen    = NFS3_##restype##_sz,				\
+	.p_replen    = NFS3_##restype##res_sz,				\
 	.p_timer     = timer,						\
 	.p_statidx   = NFS3PROC_##proc,					\
 	.p_name      = #proc,						\
 	}
 
 struct rpc_procinfo	nfs3_procedures[] = {
-	PROC(GETATTR,		getattr,	attrstat,	1),
-	PROC(SETATTR,		setattr,	wccstat,	0),
-	PROC(LOOKUP,		lookup,		lookupres,	2),
-	PROC(ACCESS,		access,		accessres,	1),
-	PROC(READLINK,		readlink,	readlinkres,	3),
-	PROC(READ,		read,		readres,	3),
-	PROC(WRITE,		write,		writeres,	4),
-	PROC(CREATE,		create,		createres,	0),
-	PROC(MKDIR,		mkdir,		createres,	0),
-	PROC(SYMLINK,		symlink,	createres,	0),
-	PROC(MKNOD,		mknod,		createres,	0),
-	PROC(REMOVE,		remove,		removeres,	0),
-	PROC(RMDIR,		lookup,		wccstat,	0),
-	PROC(RENAME,		rename,		renameres,	0),
-	PROC(LINK,		link,		linkres,	0),
-	PROC(READDIR,		readdir,	readdirres,	3),
-	PROC(READDIRPLUS,	readdirplus,	readdirres,	3),
-	PROC(FSSTAT,		getattr,	fsstatres,	0),
-	PROC(FSINFO,		getattr,	fsinfores,	0),
-	PROC(PATHCONF,		getattr,	pathconfres,	0),
-	PROC(COMMIT,		commit,		commitres,	5),
+	PROC(GETATTR,		getattr,	getattr,	1),
+	PROC(SETATTR,		setattr,	setattr,	0),
+	PROC(LOOKUP,		lookup,		lookup,		2),
+	PROC(ACCESS,		access,		access,		1),
+	PROC(READLINK,		readlink,	readlink,	3),
+	PROC(READ,		read,		read,		3),
+	PROC(WRITE,		write,		write,		4),
+	PROC(CREATE,		create,		create,		0),
+	PROC(MKDIR,		mkdir,		create,		0),
+	PROC(SYMLINK,		symlink,	create,		0),
+	PROC(MKNOD,		mknod,		create,		0),
+	PROC(REMOVE,		remove,		remove,		0),
+	PROC(RMDIR,		lookup,		setattr,	0),
+	PROC(RENAME,		rename,		rename,		0),
+	PROC(LINK,		link,		link,		0),
+	PROC(READDIR,		readdir,	readdir,	3),
+	PROC(READDIRPLUS,	readdirplus,	readdir,	3),
+	PROC(FSSTAT,		getattr,	fsstat,		0),
+	PROC(FSINFO,		getattr,	fsinfo,		0),
+	PROC(PATHCONF,		getattr,	pathconf,	0),
+	PROC(COMMIT,		commit,		commit,		5),
 };
 
 struct rpc_version		nfs_version3 = {
@@ -3056,7 +3052,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = (kxdrproc_t)nfs3_xdr_enc_getacl3args,
-		.p_decode = (kxdrproc_t) nfs3_xdr_getaclres,
+		.p_decode = (kxdrproc_t)nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
@@ -3065,7 +3061,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
 		.p_encode = (kxdrproc_t)nfs3_xdr_enc_setacl3args,
-		.p_decode = (kxdrproc_t) nfs3_xdr_setaclres,
+		.p_decode = (kxdrproc_t)nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,

