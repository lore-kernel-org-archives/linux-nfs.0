Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:39285 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030314AbdKQRqO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 12:46:14 -0500
Received: by mail-it0-f65.google.com with SMTP id y15so4965305ita.4
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2017 09:46:14 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v4 6/9] NFS: Add debugfs for nfs_server and nfs_client
Date: Fri, 17 Nov 2017 11:45:49 -0600
Message-Id: <20171117174552.18722-7-JPEWhacker@gmail.com>
In-Reply-To: <20171117174552.18722-1-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/Makefile           |   2 +-
 fs/nfs/client.c           |  87 ++++++++++++++++++++++++++--
 fs/nfs/debugfs.c          | 143 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/inode.c            |   5 ++
 fs/nfs/internal.h         |  10 ++++
 fs/nfs/nfs4client.c       |   1 +
 include/linux/nfs_fs_sb.h |   5 ++
 7 files changed, 247 insertions(+), 6 deletions(-)
 create mode 100644 fs/nfs/debugfs.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index c587e3c4c6a6..9a0553888a28 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -6,7 +6,7 @@
 obj-$(CONFIG_NFS_FS) += nfs.o
 
 CFLAGS_nfstrace.o += -I$(src)
-nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
+nfs-y 			:= client.o debugfs.o dir.o file.o getroot.o inode.o super.o \
 			   io.o direct.o pagelist.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o nfstrace.o export.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 22880ef6d8dd..7bab47d0dd07 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -142,6 +142,32 @@ void unregister_nfs_version(struct nfs_subversion *nfs)
 }
 EXPORT_SYMBOL_GPL(unregister_nfs_version);
 
+static DEFINE_IDA(nfs_client_ids);
+
+void
+nfs_cleanup_client_ids(void)
+{
+	ida_destroy(&nfs_client_ids);
+}
+
+static int
+nfs_alloc_client_id(struct nfs_client *client)
+{
+	int id;
+
+	id = ida_simple_get(&nfs_client_ids, 0, 0, GFP_KERNEL);
+	if (id < 0)
+		return id;
+	client->cl_id = id;
+	return 0;
+}
+
+static void
+nfs_free_client_id(struct nfs_client *client)
+{
+	ida_simple_remove(&nfs_client_ids, client->cl_id);
+}
+
 /*
  * Allocate a shared client record
  *
@@ -161,6 +187,8 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	if (!try_module_get(clp->cl_nfs_mod->owner))
 		goto error_dealloc;
 
+	nfs_alloc_client_id(clp);
+
 	clp->rpc_ops = clp->cl_nfs_mod->rpc_ops;
 
 	atomic_set(&clp->cl_count, 1);
@@ -249,8 +277,11 @@ void nfs_free_client(struct nfs_client *clp)
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
 
+	nfs_client_debugfs_unregister(clp);
+
 	put_net(clp->cl_net);
 	put_nfs_version(clp->cl_nfs_mod);
+	nfs_free_client_id(clp);
 	kfree(clp->cl_hostname);
 	kfree(clp->cl_acceptor);
 	kfree(clp);
@@ -380,6 +411,17 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
 	return clp;
 }
 
+static struct nfs_client *
+init_client(struct nfs_client *new, const struct nfs_client_initdata *cl_init)
+{
+	struct nfs_client *ret =
+		cl_init->nfs_mod->rpc_ops->init_client(new, cl_init);
+
+	if (ret)
+		nfs_client_debugfs_register(new);
+	return ret;
+}
+
 /*
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
@@ -411,7 +453,7 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 					&nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
 			new->cl_flags = cl_init->init_flags;
-			return rpc_ops->init_client(new, cl_init);
+			return init_client(new, cl_init);
 		}
 
 		spin_unlock(&nn->nfs_client_lock);
@@ -856,6 +898,32 @@ void nfs_server_remove_lists(struct nfs_server *server)
 }
 EXPORT_SYMBOL_GPL(nfs_server_remove_lists);
 
+static DEFINE_IDA(nfs_server_ids);
+
+void
+nfs_cleanup_server_ids(void)
+{
+	ida_destroy(&nfs_server_ids);
+}
+
+static int
+nfs_alloc_server_id(struct nfs_server *server)
+{
+	int id;
+
+	id = ida_simple_get(&nfs_server_ids, 0, 0, GFP_KERNEL);
+	if (id < 0)
+		return id;
+	server->id = id;
+	return 0;
+}
+
+static void
+nfs_free_server_id(struct nfs_server *server)
+{
+	ida_simple_remove(&nfs_server_ids, server->id);
+}
+
 /*
  * Allocate and initialise a server record
  */
@@ -867,6 +935,8 @@ struct nfs_server *nfs_alloc_server(void)
 	if (!server)
 		return NULL;
 
+	nfs_alloc_server_id(server);
+
 	server->client = server->client_acl = ERR_PTR(-EINVAL);
 
 	/* Zero out the NFS state stuff */
@@ -879,10 +949,8 @@ struct nfs_server *nfs_alloc_server(void)
 	atomic_set(&server->active, 0);
 
 	server->io_stats = nfs_alloc_iostats();
-	if (!server->io_stats) {
-		kfree(server);
-		return NULL;
-	}
+	if (!server->io_stats)
+		goto out_error;
 
 	ida_init(&server->openowner_id);
 	ida_init(&server->lockowner_id);
@@ -890,6 +958,10 @@ struct nfs_server *nfs_alloc_server(void)
 	rpc_init_wait_queue(&server->uoc_rpcwaitq, "NFS UOC");
 
 	return server;
+out_error:
+	nfs_free_server_id(server);
+	kfree(server);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(nfs_alloc_server);
 
@@ -910,9 +982,12 @@ void nfs_free_server(struct nfs_server *server)
 
 	nfs_put_client(server->nfs_client);
 
+	nfs_server_debugfs_unregister(server);
+
 	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
+	nfs_free_server_id(server);
 	kfree(server);
 	nfs_release_automount_timer();
 }
@@ -973,6 +1048,7 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	nfs_server_insert_lists(server);
 	server->mount_time = jiffies;
 	nfs_free_fattr(fattr);
+	nfs_server_debugfs_register(server);
 	return server;
 
 error:
@@ -1033,6 +1109,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	server->mount_time = jiffies;
 
 	nfs_free_fattr(fattr_fsinfo);
+	nfs_server_debugfs_register(server);
 	return server;
 
 out_free_server:
diff --git a/fs/nfs/debugfs.c b/fs/nfs/debugfs.c
new file mode 100644
index 000000000000..0195431427c2
--- /dev/null
+++ b/fs/nfs/debugfs.c
@@ -0,0 +1,143 @@
+// SPDX-License-Identifier: GPL-2.0
+/**
+ * debugfs interface for nfs
+ *
+ * (c) 2017 Garmin International
+ */
+
+#include <linux/debugfs.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfs_fs.h>
+
+#include "nfs4_fs.h"
+#include "internal.h"
+
+static struct dentry *topdir;
+static struct dentry *nfs_server_dir;
+static struct dentry *nfs_client_dir;
+
+static struct dentry*
+link_rpc_client(char const *name, struct rpc_clnt *client,
+		struct dentry *parent)
+{
+	int len;
+	char target[34]; /* "../../../sunrpc/rpc_clnt/" + 8 hex digits + '\0' */
+
+	if (IS_ERR(client) || !client->cl_debugfs)
+		return NULL;
+
+	len = snprintf(target, sizeof(target), "../../../sunrpc/rpc_clnt/%s",
+		       client->cl_debugfs->d_name.name);
+
+	if (len >= sizeof(target))
+		return NULL;
+
+	return debugfs_create_symlink(name, parent, target);
+}
+
+void
+nfs_server_debugfs_register(struct nfs_server *server)
+{
+	char name[26]; /* "../../nfs_client/" + 8 hex digits + '\0' */
+	int len;
+
+	if (server->debugfs || !nfs_server_dir)
+		return;
+
+	len = snprintf(name, sizeof(name), "%x", server->id);
+	if (len >= sizeof(name))
+		return;
+
+	server->debugfs = debugfs_create_dir(name, nfs_server_dir);
+	if (!server->debugfs)
+		return;
+
+	link_rpc_client("rpc_client", server->client, server->debugfs);
+	link_rpc_client("rpc_client_acl", server->client_acl, server->debugfs);
+
+	if (server->nfs_client->cl_debugfs) {
+		len = snprintf(name, sizeof(name), "../../nfs_client/%s",
+			       server->nfs_client->cl_debugfs->d_name.name);
+		if (len >= sizeof(name))
+			goto out_error;
+
+		if (!debugfs_create_symlink("nfs_client", server->debugfs,
+					    name))
+			goto out_error;
+	}
+
+	return;
+out_error:
+	debugfs_remove_recursive(server->debugfs);
+	server->debugfs = NULL;
+}
+EXPORT_SYMBOL_GPL(nfs_server_debugfs_register);
+
+void
+nfs_server_debugfs_unregister(struct nfs_server *server)
+{
+	debugfs_remove_recursive(server->debugfs);
+	server->debugfs = NULL;
+}
+
+void
+nfs_client_debugfs_register(struct nfs_client *client)
+{
+	char name[9]; /* 8 hex digits + '\0' */
+	int len;
+
+	if (client->cl_debugfs || !nfs_client_dir)
+		return;
+
+	len = snprintf(name, sizeof(name), "%x", client->cl_id);
+	if (len >= sizeof(name))
+		return;
+
+	client->cl_debugfs = debugfs_create_dir(name, nfs_client_dir);
+	if (!client->cl_debugfs)
+		return;
+
+	link_rpc_client("rpc_client", client->cl_rpcclient,
+			client->cl_debugfs);
+}
+
+void
+nfs_client_debugfs_unregister(struct nfs_client *client)
+{
+	debugfs_remove_recursive(client->cl_debugfs);
+	client->cl_debugfs = NULL;
+}
+
+void __exit
+nfs_debugfs_exit(void)
+{
+	debugfs_remove_recursive(topdir);
+	topdir = NULL;
+	nfs_client_dir = NULL;
+	nfs_server_dir = NULL;
+}
+
+void __init
+nfs_debugfs_init(void)
+{
+	topdir = debugfs_create_dir("nfs", NULL);
+	if (!topdir)
+		return;
+
+	nfs_server_dir = debugfs_create_dir("nfs_server", topdir);
+	if (!nfs_server_dir)
+		goto out_remove;
+
+	nfs_client_dir = debugfs_create_dir("nfs_client", topdir);
+	if (!nfs_client_dir)
+		goto out_remove;
+
+	return;
+out_remove:
+	debugfs_remove_recursive(topdir);
+	topdir = NULL;
+	nfs_server_dir = NULL;
+	nfs_client_dir = NULL;
+}
+
+
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 134d9f560240..28879236f949 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2144,6 +2144,8 @@ static int __init init_nfs_fs(void)
 	if (err)
 		goto out0;
 
+	nfs_debugfs_init();
+
 	return 0;
 out0:
 	rpc_proc_unregister(&init_net, "nfs");
@@ -2181,6 +2183,9 @@ static void __exit exit_nfs_fs(void)
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
+	nfs_cleanup_server_ids();
+	nfs_cleanup_client_ids();
+	nfs_debugfs_exit();
 }
 
 /* Not quite true; I just maintain it */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3ec165368a08..969958205cbd 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -156,6 +156,7 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 /* client.c */
 extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
+void nfs_cleanup_client_ids(void);
 extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
 int nfs_create_rpc_client(struct nfs_client *, const struct nfs_client_initdata *, rpc_authflavor_t);
 struct nfs_client *nfs_get_client(const struct nfs_client_initdata *);
@@ -165,6 +166,7 @@ void nfs_server_remove_lists(struct nfs_server *);
 void nfs_init_timeout_values(struct rpc_timeout *to, int proto, int timeo, int retrans);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
 		rpc_authflavor_t);
+void nfs_cleanup_server_ids(void);
 struct nfs_server *nfs_alloc_server(void);
 void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
 
@@ -561,6 +563,14 @@ void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq);
 extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
 
+/* debugfs.c */
+void nfs_server_debugfs_register(struct nfs_server *server);
+void nfs_server_debugfs_unregister(struct nfs_server *server);
+void nfs_client_debugfs_register(struct nfs_client *client);
+void nfs_client_debugfs_unregister(struct nfs_client *client);
+void __exit nfs_debugfs_exit(void);
+void __init nfs_debugfs_init(void);
+
 /* nfs4proc.c */
 extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct nfs_client_initdata *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e9bea90dc017..ef725106e45c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1086,6 +1086,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (error < 0)
 		goto error;
 
+	nfs_server_debugfs_register(server);
 	return server;
 
 error:
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 286b71c418b4..5dac856355f0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -27,6 +27,7 @@ struct nfs41_impl_id;
 struct nfs_client {
 	atomic_t		cl_count;
 	atomic_t		cl_mds_count;
+	unsigned int		cl_id;		/* client id */
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
@@ -120,6 +121,7 @@ struct nfs_client {
 #endif
 
 	struct net		*cl_net;
+	struct dentry		*cl_debugfs;	/* debugfs entry */
 };
 
 /*
@@ -131,6 +133,7 @@ struct nfs_server {
 						 * that share the same client
 						 */
 	struct list_head	master_link;	/* link in master servers list */
+	unsigned int		id;		/* server id */
 	struct rpc_clnt *	client;		/* RPC client handle */
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
 	struct nlm_host		*nlm_host;	/* NLM client handle */
@@ -225,6 +228,8 @@ struct nfs_server {
 	unsigned short		mountd_port;
 	unsigned short		mountd_protocol;
 	struct rpc_wait_queue	uoc_rpcwaitq;
+
+	struct dentry		*debugfs;
 };
 
 /* Server capabilities */
-- 
2.13.6

