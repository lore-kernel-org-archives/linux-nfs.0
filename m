Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:47006 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751600AbdCHTna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 14:43:30 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv4.1 respect server's max size in CREATE_SESSION
Date: Wed, 8 Mar 2017 14:39:15 -0500
Message-ID: <20170308193915.35824-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently client doesn't respect max sizes server returns in CREATE_SESSION.
nfs4_session_set_rwsize() gets called and server->rsize, server->wsize are 0
so they never get set to the sizes returned by the server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index bebb97e1..5608b50 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1038,9 +1038,9 @@ static void nfs4_session_set_rwsize(struct nfs_server *server)
 	server_resp_sz = sess->fc_attrs.max_resp_sz - nfs41_maxread_overhead;
 	server_rqst_sz = sess->fc_attrs.max_rqst_sz - nfs41_maxwrite_overhead;
 
-	if (server->rsize > server_resp_sz)
+	if (!server->rsize || server->rsize > server_resp_sz)
 		server->rsize = server_resp_sz;
-	if (server->wsize > server_rqst_sz)
+	if (!server->wsize || server->wsize > server_rqst_sz)
 		server->wsize = server_rqst_sz;
 #endif /* CONFIG_NFS_V4_1 */
 }
-- 
1.8.3.1

