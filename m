Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:43546 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752667AbeBUSqs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 13:46:48 -0500
Date: Wed, 21 Feb 2018 12:46:43 -0600 (CST)
From: Bill.Baker@oracle.com
Message-Id: <201802211846.w1LIkhqC736598@jurassic.us.oracle.com>
To: Anna.Schumaker@Netapp.com, trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs: system crashes after NFS4ERR_MOVED recovery
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


nfs4_update_server unconditionally releases the nfs_client for the
source server. If migration fails, this can cause the source server's
nfs_client struct to be left with a low reference count, resulting in
use-after-free.  Also, adjust reference count handling for ELOOP.

NFS: state manager: migration failed on NFSv4 server nfsvmu10 with error 6
WARNING: CPU: 16 PID: 17960 at fs/nfs/client.c:281 nfs_put_client+0xfa/0x110 [nfs]()
	nfs_put_client+0xfa/0x110 [nfs]
	nfs4_run_state_manager+0x30/0x40 [nfsv4]
	kthread+0xd8/0xf0

BUG: unable to handle kernel NULL pointer dereference at 00000000000002a8
	nfs4_xdr_enc_write+0x6b/0x160 [nfsv4]
	rpcauth_wrap_req+0xac/0xf0 [sunrpc]
	call_transmit+0x18c/0x2c0 [sunrpc]
	__rpc_execute+0xa6/0x490 [sunrpc]
	rpc_async_schedule+0x15/0x20 [sunrpc]
	process_one_work+0x160/0x470
	worker_thread+0x112/0x540
	? rescuer_thread+0x3f0/0x3f0
	kthread+0xd8/0xf0

This bug was introduced by 32e62b7c ("NFS: Add nfs4_update_server"),
but the fix applies cleanly to 52442f9b ("NFS4: Avoid migration loops")

Reported-by: Helen Chao <helen.chao@oracle.com>
Fixes: 52442f9b11b7 ("NFS4: Avoid migration loops")
Signed-off-by: Bill Baker <bill.baker@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4client.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

changes since v1:
	ensure clp isn't leaked if source and dest servers are the same

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 65a7e5d..2c9a9b0 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -867,8 +867,10 @@ static int nfs4_set_client(struct nfs_server *server,
 	if (IS_ERR(clp))
 		return PTR_ERR(clp);
 
-	if (server->nfs_client == clp)
+	if (server->nfs_client == clp) {
+		nfs_put_client(clp);
 		return -ELOOP;
+	}
 
 	/*
 	 * Query for the lease time on clientid setup or renewal
@@ -1226,11 +1228,11 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 				clp->cl_proto, clnt->cl_timeout,
 				clp->cl_minorversion, net);
 	clear_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status);
-	nfs_put_client(clp);
 	if (error != 0) {
 		nfs_server_insert_lists(server);
 		return error;
 	}
+	nfs_put_client(clp);
 
 	if (server->nfs_client->cl_hostname == NULL)
 		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
-- 
1.8.3.1

