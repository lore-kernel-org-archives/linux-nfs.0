Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f52.google.com ([209.85.213.52]:34087 "EHLO
	mail-yw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:30:25 -0400
Received: by mail-yw0-f52.google.com with SMTP id p61so1948409yhp.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:30:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/15] NFS: Clean up TEST_STATEID and FREE_STATEID error
 reporting
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:23 -0400
Message-ID: <20120711203023.3767.32128.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a finishing touch, add appropriate documenting comments and some
debugging printk's.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   32 ++++++++++++++++++++++++++++++--
 1 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c4df35b..0d6da38 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6636,13 +6636,28 @@ static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 		.rpc_resp = &res,
 	};
 
+	dprintk("NFS call  test_stateid %p\n", stateid);
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
 	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
-	if (status != NFS_OK)
+	if (status != NFS_OK) {
+		dprintk("NFS reply test_stateid: failed, %d\n", status);
 		return status;
+	}
+	dprintk("NFS reply test_stateid: succeeded, %d\n", -res.status);
+	return -res.status;
 	return -res.status;
 }
 
+/**
+ * nfs41_test_stateid - perform a TEST_STATEID operation
+ *
+ * @server: server / transport on which to perform the operation
+ * @stateid: state ID to test
+ *
+ * Returns NFS_OK if the server recognizes that "stateid" is valid.
+ * Otherwise a negative NFS4ERR value is returned if the operation
+ * failed or the state ID is not currently valid.
+ */
 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
@@ -6667,12 +6682,25 @@ static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	int status;
 
+	dprintk("NFS call  free_stateid %p\n", stateid);
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
-	return nfs4_call_sync_sequence(server->client, server, &msg,
+	status = nfs4_call_sync_sequence(server->client, server, &msg,
 					 &args.seq_args, &res.seq_res, 1);
+	dprintk("NFS reply free_stateid: %d\n", status);
+	return status;
 }
 
+/**
+ * nfs41_free_stateid - perform a FREE_STATEID operation
+ *
+ * @server: server / transport on which to perform the operation
+ * @stateid: state ID to release
+ *
+ * Returns NFS_OK if the server freed "stateid".  Otherwise a
+ * negative NFS4ERR value is returned.
+ */
 static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };

