Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254015;
	b=LYWv/qlxlXrIaRZwV0jxuoA0ko41VYaOGzzArLYO/GJG0r1ju7G/74BEE8JnECO8ORIK
	 5TzSsXIfbvNyg1P4Ffc0Pk1LTjsr6s/SJ7KhPIdkGqTR/lkHKSRkVsKLoovjD91pdH4Bs
	 cEZvs3zK5Ilo5oemuu8dgcnbKaQZYnrhoYnE7ABLwAq0Oj6k+fteErxCPe09mUf1+V6rc
	 TMwwx1/7bIIC+VH3k4IqZxzoBtM3Y4pFzcdZHhuMvi1fVkJ/qwFyk+jGFUZFUbOQ0l7sf
	 R8zTtGzU2msqH62x5qw8l//IYALP+uzi67cndsJDJ7GLyEaT2ejyVRMAMSXyEzpB0jQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254015;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=75r6ALbhbpYcOAJoj5OO75emU4hhEHRSz/mZP8lBVEM=;
	b=2GkHPGePKpnAtmhrpKI+aK2cTEVecldzVm9uGSC2iCYrqYgnGRx9iMRogW7Cfbc1hwHy
	 8mqUH1YtbPPQ7EXr3gYDNeVNSNuFWtHfQbXPyMP5RMbDiECQ31jbxkal6/5qCcV7aMN7r
	 V9nETGkvchc2Of2M75MMrMnArM82JyqdDcwchWRK7wDjS43QECJ20w12RbcFnShRfbaHs
	 seFKEiuwZeJu/CaQjhvw2ZOZJPaiRZKFtfVisexCWmGcXrLfOt4wOxUM7h40n302UH7IV
	 U7EZisN1fPlWE/BhsOxIY5dOxOBl2GvPyiczi+GdbyhQU+AuMfsZDWBGXPBcOwMyu5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oeYYZvw0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDC0860A5BC1
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oeYYZvw0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF9621F00903;
	Mon,  9 Nov 2026 19:53:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254014;
	bh=75r6ALbhbpYcOAJoj5OO75emU4hhEHRSz/mZP8lBVEM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oeYYZvw0uJgW09hLfw18YqLiRtCqjlh5nLAs+2rmkDzLrMNyYwZXvw7xi686m6WNK
	 tJ8l0op/vZPRRsMS+gORBHKtLXVGKU2Q0Pv0TfeZS24c5FjDddHVDnVADEijJZwuCf
	 DXCjvHeupKgo1XOk8/W3BtX9cllb8FHy1oN/izRMmHkKKneDkNZlSKtY0bJOoSXB2x
	 lWeeqj7YeuTN4ZQAcWSPP5PCpbRzznS8N7ZgceGWHr9f0apf0LOTLo8IcZOxRn8w2C
	 ZXKkxgkGMeNml/pUI/x+gRJTxBdk7hrkKrsNsCewYNnRzfi6xTDIbtoCwqBUHUOI+O
	 5ZZgEPleu2cEg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:21 -0500
Subject: [PATCH 05/13] NFSD: Return NFS4ERR_IO when a payload overflows the
 Write chunk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261109-xdr-page-base-v1-5-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1426; i=cel@kernel.org;
 h=from:subject:message-id; bh=nJ8JNuYlWWik5Yf726TJ9/MnZYR7hqOyacO2gz/twhM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS48FY+p4cXuqn72IIqZJRwf8HKY9eagkfhz
 cKAHEkoIdSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 lws/EACr1BUDRw3CfrQz2BM3xWDXXMl+1BXXgBdxJV9fjnVUgv7L92ipOUqdWC1vY8uFEdDRkCK
 vNDfmazkK3qWPSfbzOogM3sPzqWEupMH5LW0SPwolqNYRY9UIrk2XikP/yPBgbamwUS3EgaOc4I
 xCW3AZCrJyneHz8QkaQfIF/xsryndWQmZEvUQSGcU8TmF/AdJRhIvCMZkR2wkG3qGUPHpQ4/XLF
 1j0u929jgady5sKHcT51TIoA/eNIL9nv78BsoygQQAB1zNUhW4UKlGqYgfaZkwiaeesMnLxc73Q
 ih3gdAi4qhEBEXhdRHH6e8anVr2OuFNhv/wfIiFzA5/KKpHGYoC79Ps8hSYGn72BdWEywGb7Vxl
 PCLnZUqe3Okjr/S2ivni7K7cGwuN9iMHifz7pPYPvA617jSbOKOWoy8iRjPzYsqHS2QWiHLvD2E
 ksilW1sINyh1PoXsPLvH75kjiTh/zOUT6km4iWRbgPRvuLX0d08XPRqBWP7HDlHxOyCB6T3PQAS
 zIZiYfsFoHSGLxPcpd7eVt8pqYuH4HKWb9Y+eS793ea/nQACnje9Ks6Ci09Pq97pyL+NkDr/4sH
 c3eVw08jKwcwddvvipTcf/A++Q6Xhg+kN/4iHj29CUkbmDXuWFdNF46onU9KxS4rmZzfJLLke7Q
 Y2jFV4WAiyZnZfQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_rdma_result_payload() returns -E2BIG when the client's Write chunk
is shorter than the result payload. nfsd4_encode_splice_read() and
nfsd4_encode_readlink() pass that through nfserrno(), which maps
-E2BIG to NFS4ERR_FBIG. RFC 8881 does not permit NFS4ERR_FBIG for
READ or READLINK, and nfsd4_encode_readv() already returns NFS4ERR_IO
for the same failure.

Return NFS4ERR_IO from the splice and READLINK paths as well.

Fixes: 76e5492b161f ("NFSD: Invoke svc_encode_result_payload() in "read" NFSD encoders")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fc14b31616d5..daa52bc5f582 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5278,7 +5278,7 @@ static __be32 nfsd4_encode_splice_read(
 	status = svc_encode_result_payload(read->rd_rqstp,
 					   buf->head[0].iov_len, maxcount);
 	if (status) {
-		nfserr = nfserrno(status);
+		nfserr = nfserr_io;
 		goto out_err;
 	}
 	svcxdr_encode_opaque_pages(read->rd_rqstp, xdr, buf->pages,
@@ -5422,7 +5422,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr,
 	status = svc_encode_result_payload(readlink->rl_rqstp,
 					   length_offset + XDR_UNIT, maxcount);
 	if (status) {
-		nfserr = nfserrno(status);
+		nfserr = nfserr_io;
 		goto out_err;
 	}
 

-- 
2.56.0

