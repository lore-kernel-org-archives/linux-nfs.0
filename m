Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120053;
	b=k/GBluI6QJYnvmHDTE2wssU8fTEnwvL2vnxcZiFqBgWudUf4xX7o4HpvZ/ehPR29wQEU
	 Nn94CsIeXv/+vQSjH1Q1i7F4FatI0+cDu8Us98M9t5OR78kg1LF228t+efw9OvpSZQpvB
	 Pejekqfy8lW1fPqbY7uulf1bJX8Y0HLgJnjPQWxzf5ascNt0NMGjzlV1/ywxy4XnkGj5u
	 mhSFMauXgrGtpGxPTIt96I3LqOmNA+nkyJqh3JAjzGmO7eVtt+7I4+Q5Qko27N62T5nB8
	 Lj9FFkj8XZf3+mVQ1A6OJb57kQowsRg46LAnjlVcJCYFaCS/vC5AYZ1CDsoXwwI15zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120053;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
	b=KlIRnMAf0l8NB4vAiM9Y1/3HvRuomwMdHD//0Loy7Zdg6A9r7k7j4tCh5F0yh9a9VZlg
	 UUIdc6e1V9KHXvJOrhcZdZsYYOWr95xbtuwDW6qXF332NfaRs/sTtEHKxCa2/CXThUyKQ
	 jCmfdmMJJIpK1MyfVO7q2zeImvU/xBkX6Xiq2JYdrkJ/0aIxPxAGeuGfKwD7Oip4ejI8T
	 +JTa7qeEjkL4xJJHBXLBx+5srCZoMSIPE5XNUBUCIJSzNWKnaCI3xwDoR1iaJf3lgUSlB
	 2dszkYlNnw1bWyOVlHyd/jp/40F/0SgkXTMxI72tSj/r2airB285rRTk92AWxxyfY3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BZ9ImGOo;
	arc=none smtp.remote-ip=209.85.210.49
Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE4C9606A336
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CE4C9606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BZ9ImGOo
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-862b3a39d0dso120942a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120052; x=1795724852; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
        b=BZ9ImGOoDZSK47YYeiPWUB06K/9DqrYvjO+X/1nUi0NKlGlOSaV2Xd1G6mHgb/s6Yb
         bNC+Wvgtv6LtRpHbmDjn8cPaHmvDQBUKVe5LG1WcLxu4JT3xSssPM1+ngzsRDaUsmWRR
         +hx/1X4H/6/k3smMYufJgXJLWWBPD11kPob3H6fY8q6cayRgaHN6mG51z2K8Ux1sQS1V
         Si8qTgeqq1dPrtC2Qx183md2I+eczwhyQBj53W2mnsET5X3wFXu7C3UisDuIicnNzLEo
         6o/R4+EkB9buBv50WOZlr4GczAArojJL4RkDowMxnkW7DSMaoStMJC7vaeyhGmR1y36K
         mXTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120052; x=1795724852;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
        b=IfQM5I+sVkr76pc/rb2lv0mu1rlOZ8E1brNAJv5gRwhLvp2Qde8cSPasQ/r9ddNQLq
         5eF51CSq86fBdJKjhMv5bwn3t66YTMHScUwcqGyWoRNo07mm0b88F0Yz2ob0vgquWqKp
         tMid1YOL0Jl1WDmo6HKKLD9ghAO9EHBiAJB28/tvUV5L7E3z4lI1QPSaHndSRF6JzFsd
         pQ+sBL7216vPa+XZc2lCwYefnff6RSpUnry8EwFeTkVeCdQVMEv5s9CTVm/FryE4v13Z
         cXQ1VxKfirh5eoBtOs1xIE5yNZKWdEOijdcmES9AIMeNSaJcRkvoXFBlC6q5NNPGCHaP
         tZEw==
X-Gm-Message-State: APuU4Z8XCYSgOsP5hkuEqIaMncjd24TJ6ixORPGj9WiRlNAhF7VSCk7h
	NlMd2NJED9WsN3HpY4Xyr2juJ/F6lFnTApcx0U66wSogaZH5A26B8aOmC1qG+hbEb87ED7/S0Tr
	osVfP
X-Gm-Gg: AYBFou0UxjyHicXdg91Yy3+Y+PXNCWPabOE1zn+kKed3RcI0oztkeWjfW+2G/lL1sCz
	GLijGgJhUF4LOxaJTYMs/VLzPoSJNeFkQLlOJr7lusLavcRdYN6GEYLDaxivfj0ZiaQwyqJMmWD
	kvxQy/H1UJRI8MkJkF9jX+Ft7343joou36e7kutmNbaJFv/0RnLztUx0OdOoC3/SKjUdLXuDgra
	S1hRogoAWEEdcj/B4z/x5Zro5Fq3guwpuD72J+1paBGqYWvTnGezpUtZgdNPWp4GUal8S4MzIvV
	zPqWhMxjE85J4SjHBstvitdoeYHssP+LgGIbdHQDQa9OxldmnrOVeJaAOwmmpUpiP0hBYViNMuO
	5dhE4vvl82A8jmYrOWTzMEcnEMak0Yw66DSaVj3l8j0ogJpT9S1/D9kieitqvyHHrts6DimTGas
	VRFD2pP69CjZpgIJcaldKiBnARugcKW14dkjls8cUiKzlUMFcQJkxnv0QFeVyZD7cz8NhJad7Xa
	vkecKUI/1oyR/vAYzwqM2m5FliFzcpFiAD92kDY0xvx1W5t/06uy/Ivn3zWRZCrKSBmWDhg+VQq
	ogeFBdxVCvowBTztHYhELoSRT21XyHidaHxDWsXyxoQf6HaSfhV03iqa1UYFfdKN84kxdLKNFS8
	A
X-Received: by 2002:a05:6830:230b:b0:816:a9dc:6d05 with SMTP id 46e09a7af769-8631537c5ebmr1492843a34.4.1795120051681;
        Thu, 19 Nov 2026 12:27:31 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:31 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/5] pNFS/flexfiles: use the MDS for locked-folio writeback without a layout
Date: Thu, 19 Nov 2026 15:27:24 -0500
Message-ID: <81fea5dcd8feebcf1590effad8b96648b288bb11.1795117974.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795117974.git.bcodding@hammerspace.com>
References: <cover.1795117974.git.bcodding@hammerspace.com>
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

Fixes: 8b0401373734 ("pNFS/flexfiles: Fix list corruption if the mirror count changes")
Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 +++--
 fs/nfs/pagelist.c                      |  1 +
 fs/nfs/write.c                         | 20 ++++++++++++++++----
 include/linux/nfs_page.h               |  1 +
 4 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3adfcc7d0cfc..56527054d87b 100644
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
@@ -1239,7 +1240,7 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 	lo = NFS_I(inode)->layout;
 	no_fallback = lo && ff_layout_hdr_no_fallback_to_mds(lo);
 	spin_unlock(&inode->i_lock);
-	if (no_fallback) {
+	if (!pgio->pg_allow_mds && no_fallback) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
 		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
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
index 0b42d31f7a75..0b2b262b0dde 100644
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
@@ -2091,7 +2093,17 @@ int nfs_wb_folio(struct inode *inode, struct folio *folio)
 	for (;;) {
 		folio_wait_writeback(folio);
 		if (folio_clear_dirty_for_io(folio)) {
-			ret = nfs_writepage_locked(folio, &wbc);
+			ret = nfs_writepage_locked(folio, &wbc, force_mds);
+			/*
+			 * -EAGAIN redirtied the folio and asks for a resend,
+			 * which can't wait for a layout with the folio locked:
+			 * resend it through the MDS once any part of it
+			 * already sent has completed.
+			 */
+			if (ret == -EAGAIN && !force_mds) {
+				force_mds = true;
+				continue;
+			}
 			if (ret < 0)
 				goto out_error;
 			continue;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index c38e4b380be5..d79bea9d4f90 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -120,6 +120,7 @@ struct nfs_pageio_descriptor {
 	u32			pg_mirror_idx;	/* current mirror */
 	unsigned short		pg_maxretrans;
 	unsigned char		pg_moreio : 1;
+	unsigned char		pg_allow_mds : 1;	/* MDS if no layout */
 };
 
 /* arbitrarily selected limit to number of mirrors */
-- 
2.53.0

