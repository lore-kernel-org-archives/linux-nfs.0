Received: from mail-qk1-f171.google.com (mail-qk1-f171.google.com [209.85.222.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C7E14E13FF
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540826; cv=none; b=eP0K+IxLWwACXA/CglwQIhuFbTZmbkvWD7/p0gH+i+bQMw2TFItzWzswU3k8rYu2WotipY7LZNFHnc3/p587ga4xtKGpx03xFawBxr8LLyY0HK5Izc8l70wX35bp4UEuRCJjziRc8ICvpCPO+q/Eu1i0VEWaTcBZuSppTlLvDO8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540826; c=relaxed/simple;
	bh=uwyW9w/1ZciAbVAqAmY0cI45bHrXrtOA8e0h6tY65/8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=afPcT6iL+yTyysbVb/GMTIdyR6CNru6efu1eN5q/8AESpdJVHO5BVeYkBUi00mmX5kUFw4E8gRsD1HL1tJavePOT/TznZFpMOW9ZUJSkXQiSVJnEXu68QmDV8fsupm0pPuTF8MVhQwomn/8p+UbaA6UrS2ITZDdz6l0BKwzc/w8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=R/xIdfCv; arc=none smtp.client-ip=209.85.222.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="R/xIdfCv"
Received: by mail-qk1-f171.google.com with SMTP id af79cd13be357-938cd95b06eso134075185a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540823; x=1789145623; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=R/xIdfCv/TffHaDOMhzZDrRk04am+lTcr01FydGWyL4vclvUzsaD6DeZY98waqdsbO
         66i7baz7ArhQODx69W0hdiih46Bte6AoDg5SYNlYvPNr6Zj/0lgzo8fqUnd3+6NT1quJ
         tvinRPhR/WjkDXGBa23glHtLpVbMDitCv63qORdJozMIVzPAfFZk0YPr60cqRYG15ePK
         CzOJCfAqD053D+yMAHdTfHR4bew9FNSpPPx1gvobeWpstyYGKxveJTorq9q3n0Fbau/g
         yojrJSpxaiNvvhyHkAWT61M0qDOKCM1zECjKX6HsA8MFSWC3e8h3uE1t1jGUBjA9H5Ui
         nMZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540823; x=1789145623;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=IKMHTegNByTHL8heewKRJKekF7dQR7LTGBsDD8pPqgle58G0zKkYJ0PPWkd/xM/rPg
         4FHg4UpRo7cpSAdxDu96jx8oscfW4Chu0SVJqSzRLrWcDusOQP6WPW9jvb07SLbOX4CS
         EmnUC/Rob0dFizhgvZR13NRDU19Uakv+IkZuz86asO14rWIyw2M1tl6YIthvcfTcwghQ
         rFJAsrlgEEODjdz7/pZbAlT0LUfLXEiqHRK4lgOy+z+gi7iEmWjloY/ea9ZTBcfAydsH
         sA0cN26Yw949g9dbY+LZN+bf8FXbb6MYiYryaZLqCY3nAidOrSSU7ZHJqoxiamgM7xrG
         4eCA==
X-Gm-Message-State: AFuF++nA7RjxySDlnuKq7AqQLhXdDv87Kq7/GbZhP8LATeiCE/hewMtM
	a+Tobs2cwzDl725cod/sFgovS2JQL+qjRcZKgJVNs3F+8yl2MEY/c8CaSAEBKH4MI5U=
X-Gm-Gg: AYBFou2riIfeA1cVDbrZgLkMvZ7M1s91f0AZopJ9Se5uVDhjsEmXE/XLWfIf70STSPn
	+cqYCN75z5G1ls//CYYA19RHL9cY4VIy/C70e/44Zns2q80MPbqbcj71mnUO27goo3n5BIWGA91
	3tTcQ6sdQ3UdRKneQXySfA2JpfaCH2CAuxcXI4lzn84TJbJmpKtxmR2tXU9Gl8XPIqk+q+lx9/Y
	LExfCcHEeuPiIaHnB32nrky0VUxCK5o8Og+6is3yTYXGRlLZk5qouuHxkDcW7swElWabx+8jYNN
	yNp64GJEZEn5ksJRfEj4BlwPWVVoEYf1YAC2U3ON/h93G5jhqnIRfkAzRTA9BXdpXX6ZsWKKLrw
	17LEgV7obVYTcw6XmSW1zxYYPhq+8iXptGFf0BvOBavw3Ko0DWrZwtcC5dV9Jwq4w4dmCxs34sD
	0iWDGJxQuqDGikMq7Lk9+PZ7CHFWTAEpeqM0/OifGh5pXN8/mmMYStHAyy+3GGtLEdGBeaxbubr
	xIPx+Ds0ZgUSAnW+rUHj6Yai+fbS3NxBOI=
X-Received: by 2002:a05:620a:2257:20b0:939:8f2b:37dd with SMTP id af79cd13be357-9398f2b388fmr44767085a.24.1788540823286;
        Fri, 04 Sep 2026 09:53:43 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 21/24] NFSv4/pnfs: Grow the deviceid cache hash table
Date: Fri,  4 Sep 2026 12:53:20 -0400
Message-ID: <b57232b3d0b4b528f8a3433a6d59badb47c37944.1788530385.git.bcodding@hammerspace.com>
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

