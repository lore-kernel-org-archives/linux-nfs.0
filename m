Received: from mail-pj2-f3.google.com (mail-pj2-f3.google.com [74.125.227.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB07C3F6C59
	for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2026 14:24:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790519088; cv=none; b=RbYvaQS3dLhtaiG9ax2hlkwNFskWchiHJs0Qk5aQgluR8XqtbrdITTD1WfszwORZcC5lNmsZlDbD10MUU5Sd1tfp3KNfZh1tFX24Ah2rKgeVc46V2QxtgQtG3P/rUOPv4TKqsqFDGbpAPH3Xbo9RatAJeGIdmmVySRog474UEbs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790519088; c=relaxed/simple;
	bh=1B7kYapCZpPFtgUkVhWVPxakfdU8+qYYCL4ZQ9DMlQs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HV3lc/1O8dXW248pvoYG0FkEctsdmMt9efPd5ATrqnWKYwgGO4K151O52SN5cRXF5feZ5O3zwFU73hBdvnwHVGqJ9C0ZL54s9mDIZJBDdbxWHXEf7UpNsmQbXG1orRPPiz9IWUDRHWgGfPe29Bag+btQf6hFT7OZL+mpkhyGrOg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=LARR76NI; arc=none smtp.client-ip=74.125.227.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LARR76NI"
Received: by mail-pj2-f3.google.com with SMTP id 98e67ed59e1d1-3a0cb6b922eso732662a91.1
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2026 07:24:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790519086; x=1791123886; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KoReSBu918TC7LfxH4R53EGW5VKxOHQwVKQfiuCg6QE=;
        b=LARR76NIMKliW+yUa2MyOaK8oRYVWAkZPm2i+R7j4X4LMZ4kFCxO6EY994tiaMQOkE
         p7flM/DSgQU4OqZ0nIoMd+IjrwxvajwzTeR56LKp0+/AUgOw/4Rs5/JA0dozTDYHply6
         NbRl+G1iqio/lznxdP2zLBRf4uVWcY2blr7OI+IUw7R3GCsryblTDaQESFyEB4nE2Bis
         Xu+c7DkM2nOd6XK3eBk2VB5uCao4t1QFnpkbUKaaN0x9uvwb7/OSTantAavb8UMiVPEA
         S7hhdK9AoLVkMlUL9YluFN6CDUTNfNlqYBVkwGSw4FRW20NA4xySSLXlBbpRdNFOvwsc
         kOJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790519086; x=1791123886;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KoReSBu918TC7LfxH4R53EGW5VKxOHQwVKQfiuCg6QE=;
        b=PqCeiEfOdAruU4G2GdFAA2QnMQbTuoF1QYPoPXsGmFae//HWxvaRt4tlRrin4eTkVf
         LekNC00qq8TiO/cm+thuFQfPkxJEMtXh66ktrmVEzPqhdsCkgt3y/MRExGUF3Hs9cvMh
         o2sURpoUKd30GMQTClUdd9lPDXS/sz2fWy/J/V5bDfRviO4q/xIJ4PfcceoGzZL/IAHa
         lqwDYaSciT1J879Gaq8tz+cCq+uUMgWBNZ7NypK35BzqiGKC1kmk8ghFjlO9fG0y/CNy
         RFwFc+ibRsybb9IHNnFHbq58tWIldaxvsJxDprPAS4nXwZ6GC7vOt/I2LGyqzumCGCqH
         n36w==
X-Gm-Message-State: AFq9FYLv3VJdvfEEh7VWCqdz88i0gd9NnFYAk6bek/4ppOqihEZ1gOmN
	2qngU7fi2YrrDjqOH2zwwWz2+thCpusqx+C+s0LFkh/NqIh7LrkM5QMg
X-Gm-Gg: AYBFou3Ztrjl4RI5K2GAbOg4gRkBF7SIIoqY/SVBKJjv4CvCfHu6gpLPbo8sUOY3OaG
	Kwto1I6NhDuzlulQwQ6s3XGS/sN+AOWhgtwdQS+A9pc0rKEmc/8dSso461Z/PHrVBxlzxlc0MVT
	YFqjf8FvlPnALnKYcQ/DFOw62D8npP/XFQ5GYKtn8gRITzXxwJiXSNHynXqojpZ4I11VuvwUJj9
	fto+GAN966WML7/kh0kvCeO+CauvC/ZNR5mbyeNMSMXTt3GuoQp+NNFPrgJcxjQZ95vRxfCKjnh
	VQ1Y/QrhoE6tjHgkvZYZ3FTobAX0t24hLGL4Mld/onAqx4CXXxhARuOXbKpi3hxegO6wQWoF1/F
	psh2QuBpOpjor339ifQsnvRajzTCtDA900CnFAMk3CI0Qh35p9F8845cZG6H8d1QrXY1x4SX6zl
	C+TyzS3HF1UTCKJhI+5hw/aX1OdMa0RgFHpwaNrb04cwHTTBfsB3pPZTR++bmFBlb6evbqEyLLt
	8FMhHluhw==
X-Received: by 2002:a17:90b:2247:b0:3a0:ca03:3e1f with SMTP id 98e67ed59e1d1-3a0ca03447amr4203206a91.32.1790519085824;
        Sun, 27 Sep 2026 07:24:45 -0700 (PDT)
Received: from LAPTOP-QJLDGQ2L.lan ([47.82.103.134])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0b9892dbfsm15424701a91.11.2026.09.27.07.24.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 27 Sep 2026 07:24:45 -0700 (PDT)
From: Boyan Liu <yymhvert@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	co+7aebac19e62711ff@bugs.sh,
	Boyan Liu <yymhvert@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] nfsd: Fix out-of-bounds read in clientstr_hashval()
Date: Sun, 27 Sep 2026 22:23:19 +0800
Message-ID: <20260927142319.12054-1-yymhvert@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

clientstr_hashval() always hashes 8 bytes of the client name, but
since commit 6b1891052a3f ("nfsd: make nfs4_client_reclaim use an
xdr_netobj instead of a fixed char array") the name is a
kmemdup()'d xdr_netobj of arbitrary length. A 1-7 byte ownerid is
legal, so the hash reads past the allocation:

    BUG: KASAN: slab-out-of-bounds in nfsd4_find_reclaim_client
    Read of size 1 at addr ffff888010acf1a1 by task nfsd/141
    Call Trace:
     kasan_report (mm/kasan/report.c:595)
     nfsd4_find_reclaim_client (fs/nfsd/nfs4state.c:1622)
     nfsd4_reclaim_complete (fs/nfsd/nfs4state.c:5286)
     nfsd4_proc_compound (fs/nfsd/nfs4proc.c:3313)
     nfsd_dispatch (fs/nfsd/nfssvc.c:1038)
     svc_process_common (net/sunrpc/svc.c:1527)
     svc_process (net/sunrpc/svc.c:1682)
     svc_recv (net/sunrpc/svc_xprt.c:886)
     nfsd (fs/nfsd/nfssvc.c:919)

The hash only selects a bucket; compare_blob() does the real
comparison. Hash the actual length, like ownerstr_hashval() does.

Fixes: 6b1891052a3f ("nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed char array")
Cc: stable@vger.kernel.org
Reported-by: co+7aebac19e62711ff@bugs.sh
Signed-off-by: Boyan Liu <yymhvert@gmail.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 18e17232c..6c50286fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1619,7 +1619,7 @@ static unsigned int clientid_hashval(u32 id)
 
 static unsigned int clientstr_hashval(struct xdr_netobj name)
 {
-	return opaque_hashval(name.data, 8) & CLIENT_HASH_MASK;
+	return opaque_hashval(name.data, name.len) & CLIENT_HASH_MASK;
 }
 
 /*
-- 
2.43.0

