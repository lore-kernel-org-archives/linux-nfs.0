Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191001;
	b=zqIwDJ0yxk2FZdhtEF+nCYKP2Wos44m9y7Jqjp//KY961ZHs1+PU2ArN5Wkg4fcth22l
	 JvmFheEr+8AErm5dC+qVt4z105IMWorCgmI6os69EAyzrBuTtglCIeLjQVPqPcfvRLXCI
	 4XI10AB5APdLgOmrzygb0J3YcQKIs2RDCcvS5Y+FPEz3NXLWahPlIy48+sWhHn9Zy2eA7
	 hMv3S9Pa9LUGz4W/BOIGxALgbKpz4isw/NhogkcL7BmQ5gu2VomKhvRnl0GrfYB1RH7t5
	 A6uC1qHiSqgQs96+Dr+vr3cV76SuIz5MW0IeUeVMBBGSCZUoYSRML08Jd0jkzDRi/Fw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191001;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
	b=CmICgIo6mjpz4tgB2Ovlhiw8QnqcE9AUVFfm4ibDy6/4TGroT5Qhw3O6ipNgUXiRpuiB
	 FRrIiUk0F0yIvnLD0xhIP3pMsXo8HYZlEftLdQuyB3Bj6RdOaKpVafi/d4k9fymPIe/lG
	 GVus9TRMUaE9pL5oQI6DtFAts9ANfT69r73ej2Xn4Wq5y7GIpq9otB495jZ1ERbsFJ7lu
	 pism2NwRBSTeqp+ri2M3T1gUqTQYGNY6dC4gpAWvmQfY9YLARxY9zvfE0NpkLyqO1+wcJ
	 Mv6i2UrNhUYFZsnzhPsDEs0ucJ3b4WOm3aF3ikMuSo7yO2b+FgKdblHdH5ainxLp6QA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=LibPHncA;
	arc=none smtp.remote-ip=209.85.161.50
Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB8F5606A332
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB8F5606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=LibPHncA
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-71ad5f20016so748310eaf.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:10:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191000; x=1795795800; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
        b=LibPHncAG7PihS8hF9fbSssEbfr42m5ZQGDSX1oD/JLkiwJcMn2T0bo/8DQsZ6mNVm
         0BMlRJBEl8WJU9WXM3Yw4TmCgDNR/P7H5JrY7tYKsQKyUpD6/wwO2lI6Ee8imY3QNSnY
         dFQ5CAzpkV4C0hl/IoiDs5NEOhv7UAOuhYfhF+pUA53fzx9+QA6QcRq5AuOgGGhkO4xI
         BbSEdRgxuF8v0xfY1HnhAEcecxBVt1X8uw6eFXvNXpf29B3wcJUuV84X8HpI+d3w2KzI
         X7FslENqZju7fZ53Ia/DQ0ETWpvqCBDxVPDEhFzrtuvRs8bUXuYJMd4dSTb05/Xg3VkX
         6fjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191000; x=1795795800;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Cy1/J7nVIEfr7R/L1kA9RYu1H+FxhJ3E+qpLeZZUjwI=;
        b=vhYnG3CjdXKoJFLX0Bzpj+oXnx6nNTpnGyoQQiFkGRqEaZCxVrJcvuc7ACaMZZWIaU
         KTtH0WOUU+cKRJGg3fyfQq4l6ue0YpeC8XcDhYns8ooIbkhckmpCWL28c5GfoPRbQPnR
         zRsxFIxbAr+7ZmQmGQt7/hB8+mx1scDVXDYcXuhaTDulzak7pIhsO4W2IEpgCiCGz396
         nij+7FdFQ05JnviCxiREgDTqYeNdQDDggDmxajMxU500PKc2zWB5EqYxRyNPzDab3OkI
         cwUOy1CcK6RMRVCXNt6YJ+/wyN8Ll6zrZDwesJgjlywbOj6vY+h3PAPnThHFTodRHhlE
         qbig==
X-Gm-Message-State: APuU4Z87Qy3dctTKDK/pqeJyiYqnAp78WWDyPislPM0pjUjNkD47FX1a
	p/eD3RhsesytiD2YrQQRHa1j/Lv1xLa1Z3CL38cYa5+e25NsD3qJc3NZ+MtNS8rl8Qk=
X-Gm-Gg: AYBFou2azjAyCTIPwaELrE9fMKAUyzvxGy0pFPBITFKEKuuDPZDPi0cuO6STe5W7tZN
	Lo/DNYpJF5742kGVi4vWOSFZYlaIPf++Lft4BMZ8RcK+zFpVdSdLBGC2IbApbCQl4oQF3jjnP+R
	hAX1ii/rEcCFcs/iVOTttgpfCqVgHtJhLdQQUA2UtObfqX1kw/dCQIpCCGduotU3MDfFXSAO5Mz
	QfbkSwSctgMn0bwJNtBSY7hAKh18dTospBFW/oCNQlmmKPCXtcFS0AgdWjkmMvdINXS+XhTk1NJ
	2+sD/GR0ycMWu3p4t9vAag+Um1eaT4HYFfkG1XOMzMEAT6nIDMYEr+jIXU4FiC3biQqXRHZENC7
	sOzMF4uC9KcDez94YGH3THZzwQc7XuYBirixrCSr5cJhKc8q8mZldm/KxQOhplQD63FnBEJSjfS
	SJJAWRwNTbDmiJ6QhOGyRu8brSUzlVpkhLcRFoxJr8GYvTmxUx3WHdDgpj77IdLPkeFtZrYLvGy
	6ftBA8Zznb/Qiviippev29SwzPWyAFIEYZDzRTAIm9j5YNFxyCs17RcH9hQP1york8C1bWTB5Qi
	3Li3Vrwgy6l3zf/Am5hAH2fV9pgZ3Awp+ho0zvM0Wn0arSqZ1hvsS9Lef1h6pMaoCPRBFtQQV6p
	EEweSW0xjZu12XLcldfTyApjOpFlzSsFY
X-Received: by 2002:a05:6820:603:b0:710:8db7:5f55 with SMTP id 006d021491bc7-71b3956c224mr2993622eaf.71.1795190999543;
        Fri, 20 Nov 2026 08:09:59 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.09.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:09:59 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/5] pNFS/flexfiles: use the MDS for locked-folio writeback without a layout
Date: Fri, 20 Nov 2026 11:09:52 -0500
Message-ID: <81fea5dcd8feebcf1590effad8b96648b288bb11.1795122900.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795122899.git.bcodding@hammerspace.com>
References: <cover.1795122899.git.bcodding@hammerspace.com>
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

