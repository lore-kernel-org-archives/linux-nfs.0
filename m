Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795586868;
	b=PfHsz+cR3w8v1NNJrxoKr/NwQQmInEZDJ9DjrmTeHhydlDiRtEWFKI3ey5t72q8UexIY
	 pr2K3v88FVRdCKLK6ivmEi7j9I+PF8N9xSxwuoXc82D3wdmJLcXiR3462lduWDx8f+673
	 pOPEhSVaiT3bA5U6lecRW5Bkffc6clwCJOBefHbFAgBDDZ10w1P3pv2FhyaN4b6OA7W+/
	 iGJC43ae+XX/J2JXe4NKWrq+Ol1zprZna5iOt7jszVVn25MbqrMeb1eZpeLR16tviVjIN
	 5mCGzAOnMuQyr9eFqsrarBeagxcdmuYkQxM2ClRTpcMy7Fqj//jlLhDjmlwS9neR+Uw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795586868;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=BHm773HOaUzVdpXKHWpteLjnflfxm++9KxTVV5Rr07Q=;
	b=Ggg0dHuLKfrVdgHc+7zz6RxSxKL/ewftkks+t7JevFG/4LZzD3rzeYK0E6gW1JaCph3g
	 yw1LnQmouFRsGGVjkVnqaSE04SqAesoXTu8RH9YgjFTUk6KW4u1nIS6A+S9eHxS+eMHpZ
	 qtqbW54afsJWpIOA38rPjoOsQYK0ySNxL+eO8PWZzFGNyG94XA9IJsGmQq6AV+XijxYDZ
	 Pwbsr2wuRyonuXac5b90bojxNY7NBfXmKhnfie4Zuqze5AG5I2Fs362Nb7QjDx+/BnaId
	 hXL+uunIhKmfblIerTei+A6G3RkEcR3cjQbEONMangBtTPsi3fJhtE0mVOh5j3JMqqQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ikuyo.dev;
	spf=pass smtp.mailfrom=ikuyo.dev;
	dkim=pass header.d=ikuyo.dev header.i=@ikuyo.dev header.a=rsa-sha256 header.s=s1 header.b=i+I9jKai;
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
Received: from sender5-op-o15.zoho.com (sender5-op-o15.zoho.com [165.173.182.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96925606A321;
	Wed, 25 Nov 2026 06:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96925606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ikuyo.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ikuyo.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ikuyo.dev header.i=@ikuyo.dev header.a=rsa-sha256 header.s=s1 header.b=i+I9jKai
ARC-Seal: i=1; a=rsa-sha256; t=1795586855; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=kQn49I1iy2/UydrjrHrXVcmyHURNfpstGdN8bYNKUxFSNEougkv0iFtxY2rYtF5/k5fKC7n8MN7RIuvpHOc0GA+EeFK7YWGFThsH1cqf97tnO2ctW4nwYCMLpJyfC61diGAvuU6v8VvErAeHG1BKfsrL1bsOwIQ+Ey2EPrj26fE=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795586855; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=BHm773HOaUzVdpXKHWpteLjnflfxm++9KxTVV5Rr07Q=; 
	b=KwEWHrpCezEvU9RbZSDOPuVLHyKs8vSSFGeHtpeokeijZCfMtQzXfL1JKj2yhKiCg5iPUzXLCkC+UzeBQovKSurzv3q2wCIu5GDJoaBbQ7PJJFYAlEeAtu5fNO7uZ1pAyTJhMKkAwZifuQZHLhuUcnDCGGJqXLvQXFLcRq1eg+w=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=ikuyo.dev;
	spf=pass  smtp.mailfrom=eritque-arcus@ikuyo.dev;
	dmarc=pass header.from=<eritque-arcus@ikuyo.dev>
DKIM-Signature: a=rsa-sha256; b=i+I9jKaiv39Ehau4s/8DsMWBT0tHFt7MdGRul/qQACFU6+Yvxn32R/cjp9Bso2Yxjs5VB4+4MYrHOavheJgNtW9go4RnHzK+wYhxJr5RMIH1+uPsShoNn1Sg0uy+BuIhCMgYXheV0uGLq+DLCJe0MIlgUDcz1yKfSZRzUufqk5wmzO4hIajYpMGKAv8hLhDMSJXw+MTuNlrAEjqhkpOTqXinJjgQi6xZ4zq+EovwM49f9X/BeCONvf8VJ+v9JXbXKDZpkHhNX2ageYy/a2vk10AErx/GV8fo9wnpSSILO0M3tyy/v6eoaDtC6jZN2a+PfTaWeu5cDJoT8wcT2D9AYw==; c=relaxed/relaxed; s=s1; d=ikuyo.dev; v=1; bh=BHm773HOaUzVdpXKHWpteLjnflfxm++9KxTVV5Rr07Q=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795586854097754.1101306058997;
	Tue, 24 Nov 2026 22:07:34 -0800 (PST)
From: Cygnus Qiu <eritque-arcus@ikuyo.dev>
To: bernard.metzler@linux.dev,
	jgg@ziepe.ca,
	leon@kernel.org
Cc: cel@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cygnus Qiu <eritque-arcus@ikuyo.dev>,
	stable@vger.kernel.org
Subject: [PATCH] RDMA/siw: don't complete a fenced READ twice on flush
Date: Wed, 25 Nov 2026 01:06:46 -0500
Message-ID: <20261125060646.155172-1-eritque-arcus@ikuyo.dev>
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

siw_sq_flush() completes the READ in the TX slot while it is still
SIW_WR_QUEUED, assuming a queued READ is not in the ORQ yet. That only
holds when a full ORQ fenced it. siw_activate_tx_from_sq() copies a READ
into a free ORQ slot, and siw_check_tx_fence() copies a fenced READ into
the ORQ once a Read Response frees a slot; in both cases the WQE stays
QUEUED until the TX path sends the Read Request. A flush in that window
completes the READ from the ORQ and again from the TX slot: two
IB_WC_WR_FLUSH_ERR completions for one work request.

The peer controls the window. It advertises IRD 1, so the ORQ holds one
READ, and answers the first Read Request with a Read Response and a FIN
in one TCP segment: the FIN suspends TX before the Read Response moves
the next READ into the ORQ, and the close flushes it.

svcrdma's svc_rdma_wc_read_done() then puts the receive context twice,
which links it into sc_recv_ctxts as a loop, and svc_rdma_free() reads
it after freeing it and frees it a second time, a double free. svcrdma
pulls the Read chunk before it decodes the RPC, so the peer needs no
RPC credentials and no export access.

Complete a QUEUED READ from the TX slot only while the ORQ fence is set.

Found with afb-afl, an LLM-driven kernel audit/repro pipeline; the fix
and this changelog were also drafted with LLM assistance. Reproduced on
an unmodified KASAN build of mainline: a plain TCP client sends nfsd's
svcrdma listener on siw an RDMA_NOMSG call whose Read chunk has two
segments and answers the first Read Request as above.
svcrdma_wc_read_flush fires twice for the chunk (5 of 5 runs), then:

  BUG: KASAN: slab-use-after-free in llist_del_first+0x150/0x170
  Read of size 8 at addr ffff8881119d9000 by task nfsd/183
   llist_del_first+0x150/0x170
   svc_rdma_recv_ctxts_destroy+0xf3/0x1b0
   svc_rdma_free+0xd8/0x2e0
   svc_xprt_free+0x22c/0x420
  Freed by task 183:
   kfree+0x162/0x500
   svc_rdma_recv_ctxts_destroy+0xe7/0x1b0

Without KASAN and with SLAB_FREELIST_HARDENED, the double free is
caught as "kernel BUG at mm/slub.c:605" in kfree() from
svc_rdma_recv_ctxts_destroy() (4 of 4 runs).

With this patch the chunk is flushed once and KASAN stays silent (4 of 4
runs). The rdma-core tests could not run: the siw provider of rdma-core
66 fails an assertion in siw_destroy_cq() on the first test, with and
without this patch.

Fixes: f29dd55b0236 ("rdma/siw: queue pair methods")
Cc: stable@vger.kernel.org
Signed-off-by: Cygnus Qiu <eritque-arcus@ikuyo.dev>
---
Tested on mainline 4405c18c95d2 (v7.4-rc3+) in QEMU. Applies to
mainline 8d7fe9885c62.

Sending the FIN only after the second Read Request has gone out, or
with no Read Response at all (the fenced READ never enters the ORQ),
gives one flush completion before and after the patch.

siw_sq_flush() now relies on orq_fence. That bit shares a byte with
tx_suspend, which siw_cm_llp_state_change() sets without the QP state
lock. A lost update there already stalls the fenced READ in
siw_check_tx_fence(); with this patch it would also lose that READ's
flush completion. I did not try to hit that window.

A reproducer and the test logs are available on request.

 drivers/infiniband/sw/siw/siw_qp.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/sw/siw/siw_qp.c b/drivers/infiniband/sw/siw/siw_qp.c
index bb780e3904..2cc0f466e7 100644
--- a/drivers/infiniband/sw/siw/siw_qp.c
+++ b/drivers/infiniband/sw/siw/siw_qp.c
@@ -1188,10 +1188,11 @@ void siw_sq_flush(struct siw_qp *qp)
 		if (tx_type(wqe) != SIW_OP_READ_RESPONSE &&
 		    ((tx_type(wqe) != SIW_OP_READ &&
 		      tx_type(wqe) != SIW_OP_READ_LOCAL_INV) ||
-		     wqe->wr_status == SIW_WR_QUEUED))
+		     (wqe->wr_status == SIW_WR_QUEUED &&
+		      qp->tx_ctx.orq_fence)))
 			/*
-			 * An in-progress Read Request is already in
-			 * the ORQ
+			 * A Read Request is already in the ORQ unless
+			 * a full ORQ fenced it
 			 */
 			siw_sqe_complete(qp, &wqe->sqe, wqe->bytes,
 					 SIW_WC_WR_FLUSH_ERR);
-- 
2.56.1

