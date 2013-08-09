Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:63668 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968172Ab3HIQsL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:11 -0400
Received: by mail-ye0-f174.google.com with SMTP id q9so1289440yen.33
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:11 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id y70sm20671009yhe.15.2013.08.09.09.48.10
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:10 -0700 (PDT)
Subject: [PATCH v2 03/33] NFS: Clean up nfs4_setup_sequence()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:09 -0400
Message-ID: <20130809164809.5362.92077.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Both the NFSv4.0 and NFSv4.1 version of
nfs4_setup_sequence() are used only in fs/nfs/nfs4proc.c.  No need
to keep global header declarations for either version.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |   11 -----------
 fs/nfs/nfs4proc.c |   16 ++++++++++++----
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d7bb59d..0feb238 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -247,9 +247,6 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 	return server->nfs_client->cl_session;
 }
 
-extern int nfs4_setup_sequence(const struct nfs_server *server,
-		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		struct rpc_task *task);
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
@@ -278,14 +275,6 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 	return NULL;
 }
 
-static inline int nfs4_setup_sequence(const struct nfs_server *server,
-		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		struct rpc_task *task)
-{
-	rpc_call_start(task);
-	return 0;
-}
-
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 63e2279..275d17d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -679,10 +679,10 @@ out_sleep:
 }
 EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 
-int nfs4_setup_sequence(const struct nfs_server *server,
-			struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res,
-			struct rpc_task *task)
+static int nfs4_setup_sequence(const struct nfs_server *server,
+			       struct nfs4_sequence_args *args,
+			       struct nfs4_sequence_res *res,
+			       struct rpc_task *task)
 {
 	struct nfs4_session *session = nfs4_get_session(server);
 	int ret = 0;
@@ -765,6 +765,14 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
 {
 }
 
+static int nfs4_setup_sequence(const struct nfs_server *server,
+			       struct nfs4_sequence_args *args,
+			       struct nfs4_sequence_res *res,
+			       struct rpc_task *task)
+{
+	rpc_call_start(task);
+	return 0;
+}
 
 static int nfs4_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)

