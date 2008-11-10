From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 79/85] nfs41: callback numbers definitions
Date: Mon, 10 Nov 2008 22:32:19 +0200
Message-ID: <1226349139-9871-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53136 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbYKJUcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:32:25 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index f8325da..9cb0451 100644
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
1.6.0.2

