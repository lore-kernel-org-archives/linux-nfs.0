Received: from mail-oo2-f39.google.com (mail-oo2-f39.google.com [74.125.231.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AF9A4825D6
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 13:42:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791207741; cv=none; b=MiMoGuUD3y/Mj5SJR5PWj7CD9FpYcBbMnHbWPAjE2FQtKjeAIEtU2pyheiTNZkt0N1gehXYsK4X9dO4Vp4ICL/BKPdRxxO9mkSh+vyVSaH4u2mzo250Cxc8d03cNtJIht0EtHNd3LULD5vpQzvxdSaetfGwYhIivHK6M1+JAnZo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791207741; c=relaxed/simple;
	bh=Re6cOzUFhiyrPnauoonJwiDQICTdFsN3wIqjBA19rI0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ofyu+CE5mAT+93VLoStrVe+vp1gjNEftX197vMhuQ0Ur7XTYi1GLBB/AVQrsBDFHNgtWGEXm5mAdGVFNxYGMB8lkfD3cKCaRutocXQ4+Exx14S2nfhuYgU4SuXTfXFMoA8w7SfHGbED20pMI4n2gmNj58I9OneM8F+k0Cr2Gfgk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=VbEYEt/H; arc=none smtp.client-ip=74.125.231.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VbEYEt/H"
Received: by mail-oo2-f39.google.com with SMTP id 46e09a7af769-8247421d2ebso879156a34.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2026 06:42:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791207739; x=1791812539; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=vH3AEFCvJT6EZZSqUtWZ2BR1dzDToqzlbbxAFZxQ5H0=;
        b=VbEYEt/HWuLUUKcJgkWpKzNqb/hqzfGDkyS7SJOd4ahtvnzN5RogTNCsHwcIl7RTuW
         yuUmtfk0F4FqL8ZFQ65q/s6GtnsVn2UJeF0i4gtUL350nRt7AZfvnrhPjArPksz0Op64
         qUoBnJ0nKqHptn4h++yG/scmoyGTbNoWmawbS2N/3HFVVdA5aKhTlHxjnGpTZzszVoKt
         3ZqDFp7V4fXNSQrbEsJkxFNcEjlCeh3mdRQyqG35cIJ1chZEEp8uCvJgVuipy05sca6q
         R1kLuiB89JNy8cgYsN/v3MD/4SGwRECmr6uExxK11x6T1ynD8NLwTZFIqZ27tgHPMKMG
         5JLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791207739; x=1791812539;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=vH3AEFCvJT6EZZSqUtWZ2BR1dzDToqzlbbxAFZxQ5H0=;
        b=OqwzHdfID1mzLKfloTq9+1ujq77Pge/Grjq7JWes8KZcGxGyffbX1TW3tEssfFZq3r
         Vm7ByzgvVVOuK0c+f4rMGqP1Hjq/3LMuJ7I2NGzHvBYds0x0n1vfgq1g2XEbhxOTPAS4
         OZlJf9+TKJ4y6KtjVl0j/vb6Yxh3UeBCPPbp4VImW7RAOKSMuhogCmF9+U+RNFDvKx/R
         3fYwSp0QnUzLsuITLe5H3iL57XnNqW5Cn5vKj/LAUiGKSNg5fKHGQZuZl+84PiNbq2z9
         w5YHXe2hmtODSo4h8Ub8whtO6qQINo21JxHqbWHh/uAqYUFdpKEPTZoWt6BanpM4/9ZN
         eE3Q==
X-Gm-Message-State: AFuF++mfrIdPPIsHiscpow/wPY7ICYlWmFg9iCCakEmGz5qtL6OaKrd4
	g9rUu1UaTnvR4niVY3wG2VlhkoSaNnvfvAH4sbwrurTsULj6cihGw46wqQaks3OwiXE=
X-Gm-Gg: AYBFou2cZxZ33fIimBzAzUcmJpwb0oqBb2bOLUBptrYZKitMkZ4vJtcNRliQyfMDV1t
	Zjh7JZlvv2mOW+qJ9iwkAFa9F9dy5wfoudBe/YxZLph4KadjbTgPHnMx4Ls1uD8lAoPyAkpTdmo
	GKP6mJKW4XIChskBIvUL7Yp+s6apGg7d/Ctvaa/JMB1kNnU8vapCKLWO5yQYwWz2nhc+Q6E9Ggb
	My2p25dpZn9Z6IATtpAMvD8iE70MMRVN3nCGuLV3qYAWA9qSMUw2t+SQ13J/uJKLp5hdrvwrTP/
	NZEx3fpbB3mc6YpDoUX1L37kR+R3MxAu3WB93s7QvedUr82by0I/wn6Jh5FVw+kHZS1JcfhW3YQ
	Ggf101wHKLquYaAYdLSm+BI4OuisI7ktH6ry0hQaOEqqCmK0XB9HQVLLXXratvkx39Zn9rg0JPR
	dOLVSxbpuQ6HjJby9orb//zjHTJwCBspbDZzutkaQPIGi5+MlK3cQFZ7g4gZTZD2++3T+ANzSU7
	C8tCs82gSvWf5cMfcRuHmbdAv3y0Dive2YioI2pQA==
X-Received: by 2002:a05:6830:2584:b0:81e:b1d2:95f with SMTP id 46e09a7af769-82283486c71mr11274038a34.28.1791207738902;
        Mon, 05 Oct 2026 06:42:18 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-82279c7859esm11946183a34.13.2026.10.05.06.42.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 06:42:18 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: wake a thread after re-queueing transports in svc_clean_up_xprts()
Date: Mon,  5 Oct 2026 09:42:16 -0400
Message-ID: <53a88892df121e5dfd0d046c2ce58df43bbf93b9.1790963561.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

svc_clean_up_xprts() takes every ready transport off the pool's queue,
deletes those belonging to the network namespace being shut down, and
puts the rest back with lwq_enqueue_batch().  No thread is woken.  A
thread that tested the queue while it was drained has gone to sleep,
and the re-queued transports still carry XPT_BUSY, so the data they
receive next cannot enqueue them either.  They wait until an unrelated
transport wakes a thread.  lockd and the NFSv4 callback service share
one service across network namespaces and wait in svc_recv() without a
timeout, so nothing bounds that wait.

Reproduced with lockd: with NLM traffic running in the initial
network namespace, mounting and unmounting NFSv3 in a second
namespace takes lockd down there, and lock requests in the first
namespace stop being answered until something else wakes the
lockd thread.

Wake a thread after putting the transports back.

Fixes: 9a0e6accc0a8 ("SUNRPC: use lwq for sp_sockets - renamed to sp_xprts")
Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/cover.1782314746.git.bcodding@hammerspace.com?part=2
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
Changes in v2:
 - wake a thread whenever transports are put back, not only when the
   queue was empty (Chuck)
 - description: drop nfsd, its service is per-net and has nothing to
   put back (Chuck)
 - sent with an in-body From so the author matches the Signed-off-by
 v1: https://lore.kernel.org/linux-nfs/5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com/

 net/sunrpc/svc_xprt.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 0de613b36fff..288d442f47c3 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1246,8 +1246,10 @@ static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
 			}
 		}
 
-		if (q)
+		if (q) {
 			lwq_enqueue_batch(q, &pool->sp_xprts);
+			svc_pool_wake_idle_thread(pool);
+		}
 	}
 }
 
-- 
2.53.0

