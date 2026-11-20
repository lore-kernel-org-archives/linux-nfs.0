Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795154430;
	b=BOobYxbNiXple9N8VlA6J9oaCwAWe5T6v1eTTjh9caXyjK2IRrV6Yg3CcCsSayDQDKZe
	 DBuPzMBaQuHt5y4N32Mj37dBieYa6EuzX3eXzwDSVxIKaV4lvnArOJ/on8u0rL97l8yQ3
	 HBCdsx7QRFxzqJOjkfpeM5EZFqNU8zNGJ4gctYiDWWX/caRXKUZLaTbWbBzzY4KiJB47v
	 1mqGc5sJzNRjgy1/kl5MInotWtTau6ekqraF1srElonqRe7dumNX7mRWuEMPnQcEBsjWY
	 lqM9yMRjjEmze56VKMZ4EWwFYaDBkOjJr5PGs6ftnNBjaI1jkXG9TJhEFZPj5WiKLZw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795154430;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=5Uq0u2UqluTfsfMVM/ngVbgb8vECy5ebkPRwAU+bl3s=;
	b=SS8jlk+fFZmV8PCdTMtVP4G9LkLUUeZYrMUoJnFqt2XbDi/mnACbLDqWgyI+zLdboZZ+
	 N5uZfGfPQzdk2njzuPReHXn5M2dAQZ2j6VgxY+SQy08t4ExWhtRl7+lPjXDZA1xaH3aFx
	 pObkYzXxEmmSN1dhFV4oN4CKv72biQLqtdSOV32yMGKpxI3UDJS7ITFwyUQZ2Wv52LAWk
	 SE6A8eirpbEiAlxYTte0YwcnW0dGRFxbNM2u0n+qam896Mu4ae89r3u4745lNJNkQlOzB
	 3MK50k02UnqNX1lducN6JA27K6PwfsAT0pQ8Hu6EV420UO8N55AKOJphI6O+EBzoNYg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ikuyo.dev;
	spf=pass smtp.mailfrom=ikuyo.dev;
	dkim=pass header.d=ikuyo.dev header.i=@ikuyo.dev header.a=rsa-sha256 header.s=s1 header.b="kU5r/FrA";
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
Received: from sender5-op-o15.zoho.com (sender5-op-o15.zoho.com [165.173.182.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A6AF606A525;
	Fri, 20 Nov 2026 06:00:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3A6AF606A525
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ikuyo.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ikuyo.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ikuyo.dev header.i=@ikuyo.dev header.a=rsa-sha256 header.s=s1 header.b=kU5r/FrA
ARC-Seal: i=1; a=rsa-sha256; t=1795154412; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=ksIpHU2pSu+1+Zehrg0nhruRQKUeMFc/z0WOZRX8k14AHgb7KtkhWJ7pKV5eEeXTwuVbX1bBEib+Nbh3NEeVH7w8hBJalFRye0Zm7yUarJnDI9AeCB9srAbB0oPujpoT58L/5A0yEkdTpA/NLgwyOSawNaGYKqe6qiJTg4e4Gy8=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795154412; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=5Uq0u2UqluTfsfMVM/ngVbgb8vECy5ebkPRwAU+bl3s=; 
	b=GX34z2lfoujbv+i4FUQnqVX/n6BOYKKEXO2FBVI/V8YusQJSZ/mqyQg3Ew5lIrR6kVMI0lBDtM352nG8yyvbUPuYOIwOAJs6E7xEkeXx3M+1bQQ96KyFe2tZJYgg5he1xZ+JJwVdWy5dyb9a2hZlRx/ObM8N7HSLdtEId4jAC20=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=ikuyo.dev;
	spf=pass  smtp.mailfrom=eritque-arcus@ikuyo.dev;
	dmarc=pass header.from=<eritque-arcus@ikuyo.dev>
DKIM-Signature: a=rsa-sha256; b=kU5r/FrA9VFlj8KOZytdj8Ed5L5B4OKMwLySVG+OTOT4ovMklkcxvF0yJNFYf8FjMMjUeKsI1oxzlSkiwclCr7hJk9GbtekI1ToUuVfQS/cXKTC3WhKaxQXD3wrK24KryJuqydW2/p1L1mYlULvCDM5kJylAe/QBN9fzv58UpJnRA3o/GMbtIW7Vu5ptBls+N2j3rxvfzu2ePCuC/ZJlW0O92oWpTl6R+juMjzbvh7j/rrurFig+Hgng7rShySDI5isarvM80OdotA0kSm6vXr3gofhFYpF7Vt4KGcAWEzgb/LZT35HrVU2X6T3OmxDPKy8FakR+eFN+vedPNz5d8w==; c=relaxed/relaxed; s=s1; d=ikuyo.dev; v=1; bh=5Uq0u2UqluTfsfMVM/ngVbgb8vECy5ebkPRwAU+bl3s=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795154409481972.0674257614792;
	Thu, 19 Nov 2026 22:00:09 -0800 (PST)
From: Yiran Qiu <eritque-arcus@ikuyo.dev>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Yiran Qiu <eritque-arcus@ikuyo.dev>,
	stable@vger.kernel.org
Subject: [PATCH] SUNRPC: copy the GSS init token with read_bytes_from_xdr_buf()
Date: Fri, 20 Nov 2026 01:00:07 -0500
Message-ID: <20261120060007.302599-1-eritque-arcus@ikuyo.dev>
X-Mailer: git-send-email 2.56.1
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

gss_read_proxy_verf() copies the token from the head of rq_arg and then
from rq_arg.pages, assuming the rest of the token is in the page list.
svcrdma rebuilds a Call that carries one Read chunk as head (inline data
before the chunk position), pages (the chunk) and tail (inline data
after it), and xdr_stream_remaining() counts the tail. When the token
starts at the chunk and continues into the tail, the copy runs past the
chunk's pages. If the chunk fills rq_pages, the copy takes the NULL
entry at rq_pages[rq_maxpages] and memcpy() reads from
page_address(NULL); otherwise the stale contents of the next page go to
gssproxy in place of the tail. This runs in svcauth_gss_proxy_init()
before any credential is checked, so a client of an NFS/RDMA server that
uses gssproxy can oops nfsd threads without authenticating.

Commit 62319c2534b6 ("SUNRPC: fix oversized GSS proxy token copy") fixed
the copy from the head and left the copy from the pages as it was. Copy
the token with read_bytes_from_xdr_buf(), which follows head, pages and
tail.

Found with afb-afl, an LLM-driven kernel audit/repro pipeline; the fix
and this changelog were also drafted with LLM assistance. Reproduced on
an unmodified KASAN build of mainline, nfsd listening on "rdma 20049"
over rxe with use-gss-proxy set. An RPCSEC_GSS INIT Call whose token is
a 12-page Read chunk (max_block_size 32768) plus 64 inline bytes gives
(gss_read_proxy_verf() is inlined):

  BUG: KASAN: wild-memory-access in svcauth_gss_proxy_init+0x71f/0xe10
  Read of size 64 at addr 0005088000000000 by task nfsd/184
   __asan_memcpy+0x23/0x60
   svcauth_gss_proxy_init+0x71f/0xe10
   svcauth_gss_proc_init+0x22b/0x440

With an 11-page chunk, gssproxy received the chunk followed by 64 bytes
that were not the tail. With this patch there is no report and gssproxy
receives the chunk followed by the tail, for 12- and 11-page chunks; a
chunk without a tail and an inline token are unchanged. Over TCP, tokens
of 100 to 30000 bytes reach gssproxy intact with and without this patch.
Kerberos and NFS functional tests were not run.

Fixes: 5866efa8cbfb ("SUNRPC: Fix svcauth_gss_proxy_init()")
Cc: stable@vger.kernel.org
Signed-off-by: Yiran Qiu <eritque-arcus@ikuyo.dev>
---
Tested on mainline 4405c18c95d2 (v7.4-rc3+) in QEMU. Applies to
cel/linux.git nfsd-next and nfsd-testing.
A reproducer and the test logs are available on request.

 net/sunrpc/auth_gss/svcauth_gss.c | 38 +++++++++----------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 43839e805531..da4043aed247 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1056,9 +1056,8 @@ static int gss_read_proxy_verf(struct svc_rqst *rqstp,
 			       struct gssp_in_token *in_token)
 {
 	struct xdr_stream *xdr = &rqstp->rq_arg_stream;
-	unsigned int length, pgto_offs, pgfrom_offs;
-	int pages, i, pgto, pgfrom;
-	size_t to_offs, from_offs;
+	unsigned int base, length;
+	int pages, i;
 	u32 inlen;
 
 	if (dup_netobj(in_handle, &gc->gc_ctx))
@@ -1090,30 +1089,15 @@ static int gss_read_proxy_verf(struct svc_rqst *rqstp,
 		}
 	}
 
-	length = min_t(unsigned int, inlen, (char *)xdr->end - (char *)xdr->p);
-	for (to_offs = 0; to_offs < length; to_offs += PAGE_SIZE)
-		memcpy(page_address(in_token->pages[to_offs >> PAGE_SHIFT]),
-		       (char *)xdr->p + to_offs,
-		       min_t(unsigned int, length - to_offs, PAGE_SIZE));
-	inlen -= length;
-	to_offs = length;
-	from_offs = rqstp->rq_arg.page_base;
-	while (inlen) {
-		pgto = to_offs >> PAGE_SHIFT;
-		pgfrom = from_offs >> PAGE_SHIFT;
-		pgto_offs = to_offs & ~PAGE_MASK;
-		pgfrom_offs = from_offs & ~PAGE_MASK;
-
-		length = min_t(unsigned int, inlen,
-			 min_t(unsigned int, PAGE_SIZE - pgto_offs,
-			       PAGE_SIZE - pgfrom_offs));
-		memcpy(page_address(in_token->pages[pgto]) + pgto_offs,
-		       page_address(rqstp->rq_arg.pages[pgfrom]) + pgfrom_offs,
-		       length);
-
-		to_offs += length;
-		from_offs += length;
-		inlen -= length;
+	base = xdr_stream_pos(xdr);
+	for (i = 0; i < pages; i++) {
+		length = min_t(unsigned int, inlen - i * PAGE_SIZE, PAGE_SIZE);
+		if (read_bytes_from_xdr_buf(&rqstp->rq_arg, base + i * PAGE_SIZE,
+					    page_address(in_token->pages[i]),
+					    length)) {
+			gss_free_in_token_pages(in_token);
+			goto out_denied_free;
+		}
 	}
 	return 0;
 
-- 
2.56.1

