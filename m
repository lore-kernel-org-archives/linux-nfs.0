Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A3B850C29E
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540821; cv=none; b=P2PfADd3fqv9VWPP1e8AD7s4taCUCIx6PEaDJIIuAoLi5J++MXwYPAaVGGQNvNS4L/a6e5XpK71YU57QcQT8b8u5Wv6uq3MEoGtEKz2toThwdQoswxxYxTLF0Z4ERfjGA0Ao2qPq3gM9e78znL/eXEBod16c0pNS5cCEAKtpI8A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540821; c=relaxed/simple;
	bh=KKjYfPXBbOycntCAXwzK6n+rerVoNtefKj2PgMh5pQ4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ppPqAof2da2ke2tEXfqP/ci1NeZ8aed3fqqIkcX9OO5ix31b62BpYAtkSkYssDC9RrAJu8BKIcaT4ZEEirDL1sDYLMVCj8dGgIgJUw3og9zDojW7VYFyCh8vUGpqYTWtbWZ5TGjbPLMkaalRWsnSA/AWiJF7/wBiZpdW4FRylxM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OjMCLtnm; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OjMCLtnm"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-930f618435cso135018685a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540818; x=1789145618; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=X/2e8OLvoPeRrM9irAjJI2v1uc5SrgX6ZjJjS0OKW6M=;
        b=OjMCLtnmjG/mhyWPPzAbayioWVGwqcob1f2WB73tg++KpquSWWtq1lv3O+lXquC0nb
         3mB+BliJ9NWulJIj1IfdBn9csbd3eQcjTMeVrZbMlsypwClaYwiFnt8EdC5AXuzRkBLV
         EgYWB8AuPwTy1YRhWRpsocRqc4XKfmOlYjDLK+UB/w+IAkI+mP0JEIdL1clQgESwrN0l
         dKRePc6Bbp0fCkzDt7Ul5TedsPyamgSwgRke2wuyj/cQqdOEgSCGOndozdsgWVqixaxS
         +gWqOKU5kPqSnb3kVdjoqYiFo5MJ+8xOsXSlmMyAobV9Oj1IPzPwq5MMuaQAuZuIYVnt
         V6JA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540818; x=1789145618;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=X/2e8OLvoPeRrM9irAjJI2v1uc5SrgX6ZjJjS0OKW6M=;
        b=QTQGKWaDyn1zpJaTx6MBnq5UcMuhvLp3d0ye84UEPi2uKMJnEPiLMneGzPsseWA9ZO
         Xvz8oP4nvhvihafA1JuCaEOTDaLCQOvbNsJp5mcLtg2CmB0D8onue9Y9WLgBZN/3+g2E
         qOr83fLvqr+xX/7vhR7tpeSKCBq7eAVsCK7AIEN+Hgg2AGLix5Nz2taOlodTOQWrZZwE
         pnmG26SrUfjfEoRmtFhdTBgwVXn/p94kjCkLkugl/5bLszQCuHOFzC38k3bl++tPt/mi
         1/wYy2XIU/H2U6BwX8x3Nefv8aA98eW+ya0Eu4f0Euh6xFvDH8PjHXKcGClJWad0d4CI
         uC1g==
X-Gm-Message-State: AFuF++mNHs1HVp2+Z5XMKH/alI1cGVwkW3N+bACd0jwJ3EpQruGYtRjd
	5apzthy8x7aVrqsEv+pqc8RqAh6cwXuiPzPi0tbsKzmQq3mJ7ubBElcr03mfeB4QCAw=
X-Gm-Gg: AYBFou0N7a9iIUXH8ODWowDm/vHiOSVc9kpzWCrNQmLp3ZUSAdP03gGWDVbsfujOfuC
	76iwS4/ZWU0jR2EST4ZwBptjb63t9Irm/3Mai+t3IQv8yjpuCOkjAhwq5FpYQU8XlSMjPElEamk
	+SuHWQRwpmwQ5wBS4lTzVwYua0fWmnsUVKczfpGEIRtoKMUdT24gtzHBGj4w5u2/dwQCHwZke7v
	z9iNH12PWGdbyjVU9H7toOx2kr+6TpR1yZuDIqJc7oA2vbKPNZ7iFjxeSnQgHXB9TsL+gnfbNBx
	De+56c/dJianWh08BWc+yG5S0e2gBwgcc+MYINXLhNLWI74MokMK5cbatRKwnu97a/M8gJeDTYp
	j/6OiPWD96DTvrJLZ/s4+ZImxhHXCWCi6t8mmo1CC5XPy4yNth7lpkzcBF+74XNnyBSklcRnCep
	71rVLnjtElQh2ZYq4SemPgjgSin+V5ZY3WpoWvU+8eMj2c1IDRPh5icjNAdcrOTyfIlFpymWKPj
	EYDZZLWab+NCnMsi26Jv9F5g3rbGrSk1bM=
X-Received: by 2002:a05:620a:4414:b0:939:81f2:5fac with SMTP id af79cd13be357-93981f25fc6mr562511185a.23.1788540813330;
        Fri, 04 Sep 2026 09:53:33 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 10/24] NFSv4/flexfiles: Hold a device node reference for layoutstats encoding
Date: Fri,  4 Sep 2026 12:53:09 -0400
Message-ID: <8bcbc93dd3a730c4d87d0792ac0d48ff91e9aebd.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ff_layout_mirror_prepare_stats() records a stripe's device under i_lock,
but the layoutstats/layoutreturn XDR encode runs later and dereferences
the mirror's pinned device node (for the DS netaddr) with no reference
of its own.  Once a CHANGE notification can re-point the pinned node,
that read becomes use-after-free.

Take a node reference at prepare time and carry it with the stripe in a
per-devinfo nfs4_ff_layoutstat_priv, released in
ff_layout_free_layoutstats().  The priv entries live alongside the
devinfo array: co-allocated for LAYOUTSTATS, an additional member of
nfs4_flexfile_layoutreturn_args for LAYOUTRETURN.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 53 +++++++++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayout.h | 11 ++++++
 2 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index d55f2759df98..015428fd6937 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -44,10 +44,11 @@ static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 static int
 ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       struct nfs42_layoutstat_devinfo *devinfo,
+			       struct nfs4_ff_layoutstat_priv *priv,
 			       int dev_limit, enum nfs4_ff_op_type type);
 static void ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 			      const struct nfs42_layoutstat_devinfo *devinfo,
-			      struct nfs4_ff_layout_ds_stripe *dss_info);
+			      struct nfs4_ff_layoutstat_priv *priv);
 
 static struct pnfs_layout_hdr *
 ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
@@ -2725,7 +2726,7 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 
 	spin_lock(&args->inode->i_lock);
 	ff_args->num_dev = ff_layout_mirror_prepare_stats(
-		&ff_layout->generic_hdr, &ff_args->devinfo[0],
+		&ff_layout->generic_hdr, &ff_args->devinfo[0], &ff_args->priv[0],
 		ARRAY_SIZE(ff_args->devinfo), NFS4_FF_OP_LAYOUTRETURN);
 	spin_unlock(&args->inode->i_lock);
 
@@ -2900,10 +2901,11 @@ ff_layout_encode_io_latency(struct xdr_stream *xdr,
 static void
 ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 			      const struct nfs42_layoutstat_devinfo *devinfo,
-			      struct nfs4_ff_layout_ds_stripe *dss_info)
+			      struct nfs4_ff_layoutstat_priv *priv)
 {
+	struct nfs4_ff_layout_ds_stripe *dss_info = priv->dss_info;
 	struct nfs4_pnfs_ds_addr *da;
-	struct nfs4_pnfs_ds *ds = dss_info->mirror_ds->ds;
+	struct nfs4_pnfs_ds *ds = priv->mirror_ds->ds;
 	struct nfs_fh *fh = &dss_info->fh_versions[0];
 	__be32 *p;
 
@@ -2950,10 +2952,10 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr, const void *args,
 static void
 ff_layout_free_layoutstats(struct nfs4_xdr_opaque_data *opaque)
 {
-	struct nfs4_ff_layout_ds_stripe *dss_info = opaque->data;
-	struct nfs4_ff_layout_mirror *mirror = dss_info->mirror;
+	struct nfs4_ff_layoutstat_priv *priv = opaque->data;
 
-	ff_layout_put_mirror(mirror);
+	nfs4_ff_layout_put_deviceid(priv->mirror_ds);
+	ff_layout_put_mirror(priv->dss_info->mirror);
 }
 
 static const struct nfs4_xdr_opaque_ops layoutstat_ops = {
@@ -2964,12 +2966,13 @@ static const struct nfs4_xdr_opaque_ops layoutstat_ops = {
 static int
 ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       struct nfs42_layoutstat_devinfo *devinfo,
+			       struct nfs4_ff_layoutstat_priv *priv,
 			       int dev_limit, enum nfs4_ff_op_type type)
 {
 	struct nfs4_flexfile_layout *ff_layout = FF_LAYOUT_FROM_HDR(lo);
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_ff_layout_ds_stripe *dss_info;
-	struct nfs4_deviceid_node *dev;
+	struct nfs4_ff_layout_ds *mirror_ds;
 	int i = 0, dss_id;
 
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
@@ -2977,7 +2980,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			dss_info = &mirror->dss[dss_id];
 			if (i >= dev_limit)
 				break;
-			if (IS_ERR_OR_NULL(dss_info->mirror_ds))
+			mirror_ds = dss_info->mirror_ds;
+			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
 			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
 						&mirror->flags) &&
@@ -2986,9 +2990,14 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			/* mirror refcount put in cleanup_layoutstats */
 			if (!refcount_inc_not_zero(&mirror->ref))
 				continue;
-			dev = &dss_info->mirror_ds->id_node;
+			/*
+			 * The mirror's pin holds the node while we're under
+			 * i_lock; take a reference for the encode, put in
+			 * ff_layout_free_layoutstats().
+			 */
+			atomic_inc(&mirror_ds->id_node.ref);
 			memcpy(&devinfo->dev_id,
-			       &dev->deviceid,
+			       &mirror_ds->id_node.deviceid,
 			       NFS4_DEVICEID4_SIZE);
 			devinfo->offset = 0;
 			devinfo->length = NFS4_MAX_UINT64;
@@ -3004,9 +3013,12 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			spin_unlock(&mirror->lock);
 			devinfo->layout_type = LAYOUT_FLEX_FILES;
 			devinfo->ld_private.ops = &layoutstat_ops;
-			devinfo->ld_private.data = &mirror->dss[dss_id];
+			priv->dss_info = dss_info;
+			priv->mirror_ds = mirror_ds;
+			devinfo->ld_private.data = priv;
 
 			devinfo++;
+			priv++;
 			i++;
 		}
 	}
@@ -3017,21 +3029,28 @@ static int ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 {
 	struct pnfs_layout_hdr *lo;
 	struct nfs4_flexfile_layout *ff_layout;
+	struct nfs4_ff_layoutstat_priv *priv;
 	const int dev_count = PNFS_LAYOUTSTATS_MAXDEV;
 
-	/* For now, send at most PNFS_LAYOUTSTATS_MAXDEV statistics */
-	args->devinfo = kmalloc_objs(*args->devinfo, dev_count,
-				     nfs_io_gfp_mask());
+	/*
+	 * For now, send at most PNFS_LAYOUTSTATS_MAXDEV statistics.
+	 * The per-devinfo private entries are co-allocated after the
+	 * devinfo array and freed along with it.
+	 */
+	args->devinfo = kmalloc(dev_count * (sizeof(*args->devinfo) +
+					     sizeof(*priv)),
+				nfs_io_gfp_mask());
 	if (!args->devinfo)
 		return -ENOMEM;
+	priv = (struct nfs4_ff_layoutstat_priv *)&args->devinfo[dev_count];
 
 	spin_lock(&args->inode->i_lock);
 	lo = NFS_I(args->inode)->layout;
 	if (lo && pnfs_layout_is_valid(lo)) {
 		ff_layout = FF_LAYOUT_FROM_HDR(lo);
 		args->num_dev = ff_layout_mirror_prepare_stats(
-			&ff_layout->generic_hdr, &args->devinfo[0], dev_count,
-			NFS4_FF_OP_LAYOUTSTATS);
+			&ff_layout->generic_hdr, &args->devinfo[0], priv,
+			dev_count, NFS4_FF_OP_LAYOUTSTATS);
 	} else
 		args->num_dev = 0;
 	spin_unlock(&args->inode->i_lock);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 7eb47ce09442..8b42a98a2c4c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -124,9 +124,20 @@ struct nfs4_flexfile_layout {
 	unsigned long		flags;
 };
 
+/*
+ * Per-devinfo private data for a layoutstats/layoutreturn encode: the
+ * stripe the stats describe plus a reference on its device node so the
+ * node (and its DS addresses) stay valid until the XDR encode runs.
+ */
+struct nfs4_ff_layoutstat_priv {
+	struct nfs4_ff_layout_ds_stripe *dss_info;
+	struct nfs4_ff_layout_ds *mirror_ds;
+};
+
 struct nfs4_flexfile_layoutreturn_args {
 	struct list_head errors;
 	struct nfs42_layoutstat_devinfo devinfo[FF_LAYOUTSTATS_MAXDEV];
+	struct nfs4_ff_layoutstat_priv priv[FF_LAYOUTSTATS_MAXDEV];
 	unsigned int num_errors;
 	unsigned int num_dev;
 	struct page *pages[1];
-- 
2.53.0

