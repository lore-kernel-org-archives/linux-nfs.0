Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35922 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933182AbcIGSB5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Sep 2016 14:01:57 -0400
Received: by mail-it0-f65.google.com with SMTP id i184so2146380itf.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Sep 2016 11:01:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/7] NFSv4.1: Allow test_stateid to handle session errors without waiting
Date: Wed,  7 Sep 2016 14:01:22 -0400
Message-Id: <1473271287-43478-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473271287-43478-2-git-send-email-trond.myklebust@primarydata.com>
References: <1473271287-43478-1-git-send-email-trond.myklebust@primarydata.com>
 <1473271287-43478-2-git-send-email-trond.myklebust@primarydata.com>
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
index 2728ef288a0f..f1f5d0f10a6e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8587,6 +8587,23 @@ static int _nfs41_test_stateid(struct nfs_server *server,
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
@@ -8606,9 +8623,7 @@ static int nfs41_test_stateid(struct nfs_server *server,
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

