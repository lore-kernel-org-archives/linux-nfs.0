Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:61539 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932704AbeGITOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:14:00 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 07/13] NFS export nfs4_async_handle_error
Date: Mon, 9 Jul 2018 15:13:33 -0400
Message-ID: <20180709191339.44740-8-kolga@netapp.com>
In-Reply-To: <20180709191339.44740-1-kolga@netapp.com>
References: <20180709191339.44740-1-kolga@netapp.com>
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
index 137e18a..a417aaa 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -273,6 +273,9 @@ int nfs4_replace_transport(struct nfs_server *server,
 
 /* nfs4proc.c */
 extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
+extern int nfs4_async_handle_error(struct rpc_task *task,
+				   struct nfs_server *server,
+				   struct nfs4_state *state, long *timeout);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 95e35c8..d820284 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -586,7 +586,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 	return ret;
 }
 
-static int
+int
 nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 			struct nfs4_state *state, long *timeout)
 {
-- 
1.8.3.1

