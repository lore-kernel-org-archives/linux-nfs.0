Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:55808 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199Ab1EITig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:38:36 -0400
Received: by mail-yi0-f46.google.com with SMTP id 27so1915854yia.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:38:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/16] NFS: Remove "const" from "struct nfs_server *" fields
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:38:32 -0400
Message-ID: <20110509193832.16568.76338.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We're about to pass the nfs_server pointer in some NFSv4 argument and
result structures to functions that may change it, so it's no longer
"const".

The preference here is to maintain existing whitespace style rather
than answer all the nits called out by checkpatch.pl.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c       |    2 +-
 include/linux/nfs_xdr.h |   28 ++++++++++++++--------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bb6b128..1168bb2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4027,7 +4027,7 @@ struct nfs4_unlockdata {
 	struct nfs4_lock_state *lsp;
 	struct nfs_open_context *ctx;
 	struct file_lock fl;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	unsigned long timestamp;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 22e34d3..ab17345 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -288,7 +288,7 @@ struct nfs_openargs {
 		fmode_t		delegation_type;	/* CLAIM_PREVIOUS */
 	} u;
 	const struct qstr *	name;
-	const struct nfs_server *server;	 /* Needed for ID mapping */
+	struct nfs_server *	server;		/* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
 	struct nfs4_sequence_args	seq_args;
@@ -302,7 +302,7 @@ struct nfs_openres {
 	struct nfs_fattr *      f_attr;
 	struct nfs_fattr *      dir_attr;
 	struct nfs_seqid *	seqid;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	fmode_t			delegation_type;
 	nfs4_stateid		delegation;
 	__u32			do_recall;
@@ -341,7 +341,7 @@ struct nfs_closeres {
 	nfs4_stateid            stateid;
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	struct nfs4_sequence_res	seq_res;
 };
 /*
@@ -413,7 +413,7 @@ struct nfs4_delegreturnargs {
 
 struct nfs4_delegreturnres {
 	struct nfs_fattr * fattr;
-	const struct nfs_server *server;
+	struct nfs_server * server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -463,7 +463,7 @@ struct nfs_writeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_writeverf *	verf;
 	__u32			count;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -478,7 +478,7 @@ struct nfs_removeargs {
 };
 
 struct nfs_removeres {
-	const struct nfs_server *server;
+	struct nfs_server	*server;
 	struct nfs_fattr	*dir_attr;
 	struct nfs4_change_info	cinfo;
 	struct nfs4_sequence_res 	seq_res;
@@ -497,7 +497,7 @@ struct nfs_renameargs {
 };
 
 struct nfs_renameres {
-	const struct nfs_server		*server;
+	struct nfs_server		*server;
 	struct nfs4_change_info		old_cinfo;
 	struct nfs_fattr		*old_fattr;
 	struct nfs4_change_info		new_cinfo;
@@ -578,7 +578,7 @@ struct nfs_getaclres {
 
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -751,7 +751,7 @@ struct nfs4_accessargs {
 };
 
 struct nfs4_accessres {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	u32				supported;
 	u32				access;
@@ -779,7 +779,7 @@ struct nfs4_create_arg {
 };
 
 struct nfs4_create_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
@@ -805,7 +805,7 @@ struct nfs4_getattr_arg {
 };
 
 struct nfs4_getattr_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs4_sequence_res	seq_res;
 };
@@ -819,7 +819,7 @@ struct nfs4_link_arg {
 };
 
 struct nfs4_link_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
@@ -835,7 +835,7 @@ struct nfs4_lookup_arg {
 };
 
 struct nfs4_lookup_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
 	struct nfs4_sequence_res	seq_res;
@@ -950,7 +950,7 @@ struct nfs4_fs_location {
 #define NFS4_FS_LOCATIONS_MAXENTRIES 10
 struct nfs4_fs_locations {
 	struct nfs_fattr fattr;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	struct nfs4_pathname fs_path;
 	int nlocations;
 	struct nfs4_fs_location locations[NFS4_FS_LOCATIONS_MAXENTRIES];

