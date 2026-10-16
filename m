Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CDB1375F9C
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 15:22:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792164137; cv=none; b=fbnAD/qSRe2DnA7jW6r7i9bJEz8aQJtK3rRzv6uDp5bLo61Snvf98Iji1lhDxLoHkKyLpis48CoXaWHMaEolVQVEBHTVU1XrCb5Fy5Dz+fEWKzSIc+lqr1UX+1EmKkamLbnyHyIhLqZrwx5FCXm8N99u7cz8X1vJwbD+0Pxdjr0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792164137; c=relaxed/simple;
	bh=YLdiba0OyOnNJEGWWQ986yfEOcrPCm7kNi8TmJSVz9o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=mHhdfYttBEpkNjk4DhkD5ZyXVh711WTFHnReIxwYu03RMDknsfZKq+BtIHiDU/A7qLx+j1dwiyCHHeuoKTTfT+XisickiQtV2TYGkANUAQwYnoFbLedZpLwbscISfof9OugIM93HVzFl2jhguCrzqbqB2OMBLh9KXE4E9fxWddQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UDcGBM0U; arc=none smtp.client-ip=209.85.128.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UDcGBM0U"
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a16c1608faso1288345e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 08:22:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792164134; x=1792768934; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=xawl2ZB3oCR8CNyK/V19qegyW6CeIP6gzp4p+HXJ0UI=;
        b=UDcGBM0UOfrDGaADiqJHwvbThD5jBzURFA58Dqy6Gh7uQCddNgZQ+YkPevW/Rq/xS3
         pZzLCqrvFGgpnS80F0Bd6V9oGbnxauIYWRO+FMuMQxLV0jIe3mdMxRuD+a41Y1f9KeI8
         XWg5FKYTDyM+TRuDdAijSLrv4BEh0uVJLDgoC31I5/N5abvJyRuxqs4ezCO18BTWkmtO
         Ufg4M4JozMLfAz/64XYJAWPgoQywe/gsmbezG0y+o+tx9U3Wm1Lydqyk9Fbq6JbcMhd9
         SGeQoY2f1Y6AqYDG0mVZu8B6XXo/fbMGpmBn3LNQ22Axx9P4QRoIVbxqUsEAhv2tSfN7
         NZmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792164134; x=1792768934;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xawl2ZB3oCR8CNyK/V19qegyW6CeIP6gzp4p+HXJ0UI=;
        b=OkEGbbzGARhKca1JEb36FzTeWuDgkzm99Z35AtNM/APTKqAS+LuCJiz2FXh0aLwMi4
         zBRsYlhuYYc1HMSkpOCHx9uiIr5PemT9+JUFjuYAUxWxyqlBu/lYvmZMSYjPf6+6je0o
         fxvy/M9lfcidXywi9G2qNMMXm/0h2N8PkAt2nrd938vnXzIOiJvECImDL6IknYFBh4UW
         84x4CFEDQx1JujKqoz6qsRas/m0FENxFWuFu0cmE4B/OcV/3TZgCj+DnGdoLqm+ZVbDt
         mraUKENG5UUTMEqppou5+dWLxL2jhSuyU9G9bqMwGN6HvrTesRYdvntyHoVver93TcGG
         t/jg==
X-Gm-Message-State: AFq9FYK+xCOgga9UnnjBKkFoLZs9oEOLRnWlyNvXcNmEtZ64U/EiydZY
	8tnH/JdhXf+7JeteqIL1avibQDbyouPp7U6HQzplPuJoBwr+US4vFllN
X-Gm-Gg: AYBFou0HkoVVeJk+3p3Qben+oto9S+Baif59iISKA1pIX9pFcmdYTCzlAbuaXUMF/1S
	v/rkQmp2MJIPZlITjRqXOvU9z5WqJyGQmWde3wAvq8necMxDR6wV6P3sklqQkT6HtcmAyT7vWBg
	0/xdF02rv3ky8qrqQadDPwJ9gDT2P7b0RuE+RUgqovJ6orji+2TXP5JNFdMcxlpsRUr5CYMcDcJ
	jbMrwv5Aq/s4V2biZrvp0ydVjv/SFgj8N8kwqAYpHvuJ8DMj1imqe5VlVqS3Cetc0AhfnYgrpVS
	0ZAGRhcW63JyrjRf1z6UQe1OBEUmLsAubZhNLLOt55m3gJxvN+OhMUEZ/rvmyB2TkrSFMERiTTc
	NY7+Glwb0WtkPmOOcTP2kA+h13kW91cq4VdUVkSyfRfpm4eaHQhcul6FMis81gdxcA0fZggkBW8
	HijAOU49KrU2GHecqBsw6nnwhFGJY13r8dKdyKUwNwJFg+e/qaUqJqq8BUaquwNfZzMzQLHIsVD
	meQeMlUnAV3Lvq4kdReZC8=
X-Received: by 2002:a05:600c:e548:10b0:4a1:d766:758 with SMTP id 5b1f17b1804b1-4a1d76607d5mr1605845e9.16.1792164134296;
        Fri, 16 Oct 2026 08:22:14 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([2a06:c701:4778:c500:7945:4901:2862:3e20])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48dfd409989sm6117028f8f.0.2026.10.16.08.22.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 08:22:13 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andy Adamson <andros@netapp.com>,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] NFSv4.1: retain MDS I/O until both thresholds are met
Date: Fri, 16 Oct 2026 18:22:10 +0300
Message-ID: <20261016152210.140449-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When both size and I/O thresholds are configured,
pnfs_within_mdsthreshold() uses size && io to decide whether to
keep I/O on the MDS. Both variables indicate an unmet threshold,
so reaching only one threshold returns false and may trigger
pNFS layout acquisition while the other threshold remains unmet.

Use logical OR instead of AND to stay with MDS I/O until both
thresholds are met, as recommended by RFC 8881 Section 5.12.6.
The new RFC contains the same threshold selection rule as RFC
5661 which is referenced in function comment.

Fixes: d23d61c8d351 ("NFSv4.1 test the mdsthreshold hint parameters")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
When size_set = true and io_set = true we reach this if block:

if (size && io)...

but it should be:

if (size || io)...

  size     io       current (&&)    with fix (||)
  -----------------------------------------------
  false    false     false            false
  false    true      false            true
  true     false     false            true
  true     true      true             true

Both variables indicate an unmet threshold. A true return
retains MDS I/O rather than acquiring a pNFS layout.

 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..0d8f9636427b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2061,7 +2061,7 @@ static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
 		break;
 	}
 	if (size_set && io_set) {
-		if (size && io)
+		if (size || io)
 			ret = true;
 	} else if (size || io)
 		ret = true;

base-commit: 2f2f7eeef8b0a1a9b9ca998231419873ccae8d4e
-- 
2.43.0

