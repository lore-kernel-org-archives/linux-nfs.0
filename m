Received: from mail-oa2-f12.google.com (mail-oa2-f12.google.com [74.125.231.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A59BD35C693
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 17:11:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.76
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788973918; cv=none; b=hHPCnammBsyE7fytADYbMSzccoMK+bSm+9QCrVKnic88hUyHndJcwawI+/fjyxFiLRXtmd/H8Osv+X/CmR4bWyQw3RlSYb1MAR121G9ksD4RVwj75oj577/qAHWSeDfmwtC6JL4suqULNgH5xtXCWaW0cbUxIGa+fdTVrkpemUo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788973918; c=relaxed/simple;
	bh=1bWNvTrQeFIcuVoVapY9tS1llRxwe5zOx9ZNJiLnwYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dMvTx42Z+z7klnogBWdTC9Dg44M0SpOvvsaFjFeTk2Sm+SIFH2RDmFcwSm+KokYNX2TqqS7sw03Y2pYh7u1uWLej+BQmgkiwnhgLMVPXz3Y+p+/3xOp9eMmMutCqsmnYraCKiH18i2ZT9e8z2vbiNqlSlxZjd8Cn4dLXK3o91HA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=hPZli7el; arc=none smtp.client-ip=74.125.231.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hPZli7el"
Received: by mail-oa2-f12.google.com with SMTP id 586e51a60fabf-46accbdfc20so363052fac.0
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 10:11:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788973914; x=1789578714; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=hcsNtQaHRCgZmtjLnYTIX0DKgN1qyuf6SkTFCy/EYQ0=;
        b=hPZli7elZQBoKPIpuV86hs2LE2N07s+yvpz7x+t5W75YrNDl1ckCwxNcabLCDJ4T2O
         BuvyhwBJe4VNdoagMb+ANLAcSlBzD9aLKkErLwTYrmHBxAE5vRq/syBcuw/dT+/KboA8
         WiLl8ivG9JBRwsQ2H5WPIdPI2oJ9tEq7R9tysD+m83HhNLoANFeBnOrFcG6kjN2bdiQl
         XDxPs3xxoJmb9Lry2fdpZUA+aiY7hmHxE47kNZXTbkm0FZEoZsGYmoocTVSajn4LoQzT
         ov1gNGIbiUC8UZCE2WACUYnzfjPo4sJvkAUbSd1I+3uBFv4Rum5jrv4LvSNR2GP1Moh3
         EG8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788973914; x=1789578714;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=hcsNtQaHRCgZmtjLnYTIX0DKgN1qyuf6SkTFCy/EYQ0=;
        b=VKLk+4h0vlf/yLs5SwJJBLOOZawc7V9ZmbqzkfoXmeLKX/BYYrTc1t9p8YC4eD6DV5
         xAqrELiQz4e0q83XbydKc6de9uLDfI3vG05UljAqMnGi7r1NWqa3CKAYcnkoKxEkjcAc
         D8EGO8SNNTNlsNe8/gCXPzbJUGN40W6gjA13/QOkzaB2uVhuZiuAjLWJCO5RFByIixQM
         TiitRGGf8rN8FOZjrGqqP5x3GZh4e+/jjEwNPidfCC4QPlANTicYdkbknxmKgULibY8J
         9VAQpcGTrOnxfmBRHGEfZiVo+IvFRzC3xxDjOgKZKQe4xFaib+G2+2ARI6wRdOFX3DE4
         D5zA==
X-Gm-Message-State: AFuF++lmC7V9QFItl3e/20X1IHgQ3NAjMN59A5jSAZb6PoFGAcrGzssD
	Rz1K9z0YeJJHqnmn7d7+wemtoclzPl7YEgfOWsth4rhoo+yPwr30tK5oYGYjS9ihGIo=
X-Gm-Gg: AYBFou2eBp0Bnmwj1x2YCnkDaWJsTMCMRNnSwDQN+o6V/DKpO4fHCh5n+oTl+tF08dn
	n6zhplKXjJn1tE8MZWPJJLFerl9t+9JtRfVHOzn3Y4gboA8HDc0q9Rl1WWRTAKPg8x0dhUAr5ta
	XIvPRHG1L3BScOSxyoYavA0Rk8l9XwzpzVteWZ+7TzWBpFsbA+Kv0s/n67w44N6UTnUSu8Cz+Ss
	KHS1tfmKVUysVPkcG6KfX/OG2kUA7Y/2HK+kEBzsh9WQ48Ng22jWST9z0n+MBdJf8/vO+bhX7vW
	Wqll5mVBchtIpbMrEdhwYx6PZggqW64Ze4ah0uO1r9yXSiyvF5AOo3bCuXJMAXHu/mAlgYQnDSB
	wu/z68pGWwiXTGf2FmiaXDXfi7dn9nWM/erROKHddSr4g7Jjz6kDDyFfPVPxExOZyVOIjmPDq1B
	3ea17GptTCl1djRaQhYNEENy/bd9xExnWTWt62S/cLxpz7pILhBljXvEmFMkRkvFPMs7AUP1h1C
	n0Tq/ekGS1bi3e//iz2DCagsKIeUWwsdgY=
X-Received: by 2002:a05:6820:178a:b0:6b1:8f51:e174 with SMTP id 006d021491bc7-6bee53a591emr2504515eaf.29.1788973913802;
        Wed, 09 Sep 2026 10:11:53 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6b6dd57198esm20616428eaf.11.2026.09.09.10.11.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 10:11:53 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 1/3] NFSv4/flexfiles: report the intended opnum when DS connection setup fails
Date: Wed,  9 Sep 2026 13:11:47 -0400
Message-ID: <b18644579b7bde1d817ecb14ebe43cf7d2aec7fc.1788973535.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788973535.git.bcodding@hammerspace.com>
References: <cover.1788973535.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When nfs4_ff_layout_prepare_ds() cannot establish a connection to a
data server, it records a device error with opnum OP_ILLEGAL, since no
operation ever made it to the wire.  But servers can use the ff_ioerr4
opnum to distinguish failed read-class operations from write-class
operations when deciding how to recover the affected mirror -- a mirror
that may have missed writes needs to be brought back in sync, while one
that merely failed to serve a read does not.  OP_ILLEGAL gives the
server nothing to act on.

Every caller of nfs4_ff_layout_prepare_ds() knows which operation it
was preparing to send, and the existing fail_return argument already
divides the callers along the same boundary (false for READ, true for
WRITE and COMMIT).  Replace the boolean with the intended opnum, derive
the layout return decision from it, and report it in the tracked device
error instead of OP_ILLEGAL.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Reviewed-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 13 ++++++++-----
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 14 ++++++++------
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 12b7be95a9c3..8b43d642969b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -883,7 +883,7 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 		mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror,
 						    *dss_id);
 		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds,
-					       *dss_id, false);
+					       *dss_id, OP_READ);
 		if (IS_ERR(ds)) {
 			nfs4_ff_layout_put_deviceid(mirror_ds);
 			ret = ERR_CAST(ds);
@@ -1132,7 +1132,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 		mirror_ds = ff_layout_get_mirror_ds(pgio->pg_lseg->pls_layout,
 						    mirror, dss_id);
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror,
-					       mirror_ds, dss_id, true);
+					       mirror_ds, dss_id, OP_WRITE);
 		if (IS_ERR(ds)) {
 			nfs4_ff_layout_put_deviceid(mirror_ds);
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
@@ -2188,7 +2188,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		mirror->dss_count,
 		offset);
 	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, false);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id,
+				       OP_READ);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
@@ -2288,7 +2289,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		mirror->dss_count,
 		offset);
 	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, true);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id,
+				       OP_WRITE);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
@@ -2398,7 +2400,8 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	dss_id = calc_dss_id_from_commit(lseg, data->ds_commit_index);
 	mirror_ds = ff_layout_get_mirror_ds(lseg->pls_layout, mirror, dss_id);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id, true);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, mirror_ds, dss_id,
+				       OP_COMMIT);
 	if (IS_ERR(ds))
 		goto out_err;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 72b11034851a..09c3cd6964fd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -256,7 +256,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
 			  struct nfs4_ff_layout_ds *mirror_ds,
 			  u32 dss_id,
-			  bool fail_return);
+			  enum nfs_opnum4 opnum);
 
 struct rpc_clnt *
 nfs4_ff_find_or_create_ds_client(const struct nfs4_ff_layout_ds *mirror_ds,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d52f485d0650..bc95628a811f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -379,7 +379,7 @@ ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
  * @mirror_ds: referenced device node for the stripe, from
  *	ff_layout_get_mirror_ds() (may be an ERR_PTR)
  * @dss_id: DS stripe id to select stripe to use
- * @fail_return: return layout on connect failure?
+ * @opnum: operation this connection is being prepared for
  *
  * Try to prepare a DS connection to accept an RPC call. This involves
  * selecting a mirror to use and connecting the client to it if it's not
@@ -387,8 +387,10 @@ ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
  *
  * Since we only need a single functioning mirror to satisfy a read, we don't
  * want to return the layout if there is one. For writes though, any down
- * mirror should result in a LAYOUTRETURN. @fail_return is how we distinguish
- * between the two cases.
+ * mirror should result in a LAYOUTRETURN. @opnum is how we distinguish
+ * between the two cases. On failure, @opnum is also reported in the tracked
+ * device error so that the server can tell which class of I/O the client
+ * was unable to send to the mirror.
  *
  * Returns a pointer to a connected DS object on success or NULL on failure.
  */
@@ -397,7 +399,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
 			  struct nfs4_ff_layout_ds *mirror_ds,
 			  u32 dss_id,
-			  bool fail_return)
+			  enum nfs_opnum4 opnum)
 {
 	struct nfs4_pnfs_ds *ds;
 	struct inode *ino = lseg->pls_layout->plh_inode;
@@ -448,9 +450,9 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 					NULL : &mirror_ds->id_node,
 				 dss_id, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
-				 OP_ILLEGAL, GFP_NOIO);
+				 opnum, GFP_NOIO);
 	ff_layout_send_layouterror(lseg);
-	if (fail_return || !ff_layout_has_available_ds(lseg))
+	if (opnum != OP_READ || !ff_layout_has_available_ds(lseg))
 		pnfs_error_mark_layout_for_return(ino, lseg);
 	ds = ERR_PTR(status);
 out:
-- 
2.53.0

