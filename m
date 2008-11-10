From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 17/85] nfs41: fallback to lower minorversion if nfs4_create_server fails
Date: Mon, 10 Nov 2008 22:20:48 +0200
Message-ID: <1226348448-7751-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60753 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbYKJUUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:54 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

retry nfs4_create_server with lower minorversion on minorvers_mismatch error

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 11c845d..0a8a082 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1118,15 +1118,17 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 {
 	struct nfs_fattr fattr;
 	struct nfs_server *server;
+	int minorvers = data->minorversion;
 	int error;
 
 	dprintk("--> nfs4_create_server()\n");
 
+retry:
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	server->minorversion = data->minorversion;
+	server->minorversion = minorvers;
 
 	/* set up the general RPC client */
 	error = nfs4_init_server(server, data);
@@ -1168,7 +1170,15 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	return server;
 
 error:
+	if (server->nfs_client && server->nfs_client->cl_recovery_status)
+		error = server->nfs_client->cl_recovery_status;
 	nfs_free_server(server);
+	if (minorvers > 0 && error == -NFS4ERR_MINOR_VERS_MISMATCH) {
+		minorvers--;
+		dprintk("%s: error %d retrying with minorvers=%d\n",
+			__func__, error, minorvers);
+		goto retry;
+	}
 	dprintk("<-- nfs4_create_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
-- 
1.6.0.2

