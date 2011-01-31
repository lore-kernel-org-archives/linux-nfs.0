Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40919 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab1AaODP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jan 2011 09:03:15 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: nfsv4@ietf.org
Subject: [PATCH 1/2] layout-sim: bump seqid on CB_LAYOUTRECALL re-issue
Date: Mon, 31 Jan 2011 16:03:07 +0200
Message-Id: <1296482588-4140-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

the seqid needs to represent the current layout state after NFS4ERR_DELAY
it is not a mere RPC-level retry.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 server.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/server.c b/server.c
index 19bb85a..b9c90de 100644
--- a/server.c
+++ b/server.c
@@ -123,16 +123,33 @@ srv_recv_layoutreturn(struct msg *m)
 }
 
 static void
+issue_layout_recall(struct msg *m)
+{
+	/* bump server stateid.seq */
+	srv_layout.stateid.seq++;
+	m->stateid =  srv_layout.stateid;
+	m->status = -1;
+	srv_layout.layout_recall_msg = m;
+	dump_msg(m);
+	enqueue(&cl_msg_queue, m);
+}
+
+static void
 srv_recv_cb_layout_recall(struct msg *m)
 {
 	BUG_ON(m != srv_layout.layout_recall_msg);
 	dump_msg(m);
 	switch (m->status) {
 	case NFS4_OK:
+		/* CB_LAYOUT_RECALL RPC is done but the meta-operations
+		 * continues until after receiving the respective terminating
+		 * LAYOUTRETURN
+		 */
+		break;
 	case NFS4ERR_DELAY:
 		dprintk(1, "%s: m=%p: layout_recall resent\n",
 			__func__, srv_layout.layout_recall_msg);
-		enqueue(&cl_msg_queue, srv_layout.layout_recall_msg);
+		issue_layout_recall(srv_layout.layout_recall_msg);
 		break;
 	case NFS4ERR_NOMATCHING_LAYOUT:
 		layout_delete(&cl_layout, &m->range);
@@ -190,14 +207,7 @@ srv_recall_layout(void)
 	m->range.offset = mynrand(MAX_LO_MSG_OFFSET) & ~BLOCK_MASK;
 	m->range.length = BLOCK_SIZE + mynrand(MAX_LO_MSG_LENGTH - BLOCK_SIZE);
 	m->range.iomode = IOMODE_READ + mynrand(3);
-	/* bump server stateid.seq */
-	srv_layout.stateid.seq++;
-	m->stateid =  srv_layout.stateid;
-	m->status = -1;
-	srv_layout.layout_recall_msg = m;
-	dump_msg(m);
-
-	enqueue(&cl_msg_queue, m);
+	issue_layout_recall(m);
 }
 
 struct rand_event srv_events[] = {
-- 
1.7.3.4

