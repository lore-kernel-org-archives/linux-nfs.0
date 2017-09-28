Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18018 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752114AbdI1R21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:27 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 09/12] NFS export nfs4_async_handle_error
Date: Thu, 28 Sep 2017 13:28:16 -0400
Message-ID: <20170928172819.50703-10-kolga@netapp.com>
In-Reply-To: <20170928172819.50703-1-kolga@netapp.com>
References: <20170928172819.50703-1-kolga@netapp.com>
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
index ac4f10b..c7225bb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -244,6 +244,9 @@ int nfs4_replace_transport(struct nfs_server *server,
 
 /* nfs4proc.c */
 extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
+extern int nfs4_async_handle_error(struct rpc_task *task,
+				   struct nfs_server *server,
+				   struct nfs4_state *state, long *timeout);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3926f11..f1bf19e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -551,7 +551,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 	return ret;
 }
 
-static int
+int
 nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 			struct nfs4_state *state, long *timeout)
 {
-- 
1.8.3.1

