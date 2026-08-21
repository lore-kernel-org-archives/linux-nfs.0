Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66C68493640
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329785; cv=none; b=btTQ7iKbgbBhZHOS0f66J0GsoNq/7n8UrqSggX4BD6DcvQMGkIGryPyu4pzzYQezLq8uAnHq60Nq26J6d2NQ+dT6DpImjWCpgOjR9RXVwfeUKqNv1GyD6OKghhQHvl5H9ToxCOFxLnxccrBjhVrvDDXkOT5zleUtAzVU1mRzP2A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329785; c=relaxed/simple;
	bh=zbaKxN24NHu1ydv2ixd0uJGCbV1pGADttdVTY/D9fNU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gzu2s32MqgC6NKQuLiR3EK8lvkGCmaWXYvX75fVCtYFsBivkr1/P0F8Rm3Jz0+tD3Sco+579bvG9+2QZSXq9ih2eUZeZYgTXCWCXhrwnbw5GqCkuoc66Fvpw7jo1yxeBnk6YZSEqV2H62pU7XaZnPnfgPs5KrOcA6HrR/XV4uLM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=azLBLPFy; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="azLBLPFy"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4864ebb6268so858036b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329781; x=1787934581; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=n9ZsNX4Ps13b0+tXoIly6h1ygzKUGAgskBinARhEPoU=;
        b=azLBLPFy4zcTIzySSIRrwVWFT4ocq2bqzN9IlSsao7MoBae6d+h/3zURZKQKaX7cun
         6Oy6MQyrsZsj1Owm8ZCFvl9Fz7qc09SiNhGYYcZlTfbcH2/SO6T/U2AZYwUXl7sGmBMv
         nBr2Jt6bMizs/8BwQg/u+bbtOKLHY15aMWhnTCVlfXSYU22XRlVWYymnmJEUfMa+Wx3p
         EVGnFyUsBuOvxDjfQ6yv+7Zwnwh9rHY8pU497By/7jLvV7PeliFAu8B2rEWg7sTQWsKe
         trpeQnq9fRrUZLruatZ9yQg+FA8xQMEm66OSp0BNpYFcXKUFyQwkviiVhzDpQHkc1xGu
         RXyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329781; x=1787934581;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=n9ZsNX4Ps13b0+tXoIly6h1ygzKUGAgskBinARhEPoU=;
        b=JEnbFk9t0CJhwkRtMsn9WbjaQuk0/sO4uhjerYSXirhuzTbA/pV3OWFraDv+vSA0fF
         TyGVG+HUkoVVUP3w/h1cLVOeEzvhledid9f33RRZ0ovGs4zWwzYeHq3f5go8wF671+pJ
         7SdT4iDaG9aXUbj0SbjiTaGFebx2gYyvb8qZnFU6m5uoZgTnsZLH42s+xFCGiCIGnTu7
         JVeXh5KfLe+9KibH/UzWV2xvS4YjvMJ95PZgYQzmfP6+k7JcJ8QrmxjyznyudKYAe2Gt
         wxidA+OYrjQAOPrStJwMLYuJFsNGn2lDUjqHlVUzATaUgPLEvBG2PCMkbj7+8uAkOuLw
         FERw==
X-Gm-Message-State: AOJu0YwguwmW7vTqRGlIDp5x5Q/Em3p+UAZrTI1gNsnNofxOfoHEsa/a
	jXJqKqOsb9qMmsMYbOndiqmBMvYvrGsS5lexyxCVgUp622wUS8t2wRKfS+Eyb8ckF9A=
X-Gm-Gg: AR+sD11vWeMIy9FOvG4S0GvB6bsZfmC92D3C+NaFJIX85KYDRUWD328lqRouekh+rHR
	z3gn+6iGlJWIIbtscXmCijtnHu5TJuTa3aR2sGisTK2jhoyq/nGHuqxGmldSTFvCoVZGZVHkjLc
	kkfhaBB2JBBFwww/NG+cpr9bmnEaRx1b1p1RWxwmCSbKAxxq+n2FAsbAwGJMtGvhricuXDdmkSK
	/LhyWz0jag5oz/SBmPR9WTXEIRvr8yuI8SORvoVPv0pY6zRRWXFULF+VpBiXgfuzky3rLU6Mfht
	6fhVSZnXnyKW5LQSdm8Rmp0IPJx/7rNQcpRxMUopqsowqcIcrcF/eohHaJF+SWTOPC2Kpe/dFPX
	n1tkMzcdX3L1JXNLfI+qbFM0buxH3BkqE+iwehsPLrjHPs4NgMw6/5J13RO5McKsk5riIV13o4V
	7AbZeiH5ilMk1mdpARwJx/+iuDOQGS7bxgcPTeQ9DyyM4xBGjEWux2ByZ91eJJYn4Pz4fXF2CHA
	7DBPFQZLqIj0hQMIJhmhp6z
X-Received: by 2002:a05:6808:6f85:b0:497:d1e7:5e90 with SMTP id 5614622812f47-4b2ef484825mr8147258b6e.18.1787329781053;
        Fri, 21 Aug 2026 09:29:41 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:40 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 09/23] NFSv4/flexfiles: Hold a device node reference for layoutstats encoding
Date: Fri, 21 Aug 2026 12:29:13 -0400
Message-ID: <ff832a1b5cd1412c2be32f02b86cb60108ffc8cb.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
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
index 4a9a36af4223..947bb277c4ef 100644
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
@@ -2706,7 +2707,7 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 
 	spin_lock(&args->inode->i_lock);
 	ff_args->num_dev = ff_layout_mirror_prepare_stats(
-		&ff_layout->generic_hdr, &ff_args->devinfo[0],
+		&ff_layout->generic_hdr, &ff_args->devinfo[0], &ff_args->priv[0],
 		ARRAY_SIZE(ff_args->devinfo), NFS4_FF_OP_LAYOUTRETURN);
 	spin_unlock(&args->inode->i_lock);
 
@@ -2881,10 +2882,11 @@ ff_layout_encode_io_latency(struct xdr_stream *xdr,
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
 
@@ -2931,10 +2933,10 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr, const void *args,
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
@@ -2945,12 +2947,13 @@ static const struct nfs4_xdr_opaque_ops layoutstat_ops = {
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
@@ -2958,7 +2961,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			dss_info = &mirror->dss[dss_id];
 			if (i >= dev_limit)
 				break;
-			if (IS_ERR_OR_NULL(dss_info->mirror_ds))
+			mirror_ds = dss_info->mirror_ds;
+			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
 			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
 						&mirror->flags) &&
@@ -2967,9 +2971,14 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
@@ -2985,9 +2994,12 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
@@ -2998,21 +3010,28 @@ static int ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
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
index ceed1a9dd697..d6ec80cf8a6e 100644
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

