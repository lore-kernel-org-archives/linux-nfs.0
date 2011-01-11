Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932360Ab1AKQVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:49 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/14] nfsd4: add helper function to run callbacks
Date: Tue, 11 Jan 2011 11:21:31 -0500
Message-Id: <1294762894-21371-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index cb002dc..fff96dc 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -560,6 +560,11 @@ int set_callback_cred(void)
 
 static struct workqueue_struct *callback_wq;
 
+static void run_nfsd4_cb(struct nfsd4_callback *cb)
+{
+	queue_work(callback_wq, &cb->cb_work);
+}
+
 static void do_probe_callback(struct nfs4_client *clp)
 {
 	struct nfsd4_callback *cb = &clp->cl_cb_null;
@@ -574,7 +579,7 @@ static void do_probe_callback(struct nfs4_client *clp)
 
 	cb->cb_ops = &nfsd4_cb_probe_ops;
 
-	queue_work(callback_wq, &cb->cb_work);
+	run_nfsd4_cb(cb);
 }
 
 /*
@@ -859,5 +864,5 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	cb->cb_ops = &nfsd4_cb_recall_ops;
 	dp->dl_retries = 1;
 
-	queue_work(callback_wq, &dp->dl_recall.cb_work);
+	run_nfsd4_cb(&dp->dl_recall);
 }
-- 
1.7.1

