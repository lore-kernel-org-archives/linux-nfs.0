Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab1CNM6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:58:00 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:58:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/12] NFS: Remove "const" from "struct nfs_server *" fields
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:57:58 -0400
Message-ID: <20110314125758.2413.94921.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
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

 include/linux/nfs_xdr.h |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bcf823b..b9ae049 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -256,7 +256,7 @@ struct nfs_openargs {
 		fmode_t		delegation_type;	/* CLAIM_PREVIOUS */
 	} u;
 	const struct qstr *	name;
-	const struct nfs_server *server;	 /* Needed for ID mapping */
+	struct nfs_server *	server;		/* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
 	struct nfs4_sequence_args	seq_args;
@@ -270,7 +270,7 @@ struct nfs_openres {
 	struct nfs_fattr *      f_attr;
 	struct nfs_fattr *      dir_attr;
 	struct nfs_seqid *	seqid;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	fmode_t			delegation_type;
 	nfs4_stateid		delegation;
 	__u32			do_recall;
@@ -309,7 +309,7 @@ struct nfs_closeres {
 	nfs4_stateid            stateid;
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	struct nfs4_sequence_res	seq_res;
 };
 /*
@@ -381,7 +381,7 @@ struct nfs4_delegreturnargs {
 
 struct nfs4_delegreturnres {
 	struct nfs_fattr * fattr;
-	const struct nfs_server *server;
+	struct nfs_server * server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -431,7 +431,7 @@ struct nfs_writeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_writeverf *	verf;
 	__u32			count;
-	const struct nfs_server *server;
+	struct nfs_server *	server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -446,7 +446,7 @@ struct nfs_removeargs {
 };
 
 struct nfs_removeres {
-	const struct nfs_server *server;
+	struct nfs_server	*server;
 	struct nfs_fattr	*dir_attr;
 	struct nfs4_change_info	cinfo;
 	struct nfs4_sequence_res 	seq_res;
@@ -465,7 +465,7 @@ struct nfs_renameargs {
 };
 
 struct nfs_renameres {
-	const struct nfs_server		*server;
+	struct nfs_server		*server;
 	struct nfs4_change_info		old_cinfo;
 	struct nfs_fattr		*old_fattr;
 	struct nfs4_change_info		new_cinfo;
@@ -546,7 +546,7 @@ struct nfs_getaclres {
 
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -719,7 +719,7 @@ struct nfs4_accessargs {
 };
 
 struct nfs4_accessres {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	u32				supported;
 	u32				access;
@@ -747,7 +747,7 @@ struct nfs4_create_arg {
 };
 
 struct nfs4_create_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
@@ -773,7 +773,7 @@ struct nfs4_getattr_arg {
 };
 
 struct nfs4_getattr_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs4_sequence_res	seq_res;
 };
@@ -787,7 +787,7 @@ struct nfs4_link_arg {
 };
 
 struct nfs4_link_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
@@ -803,7 +803,7 @@ struct nfs4_lookup_arg {
 };
 
 struct nfs4_lookup_res {
-	const struct nfs_server *	server;
+	struct nfs_server *		server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
 	struct nfs4_sequence_res	seq_res;
@@ -918,7 +918,7 @@ struct nfs4_fs_location {
 #define NFS4_FS_LOCATIONS_MAXENTRIES 10
 struct nfs4_fs_locations {
 	struct nfs_fattr fattr;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	struct nfs4_pathname fs_path;
 	int nlocations;
 	struct nfs4_fs_location locations[NFS4_FS_LOCATIONS_MAXENTRIES];

