From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 29/39] nfs41: cb_sequence protocol level data structures
Date: Fri,  1 May 2009 02:24:03 +0300
Message-ID: <1241133843-1250-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4083 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758098AbZD3XY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:24:28 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b2aea14..1b046ec 100644
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
+	struct nfs4_sessionid		rcl_sessionid;
+	uint32_t			rcl_nrefcalls;
+	struct referring_call 		*rcl_refcalls;
+};
+
+struct cb_sequenceargs {
+	struct sockaddr_in		*csa_addr;
+	struct nfs4_sessionid		csa_sessionid;
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
+	struct nfs4_sessionid		csr_sessionid;
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
1.6.2.1

