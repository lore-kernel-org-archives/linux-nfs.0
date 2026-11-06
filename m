Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793977324;
	b=GRSF4CZdDV8q+2JQsAOStNiSDf7X3bu/X+MSEcDZebXJMZRVxXf4yfYBAAGm7gE44q3v
	 fGEL5MmLVkqh9EvP48MjWOpYH8XiiwZnSiTBe/3XZIUZmiKOL7lDWntb0sfMeXSe59RS1
	 HwLEoq2wUYxprJNY8sO6Ej7e760DXAHQ5tHGVWhN3AialKzQleMRSrXJWRKNyfq6i6kJM
	 2bw+t5NKWH0QwCe5PdM7ck2XU361QgdnC3JHmxpNDYyT3xyHINv0gb8Fj2ZEU9we4wiHR
	 oDhr7Lyj4e3xBuDriKPJQoElQ402mzG3G2Dwi6J8eDlAMDw99ipVqCTbOYh1nZFlamQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793977324;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=OJGwMOZr8wszMXP4PUI9DRebX0Fe8M4M+JLp3x5FAMo=;
	b=dM1LOeXUGvIAn9nTUjZL/it8ehIli8+DDEBer3Kwsay61kDG3U6LvhMyXGjtfbAhF2X7
	 kOiGOn6QXq7/QpIZFupld++7toJoR/tw3I6DPo+CWeo5xnD9xTWDe3SI0J66GBsAh/+1K
	 MzecmLuJnW+/b+qT0fcFoaVI9zsCqOuVLSrDlaURl1FzjBGpc4YTlcjOVN2EoknAr0Qjc
	 kSb+B00M1kmgS4npqeM5ohbBBisYvzrsvW2weArQhIgG6JoEap0KlVxOo9gaPCvEHmxVS
	 Dbk2BCOT8jLi7TxWy8N3mrDN3bHmBKoTuJwThQcE1pYIi+t14dfCRmseU2eIC6eFCbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dni3PlMe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2D3C606A334;
	Fri,  6 Nov 2026 15:02:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dni3PlMe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA7FD1F0089F;
	Fri,  6 Nov 2026 15:02:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793977323;
	bh=OJGwMOZr8wszMXP4PUI9DRebX0Fe8M4M+JLp3x5FAMo=;
	h=From:To:Cc:Subject:Date;
	b=Dni3PlMeE484Iio3dTd57C8UoEN9onhzXtRfIJLPZfMXotBe3zZz0lg80gmaRQiKG
	 5N1oR+G5ti1DGCHcXUrbV0u/yhUgPmItlPCPvjStiYThn+zkMr6AAHU/pcGKR14xQ1
	 /Poq8ytyVHyEhVplE8fDs4aeJRWlVzP+IjFPPk2vKkEUWSGEv9gJ4Lm5CKZmY6zBAS
	 HTxEDh9qry5O62R+X25qO1/VnZZf35SrUvEzv8lRDl4BANcGG5wJZpNVdDnAT4yOB9
	 A6TJmCM28lXuz6gN3/xrVQbT5icC4BflYEE0ROQ3cdPgh390pC96+Xx3ZJmh3OO1Xu
	 6SEIclcaPtDYA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH] SUNRPC: Honor page_base beyond the first page in xdr_buf_to_bvec()
Date: Fri,  6 Nov 2026 10:01:59 -0500
Message-ID: <20261106150159.847600-1-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
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

xdr_buf_to_bvec() takes offset_in_page(page_base) but starts its
walk at pages[0], so the page index that page_base carries above
PAGE_SIZE is dropped. nfsd_direct_read() sets rq_res.page_base to
the pad below the file's DIO offset alignment. When that alignment
exceeds PAGE_SIZE, as with 8K to 64K logical blocks under xfs or
ext4 on a 4K-page NFSD, a direct READ whose pad reaches a full page
sends the page before the one that holds the data. The defect was
found by inspection, not reproduced.

Advance the page pointer by page_base >> PAGE_SHIFT before the walk.

Commit 2eb2b9358181 ("SUNRPC: Convert svc_tcp_sendmsg to use
bio_vecs directly") introduced the dropped shift, but no caller
produced a page_base of a page or more until direct READ.

This fix depends at run time on nfsd4_encode_operation() deriving
rq_next_page from page_base as well as page_len. Otherwise the READ
encoder accounts for one page fewer than xdr_buf_to_bvec() now
transmits, and the last page sent sits outside the release range
while TCP still references the page.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Cc: <stable@vger.kernel.org> # v6.19+
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 7353109fdbae..7eef50634175 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -161,7 +161,7 @@ int xdr_buf_to_bvec(struct bio_vec *bvec, unsigned int bvec_size,
 
 	if (xdr->page_len) {
 		unsigned int offset, len, remaining;
-		struct page **pages = xdr->pages;
+		struct page **pages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
 
 		offset = offset_in_page(xdr->page_base);
 		remaining = xdr->page_len;
-- 
2.56.0

