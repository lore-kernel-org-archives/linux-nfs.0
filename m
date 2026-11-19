Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120056;
	b=4n59X0XVc13jZMaelStUAwRfXTwi+Z4sQYxIsR/EDmuvRIBmukK2wirKZr6UJBCzlDra
	 migEP3lnsjlcENYOqkrLfGCl1EMK1EAGVwowXksZ3ub5PSbnFpsW2xatjUZJlLJa9AjF7
	 HmdYRqAk8snrbmV4krhjk8FAln8JFMqfWYyYJAmsVkdJTQ8StVVgZ56DowgVKZfUDp6od
	 R4wo6h3C8MiYezummVF7fsHVWRNdzxLiOkjh54cFmeiWWOpsOGuWfjZB5hsITij0fAZtZ
	 /aBUd9SWIYBA8uvx4ncsQuqG4QettLqiJBnZwmJqh8V7wu04zfHUD5NPv5hhfqJiURA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120056;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=+2dUbjtxLMIPRShKeAvZuOmSF+J5FdUtllj4e+uQStU=;
	b=He+rM8F8FPWAlrVhfrdiBq5jSqS2ALPP0hJW/AIQ/ruCShI54M0Zke/EzTg+8y/xZ9Ye
	 emvaS9xkBreNopl9Nh7OWQbWWmyBvhmQTqa5OcntnJlzpJU7TxcXXO70GVw9qX3CxVDFg
	 lrKB5Z1Hs2W2Z04qiVuIUzQkkqzvvNC3wkfVvF3ynrWOr9SzJp2cbVJKGm1nWn3VPawur
	 KQ4i3hLV/b4GnioXb4wUZXlefhgRe4NbSf5RbQtSLNgI8rv+rmuRTGrznkDkD4TRYlB5M
	 oSIPMB+47FBWWhtiFhkyrMMDztQjgjdyFCPlXSYktJNmhIgRpP/Ll9ZzOr6bp9oDzHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=IxhGdSz1;
	arc=none smtp.remote-ip=209.85.161.42
Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7D0A606A337
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C7D0A606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=IxhGdSz1
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-6aa9606ddadso108005eaf.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120054; x=1795724854; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+2dUbjtxLMIPRShKeAvZuOmSF+J5FdUtllj4e+uQStU=;
        b=IxhGdSz1cTKf0YcfjmTkzol8m+R6VArgiAEH0E/l1EnXGV/bKdcNjs26OI5eVE7Gm9
         UMGp3KcrH3wPMhNsoWJfwjiJo9tDx8Qn+SYCfX7osRWh0DOk0Mv45YSiWMLBxLRFcLoi
         gOeMwBrr2sp5rxYc3Ez04f5XxoqYIf66kG+6crUT4fAfYETbPLPNVItSlpahGppRhnLW
         GDRagtwoTFBfu3le9AdGFBmfnj87UTpa9PVkzLoXeBP01xaqhlRdxIcPqQKhKuYgvHA1
         lPIx+jCwmvbQSgDNTJKp56G09J8kpmZSbN15xOEErB7ew7NPXp4SuBQT7Z9ZdALHIlDr
         Q6aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120054; x=1795724854;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+2dUbjtxLMIPRShKeAvZuOmSF+J5FdUtllj4e+uQStU=;
        b=x5t67DPfxtqjirTPV753nx7gc6PaEgulgmIR4CZ/CHYJFxdsIypAFuMuXFHr/mANXd
         VlDvOKGgQCano07v+i5XgtVPLrFzrI7Oiq//F0EQj+TAcs711uFT8r/CDYePcrXTm1cw
         WSt6GdgadnNfYAWY2LVTPRLXsJARZndKZJuFGpCqeJ6iNBdUjiTxgyByWV4bDbmToPaq
         DQ44qqmIkmon/yEK6s3VSdui4yRUuUResk9+jx84GFfPhuqprbkpGuHdThWD08xf3Zr2
         0WY4oUK7QX02Ei+ZZVhX9sIoUzvUoxkAJU4De5lSX6293Knf5CSpy8FnM6wbPyqzXaiV
         P1Ig==
X-Gm-Message-State: APuU4Z+7NEdnsPwoaImNILOdrtJ9LN6yq9AG8VVZXUa3pfxErzZ41ItM
	bH295tA4zgGhEwKBH9vKe3TBQ0M4z5Hdyx9MOzDKAkW/Ilq9hWnz8ceYJVtbSJf42eGMfPlOt/F
	15BZl
X-Gm-Gg: AYBFou2pcWbq58ijqEG7CEwcAE/2vybdcShykYnm6/ov2hOUcWGrCXlvhQ2+rzyzHNy
	SJbiQnYarpL5nvSHZD0SZNhggk7PNCHI7geCl7gpzgxfPAqNGAhXGForl61G2m5/JL18Eb+Bf4S
	M1XToL5eLnNUt30pJ9JD1yGxFXlOCnWvTNvW/PbrBnmrroA2fuUidGczo9sVA4OXoKAKp9f+2AU
	l0h1DLVjxEkKL6IgMhzZcoIKFrminrED1tdUIVxzhD3l+2Xg0psZZXeU9bK44FJWpPNZIq7dSIP
	5dgKXtQ1CFEOJKeNUToDRj4R1rVstqfCDHeUIIGfGH7HZkF5w6ew3vAH6cazh26ronqgTyQbANc
	vjf9lVBmJ0TU1gefYyxQt+jHi8C6CkMu6umy9oHOB2iX+8tT/8lCo3bnC64GPn9G9OskxXO+foq
	RRV5Z4WCJNXGDJeMTYQnS6eYOqbgL6JFJdWKeaO4yjqGekQpqBZACrPpUdKdhhLfPf2G31cd1Ti
	Guw0DrHQm+ZOZXRx4yVOPbb9tYqZHZpzYUeORorl0tvG7q23smOB3kqtFO8A+kQRI007SrhUiXG
	l8ueucILXFMDEMohu/CFHgJ4UI/uXNk+lqHKEClD5ufclGLuvD6XFz3Rs3Fk+6e59+QmkOe+XJJ
	kcsVhxpNxqtjm4tHZd65pGw==
X-Received: by 2002:a05:6820:c0cf:20b0:71a:f794:49ab with SMTP id 006d021491bc7-71b39538a2bmr640786eaf.61.1795120054361;
        Thu, 19 Nov 2026 12:27:34 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:34 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] pNFS/flexfiles: remove the layout-header NO_IO_THRU_MDS bit
Date: Thu, 19 Nov 2026 15:27:27 -0500
Message-ID: <2c91bfa52049fcdce8e66284d01c656579129fc8.1795117974.git.bcodding@hammerspace.com>
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
index e29e5d8b5299..784070cd5a84 100644
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

