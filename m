Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:45330 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964933Ab3GLQcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:32:21 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so3193330ghb.23
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:32:21 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id e69sm69034701yhl.3.2013.07.12.09.32.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:20 -0700 (PDT)
Subject: [PATCH v1 06/19] NFS: Clean up nfs4_setup_sequence()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:19 -0400
Message-ID: <20130712163219.1444.82239.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4.0-only version of nfs4_setup_sequence() is a static inline
function defined in a header file.  We're about to add a little more
to the NFSv4.0-only version, so move the NFSv4.0-only version into
nfs4proc.c next to the NFSv4.1 version.

There are no callsites outside of nfs4proc.c, so I removed the
header declarations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |   11 -----------
 fs/nfs/nfs4proc.c |   16 ++++++++++++----
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 40457e2..419fc87 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -251,9 +251,6 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 	return server->nfs_client->cl_session;
 }
 
-extern int nfs4_setup_sequence(const struct nfs_server *server,
-		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		struct rpc_task *task);
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
@@ -282,14 +279,6 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
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
index d7b2c85..7b2e008 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -640,10 +640,10 @@ out_sleep:
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
@@ -717,6 +717,14 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
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

