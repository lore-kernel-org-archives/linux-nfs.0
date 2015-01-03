Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:51924 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbbACVKB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:10:01 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so16171256iec.40
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:10:01 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 2/4] NFSv4: Cache the NFSv4/v4.1 client owner_id in the struct nfs_client
Date: Sat,  3 Jan 2015 16:09:55 -0500
Message-Id: <1420319397-37704-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1420319397-37704-1-git-send-email-trond.myklebust@primarydata.com>
References: <1420319397-37704-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we cache the NFSv4/v4.1 client owner_id so that we can
verify it when we're doing trunking detection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c       |  1 +
 fs/nfs/nfs4proc.c         | 19 +++++++++++++++----
 include/linux/nfs_fs_sb.h |  3 +++
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d949d0f378ec..6ee9bf69a7a6 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -228,6 +228,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 	kfree(clp->cl_serverowner);
 	kfree(clp->cl_serverscope);
 	kfree(clp->cl_implid);
+	kfree(clp->cl_owner_id);
 }
 
 void nfs4_free_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 002c7dfedb08..8d06217b95ce 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4917,11 +4917,14 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 }
 
 static unsigned int
-nfs4_init_nonuniform_client_string(const struct nfs_client *clp,
+nfs4_init_nonuniform_client_string(struct nfs_client *clp,
 				   char *buf, size_t len)
 {
 	unsigned int result;
 
+	if (clp->cl_owner_id != NULL)
+		return strlcpy(buf, clp->cl_owner_id, len);
+
 	rcu_read_lock();
 	result = scnprintf(buf, len, "Linux NFSv4.0 %s/%s %s",
 				clp->cl_ipaddr,
@@ -4930,24 +4933,32 @@ nfs4_init_nonuniform_client_string(const struct nfs_client *clp,
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
+	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
 	return result;
 }
 
 static unsigned int
-nfs4_init_uniform_client_string(const struct nfs_client *clp,
+nfs4_init_uniform_client_string(struct nfs_client *clp,
 				char *buf, size_t len)
 {
 	const char *nodename = clp->cl_rpcclient->cl_nodename;
+	unsigned int result;
+
+	if (clp->cl_owner_id != NULL)
+		return strlcpy(buf, clp->cl_owner_id, len);
 
 	if (nfs4_client_id_uniquifier[0] != '\0')
-		return scnprintf(buf, len, "Linux NFSv%u.%u %s/%s",
+		result = scnprintf(buf, len, "Linux NFSv%u.%u %s/%s",
 				clp->rpc_ops->version,
 				clp->cl_minorversion,
 				nfs4_client_id_uniquifier,
 				nodename);
-	return scnprintf(buf, len, "Linux NFSv%u.%u %s",
+	else
+		result = scnprintf(buf, len, "Linux NFSv%u.%u %s",
 				clp->rpc_ops->version, clp->cl_minorversion,
 				nodename);
+	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
+	return result;
 }
 
 /*
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1e37fbb78f7a..ddea982355f3 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -74,6 +74,9 @@ struct nfs_client {
 	/* idmapper */
 	struct idmap *		cl_idmap;
 
+	/* Client owner identifier */
+	const char *		cl_owner_id;
+
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the mv0 callback address.
 	 */
-- 
2.1.0

