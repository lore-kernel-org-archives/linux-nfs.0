Received: from mail-pj1-f45.google.com (mail-pj1-f45.google.com [209.85.216.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7033150AC16
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 13:58:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792072721; cv=none; b=quXA8sw2/wOUikquBq8kykKnAGVCfdLpKEM2YNwPrEvHFUtz63QGUL5FmCazt+mI7w6fqya47hck3rhTco91qv+W3qft0TXfkc4TVrOgCbLA/G4YG+4UalDyqsbahSgwh+dAYJz6B055Zt8ZabS//Bpf/5q4iSqQEm4L5tJl/y4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792072721; c=relaxed/simple;
	bh=GkuhSG1E3xOY9+vYRNXA1NQsKM+K3EJmy2CQjqLyy7o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DaJ3bgcMbmEh8ZsaRu5af9IIBwKi+FF4LGiHhlZvFryIAK7Fu/CI7pEcB2Wfn/xbSGDLPKYPt7QxebsN3eUS9/tVqMySxs7CBUlQkEVF+oAMrEfzuPAywdTJrmovvQymfe50Y3OS9EZdHxGCKnSU7TJ2kIHaY3iRuMNJUR6y4qo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=U6UC1bfW; arc=none smtp.client-ip=209.85.216.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U6UC1bfW"
Received: by mail-pj1-f45.google.com with SMTP id 98e67ed59e1d1-3ab9268d90eso2826850a91.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 06:58:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792072720; x=1792677520; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=BW2z9Do1WJP4c/sF51AWRY6qGjtatAvHscnTpp551sI=;
        b=U6UC1bfWuN2XIx6irIBe2LDP4a4MgF+m7/RzfHgEJzU7d2y/HQP+QeqvwZ9rWHo1tk
         wsG8rmF09Rhs6u0Ajby22pT3pfUzX0+8lctDfRQvQsnDTZXS0pCfIR8vMRnUZ2QV5d5J
         sdjfmjY2KtaZYuIOLBfUQ78KjzMpaX8qRhjlY6t/NAlMIqgO26oefJqhEOaj5v0xGNF+
         +o7h7xiCeoDsUf6tK6jpwoMhalmLIqwhzEYJ0L9CHKMDHKaSkqersLA5X6QK5zyAz2er
         3Jpd28+q89/0gLJeyXgQ8GHOdFKHeDI0WmUvjEgGiPT8TkqR2QVwSfbWMbRpnMrISE1n
         aMDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792072720; x=1792677520;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BW2z9Do1WJP4c/sF51AWRY6qGjtatAvHscnTpp551sI=;
        b=JbwsvtlMig2GtPHliJC6df+BLqDZuFbOvODk5Vjf7QLf4oMtZNBYFKRJLEwRFfc9Cd
         f5Ce5DdPFCSIErai7hlI3di0s96yY180svBaMecPwQTdIiYQX1F0QilIOz95eKdwCs/2
         p515tvg/wfWE45xpDxoofMtu4fI80o0wV6/67naTF+Wki03IkvHB42kJoQi0mZ7aCJFx
         /3AuQUA/gEyi3zQlbPSCBcsjfU0muayctgWpx17yBIspX9RfgtCw9XRzXUsomChOlYc3
         bi5ZeAUfljEp83+6Sl49Q2rUUUS2zazFTXHhfvbbKiPzHw2A1aExBkKcWuaZtxnSIDpn
         PNSg==
X-Gm-Message-State: AFq9FYLF7uzizdkdqri1T7Mb69Oo4Vm9EWZ6t3+oPa6un7HjL0h+DERf
	miMTT7rvQRRyAocGp2En0o3aigGrZFZovmSD439ox5FxIwmW8F24EMnghy0B27Np
X-Gm-Gg: AYBFou0GC0s1IPIdId1bgBe7GnuUTHslCOTGEedi45KK5IPancvFiHWrIPd21tUbVOD
	OnMi6OImeeDtwdeb+JhBcZ5jtRTMZsSVqS7Jt0nDry/k3JX3ErYkMPhUnZymB1ywmUFjuQb8jYK
	IGmUJLJr65v/1zaB2GGE2+lSKMh9A/9fbQnDzE5lMToWeztY4szHtSS/esK5s2oECWd2zdHDnBu
	12k+Ll4j++Le9PcB5+Mpk6AEw2Tqfp4wDxCSRhtM2rwDKT0Uf4xXDcSK1NBzgBPXYs2LZVKhIhq
	U8Ep1rpSsOZennHRTwcdWmCCwgtfW2HzIisxnqxVPjZlZfPwBMwY3rVfci2cU9m+IzxUVAI8jok
	Q/vTW1hcT8CovUsvTS+npzON3WRmwjb1TmkBa1+dUtCbRVeR4xyWjaIRF6yLPeV/lK1xAj9E86/
	x1KpxcvjV9UQ7oQfpf+TDcH6z0UrjJSYL15cxQz6y5Yt6kWh9c+YOld+WB71ZC5Ky/Zk6tnjQva
	rI6xWDib/JEz29Oyv6rTeM=
X-Received: by 2002:a17:90b:54d0:b0:3ab:4e4:e979 with SMTP id 98e67ed59e1d1-3ab3ac90725mr14115192a91.36.1792072719701;
        Thu, 15 Oct 2026 06:58:39 -0700 (PDT)
Received: from localhost.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ac944a9365sm4848219a91.14.2026.10.15.06.58.36
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Thu, 15 Oct 2026 06:58:39 -0700 (PDT)
From: Jiwoong Wi <dwdnlzj@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: [PATCH] svcrdma: account for inline bytes in Read chunk page budget
Date: Thu, 15 Oct 2026 22:58:32 +0900
Message-ID: <20261015135832.67889-1-dwdnlzj@gmail.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The Read-list check limits Read bytes to the request page budget. With
multiple data item Read chunks, svc_rdma_read_multiple_chunks() copies
the inline RPC body into those same pages. The reconstructed message
can overflow the budget even when its Read bytes alone fit.

A short final Read segment escapes the existing page-overrun check
because that check runs only if len remains nonzero. The inflated
rc_page_count then makes svc_rdma_clear_rqst_pages() write past
rc_pages, followed by an out-of-bounds read during cleanup.

Include inline bytes in the budget only when multiple data item Read
chunks share the page array. Count the final Read chunk, and replace
the late, len-conditional page check with checks of both page-array
capacities before using each destination page. Single Read chunks and
Position Zero Call chunks use different reconstruction paths.

Validation used nfsd-testing 78c334bc5ae61d23ca1cc2e43079c620f1d40866.
The unmodified Generic KASAN kernel reproduced an out-of-bounds write
in svc_rdma_process_read_list(), followed by an oops during cleanup.

With this patch, the full kernel and modules built and booted. In an
isolated run, all 61 instances of the same frame were rejected during
RPC/RDMA header parsing. A two-Read-chunk NFSv4 NULL request completed:
the server issued two RDMA Reads and returned a successful RPC reply
with the matching XID. Concurrent NFSv4.2/RDMA direct I/O completed 20
repeated 8 MiB write/read transfers; the final readback matched the source
SHA-256. No KASAN report or oops occurred in the direct I/O run, and
kernel taint remained zero. The reproducer and baseline KASAN log are
available privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: d7cc73972661 ("svcrdma: support multiple Read chunks per RPC")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Jiwoong Wi <dwdnlzj@gmail.com>
---
 net/sunrpc/xprtrdma/svc_rdma_pcl.c | 12 ++++++++----
 net/sunrpc/xprtrdma/svc_rdma_rw.c  | 10 ++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_pcl.c b/net/sunrpc/xprtrdma/svc_rdma_pcl.c
index 862372279..8da0f0dc7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_pcl.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_pcl.c
@@ -238,8 +238,8 @@ bool pcl_alloc_write(struct svc_rdma_recv_ctxt *rctxt,
  * before comparing against @inline_len or the Call chunk length.
  *
  * Rejects frames where a Read chunk's inline-body offset exceeds
- * the bound, where adjacent Read chunks overlap, or where any
- * single chunk length exceeds the page budget.
+ * the bound, where adjacent Read chunks overlap, or where Read bytes,
+ * plus inline bytes when they share the page array, exceed its budget.
  *
  * Return values:
  *       %true: Read chunk positions and lengths are valid
@@ -269,8 +269,9 @@ bool pcl_check_read_chunk_positions(struct svc_rdma_recv_ctxt *rctxt,
 	pcl_for_each_chunk(chunk, &rctxt->rc_read_pcl) {
 		if (chunk->ch_position - total_read > bound)
 			return false;
-		if (chunk->ch_length > max_len)
+		if (chunk->ch_length > max_len - total_read)
 			return false;
+		total_read += chunk->ch_length;
 
 		next = pcl_next_chunk(&rctxt->rc_read_pcl, chunk);
 		if (!next)
@@ -278,8 +279,11 @@ bool pcl_check_read_chunk_positions(struct svc_rdma_recv_ctxt *rctxt,
 
 		if (chunk->ch_position + chunk->ch_length > next->ch_position)
 			return false;
-		total_read += chunk->ch_length;
 	}
+	if (pcl_is_empty(&rctxt->rc_call_pcl) &&
+	    rctxt->rc_read_pcl.cl_count > 1 &&
+	    inline_len > max_len - total_read)
+		return false;
 
 	return true;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 63d00f0cc..1f1ccf80a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -794,6 +794,10 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 	ctxt->rw_nents = nr_bvec;
 
 	for (bvec_idx = 0; bvec_idx < ctxt->rw_nents; bvec_idx++) {
+		if (head->rc_curpage >= head->rc_maxpages ||
+		    head->rc_curpage >= rqstp->rq_maxpages)
+			goto out_put;
+
 		seg_len = min_t(unsigned int, len,
 				PAGE_SIZE - head->rc_pageoff);
 
@@ -810,9 +814,6 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 			head->rc_pageoff = 0;
 		}
 		len -= seg_len;
-
-		if (len && ((head->rc_curpage + 1) > rqstp->rq_maxpages))
-			goto out_put;
 	}
 
 	ret = svc_rdma_rw_ctx_init(rdma, ctxt, segment->rs_offset,
@@ -893,7 +894,8 @@ static int svc_rdma_copy_inline_range(struct svc_rqst *rqstp,
 	for (page_no = 0; page_no < numpages; page_no++) {
 		unsigned int page_len;
 
-		if (head->rc_curpage >= rqstp->rq_maxpages)
+		if (head->rc_curpage >= head->rc_maxpages ||
+		    head->rc_curpage >= rqstp->rq_maxpages)
 			return -EINVAL;
 
 		page_len = min_t(unsigned int, remaining,

base-commit: 78c334bc5ae61d23ca1cc2e43079c620f1d40866
-- 
2.39.5

