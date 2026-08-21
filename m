Received: from mail-oi1-f180.google.com (mail-oi1-f180.google.com [209.85.167.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30B0F493636
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329780; cv=none; b=loqoLHVDSEK1bpOl5Ctd0EPb8PZpTAbmVWIzIPGFe6eiD9crMXuULijFJaCzGvIHOYkWX19JS4Mm9KCruDikSbYTIee4JfdxRZREvQ9HksxxZKddDAI1p+SpLzpmo+KgRH30nAjnVivgbTn28dk9zrn154wtYUn5nDp4cBtlSEk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329780; c=relaxed/simple;
	bh=L88VmcfUgkkCVFkq2PLJlyp3llYRox9v+Url5mmqeq0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=B/qUNF+oGn9xIHC+bDr9QEdErGPR+PwI1grQnu9EgofHXmg/5XAFMFEs6xJt9IlKWurMNAlyn+ukrh3+snUFJ3nfABljTL9WBYAx4e2gGeu8aoLEbMyCDbOgrKlQ+dGZVm6BLAxbFtGJ3S2V7lqLm7Eb+73/Szgt1vLBgE0uhGs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=UARH5pvf; arc=none smtp.client-ip=209.85.167.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="UARH5pvf"
Received: by mail-oi1-f180.google.com with SMTP id 5614622812f47-4a456e44e01so819861b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329778; x=1787934578; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=UARH5pvfN+Mb/vHnfszrr5fgGZNtfMjGTFEt1zmTcFeg9BQddb+aT4aWoExP7jjham
         1y8pkaEB/fe5hIviEjny2mBZ6bkc0f1j5oxanOBvoN8eAGg7nASJLU68czINdtUTZLNR
         93hQHCmJbcPct3ot/7XQkYPHXQY8nUO9TonDp0Ow/YzykPJ1BTUB72hnYNH/HNHAH6KH
         iJUKjBAh6UEw2EOEsqHg/1eBbAcZYnz+hCE+XFQPlRiYiybT0LY++/HVaVX6prir8R7X
         zBewB4zOXPl3gibMW4szoFo5WyllpeMrTC44ziWGnFrPBSOAvSwPU51+2/BfSkNSSqV7
         QHbQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329778; x=1787934578;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=V0n1I/HvSTKum8pdWDb0G5l5e26spOO9UVfEh1t84zo=;
        b=fynCPT5OeRk+97f7KOzo+E2u5uOpqs+gnOhE1fmO8BKyz/KdPyEmgAjclnB/UCIQOp
         fPoTZ+J1LT+hnvZhuP8KTLLgmZ/bndomNCw6DXjr+K2JiLpvFpA/E1qS/BsX7xva6EK3
         xE//WvyQpmzAi/P15CS+9d5o3wpfwruSxQepef576zy3BotB/3NLkgea1vdcZVUqwGr9
         LpuA764p3OVJGq9h5RZR5kvoJsqmaZpKj+XMMIs/rja3iIZxAPHOfwFaHezDxeUFJWVk
         mqADF16y9gAs1/Ucy+jmW/P3Gc9wyowCEdJlaegwUs+Rus9enFHLhdrM/onsF3Bdlyx2
         P4hA==
X-Gm-Message-State: AOJu0Yy2N926ZJJA0hTW5eo2V8sxH0UV3J9K4uDglQgHQhcGnkQIY3JB
	a8nQs07uqOiEbi0eftqZNior24FyF33kKusEtmWSn7ItxfiBkrfoDFjdWKGv9FYZjfc=
X-Gm-Gg: AR+sD12Md/X4GEkwyx6ICl6g1As2sHvkh8iOWacA2FbxgVyJXQd5Q76Issnddh/uU3K
	OSIsZ5w5zEelfckZ4KUmP5h4xpH+DM685cjoKPVk2JE68cbQ7WIM7gOx1PZYZXMHKSfCTAXLsoT
	5fejJOfNjsJwHklbtDdasVc45zEi6hRCq1rM6ioO4lROuWA3v7nLT+oIQrn9oZ8AFVulGwUGZx0
	g+ZtbCMkh/qL8WJuVHfhaX4nXsC0BXXHOQGoUeB9x1UqFda0PSHL017iCw2qJWgqESYMeZEADAH
	g+HrZ20XrUBlClwoX5tCRMBOr4P1uUNWosK0Kv6OJbIN/y49e4X6QBpPqXA1gvI5NYyqXbbu/a2
	HTpNE0wo6ZgJNT7w1FwvLgZf+6skZWyvmp639Byj1KrDXN2GsvAMY60S1y4yjwc59BR4NOvLNFq
	gVh15b+jAej5tPgE1CNNEQtd5Mtmf9Ah+xkeR1E2yiBcYlRPFfJe9SDrjAFhSMmpnXrC7eIYbLe
	yRPdukTQ2Ozzy5e8HgnNQZvSmGyYxW2AY4=
X-Received: by 2002:a05:6808:3a1b:b0:496:b7c:9445 with SMTP id 5614622812f47-4b2ef3398d2mr8829458b6e.12.1787329777913;
        Fri, 21 Aug 2026 09:29:37 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 06/23] NFSv4/filelayout: Anchor page coalescing on pattern_offset
Date: Fri, 21 Aug 2026 12:29:10 -0400
Message-ID: <03c4979690edfaa67ddff459bead9550287c8820.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
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

