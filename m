From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: NFSv4 callback client should use RPC_TASK_SOFTCONN
Date: Wed, 24 Feb 2010 13:48:06 -0800
Message-ID: <20100224214709.1399.59887.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45302 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757904Ab0BXVt3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Feb 2010 16:49:29 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server's callback client should stop trying to connect to the
client's callback server as soon as it gets ECONNREFUSED.

The NFS server's callback client does not call rpc_ping(), but appears
to have it's own "ping" procedure, so it wasn't covered by commit
caabea8a.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Bruce-

Noticed at Connectathon.  I think this is appropriate for 2.6.34, which opened
today.

 fs/nfsd/nfs4callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c6eed2a..5ab598d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -542,7 +542,8 @@ void do_probe_callback(struct nfs4_client *clp)
 	};
 	int status;
 
-	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_SOFT,
+	status = rpc_call_async(cb->cb_client, &msg,
+				RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 				&nfsd4_cb_probe_ops, (void *)clp);
 	if (status) {
 		warn_no_callback_path(clp, status);

