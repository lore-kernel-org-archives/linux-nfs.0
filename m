Received: from mail-pj2-f13.google.com (mail-pj2-f13.google.com [74.125.227.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB242433049
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:15:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790828105; cv=none; b=KvX9S99as5dtXWHGf3zwYimPBb01H1EYPGbbn+m5SnwzdedMmb6hmpljU1G7s3fAzH6JQr4+WiC2LQQ9COtru1PYZPpgRkwyl7GcBvZQDbc7xYgPuC6+D7OzUvPu0zU4QBp2LxaTv5Tij01pFhW7xXsby5WFuf17h5TCc9FpnWM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790828105; c=relaxed/simple;
	bh=yMrgCvGa3qhqYSJQkqvhXq27Aav/mbOlv8nbGLhr+aU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VsoYXxy5NQEGYE4VD1rvexUm/bsfJQWMOQGbQa7PM6QYoPAq2hl7hGXbxrBjVcPEGPk7ktAkG6uvlTQQXiMNwwJTVXXSfIt0SdsJRLtxgHpHYackCuo49ybRmzoFJthc+HgB1/6W1+w2dFQ8jGHydzzpBWRIEswUG+Uc/okkI9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SGNLaKMg; arc=none smtp.client-ip=74.125.227.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SGNLaKMg"
Received: by mail-pj2-f13.google.com with SMTP id d9443c01a7336-2d747ee1f9bso29100125ad.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:15:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790828103; x=1791432903; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=K+qaqnfQy5F06363dTl5OUAILO3wyf1YsFrHb6xv8d0=;
        b=SGNLaKMgDfLj9SgGmoKn31DHJjdwTtvB+amnyW5SZHp30OyBIP5oA68HNhJ5SvGObR
         U76c31lxwkZzxar/z5r2DVlyElkqwAbE9Qv+C+Y3A3TNmIYaEyVWQpnBhHgAQ6nWTfQN
         //SRsuTeBAbtxvSt6BCwfFCF8BIn635QRm9PHxg4AkQ8c9RP2wcT3MxlasLKAKWr7B8f
         LTG4ulyJBWRCPSSKZGFZBvAPkNpSzSt0DDN4dkRTyIhN0+805zjfK2XY67BLGmCZIGDd
         swSwaxLeeMHqbveZRMsL2zhntMjm5UHI3wAi/IcosJpO0zB0nVYWjgeQtXi2nRtPcEzS
         uuYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790828103; x=1791432903;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=K+qaqnfQy5F06363dTl5OUAILO3wyf1YsFrHb6xv8d0=;
        b=dDN4YB5QlQLasCs4/cm076/dtz9/3K6uX6M/eNVxu7WnbjJ9ToVdWmoP+sFMdhpqpR
         uISgh1BsUPZB/aUCQRkZYSB+PXoQpH3opxRTCRn15Hm82zOzImVvB+p3UImMuCnnFjaX
         w61ws9TqwP0RAcGfeMlPPjzOfIqlXzsIwhPoAxMZ0eXblnYAwy6nh5LOQP2eh9PgUP3u
         tBLHEa34nNdAntc8TKvubH/DlLMvNAt28n+RRIghKKLwcXNoQ53tlBVKGSJSABzskhsx
         mXPzlAlYmNS5lVCr6OU02X+1jBNzo72yY9OjfavkvIe1E3ahS7bY940zk/oylXyEprK8
         6nFg==
X-Gm-Message-State: AFq9FYL8CmMqsKjg1jy6FyISKRNJIw1+tRdR9eGe4oR1pnJLNlCEukT3
	YLcAx8FL74G+s/itY2ZrwyrY+8WHCVDksB/fx4X5hKdhBnnK989e5FQcpAxeccqj
X-Gm-Gg: AYBFou0AK3JIBKRWBi9E5JkY7KvoMWcecojdOAqyp0MtmMIaloVu/EA46V737b2XIsP
	gHCwo00vNzpK6cBTE6BdteoZv3V0Mz0kLbUDfIt1Ve+Fae9IuqLpz5SDm3DzKDgyLJzegQsllBr
	x/WCBubHJzAVGMkWY+d/M/XJaFfIvC3LGzYoELvBhECLW62Pm9xoh9RDwMunenaseAPlEFVjb2t
	l2eph84PoCjoO3gbsyu3l8Xmu13Vs3VC4UpxIvFcm3Cb6p0ALVEToiv1PIVCulMHRtVMfUQilGm
	s+Bl92EvvRjx2kK1ciVdXvbniKNiPmlAzj5CzxHAXQGv8GI7/hKiy+ggo0Kj7qMtAUzBIUMvNPO
	og0xUXqasK9MjwuyCWwx4Onit77n/MTvjhV+YNJ2RxD/+f3hieULBp3/Al4zrC/RTYswclyfpX6
	PVchyrpZlCmnTdPnsRERI+4eJJUXOpn0jtcXV45nhX0BqJFhExPpvyfLAQM9LJT39iELuOI4TXx
	oI8yR4GHhF86qN52EK49Rc=
X-Received: by 2002:a17:902:e808:b0:2df:84e0:9034 with SMTP id d9443c01a7336-2e2e48b342fmr27449095ad.7.1790828102948;
        Wed, 30 Sep 2026 21:15:02 -0700 (PDT)
Received: from Mac.tail7ad783.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e3005848a5sm4815105ad.8.2026.09.30.21.15.00
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Wed, 30 Sep 2026 21:15:02 -0700 (PDT)
From: Jiwoong Wi <dwdnlzj@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Jiwoong Wi <dwdnlzj@gmail.com>
Subject: [PATCH] nfsd: update existing connection flags under client lock
Date: Thu,  1 Oct 2026 13:14:33 +0900
Message-ID: <20261001041433.74718-1-dwdnlzj@gmail.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_match_existing_connection() searches the session connection list
while holding clp->cl_lock, but returns the matching nfsd4_conn after
releasing the lock. nfsd4_bind_conn_to_session() then updates
conn->cn_flags. Concurrent transport loss can remove and free the
connection in nfsd4_conn_lost() between the unlock and the update,
leading to a use-after-free read-modify-write of cn_flags.

Update cn_flags before releasing clp->cl_lock and stop returning the raw
connection pointer to the caller.

A natural reproducer pipelined 16 BIND_CONN_TO_SESSION requests and reset
the connection after receiving the first reply. On a Generic KASAN kernel
at v7.3-rc4-606-gfd179f8a05be, it triggered three reports in 1,000
attempts. All attempts completed, covering 55,494 BIND operations and
6,494 processed pipelined BIND requests.

With this change applied to nfsd-testing at 32eb1a60b456, the same
reproducer completed 1,000 attempts with no harness error or KASAN
report. A 750 ms post-unlock timing-aid control also completed without a
KASAN report. Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests
passed, and fs/nfsd built with GCC 12.2 without a new warning.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 02579b2ff8b0 ("nfsd: back channel stuck in SEQ4_STATUS_CB_PATH_DOWN")
Assisted-by: LLM
Signed-off-by: Jiwoong Wi <dwdnlzj@gmail.com>
---
 fs/nfsd/nfs4state.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bbc16dd2294d..6b445c5d4eb3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4810,7 +4810,7 @@ static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_s
 }
 
 static __be32 nfsd4_match_existing_connection(struct svc_rqst *rqst,
-		struct nfsd4_session *session, u32 req, struct nfsd4_conn **conn)
+		struct nfsd4_session *session, u32 req)
 {
 	struct nfs4_client *clp = session->se_client;
 	struct svc_xprt *xpt = rqst->rq_xprt;
@@ -4832,9 +4832,10 @@ static __be32 nfsd4_match_existing_connection(struct svc_rqst *rqst,
 		status = nfs_ok;
 	else
 		status = nfserr_inval;
+	if (status == nfs_ok &&
+	    (req == NFS4_CDFC4_FORE_OR_BOTH || req == NFS4_CDFC4_BACK))
+		c->cn_flags |= NFS4_CDFC4_BACK;
 	spin_unlock(&clp->cl_lock);
-	if (status == nfs_ok && conn)
-		*conn = c;
 	return status;
 }
 
@@ -4859,12 +4860,8 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	status = nfserr_wrong_cred;
 	if (!nfsd4_mach_creds_match(session->se_client, rqstp))
 		goto out;
-	status = nfsd4_match_existing_connection(rqstp, session,
-			bcts->dir, &conn);
+	status = nfsd4_match_existing_connection(rqstp, session, bcts->dir);
 	if (status == nfs_ok) {
-		if (bcts->dir == NFS4_CDFC4_FORE_OR_BOTH ||
-				bcts->dir == NFS4_CDFC4_BACK)
-			conn->cn_flags |= NFS4_CDFC4_BACK;
 		nfsd4_probe_callback(session->se_client);
 		goto out;
 	}

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.50.1 (Apple Git-155)

