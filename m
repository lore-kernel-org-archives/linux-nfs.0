Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:42365 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215AbbAVXhC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:37:02 -0500
Received: by mail-pd0-f175.google.com with SMTP id fl12so4610699pdb.6
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:37:02 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 14/51] nfs4: export nfs4_sequence_done
Date: Thu, 22 Jan 2015 15:35:46 -0800
Message-Id: <1421969783-92997-15-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4_fs.h  | 2 ++
 fs/nfs/nfs4proc.c | 9 +++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 90c4ffe..b3c771e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -447,6 +447,8 @@ extern int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
 				struct rpc_task *task);
+extern int nfs4_sequence_done(struct rpc_task *task,
+			      struct nfs4_sequence_res *res);
 
 extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e98dda7..f358262 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -694,8 +694,7 @@ out_retry:
 }
 EXPORT_SYMBOL_GPL(nfs41_sequence_done);
 
-static int nfs4_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
+int nfs4_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	if (res->sr_slot == NULL)
 		return 1;
@@ -703,6 +702,7 @@ static int nfs4_sequence_done(struct rpc_task *task,
 		return nfs40_sequence_done(task, res);
 	return nfs41_sequence_done(task, res);
 }
+EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
 int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
@@ -823,11 +823,12 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 				    args, res, task);
 }
 
-static int nfs4_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
+int nfs4_sequence_done(struct rpc_task *task,
+		       struct nfs4_sequence_res *res)
 {
 	return nfs40_sequence_done(task, res);
 }
+EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
 #endif	/* !CONFIG_NFS_V4_1 */
 
-- 
1.9.3

