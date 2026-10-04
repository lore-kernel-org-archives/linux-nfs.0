Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9782647D94A
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142837; cv=none; b=mJNErMoiENAop7+8GPau6mKaP2xtiCVCvxprbRABqHVR98FdmiZo3ml2u8OYzAvbf6iES2rwu9OJ2d8X9A9yvCU7SJLD98vFiE5nbT+plKP5ng9vkTlEuq0no8yIzui/6ui4CwrgYDxGaFd1um2oTJRSzG//Kx1vrLwhMyFNFDE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142837; c=relaxed/simple;
	bh=mLNTeg21PLsQInXfifFuzMpwziYRKieQ7FEM1Yah+Gc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=V+5vEIovGu+5CY/rdrXo1yvvClckv9jlMYh8ZTKj5KazkPOJ/GAehUS+QKOrTKe3Z7z5xut0aEgF/vMdiWbua9nWaziKNMXtxMpJTPUgWN7yUmnPw0tS+o4KWtMB1Wtc2Fux58nu6iUk9530ULbLjv/FIg2eHK59IGPnP8w0BZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bPMxlY4b; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bPMxlY4b"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 023E91F00898;
	Sun,  4 Oct 2026 19:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142836;
	bh=JtftVI00sH7NPYRhTqaYIzv2mtj1OB60ghzunJk1Fag=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bPMxlY4bZm96A3vHpOntgq3U6Dnj67MZinccUlz3ATHJ6gBUXiuZt4mSNd8I9YsRs
	 yNrUCo8bEOLSQ8P+vkTZ+sHNlcurRhxrQEowK0RE0cGkh+a3+D6VUzVMb8TJ9G/F9O
	 ZChRXqBfV+SBgNgkyZKMTNW9EDSH3uz3erOgnVbdqRZYUkmrz5y7SFrewKtX1aBE8r
	 JAKO3/IAZ7tfLPbERUQu8mGhDP+bZd2UNkcYt7cP9nbqYQTiF0SToy0esUF3pm5OBq
	 uVYtHIDeIvYnRyjDSjJH7aZB+eh90HFlIlkupAnLMeqODcIN1686H9phpkxnRe3MHV
	 QwvObrvDZTbwg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 7/7] sunrpc: assign RQ_LOCAL from the transport on every receive
Date: Sun,  4 Oct 2026 15:40:29 -0400
Message-ID: <20261004194029.10714-8-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Only svc_tcp_recvfrom() assigns RQ_LOCAL. A request that arrives
over UDP or RDMA, or that svc_deferred_recv() replays, leaves the
svc_rqst with the value from the last TCP request its thread
received. When RQ_LOCAL is set, nfsd_vfs_write() sets
PF_LOCAL_THROTTLE, and dirty throttling considers only the backing
device being written. A stale RQ_LOCAL relaxes throttling that way
for a WRITE from a remote client. A stale clear bit withholds the
relaxation from a replayed WRITE that did arrive over loopback, and
NFSD can lock up behind the NFS client's dirty pages.

Assign RQ_LOCAL from XPT_LOCAL in svc_handle_xprt() before the
request is received. A deferred request is replayed on the
transport it arrived on, so struct svc_deferred_req needs no copy
of the flag. Only svc_tcp_accept() sets XPT_LOCAL. After the
change, RQ_LOCAL is clear for every UDP and RDMA request, including
one that arrives over loopback.

Fixes: ef11ce24875a ("SUNRPC: track whether a request is coming from a loop-back interface.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 2 ++
 net/sunrpc/svcsock.c  | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 031cbac2a612..acb6e58dc522 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -884,6 +884,8 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		svc_xprt_received(xprt);
 	} else if (svc_xprt_reserve_slot(rqstp, xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
+		assign_bit(RQ_LOCAL, &rqstp->rq_flags,
+			   test_bit(XPT_LOCAL, &xprt->xpt_flags));
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred)
 			len = svc_deferred_recv(rqstp);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1814e49c671d..b226bb3cd287 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1287,8 +1287,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
-	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
-		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
 
 	/* Completing one message stops ->read_sock with whatever
 	 * follows still queued, and no path from here re-arms XPT_DATA.
-- 
2.55.0

