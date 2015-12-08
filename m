Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36535 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbLHMX7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 07:23:59 -0500
Received: by qgcc31 with SMTP id c31so13595485qgc.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Dec 2015 04:23:58 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two lease periods
Date: Tue,  8 Dec 2015 07:23:48 -0500
Message-Id: <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have the CB_LAYOUTRECALL code treat NFS4_OK and NFS4ERR_DELAY returns
equivalently. Change the code to periodically resend CB_LAYOUTRECALLS
until the ls_layouts list is empty or the client returns a different
error code.

If we go for two lease periods without the list being emptied or the
client sending a hard error, then we give up and clean out the list
anyway.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4layouts.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index c9d6c715c0fb..f72abc3ba013 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -624,24 +624,39 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 {
 	struct nfs4_layout_stateid *ls =
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
+	struct nfsd_net *nn;
+	ktime_t now, cutoff;
 	LIST_HEAD(reaplist);
 
+
 	switch (task->tk_status) {
 	case 0:
-		return 1;
+	case -NFS4ERR_DELAY:
+		/*
+		 * Anything left? If not, then call it done. Note that we don't
+		 * take the spinlock since this is an optimization and nothing
+		 * should get added until the cb counter goes to zero.
+		 */
+		if (list_empty(&ls->ls_layouts))
+			return 1;
+
+		/* Poll the client until it's done with the layout */
+		now = ktime_get();
+		nn = net_generic(ls->ls_stid.sc_client->net, nfsd_net_id);
+
+		/* Client gets 2 lease periods to return it */
+		cutoff = ktime_add_ns(task->tk_start,
+					 nn->nfsd4_lease * NSEC_PER_SEC * 2);
+
+		if (ktime_before(now, cutoff)) {
+			rpc_delay(task, HZ/100); /* 10 mili-seconds */
+			return 0;
+		}
+		/* Fallthrough */
 	case -NFS4ERR_NOMATCHING_LAYOUT:
 		trace_layout_recall_done(&ls->ls_stid.sc_stateid);
 		task->tk_status = 0;
 		return 1;
-	case -NFS4ERR_DELAY:
-		/* Poll the client until it's done with the layout */
-		/* FIXME: cap number of retries.
-		 * The pnfs standard states that we need to only expire
-		 * the client after at-least "lease time" .eg lease-time * 2
-		 * when failing to communicate a recall
-		 */
-		rpc_delay(task, HZ/100); /* 10 mili-seconds */
-		return 0;
 	default:
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
-- 
2.5.0

