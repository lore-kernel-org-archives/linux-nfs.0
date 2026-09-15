Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE83B3B42E1
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474954; cv=none; b=AUfmg3P2DUU2/qlAHRmfiQCuvqLgQhA9hx+NrYu5pb00cqA5HrLuIDwj/eVwl7J4tHltmc2Q141wrAaGpSLn/cpjZ6y6qOKrY1FhLQFc6IUPvPzB+HPyQua00yJ2afniXGc9AgyqVC7tEk7tkikLPFDEk0PfvmwJXw9KierjLwM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474954; c=relaxed/simple;
	bh=pNGgs541mK4q4GyN4bc7XAJd5dCZ2Ax6HAdwx6li7Qs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IxFYrSMhdVwlWYJ92xkblv8gWKcxNrOVug1vj15N6+GMhux4o+qu5Nyglj2dQYJIyWt1Wy1O4CiLJyJur2dpL8SNiAT2qDImLtwahv2Df/ukSZt9x163593M9VmMRJM7N5tpz9z/cXKdi+JMDnBDPnuEOaS0QiyDhaJgf9fuvo8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=c5pLbid3; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="c5pLbid3"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c6d6660191so1560117b6e.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474951; x=1790079751; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jxHtlsw+kQepZhFpBSMgUw0/pZ1fEQpYZ38PLW/x1wk=;
        b=c5pLbid34v2yT54LJZnLGxtdFdUVCTSGVY0sd+Bb3glx2dBa7v6L0iU5KMkm40sLmh
         1ha2g8iF84IJbDyPr+LIvZAeasyp9RhUjV4nAmLENM8ed8xrOEZ0QhBQmH1C7gSVcU5t
         pSeMmB2mCDkHQxhzI47yZrWLwwaGw4OlWlg56OOyHrbgxFQP+ypV1PI9jOJjP+vZnI2j
         Wlxeu75dMlpEUs/Lcy49zEQlvlHqR43Zwnmc0ux4kNj47k21o/RylJHc5Mi/rJi3plvb
         2wSrymtBa2O9znL+q9GcARqX7vhYHbThgGFmJbL0HkEFRvc8JMy52I9mqJcaz1Pg7PSd
         TV8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474951; x=1790079751;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jxHtlsw+kQepZhFpBSMgUw0/pZ1fEQpYZ38PLW/x1wk=;
        b=FPqLgiIZN1VRaRGxerg6M5t3cMke1kbGj9hS8vCs124DvfOPKp5ydKrJ6r3R8i3lJm
         Cymw6sqiUbMzYID5J471YY32WbaBHa+Qc5ehKsUvCk+WqX9EooCGfeXkXJAccmmFStLW
         jZzRguGrYrsehLPNLs9OEOdtoYk3uNliPDDhKRz6osr6Rch/NtpGCFra2o63UXV+8k+s
         pc9QJ7QYxhaO1CEMUFV1jxY+erRm8W/+uGLMzLbfpTeQbaz0uC/OA2kyGBnPHa0yrfV2
         XPwuc0qbECkg60tOpx5OtHk+ocaxyeScZ7e0uYtUvEfKliuu2KDvWuQX5VVJQVBjlWfU
         uoUQ==
X-Gm-Message-State: AFuF++lqQLZ52oLEVBSqhneZMqqOoy2QU9cLunJSuUI6F+CSdR78IqVt
	KbW36RYn9dv3hYuLyhtFhZBFLDsZJgd5l5qKne++Fg1cmLryjD+TsEn5xIRAu9iZJys=
X-Gm-Gg: AYBFou3NIl3hbafbVTFqYJf/WJyvZG52j2OUNDkj3eqrpvjRfCXw+X2aJvj0JJvBRa2
	cYkEYyzGEDZ7PTkGEFQw3YtDKj6cMohNFVan3ijwkulRF33YGszyqRDpZhJBroHe5aKZX1ZDOZU
	LLqaizblGla0Bd2IqlLvEuZOpsHWvAF9Te1PKqSHYE6LNfQjvCiI9djkys9CDh/XWkBBLschip4
	yPY6XF+X7RI1nM3/k4GYp7DQFevq3Lvsi2U7jzyog8GEX+BIe2A3RshL0KYgsxOv/L+KwMmpSWg
	t3KvCZar4yuUxLX8ZrzJ4mLMvBBqoRMQxAn7DFcemhGf/F6wyBJBlEVq0yfMk3vnEvYbCgpOplC
	YaASE6XKQtCIqlhPf6+gSbak2JjBTzzkWGQHlymgZCSR2S5s1LDY4h325CvFYbWOYpHEIjVjsRe
	hSaWD7+JMx/DBWb3Q3IBbAKgLdTaJVN6AqqgbiFzWCmjvfSgHhePBQ8lb/xShFC0uL58tTiUsoU
	liifDOwo8bEBBXcvGS/pymp2WEJ7el35Uw=
X-Received: by 2002:a05:6808:150c:b0:4b3:8323:8cd8 with SMTP id 5614622812f47-4c7b2df8993mr4803313b6e.5.1789474951380;
        Tue, 15 Sep 2026 05:22:31 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:31 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 02/24] NFSv4/flexfiles: Use the full 64-bit stripe_unit
Date: Tue, 15 Sep 2026 08:22:04 -0400
Message-ID: <1a3e67cb84b077078b4f57425c1475744cc820d2.1789474702.git.bcodding@hammerspace.com>
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

ff_layout_alloc_lseg() decodes stripe_unit as the 64-bit value the
protocol defines and struct nfs4_ff_layout_segment stores it as one, but
both consumers narrow it back to 32 bits: nfs4_ff_layout_calc_dss_id()
divides with do_div(), which casts the divisor, and ff_layout_pg_test()
copies it into a u32 first.  A stripe_unit that does not fit is silently
truncated, so the client stripes on a unit the server did not specify --
or divides by zero, if the low 32 bits happen to be clear.

Divide by the full value, with div64_u64() and div64_u64_rem().

Fixes: 20b1d75fb840 ("NFSv4/flexfiles: Add support for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 12 ++++++------
 fs/nfs/flexfilelayout/flexfilelayout.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..54ee8f6051ee 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -995,9 +995,9 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 {
 	unsigned int size;
 	u64 p_stripe, r_stripe;
-	u32 stripe_offset;
+	u64 stripe_offset;
 	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
-	u32 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
+	u64 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
 	size = pnfs_generic_pg_test(pgio, prev, req);
@@ -1010,21 +1010,21 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	if (prev) {
 		p_stripe = (u64)req_offset(prev) - segment_offset;
 		r_stripe = (u64)req_offset(req) - segment_offset;
-		do_div(p_stripe, stripe_unit);
-		do_div(r_stripe, stripe_unit);
+		p_stripe = div64_u64(p_stripe, stripe_unit);
+		r_stripe = div64_u64(r_stripe, stripe_unit);
 
 		if (p_stripe != r_stripe)
 			return 0;
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div_u64_rem((u64)req_offset(req) - segment_offset,
+	div64_u64_rem((u64)req_offset(req) - segment_offset,
 			stripe_unit,
 			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
 	if (stripe_offset >= stripe_unit)
 		return 0;
-	return min(stripe_unit - (unsigned int)stripe_offset, size);
+	return min_t(u64, stripe_unit - stripe_offset, size);
 }
 
 static void
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a5bd00f69e82..ec69cd1c3ae9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -220,7 +220,7 @@ nfs4_ff_layout_calc_dss_id(const u64 stripe_unit, const u32 dss_count, const lof
 	if (dss_count == 1 || stripe_unit == 0)
 		return 0;
 
-	do_div(tmp, stripe_unit);
+	tmp = div64_u64(tmp, stripe_unit);
 
 	return do_div(tmp, dss_count);
 }
-- 
2.53.0

