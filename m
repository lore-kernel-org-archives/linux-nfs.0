Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:6937 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667Ab3IJWon (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 18:44:43 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/4] NFSv4.1: fix SECINFO* use of put_rpccred
Date: Tue, 10 Sep 2013 18:44:31 -0400
Message-ID: <1378853073-13256-3-git-send-email-dros@netapp.com>
In-Reply-To: <1378853073-13256-1-git-send-email-dros@netapp.com>
References: <1378853073-13256-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent SP4_MACH_CRED changes allows rpc_message.rpc_cred to change,
so keep a separate pointer to the machine cred for put_rpccred.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dc2d27b..989bb9d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6001,10 +6001,12 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_resp = &res,
 	};
 	struct rpc_clnt *clnt = NFS_SERVER(dir)->client;
+	struct rpc_cred *cred = NULL;
 
 	if (use_integrity) {
 		clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
-		msg.rpc_cred = nfs4_get_clid_cred(NFS_SERVER(dir)->nfs_client);
+		cred = nfs4_get_clid_cred(NFS_SERVER(dir)->nfs_client);
+		msg.rpc_cred = cred;
 	}
 
 	dprintk("NFS call  secinfo %s\n", name->name);
@@ -6016,8 +6018,8 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 				&res.seq_res, 0);
 	dprintk("NFS reply  secinfo: %d\n", status);
 
-	if (msg.rpc_cred)
-		put_rpccred(msg.rpc_cred);
+	if (cred)
+		put_rpccred(cred);
 
 	return status;
 }
@@ -7498,11 +7500,13 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 	struct rpc_clnt *clnt = server->client;
+	struct rpc_cred *cred = NULL;
 	int status;
 
 	if (use_integrity) {
 		clnt = server->nfs_client->cl_rpcclient;
-		msg.rpc_cred = nfs4_get_clid_cred(server->nfs_client);
+		cred = nfs4_get_clid_cred(server->nfs_client);
+		msg.rpc_cred = cred;
 	}
 
 	dprintk("--> %s\n", __func__);
@@ -7510,8 +7514,8 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 				&res.seq_res, 0);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
-	if (msg.rpc_cred)
-		put_rpccred(msg.rpc_cred);
+	if (cred)
+		put_rpccred(cred);
 
 	return status;
 }
-- 
1.7.12.4 (Apple Git-37)

