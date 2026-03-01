Received: from mail-pf1-f170.google.com (mail-pf1-f170.google.com [209.85.210.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 650AC311957
	for <linux-nfs@vger.kernel.org>; Sun,  1 Mar 2026 16:17:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772381855; cv=none; b=OWcLQP+G9YsEhnOm4U2n2Efmh4nWxr1BU41gVw9hAx0xVo04sWbk0Woxhp/XB+sd1CBsow4VaB14QRFveJ7tHlP2hXfo0tHRnU4csiwZB1FtOT3EdE/W7IKEgUn5VIZwjx15BF7Y/l+edyaD6SKaa8o3e76kFg6tWUpjEvkLAO8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772381855; c=relaxed/simple;
	bh=DsCvTnRonbBjO2JlO28mIxQ6YAbIlpWMICrRxDHCp3I=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=nWXgr4eQjXzxOVakDeIl10mSSFaEGQ99c5gbCfBRJLE9wOrcezB5R8U6clTwEhCiDWtax1PwhAA8Oj3U5tCWnV6goTtYPHCU6+TuIuzKh6UueJa+AAT8u70FUL5tub0/SREu8svkiGWwZyWyBoJkhReJzjfwxbntRdG4dhFakcc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nX2bclaf; arc=none smtp.client-ip=209.85.210.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nX2bclaf"
Received: by mail-pf1-f170.google.com with SMTP id d2e1a72fcca58-824b05d2786so2988452b3a.2
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2026 08:17:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1772381852; x=1772986652; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=rX9CCCw8zu4UXrbXJRhFhr2cp9sA+7MdybCVq3xcDCE=;
        b=nX2bclafZqOMOVtfrKaGWpB+5rIGGpw/NsTGWk/jpJ/Uz2DT1pPIyLd27GmZianEB8
         UpqpmsgWkhP9E2eBiq5Nxss5vnTH2MdpTkhRI/YNOWFCGS6/NBKy6dDtliuAhoyOEEjq
         ksOi21fJB/TiMoKPQxbGmhcG1U4wjh7X8f8qUYpaG604OfaTPrrSVS4IChFzOfn/o9FD
         5PQOdyzKBIlj5h0orc7bD/RuB4aocbNEeaRAvByxOajDR5wiUJ53bC3zOOtwDfGcdbDl
         zd6Q8/nHDBT0KAyqbF+JjernTFheYy7XKIaf9L4uWndsvBsk3F891pOcfZUmMx03gVxn
         hTWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1772381852; x=1772986652;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=rX9CCCw8zu4UXrbXJRhFhr2cp9sA+7MdybCVq3xcDCE=;
        b=VXphPQZTEfyyCf4RCzYt8IgzZ+wbQ12GJ4c04JLtEfIWYGDEkiH5X/jSPpTEL3XHKl
         luOJuxPeCHNsJuoVkgs8kUDtKOHATmdyfOJDrT11Cw86itTrwf6EaChZkBsfHQXTo9Ny
         kYT3icePLnG2v5u7EX/ZumM7xusgWEedZ7pINbuqzAeQmUsu/F/qKC12/wYEFUAAfCYc
         A2+nwqHua0HMaKrE02tbM5y8U0tvrOHyyQnxwJ8myehADoWyHyGRgtv6FwpwXPyJumA1
         IpFHCPrvtO/H5zO3QBDOskGtZjQQoJyKWHu1uTqZSTOO6pXBbNEyCveQr5KmdTzQFSg0
         /sKA==
X-Forwarded-Encrypted: i=1; AJvYcCUhygFMgNQOYU96MwzyswNlDUC5+0rRcGQYuw9WuKbZV5biXh9u9JXJR5M+VbHvAuRVv+MOrRiA9YQ=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw7OjV2a9XTCl5+EsOru1iNLQyvowpUhDjkvVBI5xRBCjO/3Y1j
	sSxn5xCSSj1CIXNzb0i0DVJFgs4qSiNI1Wfduemeu/XiKPYuzpcaTBm/
X-Gm-Gg: ATEYQzxLDqVjrOf4pO5qlxoeIDWK5SmunZ5lvAJdAhm3uI7oa7rOamm7nEJ8J4zAT92
	m1U4yfGk40LfUUk05+uspm8x8BDRtdn4X2SiYH+s8dMP2CE76SeW/l+MrM6OTWOU1Ht8hl12oaf
	5J4L0tf660mUEsQ39jTMZ/lg5bw/Xyz/bLgfiuqoWDUdSMqgIG0bnEcJc/HRclu2mgg9Wyqr7LT
	ZsNNBD+vWfEF8PSFHk6EREbX1Xl9/Au6GeJeA29wb34kAIqZ85rZsmNVv0VSy+tIzLaoBoGEq/k
	nPQBw+3sZB8O1P5XnAIMAJYuVhhPU3B/K31l2J3xoWsxRdktFov1tqRn+3sD5bua155pARDcRcR
	1Os4J0uKkm/AtPH9kcNbnCuqL1hFnFw/fk7iuwBKCe7s6lgso6Qs1ViaTO9ZRz3JOQBXtyySVyr
	sT9HGmQj/XjSmN41QWl/FCetaXkPdGpAIVMQ/p1Uje5rxXYy1qWK54dpDKcDadG0lE1Mwh
X-Received: by 2002:a05:6a20:7f9f:b0:394:8455:d1a8 with SMTP id adf61e73a8af0-395c39eebb0mr11167907637.13.1772381851706;
        Sun, 01 Mar 2026 08:17:31 -0800 (PST)
Received: from sean-All-Series.. (1-160-230-14.dynamic-ip.hinet.net. [1.160.230.14])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-c70fa61fcdesm8651456a12.11.2026.03.01.08.17.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Mar 2026 08:17:31 -0800 (PST)
From: Sean Chang <seanwascoding@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	nicolas.ferre@microchip.com,
	claudiu.beznea@tuxon.dev,
	trond.myklebust@hammerspace.com,
	anna@kernel.org
Cc: netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sean Chang <seanwascoding@gmail.com>
Subject: [PATCH v6 2/2] net: macb: use ethtool_sprintf to fill ethtool stats strings
Date: Mon,  2 Mar 2026 00:17:09 +0800
Message-Id: <20260301161709.1365975-3-seanwascoding@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260301161709.1365975-1-seanwascoding@gmail.com>
References: <20260301161709.1365975-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The RISC-V toolchain triggers a stringop-truncation warning when using
snprintf() with a fixed ETH_GSTRING_LEN (32 bytes) buffer.

Convert the driver to use the modern ethtool_sprintf() API from
linux/ethtool.h. This removes the need for manual snprintf() and
memcpy() calls, handles the 32-byte padding automatically, and
simplifies the logic by removing manual pointer arithmetic.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Sean Chang <seanwascoding@gmail.com>
---
 drivers/net/ethernet/cadence/macb_main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 5bc35f651ebd..79ca19097b2d 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -3145,7 +3145,6 @@ static int gem_get_sset_count(struct net_device *dev, int sset)
 
 static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, u8 *p)
 {
-	char stat_string[ETH_GSTRING_LEN];
 	struct macb *bp = netdev_priv(dev);
 	struct macb_queue *queue;
 	unsigned int i;
@@ -3158,10 +3157,8 @@ static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, u8 *p)
 			       ETH_GSTRING_LEN);
 
 		for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
-			for (i = 0; i < QUEUE_STATS_LEN; i++, p += ETH_GSTRING_LEN) {
-				snprintf(stat_string, ETH_GSTRING_LEN, "q%d_%s",
-						q, queue_statistics[i].stat_string);
-				memcpy(p, stat_string, ETH_GSTRING_LEN);
+			for (i = 0; i < QUEUE_STATS_LEN; i++) {
+				ethtool_sprintf(&p, "q%u_%s", q, queue_statistics[i].stat_string);
 			}
 		}
 		break;
-- 
2.34.1

