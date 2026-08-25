Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73C5A44AB76
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 15:02:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787670132; cv=none; b=BTOzRIrUsoMU1hkZ8HqWxqANT3xN+oYrPPeaq1jGCMvp23VoJK5kqLikK0byHDtso9XXTmUNH8j9u7YQpl/wsojU0bJgybB5p3Jcjfsh9A9Sbbt3RepnFShCBHavQcXdISPyPYRXvqcMCkE0jCR9iQhQpYLXoc1wgoZUty0+jkQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787670132; c=relaxed/simple;
	bh=avihTkUCz1T8euModY+UM7L5mgcRsh0v6ryTVeGQohw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CjQJz6bQ8wdRBY4mPbkmtirFvEKMuElQ78/cUP8h7yrKE/XYXZL/Dp+pEey3IQunedVyjcvOLIU6qbd2veHpANJzCnT2NkHj3p8kcyV3yXYy9vUBUGgLi+dVm2t7RzpjLrK2A6QoC+fEp580Jw8BIr4OeK287QYV9sm1d885BAc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KJVW5m8w; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KJVW5m8w"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0D5001F000E9;
	Tue, 25 Aug 2026 15:02:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787670131;
	bh=Sz4yQjVl3LRiw1u7EB/37FpmcwrrIIdJVzGogDqLIZY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KJVW5m8wysPXHlBgc4BtGzSBLdSl/KSZqKwGpYS5TtgfFhrwvI+VheKpSNJbT616q
	 ObA86Gh3b3Rny8ah1ezlbeskasasBG7rL5rhSGC2IZrNxf2aWvSlfvhNvaqVtDXMNY
	 C+MH+Sh7CPNjyi24nrcSecyuHyW04z8G0YNNOcvvYYBtDfP3joAeBM1m1bXfvz33dQ
	 oce3SIHuJFUxzLRbTsUvERrWU+2O5beIg6kkMudKz0whKzSWhT98MTE+l9vkXb2Ueh
	 mtGP+KBszvbFoFWbtwo4XyhnpzVHwCyl9EpksrnOjOmH5TkuPiR5bN2tZL745lHT/G
	 rNmas1qqi/iqg==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 1/4] NFS: Add an outline for the CB_NOTIFY operation
Date: Tue, 25 Aug 2026 11:02:06 -0400
Message-ID: <20260825150209.694646-2-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260825150209.694646-1-anna@kernel.org>
References: <20260825150209.694646-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

Support for individual notification types will be added over the next
few patches.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
v2: Change res to a ssize_t
---
 fs/nfs/callback.h      | 14 +++++++++++
 fs/nfs/callback_proc.c |  9 +++++++
 fs/nfs/callback_xdr.c  | 54 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c       |  2 +-
 include/linux/nfs4.h   |  3 +++
 5 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 2a721c422d48..f7cc5b6931bf 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -143,6 +143,20 @@ struct cb_layoutrecallargs {
 extern __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
 		struct cb_process_state *cps);
 
+struct cb_notify_changes {
+	u32 notify_mask;
+};
+
+struct cb_notifyargs {
+	nfs4_stateid			cna_stateid;
+	struct nfs_fh			cna_fh;
+	uint32_t			cna_n_changes;
+	struct cb_notify_changes	*cna_changes;
+};
+
+extern __be32 nfs4_callback_notify(void *argp, void *resp,
+				   struct cb_process_state *cps);
+
 struct cb_devicenotifyitem {
 	uint32_t		cbd_notify_type;
 	uint32_t		cbd_layout_type;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3fb10c8e4271..01600d75f2d9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -369,6 +369,15 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp,
 	do_callback_layoutrecall(clp, &args, cps);
 }
 
+__be32 nfs4_callback_notify(void *argp, void *resp,
+			    struct cb_process_state *cps)
+{
+	struct cb_notifyargs *args = argp;
+
+	kfree(args->cna_changes);
+	return 0;
+}
+
 __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 				  struct cb_process_state *cps)
 {
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4382baddc9ee..8d822a3ee248 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -31,6 +31,7 @@
 #define CB_OP_RECALL_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ)
 
 #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_NOTIFY_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					 NFS4_MAX_SESSIONID_LEN + \
@@ -251,6 +252,52 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	return 0;
 }
 
+static
+__be32 decode_notify_args(struct svc_rqst *rqstp,
+			  struct xdr_stream *xdr,
+			  void *argp)
+{
+	struct cb_notifyargs *args = argp;
+	__be32 status;
+	ssize_t res;
+	__be32 *p;
+	int i;
+
+	status = decode_stateid(xdr, &args->cna_stateid);
+	if (unlikely(status != 0))
+		return status;
+
+	status = decode_fh(xdr, &args->cna_fh);
+	if (unlikely(status != 0))
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out;
+
+	args->cna_n_changes = ntohl(*p++);
+	args->cna_changes = kmalloc_array(args->cna_n_changes,
+					  sizeof(*args->cna_changes),
+					  GFP_KERNEL);
+	if (!args->cna_changes)
+		goto out;
+
+	for (i = 0; i < args->cna_n_changes; i++) {
+		struct cb_notify_changes *change = &args->cna_changes[i];
+
+		res = xdr_stream_decode_uint32_array(xdr,
+						     &change->notify_mask, 1);
+		if (unlikely(res < 0))
+			goto err;
+	}
+
+	return 0;
+err:
+	kfree(args->cna_changes);
+out:
+	return htonl(NFS4ERR_BADXDR);
+}
+
 static
 __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 				struct xdr_stream *xdr,
@@ -797,12 +844,12 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
+	case OP_CB_NOTIFY:
 	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_NOTIFY_LOCK:
 		*op = &callback_ops[op_nr];
 		break;
 
-	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
@@ -1034,6 +1081,11 @@ static struct callback_op callback_ops[] = {
 		.decode_args = decode_layoutrecall_args,
 		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
 	},
+	[OP_CB_NOTIFY] = {
+		.process_op = nfs4_callback_notify,
+		.decode_args = decode_notify_args,
+		.res_maxsize = CB_OP_NOTIFY_RES_MAXSZ,
+	},
 	[OP_CB_NOTIFY_DEVICEID] = {
 		.process_op = nfs4_callback_devicenotify,
 		.decode_args = decode_devicenotify_args,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc049ce4ba8a..5c51691fff03 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,7 +2012,7 @@ static void
 encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	struct timespec64 ts = { 0, 0 };
-	u32 notifications[1] = { 0 };
+	u32 notifications[1] = { CB_NOTIFY4_GFLAG_EXTEND };
 	u32 attributes[1] = { 0 };
 	__be32 *p;
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1a3981c26b23..2e33f2ffdc31 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -491,6 +491,9 @@ enum {
 #define THRESHOLD_RD_IO                 (1UL << 2)
 #define THRESHOLD_WR_IO                 (1UL << 3)
 
+/* Directory Delegation / CB_NOTIFY bits */
+#define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
+
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
 #define NFS4_VERSION 4
-- 
2.55.0

