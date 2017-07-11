Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:25395 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933400AbdGKQo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:28 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 10/42] NFS export nfs4_async_handle_error
Date: Tue, 11 Jul 2017 12:43:44 -0400
Message-ID: <20170711164416.1982-11-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make this function available to nfs42proc.c

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4_fs.h  | 3 +++
 fs/nfs/nfs4proc.c | 3 ++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc..f5d014e 100644
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
index b37e528..fdb6b76 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -548,7 +548,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 	return ret;
 }
 
-static int
+int
 nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
 			struct nfs4_state *state, long *timeout)
 {
@@ -569,6 +569,7 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 		return -EAGAIN;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs4_async_handle_error);
 
 /*
  * Return 'true' if 'clp' is using an rpc_client that is integrity protected
-- 
1.8.3.1

