Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34611 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754217AbcIISEq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:04:46 -0400
Received: by mail-oi0-f67.google.com with SMTP id a144so3250082oii.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:04:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v3 03/12] NFSv4.1: Allow test_stateid to handle session errors without waiting
Date: Fri,  9 Sep 2016 14:04:04 -0400
Message-Id: <1473444253-12433-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server crashes while we're testing stateids for validity, then
we want to initiate session recovery. Usually, we will be calling from
a state manager thread, though, so we don't really want to wait.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 254ab545c391..9b7ff26b63ff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8590,6 +8590,23 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 	return -res.status;
 }
 
+static void nfs4_handle_delay_or_session_error(struct nfs_server *server,
+		int err, struct nfs4_exception *exception)
+{
+	exception->retry = 0;
+	switch(err) {
+	case -NFS4ERR_DELAY:
+		nfs4_handle_exception(server, err, exception);
+		break;
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_BADSLOT:
+	case -NFS4ERR_BAD_HIGH_SLOT:
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+	case -NFS4ERR_DEADSESSION:
+		nfs4_do_handle_exception(server, err, exception);
+	}
+}
+
 /**
  * nfs41_test_stateid - perform a TEST_STATEID operation
  *
@@ -8609,9 +8626,7 @@ static int nfs41_test_stateid(struct nfs_server *server,
 	int err;
 	do {
 		err = _nfs41_test_stateid(server, stateid, cred);
-		if (err != -NFS4ERR_DELAY)
-			break;
-		nfs4_handle_exception(server, err, &exception);
+		nfs4_handle_delay_or_session_error(server, err, &exception);
 	} while (exception.retry);
 	return err;
 }
-- 
2.7.4

