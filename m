From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 26/39] nfs41: callback numbers definitions
Date: Fri,  1 May 2009 02:23:35 +0300
Message-ID: <1241133815-1151-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6137 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758088AbZD3XYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:24:25 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index e0f4e6b..3d1a324 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -20,6 +20,16 @@ enum nfs4_callback_procnum {
 enum nfs4_callback_opnum {
 	OP_CB_GETATTR = 3,
 	OP_CB_RECALL  = 4,
+/* Callback operations new to NFSv4.1 */
+	OP_CB_LAYOUTRECALL  = 5,
+	OP_CB_NOTIFY        = 6,
+	OP_CB_PUSH_DELEG    = 7,
+	OP_CB_RECALL_ANY    = 8,
+	OP_CB_RECALLABLE_OBJ_AVAIL = 9,
+	OP_CB_RECALL_SLOT   = 10,
+	OP_CB_SEQUENCE      = 11,
+	OP_CB_WANTS_CANCELLED = 12,
+	OP_CB_NOTIFY_LOCK   = 13,
 	OP_CB_ILLEGAL = 10044,
 };
 
-- 
1.6.2.1

