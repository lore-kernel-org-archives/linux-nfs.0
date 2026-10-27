Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=37.230.196.243
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793102591;
	b=3xUvVK9SQ7GiawZ/hCuVamT/BxYHRGKn6iGHh+o8IsSMjQ2GSy2wkTrTS0IWBKkIJHB1
	 Ea4m2yal3bcaZVrXMUtqbBOF8nUuxuGr9VtmHfHuuhxn4FlwMHqRguXBcFLdhwwzW9gtr
	 BnAln+Qpxxf/XodVLzj7tWSeOFDBgRJ9WQuJ1SVkQTFNiu66SgsXPEqvdme0xr7UhbPpy
	 1lYWFy2j9CkmU+KdsZhUksny1RmNXbuYZbp1Yfkxf913NQ3dRuVUZy9Ucb2P/l1o4GPH9
	 3KB2DEzg33LRTnIJ86zp9fghc+eo8qbxblkfBWD+kU7IwZLXNNevRAB4RbOcNEo0SAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793102591;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-KSMG-AntiPhishing:X-KSMG-AntiSpam-Auth:
	 X-KSMG-AntiSpam-Envelope-From:X-KSMG-AntiSpam-Info:
	 X-KSMG-AntiSpam-Interceptor-Info:X-KSMG-AntiSpam-Lua-Profiles:
	 X-KSMG-AntiSpam-Method:X-KSMG-AntiSpam-Rate:X-KSMG-AntiSpam-Status:
	 X-KSMG-AntiSpam-Version:X-KSMG-AntiVirus:X-KSMG-AntiVirus-Status:
	 X-KSMG-LinksScanning:X-KSMG-Message-Action:X-KSMG-Rule-ID;
	bh=Xk/3IAbzd1VTf1sorpQhYh140qhCaxvlTgIx+6FQd9A=;
	b=GzglyaE5ra6NVJb7nRafEAno6Ra7cmFJOElNnnu0ShM5ziBUljZ9KHZUNn7RlCYjyJIW
	 kqLD1O2mOLu9Tz/w61mtx+r6sH8Hvd977VcftSOQiZ2hFV44DnrPJmCmSOnOgPssy+R+Z
	 WKKqWINS6fuPnVoD4hBeBcD///K6pGBnV8BAxqANZurZfpieRDzlLxdPxoqGfoDrx4Pa9
	 Lp1fWrsomlJNybD2oR5sZ7wBPeqwVQ6FO/3fcMAwrI/5sqTZmKYRnyY7pKL0QBPePH9d8
	 0tjpObYn8AOYKHPBq7SLcV5SrQ9eya9Ig14loPcvZl1B0snsEbv7occtp5jsvI9VCCA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astralinux.ru;
	spf=pass smtp.mailfrom=astralinux.ru;
	dkim=pass header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=UoyobN5W;
	arc=none smtp.remote-ip=37.230.196.243
Received: from mail-gw01.astralinux.ru (mail-gw01.astralinux.ru [37.230.196.243])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78FC660A262A;
	Tue, 27 Oct 2026 12:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 78FC660A262A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=UoyobN5W
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=astralinux.ru;
	s=mail; t=1793102583;
	bh=YWoolVgm2Ixluif9oj3rIYs3Yoa5Ka1lDDAT8MCYdfk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=UoyobN5Wle8Hb0w9IdgnZ+siA/tNG7uUg0NF0kOV5aEFVGthGSjxzrOY2jYARwdLy
	 jar4TukEip4Ektz+ER+VHW8aVHBNMnnqIwUM63lyHM1r/bqr5i3iwenKcl13VIzinX
	 YhVJesQJCB3r4AvUeRdYiQCR2vsa8rW2cv34NSSQk7QCs1saRmvUMmBAH1Zy0UMH9m
	 JWGZxlZbxCTVK8y7yHktAohlEOZ239L5lBRsFgnuEN2ot7RnD2qaFBQT+0/W1gOWD+
	 cwODVBpgwQBg+7jJIA+zM5mC+saw4pr5hMDW1V61pMjfaCqW3F5pBPOJc0LzKrUoNk
	 Zu+jD+5MxTc3g==
Received: from gca-sc-a-srv-ksmg01.astralinux.ru (localhost [127.0.0.1])
	by mail-gw01.astralinux.ru (Postfix) with ESMTP id 16C7B259D7;
	Tue, 27 Oct 2026 15:03:03 +0300 (MSK)
Received: from new-mail.astralinux.ru (unknown [10.205.207.10])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail-gw01.astralinux.ru (Postfix) with ESMTPS;
	Tue, 27 Oct 2026 15:02:57 +0300 (MSK)
Received: from DESKTOP-D46TNHI (unknown [10.198.50.125])
	by new-mail.astralinux.ru (Postfix) with ESMTPA id 4jDTdr20WPz2w2G;
	Tue, 27 Oct 2026 15:02:56 +0300 (MSK)
From: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>,
	Sasha Levin <sashal@kernel.org>,
	Chris Mason <clm@meta.com>,
	Chuck Lever <cel@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lvc-project@linuxtesting.org,
	Chuck Lever <chuck.lever@oracle.com>,
	Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [PATCH 5.10 v2 1/2] rpcrdma: Fix comments about reverse-direction operation
Date: Tue, 27 Oct 2026 15:01:37 +0300
Message-ID: <20261027120143.1596-2-mdmitrichenko@astralinux.ru>
X-Mailer: git-send-email 2.54.0.windows.1
In-Reply-To: <20261027120143.1596-1-mdmitrichenko@astralinux.ru>
References: <20261027120143.1596-1-mdmitrichenko@astralinux.ru>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-KSMG-AntiPhishing: NotDetected
X-KSMG-AntiSpam-Auth: dkim=none
X-KSMG-AntiSpam-Envelope-From: mdmitrichenko@astralinux.ru
X-KSMG-AntiSpam-Info: LuaCore: 132 0.3.132 b92628ca234da971a1a6d61b32804bb3075f0fd2, {Tracking_from_domain_doesnt_match_to}, {Tracking_interpol}, new-mail.astralinux.ru:7.1.1;127.0.0.199:7.1.2;d41d8cd98f00b204e9800998ecf8427e.com:7.1.1;astralinux.ru:7.1.1, FromAlignment: s
X-KSMG-AntiSpam-Interceptor-Info: scan successful
X-KSMG-AntiSpam-Lua-Profiles: 207024 [Oct 27 2026]
X-KSMG-AntiSpam-Method: none
X-KSMG-AntiSpam-Rate: 0
X-KSMG-AntiSpam-Status: not_detected
X-KSMG-AntiSpam-Version: 6.1.1.27
X-KSMG-AntiVirus: Kaspersky Secure Mail Gateway, version 2.1.0.7854, bases: 2026/10/27 10:49:00 #28748526
X-KSMG-AntiVirus-Status: NotDetected, skipped
X-KSMG-LinksScanning: NotDetected
X-KSMG-Message-Action: skipped
X-KSMG-Rule-ID: 1

From: Chuck Lever <chuck.lever@oracle.com>

commit 84dff5eb86ceb2a356d5409fc1af21a366bf3c35 upstream.

During the final stages of publication of RFC 8167, reviewers
requested that we use the term "reverse direction" rather than
"backwards direction". Update comments to reflect this preference.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Tom Talpey <tom@talpey.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Stable-dep-of: c7653d5cebc8 ("xprtrdma: Fix bcall rep leak and unbounded peek")
Signed-off-by: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
---
 net/sunrpc/xprtrdma/backchannel.c          | 4 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c             | 6 +-----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 4 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h            | 6 +++---
 4 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index c92c1aac270a..31514e4d81ff 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2015 Oracle.  All rights reserved.
  *
- * Support for backward direction RPCs on RPC/RDMA.
+ * Support for reverse-direction RPCs on RPC/RDMA.
  */
 
 #include <linux/sunrpc/xprt.h>
@@ -208,7 +208,7 @@ static struct rpc_rqst *rpcrdma_bc_rqst_get(struct rpcrdma_xprt *r_xprt)
 }
 
 /**
- * rpcrdma_bc_receive_call - Handle a backward direction call
+ * rpcrdma_bc_receive_call - Handle a reverse-direction Call
  * @r_xprt: transport receiving the call
  * @rep: receive buffer containing the call
  *
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b8174c77dfe1..bb5648133b10 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1170,14 +1170,10 @@ rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep)
 	 */
 	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
 	if (unlikely(!p))
-		goto out_short;
+		return true;
 
 	rpcrdma_bc_receive_call(r_xprt, rep);
 	return true;
-
-out_short:
-	pr_warn("RPC/RDMA short backward direction call\n");
-	return true;
 }
 #else	/* CONFIG_SUNRPC_BACKCHANNEL */
 {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index feac8c26fb87..2e860c68735f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2015-2018 Oracle.  All rights reserved.
  *
- * Support for backward direction RPCs on RPC/RDMA (server-side).
+ * Support for reverse-direction RPCs on RPC/RDMA (server-side).
  */
 
 #include <linux/sunrpc/svc_rdma.h>
@@ -59,7 +59,7 @@ void svc_rdma_handle_bc_reply(struct svc_rqst *rqstp,
 	spin_unlock(&xprt->queue_lock);
 }
 
-/* Send a backwards direction RPC call.
+/* Send a reverse-direction RPC Call.
  *
  * Caller holds the connection's mutex and has already marshaled
  * the RPC/RDMA request.
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 73c8ab89456b..a89605e14f2f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -95,9 +95,9 @@ struct rpcrdma_ep {
 	unsigned int		re_inline_recv;	/* negotiated */
 };
 
-/* Pre-allocate extra Work Requests for handling backward receives
- * and sends. This is a fixed value because the Work Queues are
- * allocated when the forward channel is set up, long before the
+/* Pre-allocate extra Work Requests for handling reverse-direction
+ * Receives and Sends. This is a fixed value because the Work Queues
+ * are allocated when the forward channel is set up, long before the
  * backchannel is provisioned. This value is two times
  * NFS4_DEF_CB_SLOT_TABLE_SIZE.
  */
-- 
2.43.0

