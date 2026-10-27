Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=37.230.196.243
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793103817;
	b=Lc1DW/dX/05PvVCtyVTcjppRE4IEmXAfPx/CAcEBKvTBBYhbfosOkBqXcjO7XzuwLBZj
	 37dJXXCrkF0UbUrY0+suwGwA9MI5Yum+t3UBnOF11idpNhlHaHU9AyDuMHQTMuZ6cb0p/
	 iPqZAOYvQ74eaRfUl79OGCAATU4/DMYXUmZR79GJ21GjGUvyOHRy4Ott2k1Nn9KuNhZI/
	 k2ga/EehoNZaXG0x82BKdWbc4YR3a8fCoTsv/ZqjEKjAGrrUG2T99mbBDGtTlcgLkz3TP
	 TQo4k5AtEw3uyDmTx7eib68+KJgfrTIlff9cXmXwgL1+3OQskAaToQdSyk6GvHawaRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793103817;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-KSMG-AntiPhishing:X-KSMG-AntiSpam-Auth:
	 X-KSMG-AntiSpam-Envelope-From:X-KSMG-AntiSpam-Info:
	 X-KSMG-AntiSpam-Interceptor-Info:X-KSMG-AntiSpam-Lua-Profiles:
	 X-KSMG-AntiSpam-Method:X-KSMG-AntiSpam-Rate:X-KSMG-AntiSpam-Status:
	 X-KSMG-AntiSpam-Version:X-KSMG-AntiVirus:X-KSMG-AntiVirus-Status:
	 X-KSMG-LinksScanning:X-KSMG-Message-Action:X-KSMG-Rule-ID;
	bh=FTFcRVxMB4E8A0mIeQ6+07gtdiaeR91Z3SjJqQ7IfCI=;
	b=TLqQ9BFdwZrz9ze5SEuh4wYuOC7MVPb5H1WntI5EUF7ewjFAU8aFz7Fq4SaYwONI1lZ2
	 Y8zXNfvsoEHh3GuR4RUC9W651Cv4gpf0cmsv9g7F70tJvaEg6tzB5FezNmXWx4VAYJKqN
	 YDYyYQtdt6slk6sQQBE5/ff2EvzA+Qmi0c08D/JjBUJ8+fVXaBuccF3ades83hjpd4liV
	 OxKLD5jWIDnTO6zWTfxGFm2M3BRuGB9VU3XPNCN95t2UpwKGLH4NVDZ4mra2zpGTI8KNi
	 0kotOIu//O7RpqyxBe2VQpli/XKPIINAqojSQBb81qlIJy9fp+b5vKouZLzQn0r6BBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astralinux.ru;
	spf=pass smtp.mailfrom=astralinux.ru;
	dkim=pass header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=hFKJRVee;
	arc=none smtp.remote-ip=37.230.196.243
Received: from mail-gw01.astralinux.ru (mail-gw01.astralinux.ru [37.230.196.243])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F4FC606A31F;
	Tue, 27 Oct 2026 12:23:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0F4FC606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=hFKJRVee
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=astralinux.ru;
	s=mail; t=1793103811;
	bh=+DLuIycq3dkVz8VhBjz2SPbDt/Mra4q7R1NANeLIGgU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=hFKJRVee5mtL6M0LCGp8YfRpTsw5P74ZIVgUg9hV4F+M4MF4iwpiyoYgvpdxTrKzM
	 F1K4Lh7r2t1MqeCJQ/uYbAfGaFkz5+c4xAPLaVw2Iuu9ySanyZI9740UY5Xq/XzAZt
	 /CSmRdxru1qJbfV2nvW4jB2nH2+6gODAmGcCB73A1ZXm8nxG6L8ryMYl9454f6l6tj
	 Jq61bQLzHIlZ/+KBSg3CZtnsFIy3WBgo/UN5e0WC6/eU9tUbblSrR7cwJIDWd1EijE
	 r24s/PwTt1Oz6PhwR0F4VEWowUKKY3t7FCmz7Xs1COmeLRNRRO5YspgwBbFwJEkyS8
	 0mpfGHp9a9ulg==
Received: from gca-sc-a-srv-ksmg01.astralinux.ru (localhost [127.0.0.1])
	by mail-gw01.astralinux.ru (Postfix) with ESMTP id 4951B25FE9;
	Tue, 27 Oct 2026 15:23:31 +0300 (MSK)
Received: from new-mail.astralinux.ru (unknown [10.205.207.10])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail-gw01.astralinux.ru (Postfix) with ESMTPS;
	Tue, 27 Oct 2026 15:23:30 +0300 (MSK)
Received: from DESKTOP-D46TNHI (unknown [10.198.50.125])
	by new-mail.astralinux.ru (Postfix) with ESMTPA id 4jDTds5sdDz2w2H;
	Tue, 27 Oct 2026 15:02:57 +0300 (MSK)
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
Subject: [PATCH 5.10 v2 2/2] xprtrdma: Fix bcall rep leak and unbounded peek
Date: Tue, 27 Oct 2026 15:01:38 +0300
Message-ID: <20261027120143.1596-3-mdmitrichenko@astralinux.ru>
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
X-KSMG-AntiSpam-Info: LuaCore: 132 0.3.132 b92628ca234da971a1a6d61b32804bb3075f0fd2, {Tracking_from_domain_doesnt_match_to}, new-mail.astralinux.ru:7.1.1;d41d8cd98f00b204e9800998ecf8427e.com:7.1.1;astralinux.ru:7.1.1;127.0.0.199:7.1.2, FromAlignment: s
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
Signed-off-by: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
---
Backport fix for CVE-2026-72466
 net/sunrpc/xprtrdma/rpc_rdma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index bb5648133b10..c9e179b7366e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1146,6 +1146,8 @@ rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep)
 
 	/* Peek at stream contents without advancing. */
 	p = xdr_inline_decode(xdr, 0);
+	if ((char *)xdr->end - (char *)p < 5 * XDR_UNIT)
+		return false;
 
 	/* Chunk lists */
 	if (xdr_item_is_present(p++))
@@ -1170,7 +1172,7 @@ rpcrdma_is_bcall(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep)
 	 */
 	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
 	if (unlikely(!p))
-		return true;
+		return false;
 
 	rpcrdma_bc_receive_call(r_xprt, rep);
 	return true;
-- 
2.43.0

