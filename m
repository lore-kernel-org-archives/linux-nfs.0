Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7D17265623
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653818; cv=none; b=nBChyaAUaWK20fQkYmLapT1a4fSadYNHaqt+fiB0M+1m0MF1CUW3H6Ei5DZSzbrTi1Zvp4ru7yDojkaE9p99Kwe1nghh6PipH36F35RlgOlxecTWDL2e0n6zdowUQn07sJ6YLJU47IM/hlFERlaHf7AlTgp+IZepRuLsLlNQoOQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653818; c=relaxed/simple;
	bh=pH7gJYkj5moA1RWETi1rDqZfDZDx1Py5Q7h5BCzGPFo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fk+XE3Btv+KXy+6daYy3k0exsyE+aWK5sDzo/cFiOzG6ZlLiJSLSoPwzhmjMoQdvE1pkE4j2+0eXhpk3G6+U3FSGsu78bZ7edgUTsgHGPH06qDEX1YaT5dK6mVj9HN6rw0W3zdy5wM4fQjMI8Z9qWMgnPAJHkg/Cs/I+uLn13Kc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=EUsuCvZo; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="EUsuCvZo"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4960fb63c75so157118b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653816; x=1787258616; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=V0ST5eK7dKvvqRzBfg4Rd5pMamn4rTXYEfaEZ6sytwg=;
        b=EUsuCvZo1z92+lpO+bk++ECKvI5b9w5elY4WxjItTYJOlwb+y3miG+qfV2XEmdDoVM
         elyZ5q35skrAzNxro8Mk7cLKBF/Lymr6gDLC9IFgO5+ow2gMH5dbtRfMRZ64mI4kAsca
         TYitpND8LqPeXgfqiSYAOvXLVXOYnglPGynDkRFZCZyKQaqQpgPtz+wwXZ7LgXGNfiW+
         y3DOuqOjaQRpo/ZGKXN6FIVRdRBVliRDN41bUuT5mQyyz7W6yq40XktQbJ27wWUOfnWe
         cac2MfmCDfN8Q/cpQNVGAvmhZfku6QYCByyXqPj75M76DQ8itiyllg0/alsgrZhv0ejH
         cJTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653816; x=1787258616;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=V0ST5eK7dKvvqRzBfg4Rd5pMamn4rTXYEfaEZ6sytwg=;
        b=TkPJafnwd8HgLPxSXC24Nz1ENtrzRopqANBjJHPRz1J/+8HdX7tzaWG7BmT8m0UIPu
         jM2dKwxggg7wObkO4qFRHmi7hQBAg0gnv8fF/kpsTuinQ38nR8WBwS4vG0k+qpkFdWa5
         DccVSWTByLtO4Qs4JOvPFVjvnfGui85wkt5Wmtuu9Hwy+YiYN6FEfTtOYAH4Apq5HNbZ
         VXonvIqrvVDGHSoxPNefAKGLti1k5kmG7ctaHbjcY3QnPdpnxhB+th2LgPyWrdtL/gKJ
         FqGBle+u7a7DahsOKcIrdNhikyzzSHxn4K71BBtj2+RYvWj9+P9PCAyw1Lg34Xqm46i+
         e4NA==
X-Gm-Message-State: AOJu0YxyG8oNK03/Kt9terzVVp58jPF68C0LWiynGbVpMHifvKwtUwyR
	gRuUNf6xsuhuyQHLAV7QLOmh2c+QTi7kAQGSpycoYG+6si1jivHWiLPFCZAW3iGg+Ak=
X-Gm-Gg: AR+sD10gxVBKyqQg4BIwp2DwmPrtoS238LK0XzLGX73JHz3QLLFKwN77cLOTd2/061G
	6BmvbKrz5gbt5KPpIelKeQcwD9xToUgIVxkaQtgjhVKT6IpZEhRTMzS5nNqCvqKKCHT0tQRU6Jx
	5oZYpCER5m247NEv2zStbrRa1ULAe6I2huiP7uohKuIReqwa/8Yz7AdZMZyz/j4JugBRYfpZWrx
	+siIOR15KJzAuLkVSxKKSf5YJXUI/nUCYfdEcV9TMlj1PTVpwaw+v+UgOtSLnXI0FtGQdHQLS9l
	eUsv3WCiMyDIPXY5yjPVXVJFGuFA0vbM1iQUkjBfcjpMDMaZYtwGTSEvgAZrcwsAA4/DoPqhEgY
	fclJYeWQHq3XTQdBDsbGuJqwkErDDhhFXbXRLnLXFQOi0zepTxAncbi/cVQaQ3OGE1D/MpLeZUZ
	nPnMFaW0rf6WhH+c2kJTOUBBEcaEt0edK2L6YrFvDIu5GZToj7Gzjt/85g715AhekKATLfd5npo
	G4g0i3OsfqSEc6VXEfjZHUA
X-Received: by 2002:a05:6809:2cc:20b0:4a4:ade8:a287 with SMTP id 5614622812f47-4b241ccc905mr555795b6e.13.1786653815697;
        Thu, 13 Aug 2026 13:43:35 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:34 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 11/21] NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
Date: Thu, 13 Aug 2026 16:43:07 -0400
Message-ID: <69c2469b68ad86b9d3340b211945bc376de22168.1786653063.git.bcodding@hammerspace.com>
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

nfs4_callback_devicenotify() treated CHANGE identically to DELETE: both
only unhashed the cached device, so references pinned under live
layouts kept sending I/O to the old mapping until the layouts were
freed.  Per RFC 8881 Section 12.2.10, CHANGE exists precisely so a
server can change a mapping without recalling the layouts.

For CHANGE, after unhashing the stale cache entry (so re-resolution
cannot re-pin it), invoke the layout driver's re-resolve walker to
re-point pinned references under live layouts.  DELETE is unchanged,
and drivers without a reresolve_deviceid hook see no change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 10f2354ba304..64c994790d3f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -390,7 +390,16 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 			if (!ld)
 				continue;
 		}
+		/*
+		 * Unhash the cached device first so re-resolution cannot
+		 * re-pin the stale node, then re-point any references
+		 * pinned under live layouts (RFC 8881 Section 12.2.10).
+		 */
 		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
+							&dev->cbd_dev_id,
+							dev->cbd_immediate);
 	}
 	pnfs_put_layoutdriver(ld);
 out:
-- 
2.53.0

