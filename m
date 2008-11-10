From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 83/85] nfs41: cb_sequence proc implementation
Date: Mon, 10 Nov 2008 22:33:01 +0200
Message-ID: <1226349181-10008-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53156 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbYKJUdI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:33:08 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, just free up any referring calls information.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h      |    4 ++++
 fs/nfs/callback_proc.c |   30 ++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 5616257..81a9df6 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -119,6 +119,10 @@ extern void nfs_callback_down(int minorversion);
  * so we limit their concurrency to 1.
  */
 #define NFS41_BC_MIN_CALLBACKS 1
+#define NFS41_BC_MAX_CALLBACKS 1
+
+extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
+				       struct cb_sequenceres *res);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern unsigned int nfs_callback_set_tcpport;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f7e83e2..63b8662 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -101,3 +101,33 @@ out:
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
+	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS;
+	if (res->csr_highestslotid > args->csa_highestslotid)
+		res->csr_highestslotid = args->csa_highestslotid;
+	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS;
+
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	res->csr_status = status;
+	return status;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
-- 
1.6.0.2

