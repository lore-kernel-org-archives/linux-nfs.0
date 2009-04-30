From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 30/39] nfs41: cb_sequence proc implementation
Date: Fri,  1 May 2009 02:24:10 +0300
Message-ID: <1241133850-1284-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30117 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758854AbZD3XY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:24:28 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, just free up any referring calls information.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: fix csr_{,target}highestslotid]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h      |    4 ++++
 fs/nfs/callback_proc.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 1b046ec..0316a06 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -103,6 +103,9 @@ struct cb_sequenceres {
 	uint32_t			csr_target_highestslotid;
 };
 
+extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
+				       struct cb_sequenceres *res);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
@@ -119,6 +122,7 @@ extern void nfs_callback_down(int minorversion);
  * of slots for the backchannel.
  */
 #define NFS41_BC_MIN_CALLBACKS 1
+#define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
 extern unsigned short nfs_callback_tcpport;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f7e83e2..f731bbe 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -101,3 +101,31 @@ out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
 }
+
+#if defined(CONFIG_NFS_V4_1)
+
+/* FIXME: validate args->cbs_{sequence,slot}id */
+/* FIXME: referring calls should be processed */
+unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
+				struct cb_sequenceres *res)
+{
+	int i;
+	unsigned status = 0;
+
+	for (i = 0; i < args->csa_nrclists; i++)
+		kfree(args->csa_rclists[i].rcl_refcalls);
+	kfree(args->csa_rclists);
+
+	memcpy(&res->csr_sessionid, &args->csa_sessionid,
+	       sizeof(res->csr_sessionid));
+	res->csr_sequenceid = args->csa_sequenceid;
+	res->csr_slotid = args->csa_slotid;
+	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	res->csr_status = status;
+	return status;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
-- 
1.6.2.1

