Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f52.google.com ([209.85.213.52]:34087 "EHLO
	mail-yw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab2GKU3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:29:49 -0400
Received: by yhpp61 with SMTP id p61so1948409yhp.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:29:49 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/15] NFS: Fix up TEST_STATEID and FREE_STATEID return code
 handling
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:29:45 -0400
Message-ID: <20120711202945.3767.90636.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The TEST_STATEID and FREE_STATEID operations can return
-NFS4ERR_BAD_STATEID, -NFS4ERR_OLD_STATEID, or -NFS4ERR_DEADSESSION.

nfs41_{test,free}_stateid() should not pass these errors to
nfs4_handle_exception() during state recovery, since that will
recursively kick off state recovery again, resulting in a deadlock.

In particular, when the TEST_STATEID operation returns NFS4_OK,
res.status can contain one of these errors.  _nfs41_test_stateid()
replaces NFS4_OK with the value in res.status, which is then returned
to callers.

But res.status is not passed through nfs4_stat_to_errno(), and thus is
a positive NFS4ERR value.  Currently callers are only interested in
!NFS4_OK, and nfs4_handle_exception() ignores positive values.

Thus the res.status values are currently ignored by
nfs4_handle_exception() and won't cause the deadlock above.  Thanks to
this missing negative, it is only when these operations fail (which
is very rare) that a deadlock can occur.

Bryan agrees the original intent was to return res.status as a
negative NFS4ERR value to callers of nfs41_test_stateid().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15fc7e4..9a0397c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6589,10 +6589,9 @@ static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
 	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
-
-	if (status == NFS_OK)
-		return res.status;
-	return status;
+	if (status != NFS_OK)
+		return status;
+	return -res.status;
 }
 
 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
@@ -6600,9 +6599,10 @@ static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
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
@@ -6620,7 +6620,8 @@ static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 	};
 
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
-	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
+	return nfs4_call_sync_sequence(server->client, server, &msg,
+					 &args.seq_args, &res.seq_res, 1);
 }
 
 static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
@@ -6628,9 +6629,10 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
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

