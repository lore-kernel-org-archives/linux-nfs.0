Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10685 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750867AbeDMRD1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:03:27 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 09/13] NFS export nfs4_async_handle_error
Date: Fri, 13 Apr 2018 13:03:10 -0400
Message-ID: <20180413170314.17634-10-kolga@netapp.com>
In-Reply-To: <20180413170314.17634-1-kolga@netapp.com>
References: <20180413170314.17634-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make this function available to nfs42proc.c

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h  | 3 +++
 fs/nfs/nfs4proc.c | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b374f68..7303a6f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -248,6 +248,9 @@ int nfs4_replace_transport(struct nfs_server *server,
 
 /* nfs4proc.c */
 extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
+extern int nfs4_async_handle_error(struct rpc_task *task,
+				   struct nfs_server *server,
+				   struct nfs4_state *state, long *timeout);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 46571f7a..dcd08ba 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -553,7 +553,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 	return ret;
 }
 
-static int
+int
 nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 			struct nfs4_state *state, long *timeout)
 {
-- 
1.8.3.1

