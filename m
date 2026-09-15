Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E59F48E0F5
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474959; cv=none; b=fR0QJVV3bOMsVID6GDVcajImqftCZz8yKCKO/un1lcRlKnPP2MrESsijU00/w09/7zatibgq7/c7IiEw2DtpWH49QtyXF30UX1slQub57FGQsA+Qb0pH78F4RMJWdI4L43CcZbWq2Im98vjjkRd/4UgVBPDsMyvD8ttHUkug8v4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474959; c=relaxed/simple;
	bh=L88VmcfUgkkCVFkq2PLJlyp3llYRox9v+Url5mmqeq0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ppw3Stxng2QMJ41+VLj4l8VoLrhUisDwmNJynU4JbkOqigeDRI6xngHqQIsH///zF7FgFWgQrCt0Vz41xDOBaoGcB1i73/dotSt33Csmq0HtBM9OpKywhK5nED7cNR8Mmz4BsLf7KUszIIcyrW0L01OT5gpg8Ywc5RXT0KV7VN4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Vm4gcKTe; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vm4gcKTe"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b37a3a9768so115960b6e.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474957; x=1790079757; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=Vm4gcKTebO7q5ppatgAzyRgB/TjbibhiAU+99wjmsnWklNEm5c39cxIWDw5gtDyMSN
         rkIFhakyK7vce2quTRnMlksiv9jzVswBRH3Yx3zHkt9F4kJPAwO9NSsDZH8gr9puKVAh
         /VeOqc61/rGB5MgiGPk/JJdSDmF7gM9XUT7jBTLN6zDP1lZ7sBHj7jYX36NyLpY3B+NV
         LxWumt9qOZ98G6MreTeuo2aClB+A8wVNOu6FK5evc8M2cayAeiU/z/ajwqvjzLPi5dHf
         Q7+7nQmC5vBqdKaZeJCPprlwy5jCY+8GHn1zVz2zhBOXOVzm+lu6uFuosrIEBqmh+nW9
         haJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474957; x=1790079757;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=MiXfQ408+EpMPV7B1ffIHhHyLNAg27ByPtif3+J1/Ae/CcpYY+LRBlC9rnOjVfhSMt
         WPPAVMDOdMvK8RUHOzyFe/ckxR3xmQsPpD9CeIcLk4xBz8T2ezXqP9Iiu263f3VgAWo9
         u6zz/DDNo55lj/iUe5HQiThBqgx57qzauusuDYTjYilMjsql2pSi+JcJlwOcTkp0o9Vr
         cweYizXTDSExtE8lA2QiDgA+e5peSOaiXJ6jzxH1wHMMcfHnZE+rW+Ho/yCEuZw/Twfl
         E1LcccsDbnrupkgt9GQWDv0b6FDbBwA0ASbmQWX9ezBD7eUMbHcCvJreRY/8/BrfJP4S
         9cQQ==
X-Gm-Message-State: AFuF++lC6sh0FwLCbn1QR9XO7QWBnEvNMTIAnRblEiJXQIJY14fLFgkg
	9H7w2o52fb7absN2TyC5HS+Y7mVZSrOHmTTU0sjC8FrCoDxywqbvofBL/SsfTfuKT8o=
X-Gm-Gg: AYBFou2SPU0coMg+gsSCVP4lzX7bk9KM/ZcRsWwUU6vWDd177WRfYQTaNuRqC9EIiNf
	y5WVWmMUzCOYHqCuRfKcsukuL4tU3z6iDmhm+lU292ZK6mBKCVQiR55UsCczjRVsLjLcMYWqjCR
	0DLu17qgNoPq+ZfyD0BJIUShjuCMDDfpU++m1fyT7ESDGrmL0Qw8E19Ky0Ylxu6AFXTB3sAcrAl
	Ql9KWZpsiyTgaPATyKFJ2SKiYI3f7e6N1e4mgAzzZ/UKu1t/OuhLaaC4sXJOSI+6G3ZIT0d9DOT
	GRY//ki15h4LZPYSAgr3pcXdsuL8UmEWrCfENS8qLfd86F0zgYQQjmFKZ7BpaMrxHixw1vqxomk
	y+LkG1PzuON/WjyaphunH1fIlOXVnNQpogEwyAYytS1nUZtSclkd7GhjBf2KJ9vCk8sMIUvlys7
	NHpcO+guRQ4tdvDupc5aqoorbLWHfTVchbiuzh24oVi8XAEvRiPaQrzmWKeqksYjDhyMqUVPsqU
	fGujjEzxc/agjPk/dqJOYkrje9/nrULyLw=
X-Received: by 2002:a05:6808:15a6:b0:4c6:7ce9:1bf0 with SMTP id 5614622812f47-4c9acca010dmr466351b6e.20.1789474956916;
        Tue, 15 Sep 2026 05:22:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 07/24] NFSv4/filelayout: Anchor page coalescing on pattern_offset
Date: Tue, 15 Sep 2026 08:22:09 -0400
Message-ID: <aa1154617470b62bb0f774de0fe0e98749298852.1789474702.git.bcodding@hammerspace.com>
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

