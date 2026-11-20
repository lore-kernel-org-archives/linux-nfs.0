Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136521;
	b=ykamwAxDD9i6B2iWhsglMVQv9KZ0ctbMJLNcyPitdQd+mtcY25oBYd4RR0sv/OxbfSfr
	 hyMl15P4sQ0nNdcNjTBXj0V/yRBpU4zxsPyKAX5nu4DlnRvhN27yWrB0tnJxZCBxrNGSg
	 2yeWA+jQ2FCCPOGEhYckqiMtMnzNq3Qsa6kDBuMESLr5uEN7OuFxO7pH5LRjYTkDyNdp4
	 u3ShQXDFJEWDqlj26PjcMJaSnxc8t7lnLmFAj9ZDJ5ZwCbOqbSgI53E22hhbwiznNkVV8
	 oplRfSEbucau/lTTC7PWANNJoRB2tLHa7zsaAU7RDm9Mc2JxCRjDaae2kTQLhnZRygQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136521;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=lqsZ0W3pztHAbDfq8i7xBbH2UFJrqKGxgAFxaM3+iYM=;
	b=LHe0XCeJdkD1k0gPjeF5AgTtext3vbaShdjqmio6Zn94bjBPRKUSsaBLLNPhwR9eJlvr
	 zgQF0anrPNRvZTgD4wQW//sJgZT0p5Tdh1RKGLh+lhTBXw3BvW1frWyMJFIWWJGxWQc3B
	 ckMUINABFVvZsrNQmYXBxNhiYu+Wo1NtJwfwF71vIzfpVpdhMzVlEWAzD2Z9ZZnGgmbf4
	 b/rD9jlxIr3TZ6PujsOnnnqnWpBdbFVXNN77EJIQCjZVG3Os9c0EXDiqrnxftNWa3Hhpx
	 ssy9gkdAx97/tJPhbcAytlmVHfMb1RXyN1yujF5JJbNSwmx5K9rFz0Boy2wP6vAEpCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NDZHNpUP;
	arc=none smtp.remote-ip=209.85.161.52
Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F513606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:02:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3F513606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NDZHNpUP
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-702dedeb70dso253964eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:02:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795136520; x=1795741320; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lqsZ0W3pztHAbDfq8i7xBbH2UFJrqKGxgAFxaM3+iYM=;
        b=NDZHNpUP/UWqgHTG5PFp1q9fFdjEi3Q0kUZ7TgBgOEMQLXzSw2JLB0yI4CFTrp/6GY
         ftGWt/NYQ+tUrBS0Pk4gslzyABonduhjGPaLDs3+Ne4aNhcla1r9/nNLwqLOz+APZ5dO
         NuVziRahnd16bY1eG+9iKj6yeL/MHj8fyMX5EAGqzfpauGvlmXSzYzkN59LbNPHu+/XT
         ERRqVTRtzODdnBtDBApP93+8TJkXeRdAlQ/N9/tPC/oXqiNJBK3qvCkpNJrHYe9e+cr1
         WyKk4klDvGM+thMxe3YisBkOO7tR3HKQx2wfuuXms/mN9vqb/JB1Hac0Ciw/pHkLXXsY
         tMzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136520; x=1795741320;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lqsZ0W3pztHAbDfq8i7xBbH2UFJrqKGxgAFxaM3+iYM=;
        b=DxUvvVjmxC73nwD+o+sF89ppg/9Acwrb2iJ8KUEPmPw79MaFBUjZznfrzV/XGF+zm2
         1kOvrlQ7WtjwYfUuySlhvU1b0ajQ7ehsnQZkXHR4dYd9IBZnSK9K7BlUq/DpKSelKk1v
         66Rcgp/VKq0f/a1lDVFqkCeyPLLjotLlqYP5s0CGhH+k5QBL+rc4Z5LslEXgnSjtvyoL
         +hsCgCSrXDGBWkaY7iZaNxq8p2RPtr6OZhYFUK44B3KAwJJyOwEyx3YJrxfLtdoISiLx
         JENJpRhkGttuzi0qJBtxxrIzOeDhhDiYOco3wXfpYd9OtfnEUA4AbO3CGWRCPnGN0C6O
         TroA==
X-Gm-Message-State: APuU4Z89M/uB4d+MiCKDIQLK9evdR/06oEVdwhpEhPUaD2i0nA6ctzLM
	QAYNArJfKfzltcXoPsjwFn+fTgJ5XWarqSoLdf8JjKBz0saKx6hUnaZ4nThPMNoqCGsm6f2+sp7
	Vbj9d
X-Gm-Gg: AYBFou2Dj9/8v+BCBpvDxaw+yn6QihtgE8yiO+Bf94DBhROjcZmIVDoVHQ6GMM6joOF
	UL7UzVF1ZQ6ELTidgKleIXnthwMpExQB7jf74GHlvVcd1ev+a9IVyO2nSDEP+oIW6pXqK0EXx9z
	nmh9dd+rilCbftp220qmz7UwTrZfT902S0H4ftxHHHB4/ho16Mfik3jotB2kSycBmxqaGeMgICC
	gHYxouDju2Ay9LF2k9+LlDg+45qBisHcw+tqM0s+pnGMvK8zTFP/J7IHCt2Sti2myl1vnnLG/eX
	DdKFvcbaXewWxPMGjMWxfFGeXHTxmY/BrpTLNW4FOYzozhL5Pp5TBSItYx6YnvlrPWC6LHwczjS
	qVNm26RstvevjSG4EjqKw/tKJRiAC1pSJVvPjn9z5aWlw2M94nNgvUCr6K8lY7EQe3gOk3A7SUP
	tSqI5ZdncEIiBz2nrkQ1JnyJkA7Va9RLToeWrFWrDOLsO0TdxAK6t7IFekBsp0iZLUqdUinPuIm
	Srk2tQrM6lEvfRMto9+l1rquPqrhiTMF4c7dbHxMDtTgGOZe6DSsQVsMI9QAyE2tPn5a+57btgM
	hd3TrTrCKT94B3ZN0O2e9aHOuOxeFhLsX4K2e5CpdZopF/DW2tcgQJ+g7+qmqmApehIX/oE+3D7
	P
X-Received: by 2002:a05:6820:808:b0:71a:cf71:eac8 with SMTP id 006d021491bc7-71b39511525mr1479014eaf.57.1795136519777;
        Thu, 19 Nov 2026 17:01:59 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea818bsm1101995eaf.1.2026.11.19.17.01.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:01:59 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pNFS/flexfiles: don't switch a busy mirrored write descriptor to the MDS
Date: Thu, 19 Nov 2026 20:01:54 -0500
Message-ID: <ac9c90fc9576a7651e13cb0c6cca1f11a1ea5daf.1795136323.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795136323.git.bcodding@hammerspace.com>
References: <cover.1795136323.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

nfs_pageio_reset_write_mds() replaces pg_ops before it completes the
descriptor, so the completion sees only mirror 0.  Requests queued on the
other mirrors are never sent or cleaned up, the mirror array they are
linked on is freed, and their folios never leave writeback.

ff_layout_pg_init_write() falls back to the MDS from a later pg_init while
other mirrors still hold requests: when the layout segment is gone, or when
a mirror's DS cannot be prepared.  In that case return -EAGAIN as for a
mirror count change, so error cleanup redirties the queued requests, or
requeues them for an O_DIRECT write, with the flexfiles ops still in place;
the next pg_init starts from an empty descriptor and can switch safely.

ff_layout_write_pagelist() returning PNFS_NOT_ATTEMPTED has the same
problem through pnfs_write_through_mds().  It does that when a DS of the
layout is unavailable or when preparing the DS failed fatally.  For a
mirrored layout, return PNFS_TRY_AGAIN instead and leave the MDS fallback
to pg_init of the retry.  pg_init now also takes it, through the check
above, when the DS it would use for a mirror is marked unavailable; a
failed prepare_ds fails there again.  Other failures, such as creating the
DS client or finding a credential, are not visible to pg_init, so mark
that DS unavailable before retrying, unless the failure was a fatal one
from preparing the DS.  A single-mirror descriptor keeps using
PNFS_NOT_ATTEMPTED: pnfs_write_through_mds() switches it safely, since its
only mirror is not freed.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 48 ++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3adfcc7d0cfc..111662f14524 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1133,6 +1133,22 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_reset_read_mds(pgio);
 }
 
+/*
+ * Switching to the MDS discards the mirror array, so it must not happen while
+ * any mirror still holds requests.
+ */
+static bool ff_layout_pg_mirrors_busy(struct nfs_pageio_descriptor *pgio)
+{
+	u32 i;
+
+	if (pgio->pg_mirror_count == 1)
+		return false;
+	for (i = 0; i < pgio->pg_mirror_count; i++)
+		if (!list_empty(&pgio->pg_mirrors[i].pg_list))
+			return true;
+	return false;
+}
+
 static void
 ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
@@ -1172,6 +1188,17 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			req_offset(req));
 		mirror_ds = ff_layout_get_mirror_ds(pgio->pg_lseg->pls_layout,
 						    mirror, dss_id);
+		/*
+		 * A mirrored write cannot fall back to the MDS from
+		 * write_pagelist, so do it here for an unavailable DS.
+		 */
+		if (pgio->pg_mirror_count > 1 &&
+		    !ff_layout_no_fallback_to_mds(pgio->pg_lseg) &&
+		    !IS_ERR_OR_NULL(mirror_ds) &&
+		    nfs4_test_deviceid_unavailable(&mirror_ds->id_node)) {
+			nfs4_ff_layout_put_deviceid(mirror_ds);
+			goto out_mds;
+		}
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror,
 					       mirror_ds, dss_id, OP_WRITE);
 		if (IS_ERR(ds)) {
@@ -1198,6 +1225,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	pgio->pg_error = -EAGAIN;
 	return;
 out_mds:
+	if (ff_layout_pg_mirrors_busy(pgio))
+		goto out_eagain;
 	trace_pnfs_mds_fallback_pg_init_write(pgio->pg_inode,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
@@ -2455,9 +2484,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	return PNFS_ATTEMPTED;
 
 out_failed:
-	nfs4_ff_layout_put_deviceid(mirror_ds);
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
-		return PNFS_TRY_AGAIN;
+		goto out_try_again;
 	if (ff_layout_no_fallback_to_mds(lseg)) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
@@ -2465,12 +2493,26 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		 */
 		pnfs_error_mark_layout_for_return(hdr->inode, lseg,
 						  &mirror->dss[dss_id].devid);
-		return PNFS_TRY_AGAIN;
+		goto out_try_again;
+	}
+	/*
+	 * pnfs_write_through_mds() cannot switch a mirrored descriptor.  Mark
+	 * this DS unavailable so pg_init of the retry uses the MDS; a failed
+	 * prepare_ds fails again there.
+	 */
+	if (FF_LAYOUT_MIRROR_COUNT(lseg) > 1) {
+		if (!ds_fatal_error && !IS_ERR_OR_NULL(mirror_ds))
+			nfs4_mark_deviceid_unavailable(&mirror_ds->id_node);
+		goto out_try_again;
 	}
+	nfs4_ff_layout_put_deviceid(mirror_ds);
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
 			hdr->args.offset, hdr->args.count,
 			IOMODE_RW, NFS_I(hdr->inode)->layout, lseg);
 	return PNFS_NOT_ATTEMPTED;
+out_try_again:
+	nfs4_ff_layout_put_deviceid(mirror_ds);
+	return PNFS_TRY_AGAIN;
 }
 
 static struct nfs_fh *
-- 
2.53.0

