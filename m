Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34754 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378AbbITUpP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 16:45:15 -0400
Received: by ykdg206 with SMTP id g206so87282026ykd.1
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 13:45:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: nfs4_async_handle_error should take a non-const nfs_server
Date: Sun, 20 Sep 2015 16:45:09 -0400
Message-Id: <1442781911-76248-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1442781911-76248-2-git-send-email-trond.myklebust@primarydata.com>
References: <1442781911-76248-1-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For symmetry with the synchronous handler, and so that we can potentially
handle errors such as NFS4ERR_BADNAME.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 6 +++---
 include/linux/nfs_xdr.h | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ab48308f195..b6bf246b9b6c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -78,7 +78,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, long *);
+static int nfs4_async_handle_error(struct rpc_task *, struct nfs_server *, struct nfs4_state *, long *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
@@ -4956,7 +4956,7 @@ out:
 
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
+nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 			struct nfs4_state *state, long *timeout)
 {
 	struct nfs_client *clp = server->nfs_client;
@@ -5530,7 +5530,7 @@ struct nfs4_unlockdata {
 	struct nfs4_lock_state *lsp;
 	struct nfs_open_context *ctx;
 	struct file_lock fl;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	unsigned long timestamp;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52faf7e96c65..53f2acc68baf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -528,7 +528,7 @@ struct nfs4_delegreturnargs {
 struct nfs4_delegreturnres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr * fattr;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 };
 
 /*
@@ -601,7 +601,7 @@ struct nfs_removeargs {
 
 struct nfs_removeres {
 	struct nfs4_sequence_res 	seq_res;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	struct nfs_fattr	*dir_attr;
 	struct nfs4_change_info	cinfo;
 };
@@ -619,7 +619,7 @@ struct nfs_renameargs {
 
 struct nfs_renameres {
 	struct nfs4_sequence_res	seq_res;
-	const struct nfs_server		*server;
+	struct nfs_server		*server;
 	struct nfs4_change_info		old_cinfo;
 	struct nfs_fattr		*old_fattr;
 	struct nfs4_change_info		new_cinfo;
-- 
2.4.3

