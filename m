Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191005;
	b=n6PFqabd3xwzYzQcPPYMNTQyW+S1I0UwsP5+SDxkEDFnu+kpQeO3kBaVGwB6j6Z0p82q
	 /P+WtsL9WZg1AqdcdNmDE5x/DrN2kGPPcyrydlIY8dsUWYxoberExRPxKAMUSs4OQs1Qm
	 zxCE5nWxoAd/AV1arBKEujbTRvT2DbwldXrqmBUGzr26bHz4448GXF1bGygg7tGy+Bpqu
	 a8ssnl4nWWaa01KjY7U7FNfcAURvtt+B5JR0PkWxpR1d4B5jn84LpdmDdoIHOxQ5xtf6t
	 HO0TZsZGR8xBdWnrUnqGKCLER7XMgnP9hJnHVAv+1IavoEHN3eZLftUcSgZIPTbVfWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191005;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=kx94Bv0gC76LfxPNUmg3/jLeR+aqLAIPw/rqNnMCbaY=;
	b=pYqdvh/Xt2zjuBry4o3jFKHKMNBA3C41XnBU6aUvbDtrWG6mCBe5P0p1M7SIpTzE3iAg
	 Sy2vb7P8hhLrKyxEn3/j2+AMZi9YgiY5SNUAi3bLKk8UVTtLnFvr+vhvoRMoqVGoc6eQ8
	 +Qyvc61DnbTe4PkT2BHBoUeN6wVLgGO0aApl7636NnT65iVY8KBISF9JNrSyLsVprEIHt
	 TLa2W7Q2pbTbYh2NI9jh6L84Swl1aZkOReSaKTVjsejAQwVqWWKTaRHkk3bqk3PlZ0369
	 0jIjHWxcouKi8b7RTOyn16mHni2ocF4KB4HAy9RQp4k4HBg4xgCuPauLk9WH1hh/x+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="hQMHFm/s";
	arc=none smtp.remote-ip=209.85.161.46
Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A490F606A332
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:10:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A490F606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=hQMHFm/s
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-702fd86d674so743378eaf.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:10:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191003; x=1795795803; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kx94Bv0gC76LfxPNUmg3/jLeR+aqLAIPw/rqNnMCbaY=;
        b=hQMHFm/sm5TC0+z9WFBv+L6uz6LUd6q9XgNlq6KYTLBplLpKTDJESUof4QUHAo12Te
         qbPVufOjTZ3AHlPgftKHVFqOHSJyXKg4g+Epfo4aFQ+NA4bzglvvfm0VSrHMgGnOGW9S
         hRG4Eszw34kzOvnNkZGBkAfdhZ1JL0WgGX9z3rlxAlJBMNYkJ/4Ti6h9BSR0LcG8w0OV
         OyA2HfqL2/zaKhbN3Kr8oLAYOVSt1ukeWQmhj+z3qfGZ1pWX2umOOT6kL8bvebCJU0At
         cNvkKHUnyJ83+Acohzzg8fqlaz6Bt0PG+99gIjjwwCo9Fktw4lO2BLW61Q1W5r3R2miD
         aRCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191003; x=1795795803;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kx94Bv0gC76LfxPNUmg3/jLeR+aqLAIPw/rqNnMCbaY=;
        b=tRarfMn/Md6SF1Lrc4BmDDtxLnuI2URnluhV+Mnzfl6wiCAmCoe1cf/+dCGkxCTzd0
         ei2BHH/D0BWbk56XkhhGGi+bsCr8PVEFyBc0iP7T2qKT88Ed0nyLJ9ZpThrMnle+9RHT
         DmbSB4aY1DAJmJ09gug22x2oLki5ug1iHga+dZUKMF3XyUyxZBJ6A9hiHz9Iji4vkoSr
         msAu7OYSFaXznWQVhWL9DgfYx5k5AA1UlnsjseEjVAlSgZ3UuzW3ywhZPDiVMEKn/J8R
         UPm1TtiflRNPOMwIl2bFnbLNLjxLzloCqMzwbXM55tSUCZl/IRNx51fpG13Z1oeCRjXU
         cGPQ==
X-Gm-Message-State: APuU4Z8JzrU31L6tOLCa6Jd9MJ7cl1SDh1uHi+CX5tJDQYrL5WFtUixg
	69JCL8poeXrRG2Oek7ZiyFQtr+cnqw3X8jhBzvSY/uh4ioc/PGo7KEURl3jWJ9LjJ7yN3pmQ9+T
	3yHDY
X-Gm-Gg: AYBFou2oWHFKIkr7wGJw8TjzOddQO6hyy2Q7nvCw1XHfq5GlrSRWj3e4tyIMdn86CBu
	ybfCbi1TQSeEfOt1CFETcU8LmpZxC9Xm5LO9oJ/NvnW60JqKguadlrs23BUY+AOkzihPTd5jZ8z
	Lc8SebtBmMCEmFtkdZFROYdgRHgCs7V5KNFYt2zwfcUsAbDN/SmnNAfNpV3N3s1ZkVuzcXznCGl
	Qm4D/oD34ndTOWLc3rxQ/CG9U4t4HB3jSt1n8CSNDHpiv5C/Aw+cVa/bacHDoltgA0nF7TX1RTY
	IHNSZ24qHjqmSag0BOYC7FSh+FLix30dmhSAO1NICH3uasGmqgxWV5/Ql/3xJH+gIF0O4gIGtc7
	C3DLA+yb0mOJKZZYYOOn7NZT+EEzVb95eiGBBInOGRwHFT9jUyk0H0BDS2PQ26RGVDlPiNLeLbp
	+agMdiRnWz2yBYMr0FfmuILbdo7z9LAr+27+DWsV9+Gpcv1pKgCrWkcVVoRtTJxLQbq9dynEzt/
	/IJJT9JaJNiHffCM1+EUudKCgbtPDbhnceCkI48DZBmgPx6lD+m/SwYK4n7LgD73C19yngoiodB
	5xPgQBTJ4g0+4oBpVwTwxAV2uRnH3sMkxSJBpr/HH01skuxv5CXCC223qa3q9p/N86HeO1p4mgn
	BWKNwuUmpThAfHUjwvC/lTXtzrAeQzpQ=
X-Received: by 2002:a05:6820:2207:b0:71a:f272:60e0 with SMTP id 006d021491bc7-71b47fed982mr109267eaf.66.1795191003284;
        Fri, 20 Nov 2026 08:10:03 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.10.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:10:03 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/5] pNFS/flexfiles: remove the layout-header NO_IO_THRU_MDS bit
Date: Fri, 20 Nov 2026 11:09:55 -0500
Message-ID: <5477af43e4c72fa1c9f52abaefd07bfa70e30ad3.1795122900.git.bcodding@hammerspace.com>
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

Nothing tests NFS4_FF_HDR_NO_IO_THRU_MDS since writes moved to the
inode's NFS_INO_NO_IO_THRU_MDS bit.  Remove it, its helper, and
nfs4_flexfile_layout::flags, which held only that bit.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  8 ++------
 fs/nfs/flexfilelayout/flexfilelayout.h | 16 ----------------
 fs/nfs/internal.h                      |  9 ++++-----
 3 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ef8715de6474..4d3ad04775d6 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -641,12 +641,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	if (!p)
 		goto out_sort_mirrors;
 	fls->flags = be32_to_cpup(p);
-	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS) {
-		set_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
-			&FF_LAYOUT_FROM_HDR(lh)->flags);
-		/* Outlives this layout hdr; see NFS_INO_NO_IO_THRU_MDS */
+	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS)
 		nfs_set_no_io_thru_mds(lh->plh_inode);
-	}
 
 	p = xdr_inline_decode(&stream, 4);
 	if (!p)
@@ -1151,7 +1147,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	 * MDS there is no fallback to take, so wait for a layout on the
 	 * same terms as the -EAGAIN above.  The layout hdr that carried
 	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
-	 * this asks the inode and not the hdr.
+	 * the flag is kept on the inode.
 	 */
 	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 5d5587fded76..bb60537b2b93 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -113,16 +113,12 @@ struct nfs4_ff_layout_segment {
 	struct nfs4_ff_layout_mirror	*mirror_array[] __counted_by(mirror_array_cnt);
 };
 
-/* nfs4_flexfile_layout::flags bit indices */
-#define NFS4_FF_HDR_NO_IO_THRU_MDS  0   /* any lseg has had FF_FLAGS_NO_IO_THRU_MDS */
-
 struct nfs4_flexfile_layout {
 	struct pnfs_layout_hdr generic_hdr;
 	struct pnfs_ds_commit_info commit_info;
 	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
 	ktime_t			last_report_time; /* Layoutstat report times */
-	unsigned long		flags;
 };
 
 /*
@@ -186,18 +182,6 @@ ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
 	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_IO_THRU_MDS;
 }
 
-/*
- * Sticky hdr-level mirror of FF_FLAGS_NO_IO_THRU_MDS so callers that have
- * no current lseg (e.g. between LAYOUTRETURN and the next LAYOUTGET) can
- * still honor the no-MDS-fallback policy.
- */
-static inline bool
-ff_layout_hdr_no_fallback_to_mds(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
-			&FF_LAYOUT_FROM_HDR(lo)->flags);
-}
-
 static inline bool
 ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 831f0e80206a..9819c4db3d85 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -556,11 +556,10 @@ static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
  * FF_FLAGS_NO_IO_THRU_MDS in ff_layout_alloc_lseg()).  The RFC 5661
  * mdsthreshold hint must not be acted on for such a file, since the only
  * thing pnfs_within_mdsthreshold() can ask for is the one thing the
- * layout forbids.  Servers are assumed to be consistent in their
- * no-fallback policy per file, the same assumption
- * ff_layout_hdr_no_fallback_to_mds() already makes; if one were not, the
- * only effect is that its mdsthreshold hint - a SHOULD - stops being
- * honored for an inode that is already in core.
+ * layout forbids.  Flexfiles also retries reads and writes that have no
+ * layout segment instead of sending them through the MDS, except
+ * writeback of a single locked folio (pg_allow_mds).  Servers are
+ * assumed to be consistent in their no-fallback policy per file.
  */
 #define NFS_INO_NO_IO_THRU_MDS	(30)
 
-- 
2.53.0

