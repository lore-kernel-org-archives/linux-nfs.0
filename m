From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 82/85] nfs41: cb_sequence protocol level data structures
Date: Mon, 10 Nov 2008 22:32:51 +0200
Message-ID: <1226349171-9974-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53149 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbYKJUc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:32:57 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b3ccfe8..5616257 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -70,6 +70,41 @@ struct cb_recallargs {
 	uint32_t truncate;
 };
 
+#if defined(CONFIG_NFS_V4_1)
+
+struct referring_call {
+	uint32_t			rc_sequenceid;
+	uint32_t			rc_slotid;
+};
+
+struct referring_call_list {
+	nfs41_sessionid			rcl_sessionid;
+	uint32_t			rcl_nrefcalls;
+	struct referring_call 		*rcl_refcalls;
+};
+
+struct cb_sequenceargs {
+	struct sockaddr_in		*csa_addr;
+	nfs41_sessionid			csa_sessionid;
+	uint32_t			csa_sequenceid;
+	uint32_t			csa_slotid;
+	uint32_t			csa_highestslotid;
+	uint32_t			csa_cachethis;
+	uint32_t			csa_nrclists;
+	struct referring_call_list	*csa_rclists;
+};
+
+struct cb_sequenceres {
+	uint32_t			csr_status;
+	nfs41_sessionid			csr_sessionid;
+	uint32_t			csr_sequenceid;
+	uint32_t			csr_slotid;
+	uint32_t			csr_highestslotid;
+	uint32_t			csr_target_highestslotid;
+};
+
+#endif /* CONFIG_NFS_V4_1 */
+
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
 
-- 
1.6.0.2

