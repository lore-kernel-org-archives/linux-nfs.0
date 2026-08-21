Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D9B3493637
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329773; cv=none; b=kuhjA5/tvbegu9PVN4LQb7ppPi8JMsdGyGpIQhLMTPBo9VDAvTR9c+E4yMnBMNHkVdQ5hAtN3sZeM9maSP6JoWdMdbIAiq6Y4dNCG99HEYK4fatLvHkk7wWPvM6VC38RXrfoMF3ilA+GnwE35VfUHZI9ElD2xAiSNK38ZLstUOI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329773; c=relaxed/simple;
	bh=HYaOoKy+FnhAiKd8hbB5LUH4cJrkUaqj44CQiOe/JQE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sidPtkO4SYdh0iPks+wMamm13jA12651gxu8IFJD/2OdOCC5OoxipDbrNECbE9A9ix5iM6p+sb9vSV5jbvZZIt/7lGtvJFrVsI80Vzv/eAlvyW+bFVrX2A4NVhygBMfa0kYZQZP7GvLarF1nNnOlKEZUCBXAPiURWpOvxZDPTJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fGvekEBW; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fGvekEBW"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4a45b3f0becso1130323b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329771; x=1787934571; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=eTETFHL9xQKR5P+AfRsuEB1dZ7O7yRk11OHcyc8vX/U=;
        b=fGvekEBWmCKsgItblMcTuR2WOphRfNStF65nxuVxFpF67YIpAYZxSLUUvLMSIwETWI
         kLYEWJb1iRuSbJ6D88eDNh5uWfe2VLYzyb+0V8BXSwu3Kes0WPmQsXoLsv+Jl/E+8qQj
         NQ7WHF9C12XgtvG+01EoRvKV0Ul/IQp95YLvolDK6sEnj8s2V+pHKBFGaaxCFtt7j9op
         t1UHDUKoZeJ3mS63C2NxaN+eF4Z5cvaIAL2a51nDdYhswnkhVPNViuQ0B4VEmVQicVgc
         JkjsV+CgOM6SNkqSXKytZF1lybFjQQmxZWnIYEqY0W0O/XuHtp4UzcdGNplKm3W1jDPq
         yK4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329771; x=1787934571;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=eTETFHL9xQKR5P+AfRsuEB1dZ7O7yRk11OHcyc8vX/U=;
        b=OdfKKP9N5KHUqrbVSNyhl5MphyYgdySGNhEdS/lCtLJ6txT1FOQbxH2zDqzKUh8eNz
         wwFTaBdjUv4gwPCI5ekO60WnCHc6Lm3VF6EzEf/eobjIBkq6DH/SkP9dzwArRC9Iyj9L
         9/ebsM5i56Eg3Vb+jxedroJmZayqeZi6OEfmflSw30/rYs70PWnC38jMdEMiD0a/U4hG
         j+crr70I3BbN2foOaB2DJa4yg7sTwGQiAnEkL2Kot/+DM5g4/spP/FFz0xfbuaLYDnDs
         +GHlKgO+iBkL12qpCo7LaP/PQkx5fJUXkiu8z3SH33Ciyiih4VCP6aDvRvyyWBBJUJBh
         9aZw==
X-Gm-Message-State: AOJu0YxLavnby+kxuM58E0XDarON4o9sGEkWgLMfQ2JxtCmx2kV0qFpO
	XZbAPnWdmjXk29F2o58oFu2guRYi2Yy9siVvUTwWBwhfEqHL1r52EPwV4XIs/MJTq1w=
X-Gm-Gg: AR+sD13+3CVzi9dyK0W90YeV1HupNFEsGebUz6thDIekwGQQN7Xu6xCNjHIyeKAY3hD
	vhI+svhsvzC3/ugJLacadtY9FmTUBbymV5rW230Sk1LC3WjOsB1+/UdSYvN/NL4H9fCtSBklcCJ
	mntmzSqXOi9LfSABgH8npu9/8GdOsWkYlx17VRXV6z/sVGm0AaNo4agB42gp8l/qp3VOdQP8UO2
	RkRvhUpECGgXMh1YC7IjoxYXc+ztPUHua5VzanI2Gnei+ZKVmYL6Ruz3dk8mPl4rKr7wX37jubF
	j0yBn66G74xlgTpV/BWEJ6m8BvYyQ8yq5uTEBA7rud2wxRmV/jnsQbsHnRs8+n8x2IqkmRwXeKf
	Tpa1XKaes86j8DFadqv4vr3A17TLOTrogJ2DItuAwzJjsHtB8eIlhaNZXiq+538N9djWhgg0Nyn
	VbhKm4XMlWhanA5f7Y3aI2IhmCV/fYxxd48Xb2fNmH3V8O31rkSlMG2DSt1JtnkoTjybnIWGc3V
	H/2Gyx4hv+M1c7SAbzSccA9
X-Received: by 2002:a05:6808:144f:b0:4b2:8d91:ef6a with SMTP id 5614622812f47-4b2ef2b9c38mr7237852b6e.8.1787329771237;
        Fri, 21 Aug 2026 09:29:31 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 02/23] NFSv4/pnfs: bound the CB_NOTIFY_DEVICEID array count before allocating
Date: Fri, 21 Aug 2026 12:29:06 -0400
Message-ID: <99d7b8043b5a609a9712e4bc40b4614088688f3b.1787327939.git.bcodding@hammerspace.com>
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

decode_devicenotify_args() hands the server's notification count
straight to kmalloc_objs() as the array length, without checking it
against the message that carried it.  Bound it the way nfs4xdr.c bounds
an attribute length, against xdr_stream_remaining().

Fixes: 1be5683b03a7 ("pnfs: CB_NOTIFY_DEVICEID")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4382baddc9ee..2d3d0f237ba1 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -271,6 +271,13 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	if (n == 0)
 		goto out;
 
+	/* sanity check the count against the remaining stream */
+	if (n > xdr_stream_remaining(xdr) /
+		((4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+
 	args->devs = kmalloc_objs(*args->devs, n);
 	if (!args->devs) {
 		status = htonl(NFS4ERR_DELAY);
-- 
2.53.0

