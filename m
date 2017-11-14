Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44211 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755339AbdKNXGl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 18:06:41 -0500
Received: by mail-io0-f194.google.com with SMTP id q101so8820048ioi.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 15:06:40 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v3 6/7] NFS: Add API to fail client
Date: Tue, 14 Nov 2017 17:06:30 -0600
Message-Id: <20171114230631.14682-7-JPEWhacker@gmail.com>
In-Reply-To: <20171114230631.14682-1-JPEWhacker@gmail.com>
References: <20171114230631.14682-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Failing a client will cause all current and future RPCs sent to it to
fail with -EIO

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/client.c           | 25 +++++++++++++++++++++++++
 fs/nfs/internal.h         |  1 +
 include/linux/nfs_fs_sb.h |  2 ++
 3 files changed, 28 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9d88dea4bc59..0e41b8d5904a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -758,6 +758,31 @@ static int nfs_init_server(struct nfs_server *server,
 	return error;
 }
 
+static void
+fail_rpc_client(struct rpc_clnt *client, bool failed)
+{
+	if (IS_ERR(client))
+		return;
+
+	client->cl_kill_new_tasks = failed;
+	if (failed)
+		rpc_killall_tasks(client);
+}
+
+void
+nfs_client_failed(struct nfs_client *client, bool failed)
+{
+	struct nfs_server *server;
+
+	client->cl_failed = failed;
+	fail_rpc_client(client->cl_rpcclient, failed);
+
+	list_for_each_entry_rcu(server, &client->cl_superblocks, client_link) {
+		fail_rpc_client(server->client, failed);
+		fail_rpc_client(server->client_acl, failed);
+	}
+}
+
 /*
  * Load up the server record from information gained in an fsinfo record
  */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 75da8185ceb8..b713f9f38d6d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -159,6 +159,7 @@ extern void nfs_clients_init(struct net *net);
 void nfs_cleanup_client_ids(void);
 extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
 int nfs_create_rpc_client(struct nfs_client *, const struct nfs_client_initdata *, rpc_authflavor_t);
+void nfs_client_failed(struct nfs_client *client, bool failed);
 struct nfs_client *nfs_get_client(const struct nfs_client_initdata *);
 int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
 void nfs_server_insert_lists(struct nfs_server *);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0eb7093faea7..6d182da286a2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -58,6 +58,8 @@ struct nfs_client {
 	int			cl_proto;	/* Network transport protocol */
 	struct nfs_subversion *	cl_nfs_mod;	/* pointer to nfs version module */
 
+	bool			cl_failed;	/* Client has failed */
+
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
-- 
2.13.6

