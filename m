Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47363 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753374Ab2A3Tay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 14:30:54 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 14:30:53 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6501C38C8063
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:30:00 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJU0QG313896
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:30:00 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTxWb015814
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:59 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvqO015737
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:57 -0200
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/13] NFS: Avoid spurious replication recoveries
Date: Mon, 30 Jan 2012 13:29:55 -0600
Message-Id: <1327951795-16400-14-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As soon as we detect a server failure, we quickly handle replication
recovery without waiting for all the active commands to finish from the
failed server.  The first error would cause us to work with a different
(replicated) server.

Any later failures from the old server are indistinguishable from the
new replicated server. These failures from the old server trigger a
spurious replication recovery again. To avoid this, we add start time to
nfs_client. If this is a recent enough nfs_client, we don't handle
replication recovery and just retry the request instead.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4namespace.c    |   23 +++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 000ebdb..f0d8d24 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1477,6 +1477,7 @@ int nfs4_clone_client(struct nfs_client *clp, const struct sockaddr *sap,
 	 * lose state.
 	 */
 	new->cl_boot_time = clp->cl_boot_time;
+	new->cl_start_time = jiffies;
 
 	dprintk("<-- %s moved (%llx:%llx) to nfs_client %p\n", __func__,
 			(unsigned long long)server->fsid.major,
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index ee75e27..617d6bf 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -356,6 +356,29 @@ int nfs4_replace_transport(struct nfs_server *server)
 	unsigned int i;
 	int error;
 
+	/*
+	 * As soon as we detect a server failure, we quickly handle
+	 * replication recovery without waiting for all the active
+	 * commands to finish from the failed server.  The first error
+	 * would cause us to work with a different (replicated) server.
+	 *
+	 * Any later failures from the old server are indistinguishable
+	 * from the new replicated server. These failures from the old
+	 * server trigger a spurious replication recovery again. To
+	 * avoid this, we add start time to nfs_client. If this is a
+	 * recent enough nfs_client, we don't handle replication
+	 * recovery and just retry the request instead.
+	 */
+#define NFS_REPLI_SETTLE(rclient) (2 * (rclient)->cl_timeout->to_initval)
+	if (time_before(jiffies, server->nfs_client->cl_start_time +
+		       NFS_REPLI_SETTLE(server->client))) {
+		dprintk("%s() ignoring spurious replication request, "
+			"current: %lu, client start: %lu, repli_settle: %lu\n",
+			__func__, jiffies, server->nfs_client->cl_start_time,
+			NFS_REPLI_SETTLE(server->client));
+		return 0;
+	}
+
 	sap = kmalloc(addr_bufsize, GFP_KERNEL);
 	if (sap == NULL) {
 		error = -ENOMEM;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8c16ec5..9d79a0e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -88,6 +88,7 @@ struct nfs_client {
 #endif
 
 	struct server_scope	*server_scope;	/* from exchange_id */
+	unsigned long		cl_start_time;
 };
 
 /*
-- 
1.7.8.3

