Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42581 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161130AbdKQRqR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 12:46:17 -0500
Received: by mail-io0-f193.google.com with SMTP id u42so9529756ioi.9
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2017 09:46:17 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v4 9/9] NFS: Kill all client RPCs if transient
Date: Fri, 17 Nov 2017 11:45:52 -0600
Message-Id: <20171117174552.18722-10-JPEWhacker@gmail.com>
In-Reply-To: <20171117174552.18722-1-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When unmounting with the MNT_FORCE flag, all client RPCs will be killed
in all mount points if the mount is transient

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/super.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 09c413c098ef..f97cec1a1dec 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -904,6 +904,18 @@ kill_rpc(struct rpc_clnt *rpc)
 	}
 }
 
+static void
+kill_client_rpc(struct nfs_client *client)
+{
+	struct nfs_server *server;
+
+	kill_rpc(client->cl_rpcclient);
+	list_for_each_entry_rcu(server, &client->cl_superblocks, client_link) {
+		kill_rpc(server->client_acl);
+		kill_rpc(server->client);
+	}
+}
+
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
@@ -914,8 +926,12 @@ void nfs_umount_begin(struct super_block *sb)
 
 	server = NFS_SB(sb);
 	/* -EIO all pending I/O */
-	kill_rpc(server->client_acl);
-	kill_rpc(server->client);
+	if (server->flags & NFS_MOUNT_TRANSIENT) {
+		kill_client_rpc(server->nfs_client);
+	} else {
+		kill_rpc(server->client_acl);
+		kill_rpc(server->client);
+	}
 }
 EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
@@ -926,13 +942,29 @@ restore_rpc(struct rpc_clnt *rpc)
 		__atomic_add_unless(&rpc->cl_kill_new_tasks, -1, 0);
 }
 
+static void
+restore_client_rpc(struct nfs_client *client)
+{
+	struct nfs_server *server;
+
+	restore_rpc(client->cl_rpcclient);
+	list_for_each_entry_rcu(server, &client->cl_superblocks, client_link) {
+		restore_rpc(server->client_acl);
+		restore_rpc(server->client);
+	}
+}
+
 void
 nfs_umount_end(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
-	restore_rpc(server->client_acl);
-	restore_rpc(server->client);
+	if (server->flags & NFS_MOUNT_TRANSIENT) {
+		restore_client_rpc(server->nfs_client);
+	} else {
+		restore_rpc(server->client_acl);
+		restore_rpc(server->client);
+	}
 }
 EXPORT_SYMBOL_GPL(nfs_umount_end);
 
-- 
2.13.6

