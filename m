Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=37.230.196.243
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792669837;
	b=HGA3V4mi7dhelqc5Ewwj8eX5LpcI22Aw5Lb5sUuXbV4JlL5lCxROiMyN6EqwHqcQlPqe
	 /8mKiS6Zzno/1+zimaJynwOOlH62Uaq2GoEyBNYMA1LYY5iyGl8b4ZuVKel154koSfgUE
	 czUiyX+pj3UxPk9VRwdsXGi9wEz94alVhXZ6sd+ajKcKmjiSqA4xXAIWKwrISFVCdZty4
	 7mbTEXoeRo+vhchix7ZfJ1GTaSPRjEbEc1GVbmKln3Cgq6ca89QZO8eb9y9XniSyygkUv
	 +JzXJFyAqft7yUAw9qOadiHhK46gmPTva9DylGEO/PhAN1P4V3F6XswEImX4JMZOhdg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792669837;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:X-KSMG-AntiPhishing:X-KSMG-AntiSpam-Auth:
	 X-KSMG-AntiSpam-Envelope-From:X-KSMG-AntiSpam-Info:
	 X-KSMG-AntiSpam-Interceptor-Info:X-KSMG-AntiSpam-Lua-Profiles:
	 X-KSMG-AntiSpam-Method:X-KSMG-AntiSpam-Rate:X-KSMG-AntiSpam-Status:
	 X-KSMG-AntiSpam-Version:X-KSMG-AntiVirus:X-KSMG-AntiVirus-Status:
	 X-KSMG-LinksScanning:X-KSMG-Message-Action:X-KSMG-Rule-ID;
	bh=3oJECff/6TmNjjeVvttGOtHn9ZcQvbn4GEFnSWveklU=;
	b=x4WSyoAhVNnXtoSZ6BlHK+S4nAmQo10GPMKWspTZqasguSBwCKaEEb/9o20Vp3I+NDMy
	 RzXgHjSJxi8zN53LzGlQqX4fkFm0ieyoLjkVP7zB9QzTEMSSk7gQ1JlGN24jQf75KOamv
	 EJPZ5oX9iO2Nt4xHQUZkn5qx7CmuUEeiT1Nn0CJf0cFgON5M3zEpOuLhTNl1kycbNQYhb
	 zjlxddsuR81oof1cJ7u5xQZl8wqYCVvrlFfbrRpvPFJEVpy+JgSzMePFe2//riXegMcfh
	 QVNpJqyq/mf+L1rmhpwi5IXk7SqPf27zzEJguNBgjd3dI5ziMTPQnCeGAdQVVRLCyxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astralinux.ru;
	spf=pass smtp.mailfrom=astralinux.ru;
	dkim=pass header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=HTyTEdqo;
	arc=none smtp.remote-ip=37.230.196.243
Received: from mail-gw01.astralinux.ru (mail-gw01.astralinux.ru [37.230.196.243])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C6D5606A319;
	Thu, 22 Oct 2026 11:50:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6C6D5606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=HTyTEdqo
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=astralinux.ru;
	s=mail; t=1792669830;
	bh=RoWr8fDzA3UyiihscIKqmbkE7eoSYQCoE7+XgXJK44A=;
	h=From:To:Cc:Subject:Date:From;
	b=HTyTEdqoYwizTzEYXMjLAM94msMUUplS2R0b9qpWvlMv9sotVUSxUt2vrGgEtLITG
	 /Zpk26HeDyflyFT8rV3DAeJCck/2TdWCCplJXLLL0qiP+m92h4dLk4vSAsodwAD4H0
	 YQTCcr43mePI0lzg5HsSNJ7w61IEUqMqv7zM9osCwEWoty/3T7jkxJyypSdLr8IX2/
	 qfXQ9G2DnpQ4vcwM2OqGzSAgTCVqkOibrYbvcq8ipuTQwH95z0KJU0MsvtW9zNMSYH
	 pRv4pssvBIPHJlGzTE1MnueOeTz9A4ZCcpEZVgG7uZTRkRmM1PFsQlp3fcLSZibt5g
	 vgX0JEO/Tiymw==
Received: from gca-sc-a-srv-ksmg01.astralinux.ru (localhost [127.0.0.1])
	by mail-gw01.astralinux.ru (Postfix) with ESMTP id 03268259D9;
	Thu, 22 Oct 2026 14:50:30 +0300 (MSK)
Received: from new-mail.astralinux.ru (unknown [10.205.207.10])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail-gw01.astralinux.ru (Postfix) with ESMTPS;
	Thu, 22 Oct 2026 14:50:27 +0300 (MSK)
Received: from DESKTOP-D46TNHI (unknown [10.198.49.111])
	by new-mail.astralinux.ru (Postfix) with ESMTPA id 4j9Pbk4BDfz2Khh;
	Thu, 22 Oct 2026 14:50:26 +0300 (MSK)
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
	Anna Schumaker <anna.schumaker@hammerspace.com>
Subject: [PATCH 5.10] xprtrdma: Fix bcall rep leak and unbounded peek
Date: Thu, 22 Oct 2026 14:50:02 +0300
Message-ID: <20261022115004.1615-1-mdmitrichenko@astralinux.ru>
X-Mailer: git-send-email 2.54.0.windows.1
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
X-KSMG-AntiSpam-Info: LuaCore: 131 0.3.131 f330ffd1b9dcd8f1d29707120f19686573775fe7, {Tracking_from_domain_doesnt_match_to}, new-mail.astralinux.ru:7.1.1;127.0.0.199:7.1.2;astralinux.ru:7.1.1;d41d8cd98f00b204e9800998ecf8427e.com:7.1.1, FromAlignment: s
X-KSMG-AntiSpam-Interceptor-Info: scan successful
X-KSMG-AntiSpam-Lua-Profiles: 206897 [Oct 22 2026]
X-KSMG-AntiSpam-Method: none
X-KSMG-AntiSpam-Rate: 0
X-KSMG-AntiSpam-Status: not_detected
X-KSMG-AntiSpam-Version: 6.1.1.27
X-KSMG-AntiVirus: Kaspersky Secure Mail Gateway, version 2.1.0.7854, bases: 2026/10/22 03:54:00 #28723736
X-KSMG-AntiVirus-Status: NotDetected, skipped
X-KSMG-LinksScanning: NotDetected
X-KSMG-Message-Action: skipped
X-KSMG-Rule-ID: 1

From: Chris Mason <clm@meta.com>

commit c7653d5cebc8492c77ec0415b5e9c0fb3e644bc6 upstream.

rpcrdma_is_bcall() decodes a reply's first words to decide whether
the frame is a backchannel call. Two issues in that decode path
let a short or malformed reply leak the receive buffer and drain
the Receive queue.

First, the speculative peek

    p = xdr_inline_decode(xdr, 0);
    /* five p++ reads follow */

asks xdr_inline_decode() for zero bytes, which returns xdr->p
without consulting xdr->end. The five subsequent __be32 reads can
then walk up to 20 bytes past the wire payload into stale regbuf
contents and misclassify the reply as a backchannel call.

Second, after the post-peek

    p = xdr_inline_decode(xdr, 3 * sizeof(*p));
    if (unlikely(!p))
            return true;

the short-header arm returns true without calling
rpcrdma_bc_receive_call(). The contract with the caller is that a
true return transfers ownership of rep to the backchannel path:

    rpcrdma_reply_handler()
      if (rpcrdma_is_bcall(r_xprt, rep))
              return;        /* bare return, skips out_post */
      ...
    out_post:
      rpcrdma_post_recvs(r_xprt, credits + ...);

Because rpcrdma_bc_receive_call() never ran, no one took rep, but
rpcrdma_reply_handler still bare-returns past rpcrdma_rep_put()
and rpcrdma_post_recvs(). The rep, with its persistently
DMA-mapped receive buffer, is orphaned on rb_all_reps and freed
only at transport teardown. This completion reposts nothing, so
its slot is reclaimed only when a later forward-channel reply
reaches out_post and rpcrdma_post_recvs() allocates a fresh rep to
backfill; absent that traffic the Receive queue drains and the
peer's Sends draw RNR NAKs.

Fix by consulting xdr->end after the zero-length peek so the five
__be32 reads cannot run unless 20 bytes of wire payload remain. A
byte-precise comparison against xdr->end is required because a
non-4-aligned receive rounds the stream's word count up past the
true payload. Also return false from the short-header arm so the
reply falls through the normal out_norqst cleanup chain
(rpcrdma_rep_put() plus rpcrdma_post_recvs()).

Fixes: 41c8f70f5a3d ("xprtrdma: Harden backchannel call decoding")
Assisted-by: kres:claude-opus-4-7
Signed-off-by: Chris Mason <clm@meta.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
[ mdmitrichenko: 5.10 lacks commit 84dff5eb86ce ("rpcrdma: Fix
  comments about reverse-direction operation"), which replaced the
  out_short label with a direct return. Return false directly here as
  well and drop the out_short label together with its pr_warn(), which
  would be unused otherwise. ]
Signed-off-by: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
---
Backport fix for CVE-2026-72466
 net/sunrpc/xprtrdma/rpc_rdma.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b8174c77dfe1..c9e179b7366e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1146,6 +1146,8 @@ rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep)
 
 	/* Peek at stream contents without advancing. */
 	p = xdr_inline_decode(xdr, 0);
+	if ((char *)xdr->end - (char *)p < 5 * XDR_UNIT)
+		return false;
 
 	/* Chunk lists */
 	if (xdr_item_is_present(p++))
@@ -1170,14 +1172,10 @@ rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep)
 	 */
 	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
 	if (unlikely(!p))
-		goto out_short;
+		return false;
 
 	rpcrdma_bc_receive_call(r_xprt, rep);
 	return true;
-
-out_short:
-	pr_warn("RPC/RDMA short backward direction call\n");
-	return true;
 }
 #else	/* CONFIG_SUNRPC_BACKCHANNEL */
 {
-- 
2.43.0

