Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85E3B4FC8D5
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540813; cv=none; b=t1WdKDhLHAWnobG63Ni/dkWhljrxYJ4sH8AA69OeHGNmyMEAvsOm/M/7A+hs2jSs45g0hN+5d06PjvIr2xiF5QmcqQjuAxm0KXBu6AWwyxpjsKz1bWBuv6l1echiAxfps6MqlRjIrzS1VgevVOQ5P93ZZlIG93+EGBOlUaBuwl4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540813; c=relaxed/simple;
	bh=pLifTJvC94l2fdLRZKifRbcuYeLS3/vEB4oyC1D18B4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cs3hPjRoCfNP2VrnA8EhKtijTtpDTO0s6uPNHU3RnQLG71BJoq/AlZPUNyE33AykJhQ1MxOiktCkPze18Ffb3GzYoxYcwccjIoG0wVtEyMfgTwjidkB/Zrp32XpGcyWcMte1u3mpfYSL22cHqJjHHpAQ8LezFbVA48wrs+0H6kk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=mTUdSInJ; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="mTUdSInJ"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-9309d4ea213so121784585a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540810; x=1789145610; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=eEkiMv8EBrli0jOoHDjr5RT9GFvolwHoMtwLmjEFwzA=;
        b=mTUdSInJbtN4zOmyEauhhNGxBYo3ao2a6N+u6R+2QTk4XzsNE14dU53aeOSb2+MM9Y
         co2FnHTiF26lIZ8pvl+SdFkrjdPx9fydoNeW8svdXyd4OpIlMYdy+j1fJB38yXzB4G2m
         NA2zCjMc9EhQx2qXCI1PSzAqhvOhsx6hNG0KWIW6ME1UyQW5zlzxdv9+hO/p58be9R4P
         Y2bwzYi7dCdlpdLKd+2eYSMIhapMDaePGta7X5jcQ6b+4BAbXcBQdkoqJ4Sh3lzUN6dR
         DoMTPOTzQGtDqxPWOZkPLO0Qb8HYRGefFLTisxS+JNYkGV5w0JBC6ufCEzHPd+9s6LDQ
         sVIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540810; x=1789145610;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=eEkiMv8EBrli0jOoHDjr5RT9GFvolwHoMtwLmjEFwzA=;
        b=tGgTzFJUR4t/rsQnb7Z1xhh2ggLCr53kYiAV4Q74eLX8gxZNEg+D9BR5glI1iEnWGL
         B/1g+S6wri70PkK2HeaZiX0W4QhNbr2zicNhrOoVPkiiVR6kVYKac1j2PhBX6s2MDHP/
         CLRskrMG2lX+TPvYhmbO+ZbUKDCA7+7j+c2M0Nfo8sQIeVZaDc+OonGAYZbjcnz1Xlqo
         RoY6SUj+zBeZmcGhc3YcV9mtdSUHjQFq2vCzGDDTw3FJVeQ6W3PeF33zcPAv5RZ6XF8l
         4aLRGg6fcAHV4ychJKrUpCu7wjsKxEd6viHZ4HSOBuqTVpVzjAneeQpKGaTrUoDCZ1ch
         garw==
X-Gm-Message-State: AFuF++m4dCYbV+M/5YAOIetTeRcc9ChkgQFpruirwLKKnOPmOMkIxko3
	D/ruSRQuYFBZDkjTirD+aT5Mf9d/nsaIdNQbhsyQ1AT0a/rcRV+Wr5qgHxeKBdnlkFA=
X-Gm-Gg: AYBFou0FOxvf/E4E+Bfa2rH9El3GgtoKPbhlfAnBqUgXdXnBzWrLloJr/ybXe4qTyXO
	6MNytROZY5SsiH7JBzj3yM+5r1N9R3wnGOb94sKalp5KLGxJcEdxEfaUeeIS36Wp4d2w8fyN8In
	Mg3hyjH568Bp0z287TomIi96nQcZOl0t9G/78jW4m3VKL3DkT5EXO6uuSQOVTcN/bZ8OWyjgmTD
	G3iD44YCAzquBOjFNDxh18/oUCrpK9fqYRbBPGbDIPwAgn2NjBYcTBMgm4gBaS9JWNm8JSLce+x
	OaPeWaBxR7Ojp4RYgRDlPz/JTkCdz2FUOyVEt1g+Ya7iyYtROb5Udt9sTGcavt2EtqtlUorq90f
	i45N6zbzNqMPs7skR9ycqFQhlnBH8H77dfFwwION2CHGiJQKcWTGzPE9UXFaDYOhDhwTBFi8vcX
	FFtQK3KzEEbduwRdVnXMSVgU2OcdMEZ6/3s3i9HjT6y4PZAJKuVgPUjR/STGqVPuOgFMsrNAD6v
	iHedv1LognlWxfFYZPOLhh7
X-Received: by 2002:a05:620a:40c5:b0:939:3696:6509 with SMTP id af79cd13be357-939803f3212mr723797485a.0.1788540810099;
        Fri, 04 Sep 2026 09:53:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 06/24] NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
Date: Fri,  4 Sep 2026 12:53:05 -0400
Message-ID: <2c1821359cca92ce19003bb62e6a884dad3c4539.1788530385.git.bcodding@hammerspace.com>
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

