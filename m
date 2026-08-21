Received: from mail-oi1-f182.google.com (mail-oi1-f182.google.com [209.85.167.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19BA4493636
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329797; cv=none; b=fRVNWFUUzXN/l1I5xzLu6Y2K3epZcSkYTqMiM6CAI34JFo1Cndg7BoPM/X3kOtrlA93fjxkjeK4LqCqaGDs2lrMuzO/HNtgOvY58iu1eTslWWjfNCGifEVypDYfpCOWXTTP8ONIDpx5OM3xRNJH3iOMN5vmhNTZ+xUGRKWX1tJ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329797; c=relaxed/simple;
	bh=uwyW9w/1ZciAbVAqAmY0cI45bHrXrtOA8e0h6tY65/8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tvqrVguDrcro9tnaGT8tGKtnyc5S1W5/iJlGGeptkPAbZC1X8A3HOpBOhFRJE0DVFFRQztDUl16dpNqssn1akwW+elfaIgzkQWzj42lqeH8RukTO/zZji6OeCvgIFBn0z+rgmx7M4aJ1iuhiQpMExk6X+Cjw/QVLjJBtX4eitdc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ltU84F9L; arc=none smtp.client-ip=209.85.167.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ltU84F9L"
Received: by mail-oi1-f182.google.com with SMTP id 5614622812f47-4a45b3f0becso1130732b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329795; x=1787934595; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=ltU84F9L5l8Tg/CRGT0KSsp1PgHywFUpDIIhw25++M5F1AunXWEZtUjIgNt3neUUae
         MMWpQmrfJYG3G//ku1YRdM/+LH8MyHO9gqVyM3c/Tio6p8jS1ZpRkedW/eGBCNiwEHIm
         F9O1DRGUp7bnUyq75nWhsd4FtS6urLjH+kes7VE6EGhwDYKmyTBdBxkE8eO805Pol5mq
         qa6OndZd4PpuH7b0GUgwB3zsQi5MkX96oXazHixkpnipzrEmzij6MHhgJ7je9ICNUIEi
         NaPRjB5x8tLaPtknsn0rr3ttjsj+Xeu+XjwdNe6/hpPs+uD2uKQdWUoXvhwZ29tGJegv
         4Zjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329795; x=1787934595;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=jJ3PAElnZye9yC/uWIz77iobB0s0VXJV6gYW0dVwjcU0CwR5qXVtkYJBsdcMfUFQ9P
         cGiv6HwK71DIXWVRQtEb29MdOas8XFCcE4ut0UDWz8PZKV9bSWnyuf3F5jwRLhJrEaky
         niX/eTf7sNmQcYE2sgN+k+eDZBuxCXgazjsa2eJ4jmYMATuZuA2kN/8eEeHlZRLgPTns
         QA2wKKYLZMqkZU1fKaCw/8frdI3dnzgLHMG4/dbv8rafrEXhjgnSlp/djLx9dHrDmbip
         52yEvMNypILSQZDE9263arI44kviJzzLS7QH387cN9bPChDR7XYon89if/G2nF+HmGUg
         18Gw==
X-Gm-Message-State: AOJu0YwPAcSB3on93eiBcDmLf6zcx/9l9GCeZetaGS1sz4DNUFBK7D/e
	UEgRm+5FCzA+eEdACmKQP8hGN3CZfZdOMHTSk/WMWguJ7b25ia7nA8Dvn7f94jh46dM=
X-Gm-Gg: AR+sD13isjOEMZCoFE1VtEfwwYpxVLfoOFR//xR684ymCjIeAKCk/Xq12asQdtJAcgM
	x1gPYKzhP2SefEjQLRNLMofb01YfvBOksQ33p7DWGuMra9hfhBDtIRjMdQEhGQI4N9J7TXJbYD3
	oLny4ItXc1/HNoSLie5DT/ta6m0ZMqyJyrNsJy3csyiLQR3LOgNxFfARFm6/HmKrXzb9ZjdrVaD
	uCzr7ozg54sOd6ZpvsPo+8ofTWUj98Ukny1svOdF7zbnJX+GFFEuSAzpsTMCyckVDHqv53D9eKq
	OR/awwOfAonqe9C0bqoxos72w9MfZx5H9Dtd50Rwry/2HhBWPj/l5EzfNu3jd9i9deridjtR1cz
	CbBJ+mZcGDD4fOmTiRRtjNqbPog5M8adATRGYxB3sE4sqqLcaw+TNhEcF78ZLDRPl+b7OhbwBjZ
	eov5bBQXKWF+fJXHPvQSoaybM5qyQD9uAjT1N5Ccba10B8e22GjA8CpPtGTTNQyQCANv/mTP2yA
	ikGggaNVv9D5NXpQQbHl4pq9KAZPYOdiX8=
X-Received: by 2002:a05:6808:2293:b0:4b2:98a3:a567 with SMTP id 5614622812f47-4b2ef1bea44mr8292181b6e.4.1787329794814;
        Fri, 21 Aug 2026 09:29:54 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:54 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 20/23] NFSv4/pnfs: Grow the deviceid cache hash table
Date: Fri, 21 Aug 2026 12:29:24 -0400
Message-ID: <b96440fcfa33e1f332c26c0e42133d05f51d532e.1787327939.git.bcodding@hammerspace.com>
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

The global deviceid cache has 32 buckets shared by every server and
layout type.  Striping deployments initially anticipate device counts
scaling to 1024 or more devices, which leaves those chains 32 entries
deep for every resolution to walk.

Grow to 256 buckets, four deep at that scale, for 2KB of BSS on
64-bit.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index a3b28409539a..e8143977965c 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -40,8 +40,11 @@
 
 /*
  * Device ID RCU cache. A device ID is unique per server and layout type.
+ *
+ * 256 buckets keeps the chains short at the 1024-or-more devices a
+ * striping deployment expects, for 2KB of BSS on 64-bit.
  */
-#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_BITS	8
 #define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
 #define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
 
-- 
2.53.0

