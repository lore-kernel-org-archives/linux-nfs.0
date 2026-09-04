Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4675C50C2BC
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540813; cv=none; b=QR8FimqXM+o3wcGdOgXL1O4w1LAMSa5hLVrkK9L4hNMEgFfQxp3WzR2hJKOLUiqNcpfRfAisR2S5PUhvzRwp7NWr1fyFTDmRTW/8inzkUQ4O6MIUn8TY4QvEcj85h8oLsuffQauCU8Q25dizXm5+gjaq+Da5Vzo6jpnFHSNDPew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540813; c=relaxed/simple;
	bh=L88VmcfUgkkCVFkq2PLJlyp3llYRox9v+Url5mmqeq0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Yd5/Nz/0yUftzdGHBmeQ/AZwiodTCdocuAyri8c8La9wkgWzQcWjvWpEHBOCj8B3BRavCemOd4lQGmp6/dIWH85h/l7V14cLkCiTlWJyVeKQ9VSwTk9Feg62jj6N7URESyZft+8OVADfonirPj8WMkL+iYpTFA8nSnRjo/5g8bo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=W3pcynKZ; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="W3pcynKZ"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-92e50a650a0so123156485a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540811; x=1789145611; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=W3pcynKZqI/nBM7XiBbivgPagngzqiMbeHdyyLUgGPRTbfJWYBCgBJCbiPQZc67QiP
         fKoFVvrqDOf+TsoCdl3CHOisNGq33aXy8wJOSyD3WqPzeoSdjO3evKa++vQTX1Hra3ws
         RcC4OnTnBeEXqDE6kEBt5K74VbJt0QeOzdMuW2kqQAyOq6y6rjxNSQetYqtaIrwxoqeA
         neB8UtS3Mp7tXnlaJNdV22vo6g1DNyqLC3QR2LLhgdezjwmHqiVY8Or2R5S9OUbAjN6t
         x7LzdXXLTFS+1KipdYZs4+xSE9SLKYS4ScyVftc4btTojeGW1qUsIGz0A3d8bO/L9JPb
         TA1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540811; x=1789145611;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=H+6NMjMvv2Y8LQWCLX0Gt7pnyOz0ndmOi2a16NUPDP7WpG+Hliv7ydn+x3xALGadsK
         mfcKQzWvbty8HYpipgYB+x7di/KchcaGaxVvLR2SWsfeFd+iHgXV6HeI3Ao45/GIsJdx
         xraxtPF1XO44mp09zYU9WP+0R9wGS9ni/6myGYpYhhSxNDfHzdXEXFlre50AxVaBtY2l
         mBgisSSNd9QB1lBeEesZ3r+w15zBcXDqJJDTOa82SSE+8ajL1plSVM98qcFqkTtjWNUy
         XCAPU6/bJt8GH0yvIByj6XW4x7IJz8z0KTwuE/q6rZUEmu6xMvyBtusDZWkMM1qDQ6DM
         7Cew==
X-Gm-Message-State: AFuF++n6nTQX/P1DjRm+F8TuVRfQIRpblYb/ucZuHEAWl4FcEMnSl7oK
	GDsEJMM9DxrL+OMg6kuM9ZbQSNQGfDt0Di+1lLRLCrKdRE9IULGunTLLoMx/3oMkjuc8RKoTZGM
	WKsv9
X-Gm-Gg: AYBFou3731HBUlVFdIkj4trlnrF49tvvDLCG728Owicinl6vdcPDxIzKOGRVbplTW1F
	7pF17Tbk9uKxHo4g0PCGjLI1uwo6sgfxKPNfICEOGHsgEqhp6ouVAWqbiztS/WCQz/lqwbBlKqH
	rRTExT1UpyksLGSYf8FElcYfgwIAnnkvFYw8Oa6so2f/HLiCfNoBXH0EO7ueCO49Av3Mu7HPOWH
	tcXBpq4Xg7X6Au52T0prP3E7G7mhwbmtBneQ4SxA7T7+2WaABzltO9vb2M9vnpDGgXAz/hLZfsg
	TT+cMYu9PUmR4zaafA5cMnM1DcEyZKZoANbEsFV1O06ZMPfM6XUlL3XVO6gnmrju8YAWq2EwhrE
	56pz0chZtPdPr0UzW77SKQAxogkF+DOwz6eGE1TZV1dFoa4NuFAWky/RzBCHr5S6j1dqmSiW0vK
	ppIx1UpDDGkNcPezJhq8mkCSRd0z13Zl6D0z6ZX4XxWGNPTOiQeIugghkNX252iKCz5T6MWNxqv
	Z++zji23TSfriRT/BIIu+mP
X-Received: by 2002:a05:620a:4493:b0:939:31b5:4e08 with SMTP id af79cd13be357-939800fc582mr701535285a.0.1788540810915;
        Fri, 04 Sep 2026 09:53:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 07/24] NFSv4/filelayout: Anchor page coalescing on pattern_offset
Date: Fri,  4 Sep 2026 12:53:06 -0400
Message-ID: <aa1154617470b62bb0f774de0fe0e98749298852.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

filelayout_pg_test() bounds page coalescing to a single stripe unit
using an offset relative to pls_range.offset, but the data server is
selected by nfs4_fl_calc_j_index() using an offset relative to
pattern_offset.  When a segment's pattern_offset and range offset are
not congruent modulo the stripe unit, the coalescing window is shifted
off the DS-selection grid, so a coalesced I/O can straddle a stripe
boundary and send the bytes past it to the wrong data server.

Anchor coalescing on pattern_offset to match nfs4_fl_calc_j_index().
Stripe-congruent segments, including the common whole-file pattern_offset
0 case, are unchanged.

Fixes: c6194271f94b ("pnfs: filelayout: support non page aligned layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/filelayout/filelayout.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 72e20b56fbc7..0d53277f972e 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -796,7 +796,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	unsigned int size;
 	u64 p_stripe, r_stripe;
 	u32 stripe_offset;
-	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
+	u64 pattern_offset = FILELAYOUT_LSEG(pgio->pg_lseg)->pattern_offset;
 	u32 stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
@@ -808,8 +808,8 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 	/* see if req and prev are in the same stripe */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev) - segment_offset;
-		r_stripe = (u64)req_offset(req) - segment_offset;
+		p_stripe = (u64)req_offset(prev) - pattern_offset;
+		r_stripe = (u64)req_offset(req) - pattern_offset;
 		do_div(p_stripe, stripe_unit);
 		do_div(r_stripe, stripe_unit);
 
@@ -818,7 +818,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div_u64_rem((u64)req_offset(req) - segment_offset,
+	div_u64_rem((u64)req_offset(req) - pattern_offset,
 			stripe_unit,
 			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
-- 
2.53.0

