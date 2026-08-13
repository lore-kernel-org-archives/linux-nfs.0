Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BA16265623
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653828; cv=none; b=Tnj7hQehkUq6fsmOjS3e5Z16HIfzPMa5e4vhKb6v8cl5CdW8AGXKBkE2a2hcsT3iaTO51eVyfTgdXrZgjO4Xl0YuB6PpRdC9K2iCQBeidNQ98HkqdGm9VBg1LAbXakpMVvSS779bZgWzcge7iy/ZGhdLG0ejSzZuR9zxyxQE910=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653828; c=relaxed/simple;
	bh=OmBp42bZHb2efF6sjR0Nx7Sxopz4qqtvGPxyGsPeOWs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LZ2iCldDBTPiRUSZt590huZCFVkPW2bXHWILqG3NakZQYEWu09Xwjm0yaQzWFDcaneDmZ5yuBMBhdAdekIZS7qWV6Enz7KsOF3aN+Js9uMkpSs1GU85AQQTib2LdBmeOIcEAjdgQvo6+key2KRLvi8oeXJAcntgIjDKSZ6Uh4y8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Mkao7OyN; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Mkao7OyN"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4b1ba286f6bso844182b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653826; x=1787258626; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Omt21ylp4oQgK/AHcKFYX3RubZePI0K3RsKVxRfm/38=;
        b=Mkao7OyNDkwMuVWxVF4Z8Z+bNyPhkRuoUxhbsiEmeHomRJVYO3EdFzJZOX2Kyk05q4
         AYfW4jS6jlgPm2QsC15Sv+W84Jisz2C2cKoHbCJ+FScZAb05slm+OdCJe40Om4PDKH+5
         htpP3qsMWgBtjXcegJ0/EKFFoqhR8BAJpd0sD+O/rSyOLMHVBD+Dkxb8XiNjyPf5hjzK
         asTedkGqLB43wyIEfiPrwEzexL58SnxWlaD7I2VZMCRh8fL49HQsq7vO6rW9IOC25oYR
         6dlHOXp/fou4/T8MLyo+NDrJhC/MeaBqxuI51y/SjAemi9RmLExLU1Oy4taZGE+H87go
         DM8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653826; x=1787258626;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Omt21ylp4oQgK/AHcKFYX3RubZePI0K3RsKVxRfm/38=;
        b=kexKMy8b2d46+JzUJbl7jlh88vvLVlOE78S59fNMKQufH/G2+M/cDB27gqXpQYQsv6
         isKYbph4cxLC6Qe0Ck43nkjtW1tCp+fwLX3IbSc177+T9ZPK9hVFh6FVoEAbYczSzMVb
         uHlQaNFKoq/66RscPzs+iHDdZJ3tNflaKzRFMPwugu0yHc3XtfjhccmFmYTrLaFveaQ9
         pQOwC2pSqQRTY/m0NYUmGo+qg5KT+9fN5vvlFgJsdh8UG1/sDGHL8CaUENhkVgtR1+g/
         V2J9MoVQi4cpqWpOev7SMQX+7Jy0HkLNbyHC6NuMK0rXw3Z53y4/QRMVjd87xOxVT0nf
         lChw==
X-Gm-Message-State: AOJu0YxE7wkQqF2bzVe55NG+xpnIXpY0cdKoIN1nhE441Ttv/FlnXqhQ
	q0PWauZA11hg1adgNEKbKkjJfGAoWxX1xZFcAuqxwYtTyI8u90LC7qLA1J73sZsy6gEU8lHlgcX
	ZCoqg
X-Gm-Gg: AR+sD10H4iYuT/Gkx4xB08VVTPGKiHSmnzpU9IH0bbPb2+txz3cWLmH7KKVd39jDNX3
	vpECG0ycH9MfFiSNwYNIrq5oLvNMHLF5Hi3Qe+/f5b8b6KGORyRGUx0HbgJVe+8h+GqpSJOBYoG
	tbptQSwki/8qHtrnrpHbwc1JeX1JNwQVdiimUliwaOg6ayRYUGFQ9vyGf1uxFYB1X0vrQKpuyJ2
	2cLwqu8+rt1SINCj0RMuR2sXBPo3liZfwKAeKNg9bHUdRtmjrumF88uasEiIe9KZVIi9d8K1FEf
	6mJNgU4JzuHkOkyC8f7L/uUCgYLidy46929dMU3yIdczp0y5h8NF1w8f9UEf87GpKidzxVUr8lQ
	QazwOk650tDXX0GqsPWhw/wQCbqehzW4wJUQtjF/y7SFubwP7tt7bRXkxfsoFsYOH1QihVcSzH/
	xTk4Z6yMAYmJeFI5gpk4/O2bV4bS8s+11IBqcgB+bznyv27jvLIVNBSbNnw8IOWESQLV65n/E8x
	3qA7gkYa6nuQfs77BnAmAKl
X-Received: by 2002:a05:6808:bc4:b0:49c:8a0f:f9e2 with SMTP id 5614622812f47-4b240456e0fmr551201b6e.17.1786653826096;
        Thu, 13 Aug 2026 13:43:46 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:45 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 18/21] NFSv4/pnfs: Grow the deviceid cache hash table
Date: Thu, 13 Aug 2026 16:43:14 -0400
Message-ID: <75f92269fa1b13ee6512f66b69ec9148010c764e.1786653063.git.bcodding@hammerspace.com>
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

The global deviceid cache has 32 buckets shared by every server and
layout type.  pNFS striping deployments put hundreds to ~1000
distinct deviceIDs in play per mount (mirrors x stripes), a load
factor of ~31: resolution and re-resolution bursts walk long chains.

Grow to 256 buckets (2KB fixed): load factor ~4 at 1000 devices.
The existing byte-folding hash distributes fine at any power-of-two
size (the multiplier is odd), so bucket count is the only lever.
Alternatives considered and set aside: per-client tables do not help
the headline single-mount striping case, and a resizing rhashtable
is unwarranted for a burst-only (never per-I/O) lookup path.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_dev.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 0c39ae8325b3..e09f25a26004 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -40,8 +40,16 @@
 
 /*
  * Device ID RCU cache. A device ID is unique per server and layout type.
+ *
+ * 256 buckets keep chains short for pNFS striping deployments with
+ * hundreds to ~1000 distinct deviceIDs (load factor ~4 at 1000) at a
+ * fixed cost of 2KB.  The hash folds every deviceID byte through
+ * x = x * 37 + byte; 37 is odd, so the low-bit mask distributes
+ * deviceIDs differing in any single byte perfectly at any
+ * power-of-two table size -- bucket count, not the hash, is the
+ * scaling lever.
  */
-#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_BITS	8
 #define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
 #define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
 
-- 
2.53.0

