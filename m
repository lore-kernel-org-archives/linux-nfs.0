Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AF1746C4D3;
	Fri, 28 Aug 2026 13:50:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787925041; cv=none; b=YgWBV7Yji0smz1ehFvhbCV2vvBFJngejonAP+VDJ4foRhaL33+6J23d3ZvSeVBMJ4aRdMB+HJb0XeBFUVFmcv7COWybwfcgIGPE20e7RKEfVdBpwu6nJg9LyP1mMlDY5ZkZ7ZV0lqvo1Ar/ZS8MBKfXSugA0BbcY0avPX+pZUEw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787925041; c=relaxed/simple;
	bh=Bg+1oTvVuUHH14FyCQ0ZHzlRxqEKW21vksn3PcNKSsE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IxEeX5i5ADyD8tOOjYwEyiqu1AAS1mn1Ij4TJgF+99lPlRI7jYnesSFn1tOn8KrQEUYNCFHCsHDjLnZwFKHcxr33hYXHmgybm0wE2/eikYsWTSs1Jswq+hsBs6oXrBbpiGTr9FdneKtPitscLx2VtZvy49Zg6anQ1DxvCMN1aLs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lOkzK4fV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lOkzK4fV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12FF81F000E9;
	Fri, 28 Aug 2026 13:50:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787925039;
	bh=dKGIwVh2H8WNZRjFskB+lFkinSXT2kPubyIj86Awnv8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lOkzK4fVuzfbZ+s3EGMcRyDl89ZIAbgONCDkPlMRLDIgeIvQfniLQsAYMb6qPsUXW
	 zDJCae6DPM1JOHshYCZ2phbquX7Yhd/agS8a0KYL3ivRKfyoqms6U1NNudh42XRL1k
	 xDNkf3ymgpd3+fxbc1sAbLYH7fzN1ng+ikz42jGnQ2fnSf0MIDoNA78CY3aVYczZRa
	 MygXUrhE7+PDybnQXfAKkVdV2g6gcm+vwNUbZljGf8EWImEyv92w5GVBFRV3jHk3Pz
	 I7D5CVI1yKEmz0Sl9mZ/mB3SiSHj0mR1PQj8Keg/hjpBf87h26YS6Bl0Jg819+quWo
	 VYs5zZie9owMA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH 2/3] svcrdma: Clear XPT_DATA when the last receive context is consumed
Date: Fri, 28 Aug 2026 09:50:35 -0400
Message-ID: <20260828135036.796842-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260828135036.796842-1-cel@kernel.org>
References: <20260828135036.796842-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_rdma_wc_receive() and svc_rdma_wc_read_done() set XPT_DATA after
adding a completed context to sc_rq_dto_q or sc_read_complete_q.
svc_rdma_recvfrom() dequeues one context and leaves XPT_DATA set, so
the svc_xprt_received() that follows re-enqueues the transport and
svc_xprt_enqueue() dispatches a second thread. That thread finds both
queues empty and returns zero.

Recheck the receive queues after each dequeue and clear XPT_DATA when
the last context is taken, rather than only when a dequeue finds
nothing. svc_xprt_received()'s kernel-doc no longer describes every
transport, so relax its note about when XPT_DATA is cleared.

Measured on one NFSv4.2 connection over 100GbE RoCE. A 4KB random read
at queue depth 1 falls from 2.997 transport dequeues per RPC to 1.998,
and from 96,629 to 82,398 server cycles per RPC. A 256KB random write
falls from 3.270 dequeues to 2.004, and from 259,936 to 246,059 cycles.
Each dispatch removed is worth about 10,000 cycles.

The gain shrinks as the receive queues fill, since a leftover XPT_DATA
then dispatches a thread that finds real work. An 8KB random write at
queue depth 512 already runs at the two dequeues an RPC with a Read
chunk requires, and shows no change. Throughput moves only where the
server has no idle CPU to absorb the saving, so only the queue depth 1
read gains, by 1.8%.

One dispatch per RPC remains. svc_rdma_send_ctxt_put() sets XPT_DATA to
schedule a drain of sc_send_release_list, and svc_rdma_recvfrom() does
not service that list.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c                   |  5 +++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 18 ++++++++++++++----
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb..c0e6772c6683 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -218,8 +218,9 @@ EXPORT_SYMBOL_GPL(svc_xprt_init);
  * The caller must hold the XPT_BUSY bit and must
  * not thereafter touch transport data.
  *
- * Note: XPT_DATA only gets cleared when a read-attempt finds no (or
- * insufficient) data.
+ * Note: xpo_recvfrom decides when to clear XPT_DATA. A transport may
+ * leave the bit set until a read attempt finds no (or insufficient)
+ * data, or clear it as soon as it consumes the last queued receive.
  */
 void svc_xprt_received(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index fdfed1be97da..d029bcb7a5c0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -925,8 +925,9 @@ static noinline void svc_rdma_read_complete(struct svc_rqst *rqstp,
  *	%-ENOTCONN if posting failed (connection is lost),
  *	%-EIO if rdma_rw initialization failed (DMA mapping, etc).
  *
- * Called in a loop when XPT_DATA is set. XPT_DATA is cleared only
- * when there are no remaining ctxt's to process.
+ * Called in a loop when XPT_DATA is set. XPT_DATA is cleared as
+ * soon as both receive queues are empty, so a consumed ctxt does
+ * not leave a stale bit behind.
  *
  * The next ctxt is removed from the "receive" lists.
  *
@@ -960,6 +961,15 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	ctxt = svc_rdma_next_recv_ctxt(&rdma_xprt->sc_read_complete_q);
 	if (ctxt) {
 		list_del(&ctxt->rc_list);
+		/* Producers add to these queues and set XPT_DATA under
+		 * this lock, so the clear cannot race one. The clear can
+		 * drop the XPT_DATA that svc_rdma_send_ctxt_put() sets
+		 * for sc_send_release_list. svc_xprt_release() drains
+		 * that list before this thread looks for more work.
+		 */
+		if (list_empty(&rdma_xprt->sc_read_complete_q) &&
+		    list_empty(&rdma_xprt->sc_rq_dto_q))
+			clear_bit(XPT_DATA, &xprt->xpt_flags);
 		spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 		svc_xprt_received(xprt);
 		svc_rdma_read_complete(rqstp, ctxt);
@@ -968,8 +978,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	ctxt = svc_rdma_next_recv_ctxt(&rdma_xprt->sc_rq_dto_q);
 	if (ctxt)
 		list_del(&ctxt->rc_list);
-	else
-		/* No new incoming requests, terminate the loop */
+	/* sc_read_complete_q was empty above, under this same lock. */
+	if (list_empty(&rdma_xprt->sc_rq_dto_q))
 		clear_bit(XPT_DATA, &xprt->xpt_flags);
 	spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 
-- 
2.54.0

