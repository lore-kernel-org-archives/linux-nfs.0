Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD93542C4F8
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653808; cv=none; b=Gb9LxVR1VHIhWibAYKMHAYoDMP+X/bTvAGsP8UZbhIWbhrhXwqFjAyH6bhlAMJ+cw+plu5FN40uch9vuZvUvjUEtW5Kn+9LhdoKeg4r2osU0y9Wmd5XRAUDaqCQ843usStwYcuGfGlVHu99r8b+ggxYFIOfSbODC75XntcN0kas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653808; c=relaxed/simple;
	bh=L88VmcfUgkkCVFkq2PLJlyp3llYRox9v+Url5mmqeq0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Zz4LUAjZsTwNA7A7Hy/7CNZgYwVNC/yuSMhh9aSfGdZmc4fDGsQYoxaXjkSF5u8P+E7shL2Y62HyfeuvClS0YSaDqj7ZGQaaGHjcK/DsmRvsLZ0C3gTKwh8mxsILOZnM2jU7N2LtvDnPSj+mqY6n2Lnb0cV/ssUO9j48GMIv8Dc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=KhP0hI51; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KhP0hI51"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-7eb9b427da2so867017a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653806; x=1787258606; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=KhP0hI51g4sy5GD7Z0lA0pihXxLBpzBNtxDi6+oNxRjF+mWpLLfLYxWvcy004YFNCZ
         UoQAppOXX5Ad9ZhWNlKV6JCTCBnZ+nBD7x+7M1ecX9fsfw+qHQaY+ePA0vNKZRkRs99Y
         /dwfMvI2K8O6gxmu5S3+PJsoP3tTOy413JFFrTqXG5TW0WRF6/MstweXNQKP+KiHZjYq
         w6u8IEoB+7PZsnlQkJUwgUlA1X25X3Xc0zmsRTD2Tp6W31j03y3HQuxGnx/SE2u8fJ9w
         BZd/hcdBEsrO/3bHyilwkwiSAghEtxM4APay2w5SwM5/nJoZqghObzLPNKBfQb2XEXL/
         Cmcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653806; x=1787258606;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=NgJfmHTAHlBirUmb3hvaGyMSkcF/GCtSZZJAjESDO4EdhnrQUh+TJXwZq5cbWT/1O4
         pP5mAv/oM5KSI9KoqjyAW02Em23dv1J4GRnGUnHMzmoEpK5sWMd1DUZeW8yTAe5pNXd2
         At4FO4yIYbYat067pAjIBQrHGfhvjcrn7eqi5Zkq/XeE0MYpZmBrghHf8A7ECnckqKOe
         1RdPJbvAm9Xmmk692ADGp4XSYL8TZCX0YN1+5KVAfSHZ+MTOYk9MnSs0zEDGRKmnCHC5
         KZsXpsV48w3c1N0bO/n+al1G4HV3KnIFxdgcp9RWdGMo8vh95xs6l8ymwV0+5aH1p1TC
         yocQ==
X-Gm-Message-State: AOJu0YxNuWqE842+v6Lzd3l/Mzv+ARXOJmP0Wqx+SJxOhsRvpi3Di/VK
	SxPEj4XJknPgPBR9pXxgr4asz3Wi1S0BLW58nwEcHeckTXfr4gfDZdk8UWkpHfTUHic=
X-Gm-Gg: AR+sD13Yp7h6Z7i7izp+J+EYl6kjIrn+nmdO1sOd67q7B9caEJzLRooGO8bq7vBhysY
	2RQyeUPo/PIKc0QnhjdcCMx7Bhh2FEy8dMCnmZNigNngf+VLJtff0R4sHCzp0I6nYSgInyr1B/4
	QfIDpvSDdkd20G/ymhym5RpZjtxYOwPo9Hzje+iGOycYbd2jjPFbFpjPGiivG7w7siDPEmtf1b3
	tqWR1DXSTU3RGWHwXOhJWwTBPuWCfc+nCP5pqvA6u/wNo5fJejVCbGAwluBR/6/HaRO17Qx1gK+
	flZo2AiTV+KwOXfINLRPYYhaWhLYKiL5u3nZuize0BKfJQWm/7+EFYluYygS3K3KifzPYtna6e+
	sLM1N8VAeXz9iagsD9To8Qs1P9FjzQc76XYPCPmKhJWslLnhsgqy/TxTocuPQ7PCsf5hVXzNG74
	JW8fGH41Tjn9vy2hwMSD6/m/zOb0Y0+aha7XWmVApYsY4B8tDt8FAz6FOS/rTMSAqEBPJs0J3ri
	fYdmuKZ6ZLVFiy9cW4X/LzZ
X-Received: by 2002:a05:6808:13cc:b0:495:ce6d:7d48 with SMTP id 5614622812f47-4b240284c10mr535469b6e.9.1786653805669;
        Thu, 13 Aug 2026 13:43:25 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:24 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 04/21] NFSv4/filelayout: Anchor page coalescing on pattern_offset
Date: Thu, 13 Aug 2026 16:43:00 -0400
Message-ID: <8c8cb4032593df59b01a807ccbfc6a2daad2772d.1786653063.git.bcodding@hammerspace.com>
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

