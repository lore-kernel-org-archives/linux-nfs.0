Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2B903D6487
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474958; cv=none; b=OO7ro5pLg4HbdLLggSZc0Ut8hNuA0I8z1ye8GFQ/m+0EjMhTSuT6p2OLjQpBoSKvJdZYibH7twL91lfKVOygjsYXA428hqJibjkW6VE9wYhHkNSatFndjWBPuBfAJ1a1lTk2qL59nM0MNU9V8LBUrCR+vUk3gIZdIVNnEKVT8O4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474958; c=relaxed/simple;
	bh=pLifTJvC94l2fdLRZKifRbcuYeLS3/vEB4oyC1D18B4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=V02L+trkMEcPXaKp4lhI04Kn6h9zAEXrY7plYCWWTW1TKuzFvdvQmx/8ND/pVcBFYSN1LPvI8zpbPs+y9xaIfON2H+Uxb9jxyMefqjOu8+NN2SU9/zmi3P+dgF/oQqw5wuaKNNUb8tIx9jDr/3A1ZyG5DvewvtL1PNNI6G8dJaY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=VH/db+es; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VH/db+es"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a316adfso121161b6e.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474956; x=1790079756; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=eEkiMv8EBrli0jOoHDjr5RT9GFvolwHoMtwLmjEFwzA=;
        b=VH/db+esbveiSMHCXXVBMDE3vIDc6keri3keY0+APRGVkZIpxHQe28qASX7otW8WkA
         HN8PbctDWGetUg0yIHiHbV5xeXqP2xCZRKDGoygFMbhrAUXtmm0ta7GxgG7zw11QuKN6
         kcRcotRkKYNuuMEPAkKDrkrZFykRQeZyyKwEJHek9YgqPqWxRhg45iQOIhzW310OAzL6
         LRyfZ6rcd3hqI3Hroh8cd0WWyXItVjuLd1ny36d3oJg56EcMiEDZGQV7DjJK55IL9OEi
         WJlJgwnp4YhQSu0EMVR+FVE7SuNMDE8Dy5ub1hOw4F4oxl3WlEirnlPZG3OEZiadBtrj
         fmMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474956; x=1790079756;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=eEkiMv8EBrli0jOoHDjr5RT9GFvolwHoMtwLmjEFwzA=;
        b=O+g+LZ9w9g9046l9TNkXOBHSrpu7hdR2e8+pf6+31n5vLdWwwp4z+Ifwbql8sIZenh
         DXeuDsrq/7umDG1fW5Nt/fotpG2T5r71esyLFtxxUtsZjrgFR2tmDmwbAPe7KJKdzHe+
         lJr+ImJFg/LjhQvhlkUk+kB/AGtYRk1aYD3lRoqnAoMYmJEumNRCurS3j+8i+2g+tPEm
         bf0Kv0Ah6aWwJubXjIAw+PmxO91QLNqe0PJnTtO49xzLvd8rkRKRfZrgz0PQ307hMmIP
         YS2rsvWo1chYCJJsNoECEt+2Dffp7Yw3vqqLzvgM7Rr11zr/KsoJwZz4DdVwAP+5RX8L
         ABeA==
X-Gm-Message-State: AFuF++l8rfCY6DODwUhrPXzZqwRl8EY5nkmsx/xOr8XFu1wcJRMFkLrw
	xc8L4OI/iffS+sS6elUlvMYJN3TlUkDEG0phvyp1b2MWjDSK90af6Phdgjp6uJ8o7qU=
X-Gm-Gg: AYBFou3JPeFSDkUyE0FnrZqBoJ/l476aG+QKCArfpB/1HrG8rP/Jc0SXM+1ne/G4IWF
	bxWzY1x7qaHv9fDZVbiDDDPnqBHBy78TSiA4Jso/NtdKMGdrYOPPj1CtKOGD2kDt5rCPnZ6PVyQ
	QCmtOouAkUur/xqaf+GNOIkKk/HvuL8wamuVb0EvJmgWam0uH57tm7nC75g2pv7S4LXCCZjN0Q2
	5dk75UDoylrU22J/7Q0SzaFH9B3QLnYBb3IqbbHVBKSW+wYj9CuQsHhOvtA+O3CYiF7dLDjded6
	0qc/lEKbi8Cyz3iIiyFZ4OEfFkBwx00VNVJxHdEJsz2GbX/U8Joi32TQopitARNyGg/jA51RnGo
	zVbO1ws/yj2ocLiC9CkCJd3IGrx5nzqCEvghfV7JGo1mfwdXHTdnyerp317hgihLjySO+vvPSYr
	DUgoWVp4lrQ8wGT2xh/+qpKuUITwGysPbh8PdkMvf/sbAp4ErF+leRRh9J96qYBB3dHecLokd0m
	2+jPULgrIeMVODBWZnm+1zJlL+M3oqiwtY=
X-Received: by 2002:a05:6808:4fc7:b0:4c3:cd49:bbf7 with SMTP id 5614622812f47-4c9ab9b2c19mr550058b6e.42.1789474955866;
        Tue, 15 Sep 2026 05:22:35 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:35 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 06/24] NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
Date: Tue, 15 Sep 2026 08:22:08 -0400
Message-ID: <2c1821359cca92ce19003bb62e6a884dad3c4539.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ff_layout_pg_test() was copied from the files layout, which partitions
data servers relative to pattern_offset and bounds coalescing with a
segment-relative offset.  Flexfiles has no pattern_offset:
nfs4_ff_layout_calc_dss_id() partitions on the absolute file offset
(RFC 8435 Section 6).  So when a layout segment's offset is not
stripe-unit-aligned, the segment-relative coalescing window is shifted
off the absolute stripe grid and a coalesced I/O can straddle a stripe
boundary, sending the bytes past it to the wrong data server.

Bound coalescing on the absolute offset to match calc_dss_id().  Aligned
segments, including all whole-file layouts, are unchanged.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4078da49a93a..2d254e5e5b94 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -996,7 +996,6 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	unsigned int size;
 	u64 p_stripe, r_stripe;
 	u64 stripe_offset;
-	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
 	u64 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
@@ -1008,8 +1007,8 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 	/* see if req and prev are in the same stripe */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev) - segment_offset;
-		r_stripe = (u64)req_offset(req) - segment_offset;
+		p_stripe = (u64)req_offset(prev);
+		r_stripe = (u64)req_offset(req);
 		p_stripe = div64_u64(p_stripe, stripe_unit);
 		r_stripe = div64_u64(r_stripe, stripe_unit);
 
@@ -1018,7 +1017,7 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div64_u64_rem((u64)req_offset(req) - segment_offset,
+	div64_u64_rem((u64)req_offset(req),
 			stripe_unit,
 			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
-- 
2.53.0

