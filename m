Received: from mail-qk1-f173.google.com (mail-qk1-f173.google.com [209.85.222.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D23650AC3D
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540810; cv=none; b=Fk2RO9iW8nTUct1c125Vyi/Zz7muoxKaI4FH4WJHAcHuvaBhdbGy6WURYRjTN2XMFWKdqVQi1kEp5L2q5bAPldxEjSAUvr+1hRACfQV80vpbKkufxDodYXuBOUugI01UiV4jGtcvo0Ixs+5c8aMs/eL35cG77fBS/AO5iklbugg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540810; c=relaxed/simple;
	bh=8/LkbZltpe1muds9FtVTQxrUU/859tWZ2Nw2rJ12aow=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rLQp2kG/j48zuSbzExnIKKrWyMMqKvPaWRDihwx4Z/jVEq72ulxY68jb0+U+hypZFJdvmsNm3iZYMmMTL2ikEdOV9ikASvBqLFRBVASbPINmBxzTV1baNRPBNr+fap4gMqymDHzRap5KnHX2XFb/WMZSBoYPsfQvhRFwIc2HzJ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=j31Goh6y; arc=none smtp.client-ip=209.85.222.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="j31Goh6y"
Received: by mail-qk1-f173.google.com with SMTP id af79cd13be357-9377f717879so77249785a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540808; x=1789145608; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IHdbIheE2uWjB889IxsFeSKw2QDXTxO2nQxLG6ECF+g=;
        b=j31Goh6yadYAPI4OZcaNz8g26e03T/WZlMmZthUhl53BevhcwgO1P07BUrIxPvPEAi
         GgPIvkczm+ouayO/lG3qhOSM8cfUdJiRoV6I6dOuh1Y7fhw7pYyaKYNwuh05Rjfb5Zib
         YOBWn3wWYksZaSZetbKqz4qiyOoIGCh/gXnXtpO18iMmflpx8w1WRLyKiUOwjoquZtl0
         DOzD3Ptqrp0gUd/NcqxWxvj8tRGprEnAV/1HlzDNrMOunLs43biGbcRcAir9AEyCiphg
         CP1SjhcHZGr65357pSJLn1m0NpKJNigEfKk4OcTzGMRrwBG19dH+/O+mkFxQKHCO0Ufr
         PVyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540808; x=1789145608;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IHdbIheE2uWjB889IxsFeSKw2QDXTxO2nQxLG6ECF+g=;
        b=kqvV+Ta/hub73GcS82R3B9FbWjxyD7L/a4cWzNey2I9q/nctdCxJ4rcPd4FmXtKaN0
         MFbEM3H0rPM4uCP1pIKCmS5tZM13lydjpaVRyq0TQ15XK3bLgba5ODACRlag7I13jCoW
         STakLiLBm3kaQwML9B+fqeQO14oD++PLKhfVhzV0EckLv/NJj6VgNRG1t1PEUAUHS9Jl
         JSxL/YMoto0BabjyQYgnwQ6Y2uftmHHJVCgzmJ+HG5FNUrx48+U9jP1O0oNS+J3GUA4v
         eN56cB0PvyUMJuYIDL1ef7dkEr///W8ZfpA9H5kl9MSSJP34U6fkJiLJZ47Q6b3tEhRy
         0LQw==
X-Gm-Message-State: AFuF++noxjXvDFnn4CHfJfnsHUTBUPxi+0pWA/pfUdrM3klgvN00cELY
	vBBIH0YAOAjGEoDGZ/+wX2Hr1L47TX5shTwmeiUFWOWFLWFfmWQ3tvI/jANjr1g3goA=
X-Gm-Gg: AYBFou2kG4F45QLPlQv2Ng44lTj/D83DQFPXCTP+T3y3ZQWDLvjMjw+f/gph9AXKNKD
	05sId5EpEq7Q5jt81kpEIJauWBhpkIJZQFqs0Ya8nTUBPO9vB0CGnaiMy1naDPuXOfm3lUdBjCz
	J9mEi1/C68KMkzEaOABlSReaZ1NjW6TUcRi2zaifqNKc2gQZXI+wZD84TqU2sAw9QQUagsso/2T
	XtXvIPcQiEqhLDbHia4Hu0STw+1oN26kFidG5ZVvQ0DccVzL82rnS4Quc0r7hWsHhFiY+rNFLXM
	NuTIq63N2F9vj4eyf7dtK53iu4FqBP7YagotVh7MjZczxenvZu6cLO5Nxa30fwnXIomb+ewsHwL
	xYVG8DmDQMdx969que0m0qZj0bmiyuuIaE4/J4RJpiHuRvxV44dMlS6i6TqB/uMvS0Gt4itSQWA
	jbDAKWGNalwadw5NNmFno3PMBmOj/M3ib/lpEY7xqHVLAdjJ3Tavf1GXYbdpgRcNMv7UA8+dq+1
	JPwGhcI2IU7EMXvmu4/gwgVMykMBPqGh2Q=
X-Received: by 2002:a05:620a:7111:b0:939:5906:8060 with SMTP id af79cd13be357-9398042befbmr761343485a.25.1788540807886;
        Fri, 04 Sep 2026 09:53:27 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:27 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 03/24] NFSv4/pnfs: bound the CB_NOTIFY_DEVICEID array count before allocating
Date: Fri,  4 Sep 2026 12:53:02 -0400
Message-ID: <a4a3e33604e6c29d215bf2ef81e4fc6ad350cf19.1788530385.git.bcodding@hammerspace.com>
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
index 88e1af0fda01..b1bc2c02b5a6 100644
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

