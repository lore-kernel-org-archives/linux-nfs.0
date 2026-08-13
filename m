Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 426AD3314AC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653806; cv=none; b=NKJaY9zo6v1zabedB2+17E5PJoW/zqo7jn6Qv/YuEkRmTMUJs1pU3XNYIcYAeElzWG3ls5US2dl1AuslsSCEeaCVszvw3j8t0XVJNYlpSiAxUZGyFH0fFV5fwJgxvUVdwT89Py0jarIBx1J+IBm9NPwGABivrMn58JhivMOrMRE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653806; c=relaxed/simple;
	bh=kmPtR0UcaNZp+3Q9ox2E9zAyNG7avQbvH8MZww3WfVM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=k4GYuANtDRnYbJkvvWNFya9tGYaur+rInmIpFcniTBwEK2n8mwAhcaRknL/2rFkg1W+oLkNbZ+uV8jTeV8Mh5pUcMt+lmNu7Nbqdv08VyJiqAu3v63ZhhUvaZnKhuI2xsDNlLjBN3nAXnTT3WbyCeV/jxTllbwrCHYHkKSZT90M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=US07V8PV; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="US07V8PV"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-495b27007d0so182338b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653804; x=1787258604; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=0k66GM3RNsDB74QuAgud0rOi68oM3bGmpdnkgyVgTaQ=;
        b=US07V8PVgJrlZslRvxSVbsbHdT7uOoTWNrMrVXxVv8cJtMt9ThqWcrQkfQYvMJL5BQ
         w24FClZWhMeEmigwptcADWJTot2GokEkqWURBTnmX+jplOiGo0rTdDgBiijm2I2pU92r
         JD8KXjwKWEAIaUeNEHNipvGgEZR6EoUxnVVUP8Z0MSadlR87Mh4zXH9tYLJ1nbZ+DMw5
         iAOkAoAseVNECfETjyXqpyrxTRAZ/IGs3DWy8SkfZy/wWUTnGQloxtFJCrLwLZVFUh0U
         lrbHZzkhPrvyeChspT2SH9HTYZOjujRAp48UA1OVpvOR6Asv8qiRM6q+4X9lrrlukctR
         G4pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653804; x=1787258604;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=0k66GM3RNsDB74QuAgud0rOi68oM3bGmpdnkgyVgTaQ=;
        b=lz/8V/yZztUGX8qXUN8q+fi6vV0FaY77ws67t29+eoqLfbpL04OnaKsJ8mKmLDXPGW
         dBbpwTY20w6n8otv6Gac+KIS8WEPXXUCL6yA60vLinVMxNZsfAjZjGCBg5m7/Z+EyITS
         RswzXiojPsQ4VBIsYkSXTQCx8eOo9pXm1UG+6tbx14gL4/tq4TQYHMbSzsW9JoUgmQds
         1kWadiXDCjR7oJ7srk8lbZLMxkuVLOFSUSguz/XXT371kqeglE9rkuXcNT1A1tRX2RDA
         PMSFTjKHd1J1GuIofspFgqP2wNxGm08mbYmc1vYYq9lmywvxug+Uu9m7FwvrAaT/ccd4
         nI7w==
X-Gm-Message-State: AOJu0Yz5KSy8RkltUCreyxec2nj5VbeK7mxtUh90cI3bzEMWtLaQ9enC
	A6OGHU8iW9LMHXXT/zQT19F3HvqfbKTJeMzM6+PJAJNpmHp1Pe7ctUsn5UUOw4Y4yaw=
X-Gm-Gg: AR+sD12kg1v6lwamtr3Dl2Ag2dIbw2hIbqufo95P0pgdtEPf7TDnxUZp7Unzy6b57oU
	pBXnz/Y7ve/5kV0FnC49Ixn0Qme/j7suct3deYJ+R1YKdYOU+SPZIeaa/wWyHzbg90lbjR3boA1
	TAge3CSM58H7N4GlMWgYFjW2no/J/3AQQyNtY05q0K17/x9+IYzwoVIThQsfrkB5Lo2l/CnjKSI
	/CT57Z0n8XhcIRSHBRtTwEWA7tzf/oLyruXXeeonJ2F+qyoca250Qv8oDVcHTYimzeBFKKgy6IG
	23SkweK2PeYHZmw6dWB0T4h2z93Zf7proF+6+qdEtGLqU0Q8V0/hcgnQlKCIBLFrE+jMaKYq7DJ
	ffMWpJE07QndCIBFkdWOGDoNR8pfX+wRQnIXzCsk09tl5iVeJtkclnjiSkbUzkQFjLlJ9uw/cYk
	J6sMuyuGsWyKpTx+B/Qq70YOq6oa7PZreE3q5J1rF/lR4wB+V0G5qsqQ/nT1QSBf0Jeoj2C61Yu
	m2T86QlR+pOSkCVO19EbJSAiFRTdNCuen4=
X-Received: by 2002:a05:6808:c414:b0:4a4:adaf:5576 with SMTP id 5614622812f47-4b240f870ffmr701726b6e.4.1786653804085;
        Thu, 13 Aug 2026 13:43:24 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:23 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 03/21] NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
Date: Thu, 13 Aug 2026 16:42:59 -0400
Message-ID: <3d211bb3dcbb29c63936db084848afed5eaa1f4f.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
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
index cce56faa8b70..692ad84047d4 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -996,7 +996,6 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	unsigned int size;
 	u64 p_stripe, r_stripe;
 	u32 stripe_offset;
-	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
 	u32 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
@@ -1008,8 +1007,8 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 	/* see if req and prev are in the same stripe */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev) - segment_offset;
-		r_stripe = (u64)req_offset(req) - segment_offset;
+		p_stripe = (u64)req_offset(prev);
+		r_stripe = (u64)req_offset(req);
 		do_div(p_stripe, stripe_unit);
 		do_div(r_stripe, stripe_unit);
 
@@ -1018,7 +1017,7 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div_u64_rem((u64)req_offset(req) - segment_offset,
+	div_u64_rem((u64)req_offset(req),
 			stripe_unit,
 			&stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
-- 
2.53.0

