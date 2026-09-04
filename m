Received: from mail-qk1-f171.google.com (mail-qk1-f171.google.com [209.85.222.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A6CC50AC14
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540811; cv=none; b=QVLxB1cUR3W049AOUJ0xlnX5MuKXI1liW/8/PzqJEZ5cPr940Y0A/WIRihTDcLT9MyX5u3bH/yMu8fpSzDTSADqA2w/6XIjKK2lnZDfvp3+lVAGSZZQCI5o5fo7C6STFZjddevmqqodsO9p/vq1/UyT7jSpW1vAeSvLRd1BNU+E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540811; c=relaxed/simple;
	bh=rMxNuG1j+cuZMcGBsjm3J6+c/H7kOhH6f/IOwhWVfeM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mx/YOUYaCGfsxRlZ/mFKh2b0AWjZnNV4fNDsbPw3rdZDdSszW0W4njfx3nTsM4mNPR/vtjJNzFKdCnS9ij7CWG8OJfe7oBGDkrC6+mlUkfWjCNjS5KT7AJzwHptCalKkTBLW8gC2+9liPH6ZNLi3R6twD39O5iKQkr/HIzWRLZk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=KH5ITEMe; arc=none smtp.client-ip=209.85.222.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KH5ITEMe"
Received: by mail-qk1-f171.google.com with SMTP id af79cd13be357-9390f8a1c9eso81824885a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540809; x=1789145609; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FbwfmcQHpt9ILBq0YzZZ2JMYeFnfCP65xC+vbrXSm2I=;
        b=KH5ITEMefL1Wrsl08vHiwhBMtkPA+tAViih+/GgFbZEviZIeoIUfm0SeWDoDFCgUEg
         8OO59zBZeordsGH0Goj5vaNiZIefEx1E1BwgjjKR95eYfhpNCzXVFOHbasWP3kMDqsov
         //Msf4YH0ptWXpmz4E2PO3JlW7ifu1nAJ2W0Vu10OmS6JwOT/qczYX0r0c87R7kMHpJ7
         whjzDhLmELwpNzOcE4oofkdC+R55N6VpivaPqWJyc73CmwhLqArSmNmdI4e3fgEyu+l+
         Fr6WwQfPoxmEGxI9JduTro/u1xzNncYs/DzDDfbg05dqth5Qs2oUDuooaFkH+1IJH0Kn
         IVgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540809; x=1789145609;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FbwfmcQHpt9ILBq0YzZZ2JMYeFnfCP65xC+vbrXSm2I=;
        b=SV80+yYggcr+hMDGlINQ9LIaqAPQT4Xsi8oxU3spY/PX156oKyASnm6GZaNwFcQ7v0
         0Ev8V1izWbq+GLjRZtq5uRIr/st4UUzU8G/3z1D7WL5VhwS2Rh16QFZtHlpb7BL2YQRy
         2+gsZO+R+KPz+1pM+Z00q26GYEoYM6txKDQH4Oz9046v73hk5nMcyBpS6XQWtENuzEFI
         UQ56zeGR43kqnfdf056LCJAixDJP8PI7ccsTwUWUeEU+XK6ShreRqNf/y8y32DyfKpM1
         QafbrZk8TRQ+c4PYXc1Ab+RDL4d1ReB2tvJkRYAutpI+gXFgNcJDLJpOkjA80pNvjfUZ
         xDqA==
X-Gm-Message-State: AFuF++kf+vg6pA9gYzINdTzkr6XjOtKffC5WQWMs1pOgBOPF1L9ElXFH
	tvu+1uzUxoEw3FDw6k4jEbFMwe7bN7HHX7SbIRhOaIj6Rv5zd0F95iHKaoWzhe5Zu7U=
X-Gm-Gg: AYBFou1iOBXoAYDIBhm7xwgGSttPFQcfAyFPYjJOYWYoaqI8UNh95N+As9apOUNv6NV
	2qfaq9zj8KYqmmrBI7rXrafBAg/HV52Ol6Zb3mhKOuWHhc80+EF6aovFOAxW7axoMG1qrkFpEej
	4YmNyu4rVbuo/sbbGtz8ddAXkLPUEQ4a3F0muQBaxC8X4upWf4YKrTi9iC2fXX2+MnMgQKp6nJt
	SJdhK0/l5wz5qLMp71Rh+xaRitOkfiQY6WXGaVe1zIxGjtG4KHtXt0A4rA1jmhv9fBAYVMW2pf1
	QmJprSeCSCVCTIQe0S+l7ZieEzOFm+77EIgEBnPO/Dp1AiKmZPNNt6S6FK8jZ2tUU5FmrTA9NvO
	Drft8JPeu/7VlwCEV7aGjD0vOU5WE47YTsddvNI2+vjKXguZd5Tw0PveMmDkHwW5IzhD4BB2zAj
	sTNcl4/OinEf5B8WH202fBiqsBO56mKKQ9hL0d4UW61S24/vYykP095tPE2kZUO8dSh5kq81SUB
	bfkjKotH68hg4pARx4tpRf0
X-Received: by 2002:a05:620a:8ec7:b0:92e:bbd0:260c with SMTP id af79cd13be357-939804a38c9mr460850285a.36.1788540808659;
        Fri, 04 Sep 2026 09:53:28 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:28 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 04/24] pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
Date: Fri,  4 Sep 2026 12:53:03 -0400
Message-ID: <ec888f9f1d2e0e8ab8a11b988e06225e6296b020.1788530385.git.bcodding@hammerspace.com>
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

decode_devicenotify_args() gated the trailing ndc_immediate on
cbd_layout_type rather than cbd_notify_type, so the flag was never
consumed and a multi-item cnda_changes<> misaligned after the first
entry.

Fixes: 1be5683b03a7 ("pnfs: CB_NOTIFY_DEVICEID")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index b1bc2c02b5a6..5a1f05469268 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -319,7 +319,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
-		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
 			p = xdr_inline_decode(xdr, sizeof(uint32_t));
 			if (unlikely(p == NULL)) {
 				status = htonl(NFS4ERR_BADXDR);
-- 
2.53.0

