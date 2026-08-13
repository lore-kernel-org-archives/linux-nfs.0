Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74F103DD525
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:07:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786644444; cv=none; b=Sghr7/3G5heePf2T1rpTpZJmOdo9YUKqrxIwsZg/uM2HhYY0qxeErTwDn3Roi7iQaRQEMKLhqAWz3AWTURnVQKW+nH87EWttBO2DxLk6+FMtV80JeS28Bf9uE67LKq92Alois72sJ87sy5WcYQbFDsmALXED6OmPBoR+GuuCxic=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786644444; c=relaxed/simple;
	bh=a5JRTt3zwRu/LKS0Ld6bHL/1eCcd2ne2lNFcA5iUYjk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MEHKSqZ3utJNUM3FAFIII/gPdSBbDEKBqLrF4DdOVNwzud4uLNVUHu5I5FRpGgl8B5P51tYe9kgPcTe/3y3LZA4yg2TSfAcDvAhbnLIxA2FHI4zI9fQKAWW/u5BEPFNVKzI2VaztegEzQT8RUYCG6BIMl4ayqGYLC0+FaKvNMOU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=OmVLw7My; arc=none smtp.client-ip=209.85.160.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="OmVLw7My"
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-448cf99c133so1114324fac.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 11:07:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786644439; x=1787249239; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LkId6RVsJJgZaKNzkBsCIl0Y2OtEpkkMdy+zc+mM4FI=;
        b=OmVLw7My+uv3cCbnxKEQF/qBIEO7o9IZTPIiLYyFPJmeufhmwAI54LDKaIPpzkus8N
         qgL3AGzbc5uz7zWly5B/W8c4NwNt+8vH3WYeam4CzYWBwVC8vGUlSR6z9uwqpcpkiGmY
         W3bSMtHu7Gx2SWKPKO8hR7CXFGx47fPvQbwE1IImJXR4ohYXIVE8zdKOrRT3PX27bF3+
         cx4t1VTNOmTLy6WEh2/n8aaxP6CpS1jA8JOSctne6dla5gWRGYohdy8V8qyAPooe3+pj
         K0TrErPepZn+Wo7XXnTMtas3mcasVG5yWqqhzs2H2tvvGbtRlWe9r/3uXAyoeWzr70ri
         r/RQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786644439; x=1787249239;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=LkId6RVsJJgZaKNzkBsCIl0Y2OtEpkkMdy+zc+mM4FI=;
        b=mc5rgMEdrS/R6TsNxNsAK+OKma3Ev0tIkpA3HnIiaKRC69XVSezDRbhsEN+TVkVrvO
         1Qrpmzj0wWqcu7rk8YjrQf/gFNd/hLx373sBQiJdrGTmCsNf+iliCxoZtLJs8rLaPoHn
         ONUAlzJTV9nGONrcRrpiSPCKtcp4LU+0tRYX05m6r+wBMD8J7l3ZuTiIcvH+NRJKl1Bt
         TrTuoyWmwKa3VizbV2kUIVcUHy7sQO4h5i4gC2AxmTPirEzQJjrv0skmfsokZxdvxIw+
         kCRgPAMc+2xecfQPT2qi6CDPou3IFCeStMzIS21tBx/ThSEtgvqcwAbAeXuZyr67iLJ0
         lmxw==
X-Gm-Message-State: AOJu0YzYhV8EUJU1pUZ6oZp+NRJU+O9KOU6Ay+2CipNAGZZljP7C5pHL
	NHhx5bfnc5hyx+v7a7BfqzAkenxJWpbZLAYjUFzjcJ1PipAZxTsSIeV+AjEq7loKhsSwEiSnfly
	9Xsa1
X-Gm-Gg: AR+sD101g4x1LSg5GismXwfES0tYgdvIA8fpOpbGYDC0VbnbZQVsdcNT3rjVu7gebKi
	vl51KFj5SCTQRGPqpVv/cVT7Hi/mxlUI0xt5kJvtQnXaIhP3gsfzY50fu68VS8gmD3Fh5kuJm4y
	NCiCfIKE+6dt+qEU0U0TL0GSVIGSi8KFSWrdpgL7ldfyZGSSaprOQ1RMcrQlTyrDm7A0cA7jNkt
	4SDT3KbtS98rYjAWWTqVTUGvjUGZOXYdrpOqaS9oJiH/3KGOebyl4zqM3oTFiFoldehvcg17clc
	RtI9r0x1l/hq2WQxTdfbNHKWygvSrQKe25yoSudoA7FpQ4TRkEWHGbWKgKOrw+XWYUy05gclGcx
	vQERWifFcXj5JmlHpAvCT2FObJp9BMpOXH+zXLjHUaEZKLZzssJImp+uz0OEaCE/uSx0QHtjU4n
	xZk3PnAmA1g9xg1P6BHa1UcMcmoE3wBlp/QGN7Gfd+C7nfMr2iVlXGaYDJMBdzSxScV2WPPt5OE
	1z8oMB5Cdkz0mS9jSui9OrQ
X-Received: by 2002:a05:6871:3407:b0:456:c5c2:ee22 with SMTP id 586e51a60fabf-45e64a53112mr5713535fac.3.1786644439207;
        Thu, 13 Aug 2026 11:07:19 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-45e8f96010fsm211730fac.7.2026.08.13.11.07.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 11:07:18 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4/flexfiles: report the intended opnum when DS connection setup fails
Date: Thu, 13 Aug 2026 14:07:13 -0400
Message-ID: <716acff789261dade8d1f530f2bac243e9c7791e.1786636529.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786636529.git.bcodding@hammerspace.com>
References: <cover.1786636529.git.bcodding@hammerspace.com>
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
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 10 +++++-----
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 14 ++++++++------
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..2c30e62881a1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -893,7 +893,7 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			fls->stripe_unit,
 			fls->mirror_array[idx]->dss_count,
 			offset);
-		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, *dss_id, false);
+		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, *dss_id, OP_READ);
 		if (IS_ERR(ds))
 			continue;
 
@@ -1135,7 +1135,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			mirror->dss_count,
 			req_offset(req));
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror,
-					       dss_id, true);
+					       dss_id, OP_WRITE);
 		if (IS_ERR(ds)) {
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
@@ -2184,7 +2184,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		FF_LAYOUT_LSEG(lseg)->stripe_unit,
 		mirror->dss_count,
 		offset);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, false);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, OP_READ);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
@@ -2275,7 +2275,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		FF_LAYOUT_LSEG(lseg)->stripe_unit,
 		mirror->dss_count,
 		offset);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, true);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, OP_WRITE);
 	if (IS_ERR(ds)) {
 		ds_fatal_error = nfs_error_is_fatal(PTR_ERR(ds));
 		goto out_failed;
@@ -2376,7 +2376,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	idx = calc_mirror_idx_from_commit(lseg, data->ds_commit_index);
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	dss_id = calc_dss_id_from_commit(lseg, data->ds_commit_index);
-	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, true);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, dss_id, OP_COMMIT);
 	if (IS_ERR(ds))
 		goto out_err;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a5bd00f69e82..8e3a1e45ea68 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -252,7 +252,7 @@ struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
 			  u32 dss_id,
-			  bool fail_return);
+			  enum nfs_opnum4 opnum);
 
 struct rpc_clnt *
 nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 8be5c730e101..5920ba529a0b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -359,7 +359,7 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
  * @lseg: the layout segment we're operating on
  * @mirror: layout mirror describing the DS to use
  * @dss_id: DS stripe id to select stripe to use
- * @fail_return: return layout on connect failure?
+ * @opnum: operation this connection is being prepared for
  *
  * Try to prepare a DS connection to accept an RPC call. This involves
  * selecting a mirror to use and connecting the client to it if it's not
@@ -367,8 +367,10 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
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
@@ -376,7 +378,7 @@ struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  struct nfs4_ff_layout_mirror *mirror,
 			  u32 dss_id,
-			  bool fail_return)
+			  enum nfs_opnum4 opnum)
 {
 	struct nfs4_pnfs_ds *ds;
 	struct inode *ino = lseg->pls_layout->plh_inode;
@@ -423,9 +425,9 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				 mirror, dss_id, lseg->pls_range.offset,
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

