Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86B1A484230
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776027; cv=none; b=a7yfpQlIukv0UrP5QRdopRskgnc0Hy4z0KZVDK5Q1Ol0Q6/EyeFnYQkrPG7/KIcd0PqB47ro+6wn4U4bvwI6aINqqCkqa12NAKCs4b0uQ4EdL/PMaHwq5zEngFRNcL+kN2aVJtwca8gT0XxSjfgVBmtX8HOhPpAmmsLjNAaH8r8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776027; c=relaxed/simple;
	bh=6Zathy3cLcEXNirZWfsFyg/FrLZFmWjr8rAvDCURITM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=J1TXl9W9r3HX4V4OR7bK9uCB864TsGtrXvvuv0zwGqOsO85VxvyC89/aKLjymmybIgazILyArV/rCArDnxofCMW7UyldShesPM7de2161Sv/Ux4qUnjhQuQ2SZ2e7xDTWMcvgr0OICB9M4icRBbh15SNIEhTpol0F4Cufh+uU2k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=afPeNFCL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="afPeNFCL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6FF71F00A3F;
	Wed, 26 Aug 2026 20:27:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776025;
	bh=aaAOfKXVNvFQ3AEZwAQI5sRDD7x7zfpWwOeZRVfms/A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=afPeNFCLXlCH2851TmWDpy/fy5A9zqXrKOpiwaxzqIoM55TwwsPmBbQIPslAi9V4j
	 NF7Qgv2FX8rGCbez8UAGOXtPPFZWRIa1J1D/8N9T/3FujCYN27zy9oM8nAecZ1BQcG
	 LeDpkcc8TvYZrkOtxyeNl2NyHZgQNci2fjvOfNPBXjil/HL4DC5PfQH2xxGlbQvYnl
	 29O8flVOhZZ9V1lwc/zCTO4rplkgLS3bdGQo2hUGNJWM0vpFEV8TcDvYnuTAF082YH
	 +S9YRgS37aHWZgweAoGmq9CFAhiqr7f6FvkJ5VgU/50jBl087AZ7IOcbF1pNRqbkkj
	 mEfH18tEfEqfQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 26 Aug 2026 16:26:53 -0400
Subject: [PATCH 3/7] SUNRPC: Record last-request timestamp on svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260826-duplicate-reply-cache-v1-3-b1d51e1af5c7@kernel.org>
References: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
In-Reply-To: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1854; i=cel@kernel.org;
 h=from:subject:message-id; bh=6Zathy3cLcEXNirZWfsFyg/FrLZFmWjr8rAvDCURITM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wVjDOFkq586R2M91LV2trLgZLhqq+Xejkmu
 5XVHteuFQWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MFQAKCRAzarMzb2Z/
 l7cLD/4+Lq8B9GPBRCHFD/Erh4QZaVkjxJ9U1H1p8aJyeXiOf6vFqdOEbvhBx1AxqiY8LdYU8RU
 NVpgCUR5gX7ViDeR2R7x4CM63VWt2A9QHdHYEJ4V1UUafZJ3mn1FXKCS1BOC02A7n+Ky8x1Pgah
 MGs/wxcV6F0XHFqlclG/o6dEiwrtuurtkLpDAtDUBQor+ASk8wDe+8YeeioHqa50YvcASYN7wrs
 TJk+l6xuq6e1NdGUSXFRpBoIxXo1CSF4ZUuXQTqqbJkcLimbyLrklcCljNblv8CjhpZpHPa92+M
 3Il9bV5tvluB0MaoIK4CCB10f1haIulZoObZddomwe7n5sXIx4qdhZvd9SZWBVgdyKWhMRrU8FS
 9AIdFGVp38mFBTiA685seyYXVMeV6rUZhBmfGnFpeJqkpoXB+ypupeEB2CrkWtvaAyyjrbgDsG9
 ZDBcls2gv85khW5+LajaL0stm5mBTN6yQJ3Ow/TSO4yLiGIlWHp24TnkDdOETM79DANSh6rI24P
 HZHhKyuX9hg01Ag4w4b1sPznFt4RRZqhB8nJQZw8RQqPSgaAqV88tQguuLN3TWjohlp3q2VLLH7
 KRmcH706zbTTX9S2iZu7etH9+JzQ3zSuODif55FiqKyDIJw2l24dhtXxAGRVId3559KG6iG8pBV
 JXz+2jDd729GIcA==
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

