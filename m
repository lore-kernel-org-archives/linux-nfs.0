Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792512830;
	b=W7Zr5wB5UNnVdg36T4x+yrDQXWkXjCkQfvfYX1VnKn25NWEQVSedcgOyA4bhTy2l+ygp
	 RoMZVNqHPJ7ZSRJblzcIxkvbEfKlPyCU2S9AjdlF88Mgp75eXen3E9RrNC6/w+Tmb1hTZ
	 2nqM+QD0BAzlSxl81JNbcuJWzUd4xpkas57PHgpyhX1Bfvg6+a0DU9TczghKwSU5alkUz
	 ToUEl6yEHdWcrq2JZl5aTC+54h6DV5pIi860jR1fZwp1u6uJgjpikQrB3UMFENarnen1q
	 PxcKLZnPAmtmf+g4r/lhsWKXJpa1qPMFjSjf0HXCDrHp5YvdLRdAplUKp5QFP9dh1YQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792512830;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=21xL5Xt7fgOygZiIQ1tbQetGmQvRIV3CMYur/E8Kap8=;
	b=wnP4wnWrs5hqvAwzblR1EyIV4X6zh1SworynbmxJzs6wgitgj+PzN/9AMr9EEja+7mVK
	 RZbJvfuH3LidohpHvYDMkI5eKhEG1gEiUpRvb/pI0dah5NNy2ECEx8HBG6hbN7kCR4OAf
	 OTpFam5j4PsUDc4MOfSmTyGO9P7hrXmXzyjbktX/pY7cCy+L18PABA7tFFJvMJa5xquwt
	 QarvuPUrMNTguK4dd5/mlbzXlU/HDaQSBlaojA2DenNnDdSKm2kb0RZ26NOjzgPsjLRKh
	 tPvTo6U3kzSg3O60nx3MxF8KDHPF7Pjhw/kpxYBAMI0DSfFIBpP3oDm2SyKqtlhVzSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04356606A319;
	Tue, 20 Oct 2026 16:13:49 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8AD841F000C4;
	Tue, 20 Oct 2026 16:13:48 +0000 (UTC)
From: Sasha Levin <sashal@kernel.org>
To: Mark Brown <broonie@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@gmail.com>,
	Chuck Lever <cel@kernel.org>,
	Anna Schumaker <anna.schumaker@hammerspace.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Tim Menninger <tmenninger@everpuredata.com>,
	Yongjian Mu <ymu@everpuredata.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Subject: [PATCH linux-next] xprtrdma: fix up the nfs/nfs-anna merge of the Write chunk head trim
Date: Tue, 20 Oct 2026 12:13:46 -0400
Message-ID: <20261020161346.3711926-1-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <as4aacUf2Q78FMvY@sirena.org.uk>
References: <as4aacUf2Q78FMvY@sirena.org.uk>
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

Two fixes for the same Write chunk payload corruption meet in
linux-next. In the nfs tree, commit a0db57fee35e ("xprtrdma: Fix Write
chunk payload corruption on a short reply header") trims
head[0].iov_len in rpcrdma_decode_msg(). In the nfs-anna tree,
commit 9ee534a75912 ("xprtrdma: trim head iovec when the payload
arrives via a Write chunk") trims it in rpcrdma_inline_fixup() and
reduces buflen by the same amount.

The merge resolution keeps the caller-side trim. By the time
rpcrdma_inline_fixup() runs, head[0].iov_len already equals copy_len,
so the block added by the nfs-anna commit never runs and its buflen
reduction in rq_rcv_buf and rq_private_buf is lost. The helper is also
still passed xdr_pad_size(writelist), while its kernel-doc now
describes @writelist as the number of bytes conveyed by the Write
chunk.

Drop the caller-side trim and pass the full Write chunk length, so
that rpcrdma_inline_fixup() is the only place that trims head[0] and
reduces buflen. Compute the pad with xdr_pad_size() in the helper, so
the padding from the nfs commit stays correct for lengths that are not
a multiple of four. Its rpclen calculation and empty reply check stay
in rpcrdma_decode_msg().

Fixes: 53ab189bdc14 ("Merge branch 'linux-next' of git://git.linux-nfs.org/projects/anna/linux-nfs.git")
Link: https://lore.kernel.org/all/as4aacUf2Q78FMvY@sirena.org.uk/
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
Mark, this applies on top of next-20261020 and is meant to be folded into the
nfs-anna merge resolution.

Tim's reproducer passes with either resolution, since head[0] is trimmed in
both. The only behavioral difference is the buflen reduction. I found no reader
on the Write chunk READ decode path that uses the extra buflen, so this
restores the nfs-anna buflen change as reviewed rather than fixing an observed
failure.

Chuck, Anna, Trond: does this match what you want Linus to see?  Neither tree
is in mainline yet, so whichever pull request goes second will hit this
conflict.

This comes from our llminus-assisted integration tree. Build tested with W=1
only; I have no RPC/RDMA setup to run it.

 net/sunrpc/xprtrdma/rpc_rdma.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c0d5042f3b660..69d4e35d49ef5 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1010,7 +1010,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len,
 	char *destp;
 	struct page **ppages;
 	int page_base;
-	int pad = writelist & 3;
+	int pad = xdr_pad_size(writelist);
 	unsigned int delta;
 
 	/* The head iovec is redirected to the RPC reply message
@@ -1267,14 +1267,9 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 		rpclen &= ~3;
 	if (unlikely(!rpclen))
 		return -EIO;
-	if (writelist && rpclen < rqst->rq_rcv_buf.head[0].iov_len) {
-		rqst->rq_rcv_buf.head[0].iov_len = rpclen;
-		rqst->rq_private_buf.head[0].iov_len = rpclen;
-	}
 
 	r_xprt->rx_stats.fixup_copy_count +=
-		rpcrdma_inline_fixup(rqst, base, rpclen,
-				     xdr_pad_size(writelist));
+		rpcrdma_inline_fixup(rqst, base, rpclen, writelist);
 
 	r_xprt->rx_stats.total_rdma_reply += writelist;
 	return rpclen + xdr_align_size(writelist);
-- 
2.53.0

