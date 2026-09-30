Received: from mail-pj2-f43.google.com (mail-pj2-f43.google.com [74.125.227.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2C0930C147
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:37:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790746644; cv=none; b=X9p85wFDOmWOnO2tvjtIfoxWnK72+599GOaEf3l1qcgdguxHPM7FUhN55FlDRWKznlx7wnWxl2YSeUoMhfd2xeG+ikJU+9I+D6GD+iOEYpRZKD85/2Ky2YczuU/LsCX65rT1euV3ArmJb0c9c8FVavZoyFgeG1MCDrIzVbc3xlE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790746644; c=relaxed/simple;
	bh=lZ4CG1XNJ86ULS6Q1dtMhVSEbxPDfyhIfk7KzQlBc0o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Bl7GXTVjq4dIg8kh/ctmYBgNv1SQI4Iztl/GNZCRJPx9KW4pDGdv47i1UzjE3ScatOS16yXv9USvhZcOs1aUP2X4q6Csmo6HCOCi8R4u8HcjSJ8zrsufIE0JcrogowGYs20o+AZqGtCwGAOXm9DKiMZTobiz3KKi3Vrurp4i+K0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=U/RCJaEq; arc=none smtp.client-ip=74.125.227.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U/RCJaEq"
Received: by mail-pj2-f43.google.com with SMTP id d9443c01a7336-2d747ee1f38so22018785ad.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:37:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790746642; x=1791351442; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ABXfLcCI9uCWzauTzWRtTaAq7LAQCTVkflaA1GfjZ2g=;
        b=U/RCJaEqkPlpOg0SHKpY7VJ5Dt/pTilmQqrLwJ8azPLYKifXvhWimMl1zAyixfQybk
         UF7XUDYFDU0fuMCe6CmoJ04kE4F9yHg92TPD1uaT752rHycYCwZv8mGz2HtFSWT1C6sn
         TzuxZ/Krd1gJMhFQ2xH+IepHjX5Gq6MXpqUPpgJaszb0STMb6QnSnpdilo1PzHRQtxmZ
         fPcYEohc+7MzB0zIdVD5fNTHGE7THntGsDVG3qRjbZ926qnF9kZub24TIxaSfF4F6HkX
         4J7cbMFLCovfjpv3Uxmvi6/Ck7qfUEAVips5biDuv1odiPAsjUcdh8GJ8zAYovOizxjb
         OJzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790746642; x=1791351442;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ABXfLcCI9uCWzauTzWRtTaAq7LAQCTVkflaA1GfjZ2g=;
        b=QQ8xTRltCbbv7mdoJtOaQFbtvwWPqne5KnBb8tRH7mSRKRaQ+U3QdS9OJNeGz/jmMd
         61vGCUiVMiZ5E9J32ZL9iRYiyHBtE/B0+QfKmjDhDb9lrPBwJeqw1HZKx5lwU2s7b2cn
         5SfjRSJM8++hcqmE078zUbHH4SFjxaz+QrQKdr9NttkARxGfvPQgKmfoACSqe0LW/lIA
         8WNO/8/wJBL5s3qk21EXDfYFA9W6ZYK2YdUswi5Qcs2bGoHHkc4FFpskFAhPQ+Xo03so
         DEL3DIKoRFUAKwMEfSq/oD53h9n9wz8wsaJjMeurVvVJATlOveBlY83ltbiMgUQIkBQk
         EqaA==
X-Gm-Message-State: AFq9FYKCKxma0LcUzVL7eUM4rV0d0i0FubgaHIlUZjgMI40o8rMmEgR+
	MRV9MPie7oTkPJNZu7PAzjaYwC2bTHfQdy7EA4jMOOzW5J5xkiDm5H0tPimtpTxILP8=
X-Gm-Gg: AYBFou0sdqpMFWImH6tlpgg1tlL3fvgLvDXoG3djt24s0BwybGl6usfycqVqQMPh4+I
	dhSkbbjZExEvZKuEba7EE3RUJSKLJ/dOPYpUw3mw5S+RWwz8n4PU6ZnyY7k8aEK20tQaVyz0zRr
	3+v5usvepIPMsVTb71RQD2U2DFLpKqlX/Imk2oDTe6vQIdN5K/2KlHo0LesYlSWDsWtYws+Rqvj
	AhBRGDtiAdprauDnN2vyi3jDBQA3P01qIc3v4p5K9Gqsoceb4WJU9PHwMLkddQa8Kpj19XGa1Pv
	FeEvXgY76q81k828vBanac7K1iU2urJzpxjH/8iAzGktGoci17NyOLxG2T2WqHieo7EgLRarvUN
	i7x6YiMmWpZOw8RAQaNDTiZJ4jufu8H0tQTFlSyOyFvo/kKtWZgjxzDncfxjP1ihMHSkm9G+G2s
	i6iDrzYBa4ap2LwAPNa3jSK7nKX7Hq0GJJmJxarO/Fij3cgqKQRonNwwB8hcnraazcn7FiS9Ori
	cVilyuTXumdfTrZ4rYf8hpP2Sdcsnc2BdmkZzl8ZJzSAGSgrdlz/wuzo8VCzy9jp0ykTMkd
X-Received: by 2002:a17:902:e94d:b0:2dd:c100:7cb6 with SMTP id d9443c01a7336-2e2e4a0aa2dmr3335145ad.50.1790746641774;
        Tue, 29 Sep 2026 22:37:21 -0700 (PDT)
Received: from muumthf.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e2e5c1b7dfsm1110365ad.72.2026.09.29.22.37.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:37:21 -0700 (PDT)
From: Hyunsol Mun <muumthf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Willy Tarreau <w@1wt.eu>,
	bobtobabz@gmail.com,
	Hyunsol Mun <muumthf@gmail.com>
Subject: [PATCH v2] nfsd: pin OPEN stateid referenced by LOCK stateid
Date: Wed, 30 Sep 2026 14:36:46 +0900
Message-ID: <20260930053646.299164-1-muumthf@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A LOCK stateid stores its parent OPEN stateid in st_openstp without taking
a reference. A request can keep the child alive while a concurrent CLOSE
unhashes the child and releases the parent's persistent reference. A READ
using the surviving LOCK stateid then follows the freed parent in
nfs4_check_openmode().

Take an OPEN stateid reference when initializing the LOCK stateid and
release it from the LOCK stateid free callback. Keep the free path safe
for partially initialized objects.

An unprivileged NFSv4.1 client with normal access to an exported file can
reach the lifetime error using ordinary OPEN, LOCK, READ, and CLOSE
operations. Validation used the nfsd-testing base recorded below. Natural
race runs on the unmodified KASAN kernel completed 3,000 one-reader
attempts and 5,000 eight-reader attempts without reproducing the report.

For deterministic validation, a test-only kprobe delayed
nfs4_check_openmode() after LOCK setup, before it followed st_openstp. The
module only widened the race window; it did not allocate, free, or modify
an NFSD object. The unpatched kernel then reported a slab use-after-free in
nfs4_check_openmode() on the first timed attempt. With this patch, the same
timed READ and CLOSE both returned NFS4_OK and produced no KASAN report.

The patched kernel also completed the natural 3,000-attempt run and the
5,000-attempt eight-reader run without a KASAN report or kernel failure.
The full KASAN kernel built with CONFIG_WERROR without a compiler
diagnostic. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests passed.
A source reproducer, timing-module source, complete logs, and the kernel
configuration are available privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 02921914170e ("nfsd4: fix openmode checking on IO using lock stateid")
Assisted-by: LLM
Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
---
Changes in v2:
- Separate natural-race and timing-assisted validation results.
- Add full-build and NFSv4.2/NFSv3 smoke-test results.
- No code changes.

 fs/nfsd/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bbc16dd22..208badfe6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1781,6 +1781,7 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 {
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
+	struct nfs4_ol_stateid *open_stp = stp->st_openstp;
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 	struct nfsd_file *nf;
 
@@ -1791,6 +1792,8 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 		nfsd_file_put(nf);
 	}
 	nfs4_free_ol_stateid(stid);
+	if (open_stp)
+		nfs4_put_stid(&open_stp->st_stid);
 }
 
 /*
@@ -9301,6 +9304,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 			exp_get(open_stp->st_stid.sc_export);
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
+	refcount_inc(&open_stp->st_stid.sc_count);
 	stp->st_openstp = open_stp;
 	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_locks, &open_stp->st_locks);

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.50.1 (Apple Git-155)
