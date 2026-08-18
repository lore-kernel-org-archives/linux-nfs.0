Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAACF3815DC
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 22:57:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787093847; cv=none; b=PsCQhGJZJZloXQnpEUzH4VkfkrtcWxYWJFXnKh4mIx8W6pLM5djsGQu0X3S7Bn1kAjKa29RWb39/REyFyIYZU0s4AHOfrjKoNhVmFAwGp89wUlPoU5It23a4uOZD4usvpgXuXw622CiqCPTHfsEmAADlL+aW/4q/tyxpRFrPcog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787093847; c=relaxed/simple;
	bh=HTIdMGUHqS/osSpWpW46rgjJQbdTjfpN1jBAZx6ihik=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BShcaa131LDBsy7Ho2b1V6KPZQl483HEw3BbMRfZ47NzCkk0HvwSGNZ5v5EQmBFbCkJ1q4TxQfjIXU8ACYyT1BNJTs8aVZeYUTpkXGpTcPo0V+o/RojJfKzlEQy0Z4sGYOIqDIVWP6puvu/igaHr2/Ay9eLnMfXq5fkuMJri9oM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=kH40H3Y4; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="kH40H3Y4"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-4998e0916faso2923145e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 15:57:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787093843; x=1787698643; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=19HV3yb8dX6m7sjFj5qTXT28ekBXnozbu06g0duSsTk=;
        b=kH40H3Y4E1JyGwZHQDb/EQ98K1Y2ldgpzkQ0N8Oq9mvSVkXtV22fDsos9Bn3lx8FeQ
         Q4Lxnfe2Y582D3e/KYNo9tsuMjuz16GWG059yK71DXa2hG/5R+6YXnfNQViqAZCPHO7U
         Bep2K4/aXqSy6stYxPJjYSMgKSKdXJCzSaMmZdM5iNmyUANkL+ebkr5hBzLZr4rcQvza
         dJwMLHbFFs9ur4P133I/AkpfkW+i/IJ4W3hVpznR7h2AeQBEyiZl06Oi0WCPvROUryqw
         Zd2MbCy0Mg6Q3R8rEQGjo2EcTUlyQB8djEahO1nuTOHjlmfVmUxWq2Nx+Po0xZbe/s59
         u+oQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787093843; x=1787698643;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=19HV3yb8dX6m7sjFj5qTXT28ekBXnozbu06g0duSsTk=;
        b=GR0gIeIseLuOn50GKMliSn+v3adLanGwJQ2xpHzLa/yhmsrq7l8S46GZkpnylb9oFq
         MMOe9YRhaobRq3eK0C8Ffhv6TivI2y0fv9zhZdV0BNlkgD6AIbQ2bGJ2ZQgSYp4CqW8b
         0EemKWxJCEsywBxY1H3C40rzEBcDEw4inciUNMUfpePKSZapw/QDXB7ADSqbszAjf7i8
         vSuAgmjeY+4IoGZkFelX9/8yiH1/Lk2aK7l7HzccGbTGRNluASm0yPfinXVBYhasCzyc
         5q0UGvRYtME1vU/R4jO7iNfrqnYEdMAYSGdfrH+AcZcvWmAYrs4xkWtXN47dc3U8tfyY
         TEKQ==
X-Gm-Message-State: AOJu0Yy1TO2+QbYi+luxM0DCCJOxeprIZDWsQLa1mGjqe1n9qBt36sjk
	zpedJD4TPVD8PhDrz6lQlK0JpaZIztHNLAAYgIxZrVh/Icf7Nd/FvKWJ4CCDO302LA==
X-Gm-Gg: AR+sD12rAr9+sEIPusYkzViUw9/S08JHqg0JWf0Om3fIiiq/iDuIyvVeJ+2ubMM8meV
	MJD4L4NZVNGAce7vxdaWk0bH7FN+PU3494d8XjwCeKfLaGF+xrmvM6++6f8PsbWA5jYQ1BEREVf
	vYwA/sjpDutIlB9ltlIvipOXX48Wp55tkqBg2b2BijoF+Pv7PuOJx5D2sQH5FQv5lz36FHHUbxq
	S58dGvmcgicFyoqV0hEduhUnYIu14ua8RKXiqk8U0EUpHFI8+gqwloCPQXnOW0ffgRu3sE8d4Fi
	3mFr7caN+51ds1HZlzZdIgNBv0WFmCAYVFwq/oFl2C5xJ7wz/HUYWIkCq01XTTbflVr22Psub0r
	wuv7X7P/HKMaBMjnhpC0Jim2ZGswXOY+dEOxMDLMNDDRAm9XphSFb8fhLjMoF9dKtGDTYObndk5
	BTK1ZlRcMVpMw8YHr5xaR1X5jOYhOkMr3R6xj6JdCX
X-Received: by 2002:a05:600c:19cf:b0:499:728c:4704 with SMTP id 5b1f17b1804b1-499aa1b993bmr5258655e9.12.1787093842851;
        Tue, 18 Aug 2026 15:57:22 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482b14b8038sm508137f8f.20.2026.08.18.15.57.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 15:57:22 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com,
	stable@vger.kernel.org
Subject: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for iterator READs
Date: Wed, 19 Aug 2026 03:57:14 +0500
Message-ID: <20260818225715.572140-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A READ served without splice emits two fsnotify access events; a
local read of the same file emits one. vfs_iocb_iter_read() emits
an access event when the read succeeds, and nfsd_finish_read()
emits a second one for the same READ. An inotify watch on an
exported file sees each of these READs twice, so anything counting
accesses counts double. READs take this path whenever nfsd does
not use splice, for example with sec=krb5i or sec=krb5p, or when
nfsd_disable_splice_read is set, as the NFSD_IO_DONTCACHE and
NFSD_IO_DIRECT modes do. Spliced READs are not affected, since
splice_direct_to_actor() emits no event and nfsd_finish_read()
emits their only one.

Move the fsnotify_access() call from nfsd_finish_read() into
nfsd_splice_read(), the one path whose VFS helper does not emit
it. Each READ now emits exactly one access event whichever path
serves it. Measured with an inotify watch: the iterator path drops
from two events per READ to one, and the splice path is unchanged
at one.

Suggested-by: Chuck Lever <cel@kernel.org>
Link: https://lore.kernel.org/linux-nfs/2ed0ee16-c20e-44bd-9e7a-f5b71764f14f@app.fastmail.com/
Fixes: 507df40ebf316 ("NFSD: Hoist rq_vec preparation into nfsd_read()")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
 fs/nfsd/vfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391e..f45d4ad70b964 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1046,7 +1046,6 @@ static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		nfsd_stats_io_read_add(nn, fhp->fh_export, host_err);
 		*eof = nfsd_eof_on_read(file, offset, host_err, *count);
 		*count = host_err;
-		fsnotify_access(file);
 		trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
 		return 0;
 	} else {
@@ -1084,6 +1083,9 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!host_err)
 		host_err = splice_direct_to_actor(file, &sd,
 						  nfsd_direct_splice_actor);
+	/* splice_direct_to_actor() does not emit an fsnotify event */
+	if (host_err >= 0)
+		fsnotify_access(file);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
 }
 

base-commit: c5f58d03c50196301ac2ce7da81e8be33eba57c6
-- 
2.53.0

