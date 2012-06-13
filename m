Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35089 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2FMSUY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:20:24 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so237820yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 11:20:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Clean up TEST_STATEID and FREE_STATEID proc error
 reporting
To: linux-nfs@vger.kernel.org
Date: Wed, 13 Jun 2012 14:20:22 -0400
Message-ID: <20120613182022.5910.28274.stgit@degas.1015granger.net>
In-Reply-To: <20120613181831.5910.74030.stgit@degas.1015granger.net>
References: <20120613181831.5910.74030.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The TEST_STATEID and FREE_STATEID operations can return
NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, or NFS4ERR_DEADSESSION.
These error values should not be passed to nfs4_handle_exception(),
since that will recursively kick off state recovery, resulting in a
deadlock.  The reason to continue using nfs4_handle_exception() is
to deal with NFS4ERR_DELAY.

Moreover, specifically when the TEST_STATEID operation returns
NFS4_OK, res.status can contain one of these errors.
_nfs41_test_stateid() replaces NFS4_OK with the value in res.status,
which is then returned to callers.

But res.status is not passed through nfs4_stat_to_errno(), and thus is
a positive NFS4ERR value.  Currently callers are only interested in
!NFS4_OK, and nfs4_handle_exception() ignores positive values, so this
oversight hasn't bitten us so far.

Bryan agrees the original intent was to return res.status as a
negative NFS4ERR value to callers of nfs41_test_stateid(), as long as
no state ID recovery is attempted.

As a finishing touch, add appropriate documenting comments and some
debugging printk's.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   51 ++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d48dbef..ef69cc5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6561,22 +6561,36 @@ static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 		.rpc_resp = &res,
 	};
 
+	dprintk("NFS call  test_stateid %p\n", stateid);
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
 	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
-
-	if (status == NFS_OK)
-		return res.status;
-	return status;
+	if (status != NFS_OK) {
+		dprintk("NFS reply test_stateid: failed, %d\n", status);
+		return status;
+	}
+	dprintk("NFS reply test_stateid: succeeded, %d\n", -res.status);
+	return -res.status;
 }
 
+/**
+ * nfs41_test_stateid - perform a TEST_STATEID operation
+ *
+ * @server: NFS server that may know about "stateid"
+ * @stateid: state ID to test
+ *
+ * Returns NFS_OK if the server recognizes the state ID as valid.
+ * Otherwise a negative NFS4ERR value is returned if the operation
+ * failed or the state ID is not currently valid.
+ */
 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(server,
-				_nfs41_test_stateid(server, stateid),
-				&exception);
+		err = _nfs41_test_stateid(server, stateid);
+		if (err != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 	return err;
 }
@@ -6592,19 +6606,34 @@ static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	int status;
 
+	dprintk("NFS call  free_stateid %p\n", stateid);
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
-	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync_sequence(server->client, server, &msg,
+					 &args.seq_args, &res.seq_res, 1);
+	dprintk("NFS reply free_stateid: %d\n", status);
+	return status;
 }
 
+/**
+ * nfs41_free_stateid - perform a FREE_STATEID operation
+ *
+ * @server: NFS server that may know about "stateid"
+ * @stateid: state ID to release
+ *
+ * Returns NFS_OK if the server freed the state ID.  Otherwise a
+ * negative NFS4ERR value is returned if the operation failed.
+ */
 static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_free_stateid(server, stateid),
-				&exception);
+		err = _nfs4_free_stateid(server, stateid);
+		if (err != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 	return err;
 }

