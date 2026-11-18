Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.178
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795027019;
	b=Uc7ja5usVajrajIBe7/eagp5XTngrpOPozymhG6v175rNTt4rAfhbCeEdvZhHehR2uXk
	 0S9UZHMfhgiRCvHpwgzLity1uYxJM5RQyplyqO4xCb16J5oWBGtEBjQ35/BAGyf9+46DE
	 bfe2ZQFl05aWPCqia48MP8E26hiBiLOcdpAxH2qmGXz5zbrnRQnbaZR0+ppY2aWev1c9+
	 LZh8gwLPtGYU0ij9DkB1vnH9DpQe2mrOCOWCs57OtiOT6RQw2VKezaIX7cx2Q+rxioj6x
	 ARDwJjUKNtx2ahZ42Sn8QJvk4dw2KDGD5hh1AWuQjD7N8XnDEzLs+aHc+EtA3v2WjlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795027019;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Uk1vkfH0UfgNcKAfceuzpuSwL07Ule5Zk2c5hljKGEo=;
	b=Dp83y0dXebb9W01G5/08teCG8UZJjQmgaEH8az4BbNOOaEPcVpfYG38v00eSe1TWy3Zw
	 roFb0ZpntVUPJ983qqQm7wKm//3au4TLo6zpwvinwCejnW8ChVKES2q81Uhz6UkAsjWYL
	 sAtMJ6K4xo/ZmyNvfaKVN6/3SKSPisLnEgz4k9cpcHsRzJF3h2lkwTD0qGszOsokX6jHh
	 Z3r2tVn+Q/ab7GzG/5gX7BuKXAV4MtZ5drg8Z0jP7AKvtdJn2I67HwrIUopScrpqui2Ry
	 Vy8lUPQ6SB9gGK47S3oV8pgmAJk7o1BQ2/hU4q80jEhVx0RvFmSQGEBsa4T6xa4u4yQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iVdJjJM1;
	arc=none smtp.remote-ip=209.85.167.178
Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7234606A332
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 18:36:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C7234606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iVdJjJM1
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-53dda625f63so825812b6e.1
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 10:36:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795027018; x=1795631818; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Uk1vkfH0UfgNcKAfceuzpuSwL07Ule5Zk2c5hljKGEo=;
        b=iVdJjJM1jizhJ4n8IMWyuBBi338QsjQw+Rxzf0uzXnpNVyOStph4KW9QCD0tcxN9WK
         vd0qdVHWYvx1LrFg0Jy9q2zAJEAxi1b+L+E9QtDPqYZGCSrrYEL0Hz7mejcinArjpt+3
         RCcbTjqzzH5wHO291+9iyA6AxYq6O8ZLWNGYzjJxNsHhyPRHCN+V8etXrgzOf5fGHEHr
         mZ78LCI6ByAq/fXLx5Y3KT61RIq1MjK1S7mfzDQ441VTkSqJfvu2IGqDsqBY/QXj+OaN
         QIYLz2CdZc8bdQkO3NkG5M1D9fZgU38OOOYgXVz8kq2Ng/0IKYbSO8BfyMRVkbA3D/5i
         uudQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795027018; x=1795631818;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Uk1vkfH0UfgNcKAfceuzpuSwL07Ule5Zk2c5hljKGEo=;
        b=EVHfH5wDyQ3wMt8NE3bV84DGS/0EYveGlK7jg3mVDOBykAv2CwY9R+ib8F9/k8CCkB
         tsEMehA4FcxkghUk13mWD3eVMqf9b9K9cq08k1+xs1TbuH2L21dSDuQR/sLwSLqLi8+P
         1ngmbuA+WOqnrRf9bfK0d1WgaXRJ7L8Epzs5taEVe1AeZXk4DrHIJ6XJYOT/+wMY5GWn
         35UGssudqdgPX80aiivB0Hl67wMV2KhAkS5osCxe8JnzzPvWyC19pzsAqG5fylmXOuBU
         1RpjS2s6L6lQ4cblNCp/gE/Xf8/OfBXlFXtcrmHGANnuhQPpfD8dnc0EWyzrBK1OTIxw
         qqIQ==
X-Gm-Message-State: APuU4Z8Tlwm/GRfev6NMcY1pSQ4ftkVHBkDX3lmDTb/cSf62HZDwlZUH
	LaSRHdI2lhNsXW5xk8sBUm5qfMbm+gflsg4FXK7oA50Bzp6FHa6USkkKF2nCkITD/oJCTdDwTnY
	GpPDp
X-Gm-Gg: AYBFou1lCytDvSuxKdoxWpnuOj46hKyQr1hao32vgBpWpI7RpEtoxGDXL0oiGLMY+l0
	O8qJSKfR8rDKXGHlT1jD/3INiGruAPigXv6p/xh2nD8NIYhNSlOHIUHaUgypvuMqXldF7R/ckTA
	OynO5TYABfZoV1x39WXwFlPT5gyIxQHcXB7w4MTOgxbofOfx45jwiEN905za+bC5KzFN7KikHBX
	1CvbMskzjlkOZApXp66p5Rl+l2vhI9/wHYvNMvp4Qyu+P93UGlKGyvEebaDffn757CR9NNUz6TU
	faLmzr5SJVIbHqC0BLOROXVIdevHM7sjJPuFZlqEjIv99fz/025rYm+32xGh/Ted6eoBT72yEZd
	j/YhcnKXav4kPcUwNwio3oKwVnYrfPrQQvgKiwYWhf7LuzV6N0RV4vhYdAdzBvkppHAa/JMY/ut
	pef2wTP3btnnvibtELgW5Qd5dt9wnx0bIdJ8qTU0qyo+IlEaIrSVY45zrje300wUU3mD0ZgrOtE
	tAwI1DaHxGrLdYuQqwdnYKYr6/hzxEeFYolFmRh4j7qo+zLekd4Ti0iW0GZg8cFdGWcXUCPY2pW
	bnUioXTTOxrHmF+fxs1CwyiklBXHyfg0QNk7FkzzP4AQm0MXx4SrKACSs7sVUzCRTe4enxcfmvP
	T
X-Received: by 2002:a05:6808:19a5:b0:4ab:230c:5faa with SMTP id 5614622812f47-5773eb4fb18mr4129479b6e.18.1795027017656;
        Wed, 18 Nov 2026 10:36:57 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5777a8a6af8sm2341713b6e.9.2026.11.18.10.36.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 10:36:57 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pNFS/flexfiles: use the MDS for locked-folio writeback without a layout
Date: Wed, 18 Nov 2026 13:36:51 -0500
Message-ID: <79610683ae2bb6d39feb578a27481d588c245d45.1795024981.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795024981.git.bcodding@hammerspace.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
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

nfs_writepage_locked() writes back one folio that its caller holds
locked, for nfs_wb_folio(), nfs_wb_folio_reclaim() and migration.  When
there is no layout segment and the file's layout header carries
FF_FLAGS_NO_IO_THRU_MDS, ff_layout_pg_get_mirror_count_write() refuses
the write with -EAGAIN.  nfs_do_writepage() redirties the folio and
returns the -EAGAIN, and nfs_wb_folio() passes it to nfs_updatepage(),
nfs_flush_incompatible(), nfs_read_folio() and nfs_launder_folio().  A
read(2) or write(2) on a blocking file then fails with EAGAIN, for
example when another open context has dirtied the same folio while a
layout is being recalled.

Resending from nfs_wb_folio(), as nfs_writepages() does, would hold the
folio locked across the resends.  A bulk recall can't complete while
nfs_writepages() holds a layout segment, and nfs_writepages() would be
waiting for that folio's lock.

FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2).  Mark the
descriptor that nfs_writepage_locked() uses with a new pg_allow_mds
bit, and send its write through the MDS when there is no layout
segment.  When ff_layout_pg_init_write() can't use a data server, send
such a write to the MDS too, instead of retrying with the folio locked.

ff_layout_pg_init_write() switches a write to the MDS by resetting the
descriptor and returning -EAGAIN, which nfs_wb_folio() also passes up,
with or without the flag.  When nfs_wb_folio() gets -EAGAIN, wait for
any part of the folio already under writeback, as its loop does, and
write the folio once more with a descriptor that goes straight to the
MDS.  nfs_wb_folio_reclaim() still returns the error, and
nfs_release_folio() keeps the folio.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 +++--
 fs/nfs/pagelist.c                      |  1 +
 fs/nfs/write.c                         | 19 +++++++++++++++----
 include/linux/nfs_page.h               |  5 +++++
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c289737366f..2b0a0af469fb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1176,7 +1176,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					       mirror_ds, dss_id, OP_WRITE);
 		if (IS_ERR(ds)) {
 			nfs4_ff_layout_put_deviceid(mirror_ds);
-			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
+			if (pgio->pg_allow_mds ||
+			    !ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
 			pnfs_generic_pg_cleanup(pgio);
 			/* Sleep for 1 second before retrying */
@@ -1229,7 +1230,7 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
-	if (NFS_I(pgio->pg_inode)->layout &&
+	if (!pgio->pg_allow_mds && NFS_I(pgio->pg_inode)->layout &&
 	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 71f0ce2bc4ea..aa6d7b658d79 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -871,6 +871,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     int io_flags)
 {
 	desc->pg_moreio = 0;
+	desc->pg_allow_mds = 0;
 	desc->pg_inode = inode;
 	desc->pg_ops = pg_ops;
 	desc->pg_completion_ops = compl_ops;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b42d31f7a75..ec6b771b8dbe 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -627,15 +627,16 @@ static int nfs_do_writepage(struct folio *folio, struct writeback_control *wbc,
  * Write an mmapped page to the server.
  */
 static int nfs_writepage_locked(struct folio *folio,
-				struct writeback_control *wbc)
+				struct writeback_control *wbc, bool force_mds)
 {
 	struct nfs_pageio_descriptor pgio;
 	struct inode *inode = folio->mapping->host;
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
-	nfs_pageio_init_write(&pgio, inode, 0, false,
+	nfs_pageio_init_write(&pgio, inode, 0, force_mds,
 			      &nfs_async_write_completion_ops);
+	pgio.pg_allow_mds = 1;
 	err = nfs_do_writepage(folio, wbc, &pgio);
 	pgio.pg_error = 0;
 	nfs_pageio_complete(&pgio);
@@ -2057,7 +2058,7 @@ int nfs_wb_folio_reclaim(struct inode *inode, struct folio *folio)
 		return -EBUSY;
 	if (folio_clear_dirty_for_io(folio)) {
 		trace_nfs_writeback_folio_reclaim(inode, range_start, len);
-		ret = nfs_writepage_locked(folio, &wbc);
+		ret = nfs_writepage_locked(folio, &wbc, false);
 		trace_nfs_writeback_folio_reclaim_done(inode, range_start, len,
 						       ret);
 		return ret;
@@ -2084,6 +2085,7 @@ int nfs_wb_folio(struct inode *inode, struct folio *folio)
 		.range_start = range_start,
 		.range_end = range_start + len - 1,
 	};
+	bool force_mds = false;
 	int ret;
 
 	trace_nfs_writeback_folio(inode, range_start, len);
@@ -2091,7 +2093,16 @@ int nfs_wb_folio(struct inode *inode, struct folio *folio)
 	for (;;) {
 		folio_wait_writeback(folio);
 		if (folio_clear_dirty_for_io(folio)) {
-			ret = nfs_writepage_locked(folio, &wbc);
+			ret = nfs_writepage_locked(folio, &wbc, force_mds);
+			/*
+			 * -EAGAIN asks for a resend, which can't wait for a
+			 * layout with the folio locked: resend it through the
+			 * MDS once any part of it already sent has completed.
+			 */
+			if (ret == -EAGAIN && !force_mds) {
+				force_mds = true;
+				continue;
+			}
 			if (ret < 0)
 				goto out_error;
 			continue;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index c38e4b380be5..d64332afc374 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -120,6 +120,11 @@ struct nfs_pageio_descriptor {
 	u32			pg_mirror_idx;	/* current mirror */
 	unsigned short		pg_maxretrans;
 	unsigned char		pg_moreio : 1;
+	/*
+	 * Set when the caller holds the folio locked and can't wait for a
+	 * layout: the write goes through the MDS instead of waiting for one.
+	 */
+	unsigned char		pg_allow_mds : 1;
 };
 
 /* arbitrarily selected limit to number of mirrors */
-- 
2.53.0

