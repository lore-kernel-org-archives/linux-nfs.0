Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61502 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbaLPTCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:31 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so14724569pad.13
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:31 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 14/50] nfs4: export nfs4_sequence_done
Date: Tue, 16 Dec 2014 11:01:17 -0800
Message-Id: <1418756513-95187-15-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4_fs.h  | 2 ++
 fs/nfs/nfs4proc.c | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

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
index 9b1a481..4883a42 100644
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
-- 
1.9.3

