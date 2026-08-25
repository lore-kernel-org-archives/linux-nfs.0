Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77777418361
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 15:02:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787670135; cv=none; b=hj5oP0y76osl35YnsG0F1MRY89Wi7j8ZBHGUyEEosGJV0Wz2R9m2ZDYzK1grCDgnQeTKjh+K5VPTv8IKk1dIZJiFhq4B3BkDmlGuM7yLB2f7XtS2jmyIGohSqpP6bTefEvWKTlgoKz5u5fN1q8ihb4zaWAAFnVKpdl/CbBAQBDM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787670135; c=relaxed/simple;
	bh=hyMlGWFvUlD8+oJ1aOhmxyIOfXjJXoCc6p6B1+VgksI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FTEB+JaHY3CL0PU63NnypdR/+fL4pcudVvjzXzJiRyN8nuV2q+9eBISYaQcJSQLtsQbjnk3vKsSVqA0G3S4rXQMWe1H3HAqlIrWm6m5SVT/DD3YZZ6wsCynjOKHCvKq+1aJNccF5Rns4/oPtOkDDVhD8UsAGhnYtxh8DGbRrvvU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YTQPUZud; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YTQPUZud"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4EEF1F00A3F;
	Tue, 25 Aug 2026 15:02:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787670133;
	bh=oQ+MXKspe8ALSEfEQYTobQE0ZooQIqVvTNk9q6umE50=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YTQPUZudF0+pKlowuBt/R19vlsG/xnYz2UkaHvS1jtpw5iuyLiYbOjE/17HFEBPQd
	 4F+R3VbK7pnioRHA0LqX5iY2L6R+3GLyxOr/yTwjCaLM9A3maXFln+HjyH9766lyXG
	 aAoTJop6InVWw3fdfxotSE9ZMc5B4DYfBQiImDDuRTFqSY2o9rLMCPcLBhuqpzgGQe
	 f+TKPQXbAuiExk9d+OMvIf7MGhjeHu00mwEmviPJIE2C5Hdgqv2Rw/PV3OvgFk9Gnj
	 x9Ifjh5oX5P0JcyFYQibhTN119PUJX9E2/TpEbq1UkLni54UBjqs461Rx9jvZCeDVg
	 Tj5oZTA4Bm8PA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 4/4] NFS: Add support for CB_NOTIFY4_RENAME_ENTRY
Date: Tue, 25 Aug 2026 11:02:09 -0400
Message-ID: <20260825150209.694646-5-anna@kernel.org>
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

Renaming an entry essentially combines a remove with an add, allowing us
to reuse most of the code from the previous patches to do the work for
us.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/callback.h      |  6 ++++++
 fs/nfs/callback_proc.c | 16 ++++++++++++++++
 fs/nfs/callback_xdr.c  | 14 ++++++++++++++
 fs/nfs/nfs4xdr.c       |  1 +
 include/linux/nfs4.h   |  1 +
 5 files changed, 38 insertions(+)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index d3cc3e5df776..019ee9eed9fe 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -170,11 +170,17 @@ struct cb_notify_add {
 	bool			na_last_entry;
 };
 
+struct cb_notify_rename {
+	struct cb_notify_remove	nrn_old_entry;
+	struct cb_notify_add	nrn_new_entry;
+};
+
 struct cb_notify_changes {
 	u32	notify_mask;
 	union {
 		struct cb_notify_remove notify_remove;
 		struct cb_notify_add	notify_add;
+		struct cb_notify_rename	notify_rename;
 	};
 };
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9ac786f258c2..2e533c8e297a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -447,6 +447,18 @@ static __be32 nfs4_cb_notify_add(struct cb_process_state *cps,
 	return 0;
 }
 
+static __be32 nfs4_cb_notify_rename(struct cb_process_state *cps,
+				    struct dentry *parent,
+				    struct cb_notify_rename *cb_rename)
+{
+	__be32 status;
+
+	status = nfs4_cb_notify_remove(cps, parent, &cb_rename->nrn_old_entry);
+	if (status != 0)
+		return status;
+	return nfs4_cb_notify_add(cps, parent, &cb_rename->nrn_new_entry);
+}
+
 __be32 nfs4_callback_notify(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
@@ -482,6 +494,10 @@ __be32 nfs4_callback_notify(void *argp, void *resp,
 			res = nfs4_cb_notify_add(cps, parent,
 						 &change->notify_add);
 			break;
+		case CB_NOTIFY4_RENAME_ENTRY:
+			res = nfs4_cb_notify_rename(cps, parent,
+						    &change->notify_rename);
+			break;
 		default:
 			res = htonl(NFS4ERR_NOTSUPP);
 			goto out_dput;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 39a879e82312..e787657c5db0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -338,6 +338,17 @@ static __be32 decode_notify_add(struct xdr_stream *xdr,
 	return 0;
 }
 
+static __be32 decode_notify_rename(struct xdr_stream *xdr,
+				   struct cb_notify_rename *args)
+{
+	__be32 status;
+
+	status = decode_notify_remove(xdr, &args->nrn_old_entry);
+	if (unlikely(status != 0))
+		return status;
+	return decode_notify_add(xdr, &args->nrn_new_entry);
+}
+
 static
 __be32 decode_notify_args(struct svc_rqst *rqstp,
 			  struct xdr_stream *xdr,
@@ -390,6 +401,9 @@ __be32 decode_notify_args(struct svc_rqst *rqstp,
 		case CB_NOTIFY4_ADD_ENTRY:
 			status = decode_notify_add(xdr, &change->notify_add);
 			break;
+		case CB_NOTIFY4_RENAME_ENTRY:
+			status = decode_notify_rename(xdr, &change->notify_rename);
+			break;
 		default:
 			goto err;
 		}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9a7c4d23aea7..6d102ebf5e6d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2014,6 +2014,7 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	struct timespec64 ts = { 0, 0 };
 	u32 notifications[1] = { CB_NOTIFY4_REMOVE_ENTRY |
 				 CB_NOTIFY4_ADD_ENTRY |
+				 CB_NOTIFY4_RENAME_ENTRY |
 				 CB_NOTIFY4_GFLAG_EXTEND };
 	u32 child_attrs[1] = { FATTR4_WORD0_FSID | FATTR4_WORD0_FILEID |
 			       FATTR4_WORD0_TYPE | FATTR4_WORD0_FILEHANDLE };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 4b507a93aa38..27f083546421 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -494,6 +494,7 @@ enum {
 /* Directory Delegation / CB_NOTIFY bits */
 #define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
 #define CB_NOTIFY4_ADD_ENTRY		(1UL << 3)
+#define CB_NOTIFY4_RENAME_ENTRY		(1UL << 4)
 #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
 
 #define NFSPROC4_NULL 0
-- 
2.55.0

