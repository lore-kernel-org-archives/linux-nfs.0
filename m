Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664Ab3CSNHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/11] NFSv4: Prepare for minorversion-specific nfs_server capabilities
Date: Tue, 19 Mar 2013 09:07:38 -0400
Message-Id: <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up the setting of the nfs_server->caps, by shoving it all
into nfs4_server_common_setup().
Then add an 'initial capabilities' field into struct nfs4_minor_version_ops.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h    |  1 +
 fs/nfs/nfs4client.c | 24 +++++++++++++-----------
 fs/nfs/nfs4proc.c   |  8 ++++++++
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 627a74f..7ef19ce 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -36,6 +36,7 @@ enum nfs4_client_state {
 
 struct nfs4_minor_version_ops {
 	u32	minor_version;
+	unsigned init_caps;
 
 	int	(*call_sync)(struct rpc_clnt *clnt,
 			struct nfs_server *server,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ac4fc9a..17b34b2 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -717,6 +717,19 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	if (error < 0)
 		goto out;
 
+	/* Set the basic capabilities */
+	server->caps |= server->nfs_client->cl_mvops->init_caps;
+	if (server->flags & NFS_MOUNT_NORDIRPLUS)
+			server->caps &= ~NFS_CAP_READDIRPLUS;
+	/*
+	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
+	 * authentication.
+	 */
+	if (nfs4_disable_idmapping &&
+			server->client->cl_auth->au_flavor == RPC_AUTH_UNIX)
+		server->caps |= NFS_CAP_UIDGID_NOMAP;
+
+
 	/* Probe the root fh to retrieve its FSID and filehandle */
 	error = nfs4_get_rootfh(server, mntfh);
 	if (error < 0)
@@ -760,9 +773,6 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|NFS_CAP_POSIX_LOCK;
-	if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
-			server->caps |= NFS_CAP_READDIRPLUS;
 	server->options = data->options;
 
 	/* Get a client record */
@@ -779,13 +789,6 @@ static int nfs4_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
-	/*
-	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
-	 * authentication.
-	 */
-	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
-		server->caps |= NFS_CAP_UIDGID_NOMAP;
-
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
 	if (data->wsize)
@@ -863,7 +866,6 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Initialise the client representation from the parent server */
 	nfs_server_copy_userdata(server, parent_server);
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 028bd52..4fc1496 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6837,6 +6837,10 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 
 static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
+	.init_caps = NFS_CAP_READDIRPLUS
+		| NFS_CAP_ATOMIC_OPEN
+		| NFS_CAP_CHANGE_ATTR
+		| NFS_CAP_POSIX_LOCK,
 	.call_sync = _nfs4_call_sync,
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
@@ -6848,6 +6852,10 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
+	.init_caps = NFS_CAP_READDIRPLUS
+		| NFS_CAP_ATOMIC_OPEN
+		| NFS_CAP_CHANGE_ATTR
+		| NFS_CAP_POSIX_LOCK,
 	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
-- 
1.8.1.4

