Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD8B237A85A
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933888; cv=none; b=iabLOCJBRJ+5JZMAscvsvCxrc65zJU/F0pvdGpFUfgToO8bviaUH2Eal1lIj6lW9zkbW5ZvGNIj1odYZPAoGvxmtxb+HrCntM99qOYzGwfUz5pAX7/HdTnA0ZnsqCMiVVSjvYDFO3f90pJ1nbHkGP3vJD41gMa/6ENtMs0wIxNc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933888; c=relaxed/simple;
	bh=6Zathy3cLcEXNirZWfsFyg/FrLZFmWjr8rAvDCURITM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NqRLs/HBZsASFdkxoFuJ0zQe/NW8/g4NbzRj73iUvg7j3FTTnmRD/bQsyNw6M8piw46Z3KdBX/saYZQDIpuj+wq/M/yzbkxVba7H8j9MrPCX6nMXNee9etj8KINy9YakxvxRML62pXSKfOST65MKdxb9bTKjfAsiqA4x+vaQvx4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N5SaP1J/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N5SaP1J/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E326E1F00AC4;
	Fri, 28 Aug 2026 16:18:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933886;
	bh=aaAOfKXVNvFQ3AEZwAQI5sRDD7x7zfpWwOeZRVfms/A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N5SaP1J/6id3MWY3f1qCnVGjasXWQUmzX+1ooBU7j74XmxCcbWdVSnYNMjhy8BTt/
	 56L3l6+hGok+2pcQ7kSRjIUjC9KtHtCS0nHaQamd8AFlccMscYYleKQlh0l17Iselc
	 uRFwy0O+eP7lhGsAtSHKO8lQovofxyW1rzXkvkEY59GBAoK3AyLMWThHfSUqosV6m3
	 pRz8psLGKqvOdNmtIkJQ+A3/RfI9oqE0omTWrRoBgRLJjj0Q6YT6B1xJQJxkgQ+pO6
	 r9AUVs8tN3HUwCRhbdW9cLT5NXZD7gRkiJrFNA1+tI/aB1vtDPTsySWyKz20i1R3g3
	 n5L2U+2bTWVmQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:55 -0400
Subject: [PATCH v2 3/7] SUNRPC: Record last-request timestamp on svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-3-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1854; i=cel@kernel.org;
 h=from:subject:message-id; bh=6Zathy3cLcEXNirZWfsFyg/FrLZFmWjr8rAvDCURITM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS6HpGm1W93UG8zLYaw1E0nzl52BryM9KI0I
 zk2u5oZccqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0ugAKCRAzarMzb2Z/
 l2jKD/9L1ld97zhw5ARQAR/nd5k3UaCD6zmlSI3r6es+x069dtax43VdQFmN7JLcytso50HAjke
 fRQxYAYK1WPhxnUqP7eiuKOWYyqYz8x24P8kU7X4T1H2oJYFT+UqYmQIYL+niurJnvaB2+Fps7Y
 EMECsxSmMCqi4EqQQl3YVi6tJSGddHhI8EAOyxT/BRo7neD3Wy+PDW6Uv3+WBqeEtkHMjEGFmdO
 g9U57cTG0qzmcQMQFC0xXXLBxP2RTStsqcfziBSqHCOIF4YG4UFrPoaA5KsbZ6exfbsMmO7jhvz
 UYYjTpXOjhU++S26vGe8smkGRfeqO1qu4BkxlCssAsHLgwbOffDLadrNkIdMkTTiQlvQBahAVGf
 OKG9DQUQOWnP7elXMPHZUlmEx2xJYbnscCA4HhUwjpbNc0+zbgdAF9/qFhIRZKtTZaufFht6SyP
 pd2QAHv/caG6LfIlWYz8+3ZqSgUa522qmew7GclE6LeHm1u4QlKNPgd0WYKT4mH1JnHCGrQ4Fyj
 U9m2+7s5GTbab5hqFjecuwKJ5vuzeLL//AsDZ30wXo3DEh4LTGXOVInEE1zB3tSj36puTJNHbjF
 h3ABPkGwYovZnQblEM1U3auYpXw94MLTMwl5NhjaGJY+rp744iFXfmc1wNbS4oyzYIB4mkNNs//
 qwCZ4wwK2Lzo1Dg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

On a connection-oriented transport, the arrival of a later request
suggests the client received the prior reply. It is not proof: a
client with several requests outstanding sends the next one without
waiting for a reply.

Add xpt_last_recv to struct svc_xprt and update it in
svc_handle_xprt() after each successful xpo_recvfrom(). A revisited
deferred request leaves it alone, since that request arrived before
the deferral and is not fresh client activity. The DRC reads this
value as a best-effort signal that a completed reply has been
delivered.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h | 1 +
 net/sunrpc/svc_xprt.c           | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 88d73da5f46f..53ed073640a6 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -78,6 +78,7 @@ struct svc_xprt {
 	struct net		*xpt_net;
 	netns_tracker		ns_tracker;
 	const struct cred	*xpt_cred;
+	unsigned long		xpt_last_recv;	/* jiffies of last request */
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 	struct rpc_xprt_switch	*xpt_bc_xps;	/* NFSv4.1 backchannel */
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ca10ef965443..1d4a40627244 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -914,6 +914,13 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 
 		clear_bit(XPT_OLD, &xprt->xpt_flags);
 
+		/*
+		 * A deferred request is a replay of one that arrived
+		 * earlier, not fresh client activity on this connection.
+		 */
+		if (!rqstp->rq_deferred)
+			WRITE_ONCE(xprt->xpt_last_recv, jiffies);
+
 		rqstp->rq_chandle.defer = svc_defer;
 
 		if (serv->sv_stats)

-- 
2.55.0

