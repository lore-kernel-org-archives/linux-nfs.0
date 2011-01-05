Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43304 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169Ab1AEB6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 20:58:01 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 5/5] NFSv4: Send unmapped uid/gids to the server when using auth_sys
Date: Tue,  4 Jan 2011 20:57:51 -0500
Message-Id: <1294192671-18864-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1294192671-18864-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1294192671-18864-1-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-2-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-3-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-4-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The new behaviour is enabled using the new module parameter
'nfs4_disable_idmapping'.

Note that if the server rejects an unmapped uid or gid, then
the client will automatically switch back to using the idmapper.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/kernel-parameters.txt |    8 ++++++++
 fs/nfs/client.c                     |   16 ++++++++++++++++
 fs/nfs/idmap.c                      |   21 +++++++++++++--------
 fs/nfs/nfs4proc.c                   |   15 ++++++++++++++-
 include/linux/nfs_fs_sb.h           |    1 +
 5 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cdd2a6e..51a74a3 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1573,6 +1573,14 @@ and is between 256 and 4096 characters. It is defined in the file
 			of returning the full 64-bit number.
 			The default is to return 64-bit inode numbers.
 
+	nfs.nfs4_disable_idmapping=
+			[NFSv4] When set, this option disables the NFSv4
+			idmapper on the client, but only if the mount
+			is using the 'sec=sys' security flavour. This may
+			make migration from legacy NFSv2/v3 systems easier
+			provided that the server has the appropriate support.
+			The default is to always enable NFSv4 idmapping.
+
 	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
 			when a NMI is triggered.
 			Format: [state][,regs][,debounce][,die]
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7908530..a6c0324 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -58,6 +58,11 @@ static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 
 /*
+ * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
+ */
+static int nfs4_disable_idmapping = 0;
+
+/*
  * RPC cruft for NFS
  */
 static struct rpc_version *nfs_version[5] = {
@@ -1447,6 +1452,13 @@ static int nfs4_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
+	/*
+	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
+	 * authentication.
+	 */
+	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
+		server->caps |= NFS_CAP_UIDGID_NOMAP;
+
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
 	if (data->wsize)
@@ -1864,3 +1876,7 @@ void nfs_fs_proc_exit(void)
 }
 
 #endif /* CONFIG_PROC_FS */
+
+module_param(nfs4_disable_idmapping, bool, 0644);
+MODULE_PARM_DESC(nfs4_disable_idmapping,
+		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index e2d579d..ee4ab8f 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -257,17 +257,20 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
 
 int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
-	int ret;
-	ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
+	int ret = -EINVAL;
+
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
 }
 int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
 {
-	int ret;
+	int ret = -EINVAL;
 
-	ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(gid, buf, buflen);
 	return ret;
@@ -750,9 +753,10 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
 int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
-	int ret;
+	int ret = -EINVAL;
 
-	ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
@@ -760,9 +764,10 @@ int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, s
 int nfs_map_gid_to_group(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
-	int ret;
+	int ret = -EINVAL;
 
-	ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 39a2e3c..e06b531 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -243,7 +243,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 /* This is the error handling routine for processes that are allowed
  * to sleep.
  */
-static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
@@ -294,6 +294,19 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 				break;
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
+			break;
+		case -NFS4ERR_BADOWNER:
+			/* The following works around a Linux server bug! */
+		case -NFS4ERR_BADNAME:
+			if (server->caps & NFS_CAP_UIDGID_NOMAP) {
+				server->caps &= ~NFS_CAP_UIDGID_NOMAP;
+				exception->retry = 1;
+				printk(KERN_WARNING "NFS: v4 server %s "
+						"does not accept raw "
+						"uid/gids. "
+						"Reenabling the idmapper.\n",
+						server->nfs_client->cl_hostname);
+			}
 	}
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b197563..8fa77c6 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -180,6 +180,7 @@ struct nfs_server {
 #define NFS_CAP_CTIME		(1U << 12)
 #define NFS_CAP_MTIME		(1U << 13)
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
+#define NFS_CAP_UIDGID_NOMAP	(1U << 15)
 
 
 /* maximum number of slots to use */
-- 
1.7.3.4

