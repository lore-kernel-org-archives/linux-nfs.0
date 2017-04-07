Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:55096 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933093AbdDGSQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:01 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 23/34] NFS: Clean up nfs4_init_server()
Date: Fri, 7 Apr 2017 14:15:17 -0400
Message-ID: <20170407181528.2832-24-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a380255e85ed..2e7fc76cbd4b 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1025,8 +1025,6 @@ static int nfs4_init_server(struct nfs_server *server,
 	struct rpc_timeout timeparms;
 	int error;
 
-	dprintk("--> nfs4_init_server()\n");
-
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
 
@@ -1054,7 +1052,7 @@ static int nfs4_init_server(struct nfs_server *server,
 			data->minorversion,
 			data->net);
 	if (error < 0)
-		goto error;
+		return error;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
@@ -1065,16 +1063,10 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->acregmax = data->acregmax * HZ;
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
+	server->port     = data->nfs_server.port;
 
-	server->port = data->nfs_server.port;
-
-	error = nfs_init_server_rpcclient(server, &timeparms,
-					  data->selected_flavor);
-
-error:
-	/* Done */
-	dprintk("<-- nfs4_init_server() = %d\n", error);
-	return error;
+	return nfs_init_server_rpcclient(server, &timeparms,
+					 data->selected_flavor);
 }
 
 /*
-- 
2.12.2

