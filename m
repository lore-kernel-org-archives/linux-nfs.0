Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CACC44A0F02
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 13:31:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788355866; cv=none; b=qGMAr/J0CASt4RgQeENRffq04Butxyuj6yi+e3wS08VRSKFOdXyLbD7POnrrxdOIJvxEEK3T3TMPuMr0xeev+y2pvp8VOrtEm4z29UxrONZABq3/V9I5YAYBScR8ftfZ6SA/ayYUY5gNMK/5ta2bDw1+dS6ZopV30B//nHKee/g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788355866; c=relaxed/simple;
	bh=Edzmxryj49vjuuf2qbctJaSwCVbmbnLZX+eB4wq+lek=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=X1LwYWgJkAumuDvwfiXDSNH2DtmyEpyGe3ENd3oLzO1ZWXXyutWqpvnmyiIdiZsFNRmCo3hBtgF9jDpzWpJlNuoG1DwR7CO5KP6rKnKSi7jA31mrXrZZ448DgLHPJSS0Roz3JKUo1nlbyF5Ub1tF5Msg562XnO5wjL8T71TBEyo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ewCQMZ+6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ewCQMZ+6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4F1B1F000E9;
	Wed,  2 Sep 2026 13:31:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788355864;
	bh=A/aSx8kTUAEZpYyOSosw0A9O5hC8yTur9wj0L4SSh5g=;
	h=From:To:Cc:Subject:Date;
	b=ewCQMZ+6Oyk4l4mFmpNwYutTuFWoDevlI4lL9U+S6J5QW1OXAknSERKaDT+nB9lbu
	 LffwQbE0f78AfT1scRDP/uKzF3TtaVK7lluGohUeA5vMsgkBKeciAADmNyeqEvVVb4
	 5sXUaaFDY0ooLU7G9s+YmY2m6AbR2t2I3BaycqE8Ta3DxaV8diLOPd2fOU22TUE2HQ
	 L+xNjBS45jLxnpp2gMb3FQDapUBA5lJeWHP4CuAD0pq4V0ItJ1M0zr6ZwUBdIlcEXQ
	 BemKqE7C6v7SKbBqbBMPEBBPCx5/bNe2UYb9a3z4U7LagMHY+4Q37MikS/P92B7ULX
	 +c0H/aCKdDEFw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Kimi Security Team <bug-report@moonshot.ai>,
	Yilin Zhang <yilinzhang@moonshot.ai>
Subject: [PATCH v1] SUNRPC: Copy the deferred RPC Call from the head buffer
Date: Wed,  2 Sep 2026 09:31:01 -0400
Message-ID: <20260902133101.48914-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_defer() snapshots the RPC Call for replay once a pending cache
upcall resolves. It copies the Call starting (rq_arg.len -
head[0].iov_len) bytes before head[0].iov_base, a back-up that once
covered a transport header. No transport has had one since commit
983084b2672c ("SUNRPC: Remove svc_rqst::rq_xprt_hlen"), so the two
lengths are meant to be equal.

An RPCSEC_GSS Call breaks that assumption. Unwrapping the integrity
service truncates rq_arg.len by the length of the trailing checksum,
and unwrapping the privacy service leaves rq_arg.len short by an
amount the client sets with trailing bytes after the wrap token.
Neither adjusts head[0].iov_len. Both lengths are size_t, so the
subtraction underflows and the copy starts past head[0].iov_base.
Every deferred integrity Call replays a shifted snapshot.

A deferred replay skips GSS verification, so a shifted snapshot runs
as an authenticated Call. With the privacy service the offset is
client-chosen. A forged Call placed in that window, naming another
user's GSS context handle, runs under that identity.

Copy the Call from head[0].iov_base. Refuse to defer a Call whose
length runs past the head buffer, so the copy cannot read out of
bounds.

Fixes: 260c1d1298f6 ("svc: Add transport hdr size for defer/revisit")
Reported-by: Kimi Security Team <bug-report@moonshot.ai>
Reported-by: Yilin Zhang <yilinzhang@moonshot.ai>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 77e28dcc4d2a..7f1c6bdd8425 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1278,13 +1278,8 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 }
 
 /*
- * Save the request off for later processing. The request buffer looks
- * like this:
- *
- * <xprt-header><rpc-header><rpc-pagelist><rpc-tail>
- *
- * This code can only handle requests that consist of an xprt-header
- * and rpc-header.
+ * Save the request off for later processing. Only a Call that fits
+ * entirely in rq_arg.head[0] can be deferred.
  */
 static struct cache_deferred_req *svc_defer(struct cache_req *req)
 {
@@ -1297,8 +1292,11 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
 	} else {
-		size_t skip;
 		size_t size;
+
+		if (rqstp->rq_arg.len > rqstp->rq_arg.head[0].iov_len)
+			return NULL;
+
 		/* FIXME maybe discard if size too large */
 		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
 		dr = kmalloc(size, GFP_KERNEL);
@@ -1312,9 +1310,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = rqstp->rq_arg.len >> 2;
 
-		/* back up head to the start of the buffer and copy */
-		skip = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
-		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base,
 		       dr->argslen << 2);
 	}
 	dr->xprt_ctxt = rqstp->rq_xprt_ctxt;
@@ -1337,17 +1333,13 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
 
 	trace_svc_defer_recv(dr);
 
-	/* setup iov_base past transport header */
 	rqstp->rq_arg.head[0].iov_base = dr->args;
-	/* The iov_len does not include the transport header bytes */
 	rqstp->rq_arg.head[0].iov_len = dr->argslen << 2;
 	rqstp->rq_arg.page_len = 0;
-	/* The rq_arg.len includes the transport header bytes */
 	rqstp->rq_arg.len     = dr->argslen << 2;
 	rqstp->rq_prot        = dr->prot;
 	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
 	rqstp->rq_addrlen     = dr->addrlen;
-	/* Save off transport header len in case we get deferred again */
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_xprt_ctxt   = dr->xprt_ctxt;
 
-- 
2.55.0

