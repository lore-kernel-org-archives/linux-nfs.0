Received: from mail-qk1-f179.google.com (mail-qk1-f179.google.com [209.85.222.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6602550C29E
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540810; cv=none; b=U8OwaoQlFKv6vGaRnKkwmTUVnx4Xu72U/SficjOsePv0HbfGjiRVOKZykTg2hLS0u8AJqmc68OmEmuhjEP9W+ePXh6EwuGZpD/Tf9ektuaDlpH9KPhKLFJKo7rJXjgnieNXS/Xv8/QGKVEg7XB/E28a9chMqp7Ad+MtY6fQnSK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540810; c=relaxed/simple;
	bh=pNGgs541mK4q4GyN4bc7XAJd5dCZ2Ax6HAdwx6li7Qs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nTcFyjK0s4aVrSKx1Gn8boB3A8u//1UIV/YgtbjZTekmmlAveM7lHfU/ey8rcinkcSIo57JoaLx6fbrCsVMcGdnoflHX7Af+DCekyhsDJsDX+hEJRngvdY4+NOuiG6V/uaA82Ip85OZ2qrU48t7YyF6XLvVR/ZEY85D7UQwv2jg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=oVw6tXyZ; arc=none smtp.client-ip=209.85.222.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="oVw6tXyZ"
Received: by mail-qk1-f179.google.com with SMTP id af79cd13be357-9391e3b21fbso113416785a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540807; x=1789145607; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jxHtlsw+kQepZhFpBSMgUw0/pZ1fEQpYZ38PLW/x1wk=;
        b=oVw6tXyZp5srbcQfnxHKxlYtfGY0taAz3ExJ588V5PwEBuubnakey4KIAZXqokIkpC
         Nayma3RrBA9LBulW6BlkpcXVeWfhd9NH/U5ckvu0QGAXzFziGp9w5pQV2swUqUdqXpK0
         wAFDIA/edL54Ta/TNyLziVswZMaZQvFETA31yuFyuBAACq3OIH/3Ol32fgpkKeht8r0Q
         bMTFXx3yR90/FYaDtFGTJmC6/Yh+OVxEOMcOuROu25coLj4P0U/iLnBl1gjLmdXvXQXe
         Al0hV7BcLQbiqe5bzxjQLhdAvDyth7qN7vXnYz/Aol+09/FleE8krHiEmClRfH3PqBPy
         rcpQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540807; x=1789145607;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jxHtlsw+kQepZhFpBSMgUw0/pZ1fEQpYZ38PLW/x1wk=;
        b=iCfX50ER7paju0b4gQzQX6uWZT5JNuqDWc+kFOg4mLfc5mUTF1CzPpd7rO4yvzxVTY
         5F8gngT2wRDsvS3ekk5OEYfkK5r6LITb1Ysk7F+XrCYOSTQZiUn8zNlfjdgLtAp1QU/Z
         vU5pTrhHO0Zb7eoRsks+zxJYT2lry5u9VUGQewpvwKi2iR4O8wFJy4BxeGTJDQjmJIxQ
         ePCR+hwYFSnc5DSqxwOa2gFmmdQTvk+Doct836lcUH0Tu9A7WULcrkC19lpIqP7jlioo
         syip7ZaG3mf9m84H46CZOCXyvOw/SLqMi8ssMYQqp0dY1nuHqPM0ka36jKxPu6fGbvOF
         IPyQ==
X-Gm-Message-State: AFuF++lZlnv8HluuKxv3iEduAugr4A4DhgWJ3NYGPrdWST57Z8X9cL4g
	O7nd5m18G3TD9pTZIIwDvM8n2UYFLPVLcIFK4+eCcRkOflhDSqb4PJlceabsS/WhA1Q=
X-Gm-Gg: AYBFou3wzusAfkOhaRX9I6OfOg5px+q7TJiNMVvFbYHAybhKTJk52jiSJl+yJTW8cAd
	I7iQqUV1jcXIyl5eh86tIVjk98m3avkzIe/pKMeW5MN00KPXYnhoZG65MXgF79+WIisiu3mPfyl
	qwrfP+kRtXUnIq2OtLmbOMaBk1n4/VuueJGOb4dkYMZry0n4AKHRsjtYOCZ0S4Bvof15AByOe1a
	YQvhiU8f5fUNYnpBMUkdSrjzwu/ZE/zhZZX2FAF0ht/iLOzgBQZCSteClzOg3i8DazdcHwW7KTx
	1o+bTmRW/eV3VvumJXmX4pHORH6Mxm/5CpKJn+1shjpUQO8pmR51ma6O2rumjm7VH55pAtk1iT0
	2k4ur20ur+j2ym+gnOhhZs4Nk+cm3suMp40JXs4tRN1ovxKfh+AFbYiRtR+/QussBHI+fcU3qwN
	2U9AA66FNT8iR4q8iBi+HOC8hvZHuu/AfMikvvDdmZ/OZfd5uARoxGMKAFSSxYH9xvH0Fj/yD1+
	HNQDKBw8tEoK1wfb2H0aQKS
X-Received: by 2002:a05:620a:254a:b0:939:7f2f:b0f7 with SMTP id af79cd13be357-93980434d21mr740197885a.33.1788540807150;
        Fri, 04 Sep 2026 09:53:27 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:26 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 02/24] NFSv4/flexfiles: Use the full 64-bit stripe_unit
Date: Fri,  4 Sep 2026 12:53:01 -0400
Message-ID: <1a3e67cb84b077078b4f57425c1475744cc820d2.1788530385.git.bcodding@hammerspace.com>
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

