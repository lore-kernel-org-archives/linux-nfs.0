Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54492 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQSAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:00:19 -0500
Received: by pwj1 with SMTP id 1so281006pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:00:18 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/12] NFS: Repair whitespace damage in NFS PROC macro
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:00:13 -0500
Message-ID: <20101117180013.29429.49839.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

checkscript.pl complained about the use of leading blanks in the
PROC macros in the other xdr files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs2xdr.c       |   30 ++++++++--------
 fs/nfs/nfs4xdr.c       |   90 ++++++++++++++++++++++++------------------------
 fs/nfsd/nfs4callback.c |   52 ++++++++++++++--------------
 3 files changed, 86 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 85030b9..417531b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1191,21 +1191,21 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	.p_name     =  #proc,						\
 	}
 struct rpc_procinfo	nfs_procedures[] = {
-    PROC(GETATTR,	fhandle,	attrstat, 1),
-    PROC(SETATTR,	sattrargs,	attrstat, 0),
-    PROC(LOOKUP,	diropargs,	diropres, 2),
-    PROC(READLINK,	readlinkargs,	readlinkres, 3),
-    PROC(READ,		readargs,	readres, 3),
-    PROC(WRITE,		writeargs,	writeres, 4),
-    PROC(CREATE,	createargs,	diropres, 0),
-    PROC(REMOVE,	removeargs,	stat, 0),
-    PROC(RENAME,	renameargs,	stat, 0),
-    PROC(LINK,		linkargs,	stat, 0),
-    PROC(SYMLINK,	symlinkargs,	stat, 0),
-    PROC(MKDIR,		createargs,	diropres, 0),
-    PROC(RMDIR,		diropargs,	stat, 0),
-    PROC(READDIR,	readdirargs,	readdirres, 3),
-    PROC(STATFS,	fhandle,	statfsres, 0),
+	PROC(GETATTR,	fhandle,	attrstat,	1),
+	PROC(SETATTR,	sattrargs,	attrstat,	0),
+	PROC(LOOKUP,	diropargs,	diropres,	2),
+	PROC(READLINK,	readlinkargs,	readlinkres,	3),
+	PROC(READ,	readargs,	readres,	3),
+	PROC(WRITE,	writeargs,	writeres,	4),
+	PROC(CREATE,	createargs,	diropres,	0),
+	PROC(REMOVE,	removeargs,	stat,		0),
+	PROC(RENAME,	renameargs,	stat,		0),
+	PROC(LINK,	linkargs,	stat,		0),
+	PROC(SYMLINK,	symlinkargs,	stat,		0),
+	PROC(MKDIR,	createargs,	diropres,	0),
+	PROC(RMDIR,	diropargs,	stat,		0),
+	PROC(READDIR,	readdirargs,	readdirres,	3),
+	PROC(STATFS,	fhandle,	statfsres,	0),
 };
 
 struct rpc_version		nfs_version2 = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f313c4c..53168f6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6297,8 +6297,8 @@ nfs4_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
-	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
-	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
+	.p_encode = (kxdrproc_t)nfs4_xdr_##argtype,		\
+	.p_decode = (kxdrproc_t)nfs4_xdr_##restype,		\
 	.p_arglen = NFS4_##argtype##_sz,			\
 	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
@@ -6306,50 +6306,50 @@ nfs4_stat_to_errno(int stat)
 }
 
 struct rpc_procinfo	nfs4_procedures[] = {
-  PROC(READ,		enc_read,	dec_read),
-  PROC(WRITE,		enc_write,	dec_write),
-  PROC(COMMIT,		enc_commit,	dec_commit),
-  PROC(OPEN,		enc_open,	dec_open),
-  PROC(OPEN_CONFIRM,	enc_open_confirm,	dec_open_confirm),
-  PROC(OPEN_NOATTR,	enc_open_noattr,	dec_open_noattr),
-  PROC(OPEN_DOWNGRADE,	enc_open_downgrade,	dec_open_downgrade),
-  PROC(CLOSE,		enc_close,	dec_close),
-  PROC(SETATTR,		enc_setattr,	dec_setattr),
-  PROC(FSINFO,		enc_fsinfo,	dec_fsinfo),
-  PROC(RENEW,		enc_renew,	dec_renew),
-  PROC(SETCLIENTID,	enc_setclientid,	dec_setclientid),
-  PROC(SETCLIENTID_CONFIRM,	enc_setclientid_confirm,	dec_setclientid_confirm),
-  PROC(LOCK,            enc_lock,       dec_lock),
-  PROC(LOCKT,           enc_lockt,      dec_lockt),
-  PROC(LOCKU,           enc_locku,      dec_locku),
-  PROC(ACCESS,		enc_access,	dec_access),
-  PROC(GETATTR,		enc_getattr,	dec_getattr),
-  PROC(LOOKUP,		enc_lookup,	dec_lookup),
-  PROC(LOOKUP_ROOT,	enc_lookup_root,	dec_lookup_root),
-  PROC(REMOVE,		enc_remove,	dec_remove),
-  PROC(RENAME,		enc_rename,	dec_rename),
-  PROC(LINK,		enc_link,	dec_link),
-  PROC(SYMLINK,		enc_symlink,	dec_symlink),
-  PROC(CREATE,		enc_create,	dec_create),
-  PROC(PATHCONF,	enc_pathconf,	dec_pathconf),
-  PROC(STATFS,		enc_statfs,	dec_statfs),
-  PROC(READLINK,	enc_readlink,	dec_readlink),
-  PROC(READDIR,		enc_readdir,	dec_readdir),
-  PROC(SERVER_CAPS,	enc_server_caps, dec_server_caps),
-  PROC(DELEGRETURN,	enc_delegreturn, dec_delegreturn),
-  PROC(GETACL,		enc_getacl,	dec_getacl),
-  PROC(SETACL,		enc_setacl,	dec_setacl),
-  PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
-  PROC(RELEASE_LOCKOWNER, enc_release_lockowner, dec_release_lockowner),
+	PROC(READ,		enc_read,		dec_read),
+	PROC(WRITE,		enc_write,		dec_write),
+	PROC(COMMIT,		enc_commit,		dec_commit),
+	PROC(OPEN,		enc_open,		dec_open),
+	PROC(OPEN_CONFIRM,	enc_open_confirm,	dec_open_confirm),
+	PROC(OPEN_NOATTR,	enc_open_noattr,	dec_open_noattr),
+	PROC(OPEN_DOWNGRADE,	enc_open_downgrade,	dec_open_downgrade),
+	PROC(CLOSE,		enc_close,		dec_close),
+	PROC(SETATTR,		enc_setattr,		dec_setattr),
+	PROC(FSINFO,		enc_fsinfo,		dec_fsinfo),
+	PROC(RENEW,		enc_renew,		dec_renew),
+	PROC(SETCLIENTID,	enc_setclientid,	dec_setclientid),
+	PROC(SETCLIENTID_CONFIRM, enc_setclientid_confirm, dec_setclientid_confirm),
+	PROC(LOCK,		enc_lock,		dec_lock),
+	PROC(LOCKT,		enc_lockt,		dec_lockt),
+	PROC(LOCKU,		enc_locku,		dec_locku),
+	PROC(ACCESS,		enc_access,		dec_access),
+	PROC(GETATTR,		enc_getattr,		dec_getattr),
+	PROC(LOOKUP,		enc_lookup,		dec_lookup),
+	PROC(LOOKUP_ROOT,	enc_lookup_root,	dec_lookup_root),
+	PROC(REMOVE,		enc_remove,		dec_remove),
+	PROC(RENAME,		enc_rename,		dec_rename),
+	PROC(LINK,		enc_link,		dec_link),
+	PROC(SYMLINK,		enc_symlink,		dec_symlink),
+	PROC(CREATE,		enc_create,		dec_create),
+	PROC(PATHCONF,		enc_pathconf,		dec_pathconf),
+	PROC(STATFS,		enc_statfs,		dec_statfs),
+	PROC(READLINK,		enc_readlink,		dec_readlink),
+	PROC(READDIR,		enc_readdir,		dec_readdir),
+	PROC(SERVER_CAPS,	enc_server_caps,	dec_server_caps),
+	PROC(DELEGRETURN,	enc_delegreturn,	dec_delegreturn),
+	PROC(GETACL,		enc_getacl,		dec_getacl),
+	PROC(SETACL,		enc_setacl,		dec_setacl),
+	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
+	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 #if defined(CONFIG_NFS_V4_1)
-  PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
-  PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
-  PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
-  PROC(SEQUENCE,	enc_sequence,	dec_sequence),
-  PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
-  PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
-  PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
-  PROC(LAYOUTGET,  enc_layoutget,     dec_layoutget),
+	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
+	PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
+	PROC(SEQUENCE,		enc_sequence,		dec_sequence),
+	PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
+	PROC(RECLAIM_COMPLETE,	enc_reclaim_complete,	dec_reclaim_complete),
+	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
+	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c3c6a90..6529534 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -580,23 +580,23 @@ out_default:
 /*
  * RPC procedure tables
  */
-#define PROC(proc, call, argtype, restype)                              \
-[NFSPROC4_CLNT_##proc] = {                                      	\
-        .p_proc   = NFSPROC4_CB_##call,					\
-        .p_encode = (kxdrproc_t) nfs4_xdr_##argtype,                    \
-        .p_decode = (kxdrproc_t) nfs4_xdr_##restype,                    \
-        .p_arglen = NFS4_##argtype##_sz,                                \
-        .p_replen = NFS4_##restype##_sz,                                \
-        .p_statidx = NFSPROC4_CB_##call,				\
-	.p_name   = #proc,                                              \
-}
-
-static struct rpc_procinfo     nfs4_cb_procedures[] = {
-    PROC(CB_NULL,      NULL,     enc_cb_null,     dec_cb_null),
-    PROC(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
+#define PROC(proc, call, argtype, restype)				\
+[NFSPROC4_CLNT_##proc] = {						\
+	.p_proc    = NFSPROC4_CB_##call,				\
+	.p_encode  = (kxdrproc_t)nfs4_xdr_enc_##argtype,		\
+	.p_decode  = (kxdrproc_t)nfs4_xdr_dec_##restype,		\
+	.p_arglen  = NFS4_enc_##argtype##_sz,				\
+	.p_replen  = NFS4_dec_##restype##_sz,				\
+	.p_statidx = NFSPROC4_CB_##call,				\
+	.p_name    = #proc,						\
+}
+
+static struct rpc_procinfo nfs4_cb_procedures[] = {
+	PROC(CB_NULL,	NULL,		cb_null,	cb_null),
+	PROC(CB_RECALL,	COMPOUND,	cb_recall,	cb_recall),
 };
 
-static struct rpc_version       nfs_cb_version4 = {
+static struct rpc_version nfs_cb_version4 = {
 /*
  * Note on the callback rpc program version number: despite language in rfc
  * 5661 section 18.36.3 requiring servers to use 4 in this field, the
@@ -604,29 +604,29 @@ static struct rpc_version       nfs_cb_version4 = {
  * in practice that appears to be what implementations use.  The section
  * 18.36.3 language is expected to be fixed in an erratum.
  */
-        .number                 = 1,
-        .nrprocs                = ARRAY_SIZE(nfs4_cb_procedures),
-        .procs                  = nfs4_cb_procedures
+	.number			= 1,
+	.nrprocs		= ARRAY_SIZE(nfs4_cb_procedures),
+	.procs			= nfs4_cb_procedures
 };
 
-static struct rpc_version *	nfs_cb_version[] = {
+static struct rpc_version *nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
 static struct rpc_program cb_program;
 
 static struct rpc_stat cb_stats = {
-		.program	= &cb_program
+	.program		= &cb_program
 };
 
 #define NFS4_CALLBACK 0x40000000
 static struct rpc_program cb_program = {
-		.name 		= "nfs4_cb",
-		.number		= NFS4_CALLBACK,
-		.nrvers		= ARRAY_SIZE(nfs_cb_version),
-		.version	= nfs_cb_version,
-		.stats		= &cb_stats,
-		.pipe_dir_name  = "/nfsd4_cb",
+	.name			= "nfs4_cb",
+	.number			= NFS4_CALLBACK,
+	.nrvers			= ARRAY_SIZE(nfs_cb_version),
+	.version		= nfs_cb_version,
+	.stats			= &cb_stats,
+	.pipe_dir_name		= "/nfsd4_cb",
 };
 
 static int max_cb_time(void)

