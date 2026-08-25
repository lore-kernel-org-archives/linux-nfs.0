Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C790486647
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 15:02:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787670133; cv=none; b=P40eSdmSDGvhN7mk+LbFp/7lnImshK44eZ1diMBhFOn5To8/VwGwITk23Ko+XaOiph29h/15aeg5bvApdrGJGbNt34e52MQfE2YkrJg37Vh6qd9Pxwf7C8lPbTSFFm3EmbnKrWbN05RqkdG54eqvUELPRx4OzR3hi5dUn3Y9jyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787670133; c=relaxed/simple;
	bh=OSDPPLzli3SX4hOdWTGswnD0bx5X+fzA9Yqx73JoGXk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MnNGVGANf8C9uWMYk4H+ZTSB4UFG4znLXuF06rjQtq67/M+wPRNKZg59vc0yrIQyvq3iPDnWZuth3eMfhX3MrlgY99siU0sCfJK9wECKQ/dVpCb0dAifZ71ixHK4msMYJPlUs7A6TLUh7b2TMwq1MGedeRFdBXYhkFoak/wfqIY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GwiMInWj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GwiMInWj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 91DF61F00A3E;
	Tue, 25 Aug 2026 15:02:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787670131;
	bh=9E3hYNAzwi5VEdeLMiTiatKVhTNI8GCaZTVifB1F9fs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GwiMInWjmlN9T8DuJMLbFpHAP6Bpx02ptHJf7qDrtD0rFYigvaZfbMVbyVyoU1Pld
	 oY8g9oVgO6CQ/G03K/irx7IcWIvcBWeAfDb5aEcgzo/65CIdSeehSdy3ZmTfwxdOiK
	 wA7wEIorU2NV3tOL7Dc8zs2sAFNs/Sk8y7kzA3c/PgXVvMhgirnJuWngAgSR6HI49M
	 FJdvn6M599DKuBecwsUoOgtsW3yMgjau1EPTRvSAHbN4EYjdd80xwBkMdTSEF6i9OF
	 ISBErhbX2gYwQMRbpVsEFkEN9SC9q5ZcMIayf9XvZJgktVODODXGPOoO5JWEHFxBd+
	 L2HC41ElYeV3g==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 2/4] NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
Date: Tue, 25 Aug 2026 11:02:07 -0400
Message-ID: <20260825150209.694646-3-anna@kernel.org>
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

When the server tells us that a directory entry has been removed then we
need to take that as an indication that our knowledge of the directory
has changed and needs to be refreshed.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
v2:
  * Initialize 'res' to 0 in nfs4_callback_notify()
  * Add missing error handling
  * Remove nfs4_cb_notify_lookup()
---
 fs/nfs/callback.h      | 16 ++++++++++-
 fs/nfs/callback_proc.c | 63 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/callback_xdr.c  | 62 +++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c       |  3 +-
 include/linux/nfs4.h   |  1 +
 5 files changed, 142 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index f7cc5b6931bf..3740c999bb82 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -143,8 +143,22 @@ struct cb_layoutrecallargs {
 extern __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
 		struct cb_process_state *cps);
 
+struct cb_notify_entry {
+	u32			ne_namelen;
+	const char		*ne_name;
+	struct nfs_fattr	ne_attrs;
+};
+
+struct cb_notify_remove {
+	struct cb_notify_entry	nrm_old_entry;
+	u64			nrm_old_entry_cookie;
+};
+
 struct cb_notify_changes {
-	u32 notify_mask;
+	u32	notify_mask;
+	union {
+		struct cb_notify_remove notify_remove;
+	};
 };
 
 struct cb_notifyargs {
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 01600d75f2d9..d8ad3cd792df 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -9,6 +9,7 @@
 
 #include <linux/errno.h>
 #include <linux/math.h>
+#include <linux/namei.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/slab.h>
@@ -369,13 +370,73 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp,
 	do_callback_layoutrecall(clp, &args, cps);
 }
 
+static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
+				    struct dentry *parent,
+				    struct cb_notify_remove *cb_remove)
+{
+	struct qstr filename = QSTR_INIT(cb_remove->nrm_old_entry.ne_name,
+					 cb_remove->nrm_old_entry.ne_namelen);
+	struct dentry *child;
+
+	filename.hash = full_name_hash(parent, filename.name, filename.len);
+	child = d_lookup(parent, &filename);
+	if (IS_ERR_OR_NULL(child))
+		return htonl(NFS4ERR_BADHANDLE);
+
+	d_drop(child);
+	dput(child);
+
+	nfs_set_cache_invalid(parent->d_inode, NFS_INO_INVALID_DATA);
+	return 0;
+}
+
 __be32 nfs4_callback_notify(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
 	struct cb_notifyargs *args = argp;
+	struct dentry *parent;
+	struct inode *inode;
+	unsigned int i;
+	__be32 res = 0;
 
+	if (!cps->clp) {
+		res = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+		goto out;
+	}
+
+	inode = nfs_delegation_find_inode(cps->clp, &args->cna_fh);
+	if (IS_ERR(inode)) {
+		res = htonl(NFS4ERR_BADHANDLE);
+		goto out;
+	}
+	parent = d_find_alias(inode);
+	if (!parent)
+		goto out_iput;
+
+	for (i = 0; i < args->cna_n_changes; i++) {
+		struct cb_notify_changes *change = &args->cna_changes[i];
+
+		switch (change->notify_mask) {
+		case CB_NOTIFY4_REMOVE_ENTRY:
+			res = nfs4_cb_notify_remove(cps, parent,
+						    &change->notify_remove);
+			break;
+		default:
+			res = htonl(NFS4ERR_NOTSUPP);
+			goto out_dput;
+		}
+
+		if (unlikely(res != 0))
+			break;
+	}
+
+out_dput:
+	dput(parent);
+out_iput:
+	nfs_iput_and_deactive(inode);
+out:
 	kfree(args->cna_changes);
-	return 0;
+	return res;
 }
 
 __be32 nfs4_callback_devicenotify(void *argp, void *resp,
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8d822a3ee248..612d215ac66e 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -252,6 +252,50 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	return 0;
 }
 
+static __be32 decode_notify_entry(struct xdr_stream *xdr,
+				  struct cb_notify_entry *args)
+{
+	uint32_t bitmap[3] = {0};
+	__be32 status;
+	u32 attrlen;
+	__be32 *p;
+
+	status = decode_string(xdr, &args->ne_namelen, &args->ne_name,
+				NFS4_OPAQUE_LIMIT);
+	if (unlikely(status != 0))
+		return status;
+
+	status = decode_bitmap(xdr, bitmap);
+	if (unlikely(status != 0))
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+
+	attrlen = be32_to_cpup(p);
+	if (attrlen != 0)
+		return htonl(NFS4ERR_BADXDR);
+	return 0;
+}
+
+static __be32 decode_notify_remove(struct xdr_stream *xdr,
+				   struct cb_notify_remove *args)
+{
+	__be32 status;
+	__be32 *p;
+
+	status = decode_notify_entry(xdr, &args->nrm_old_entry);
+	if (unlikely(status != 0))
+		return status;
+
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+	xdr_decode_hyper(p, &args->nrm_old_entry_cookie);
+	return 0;
+}
+
 static
 __be32 decode_notify_args(struct svc_rqst *rqstp,
 			  struct xdr_stream *xdr,
@@ -289,6 +333,24 @@ __be32 decode_notify_args(struct svc_rqst *rqstp,
 						     &change->notify_mask, 1);
 		if (unlikely(res < 0))
 			goto err;
+
+		/* Decode opaque size */
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto err;
+		res = ntohl(*p);
+
+		switch (change->notify_mask) {
+		case CB_NOTIFY4_REMOVE_ENTRY:
+			status = decode_notify_remove(xdr,
+						      &change->notify_remove);
+			break;
+		default:
+			goto err;
+		}
+
+		if (unlikely(status != 0))
+			goto err;
 	}
 
 	return 0;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5c51691fff03..e275fbfd395e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,7 +2012,8 @@ static void
 encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	struct timespec64 ts = { 0, 0 };
-	u32 notifications[1] = { CB_NOTIFY4_GFLAG_EXTEND };
+	u32 notifications[1] = { CB_NOTIFY4_REMOVE_ENTRY |
+				 CB_NOTIFY4_GFLAG_EXTEND };
 	u32 attributes[1] = { 0 };
 	__be32 *p;
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2e33f2ffdc31..8de3ea283767 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -492,6 +492,7 @@ enum {
 #define THRESHOLD_WR_IO                 (1UL << 3)
 
 /* Directory Delegation / CB_NOTIFY bits */
+#define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
 #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
 
 #define NFSPROC4_NULL 0
-- 
2.55.0

