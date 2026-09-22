Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A17AF1B3925;
	Tue, 22 Sep 2026 01:51:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790041893; cv=none; b=OvurL+T+STadgH8SIAF46Yab2x4dBV8Koc/KeeXI6nX1d/GZxg2HqsWFRUFKfyzxqwwHO04VMiRbvtWLZtDwHDeweIq/52S6DvjbnJ2F24SaEKvoXadRO6NOAYBok4qrDcbRl0E2Bq1jCWinAnRlcXjSWll8j75wgElyZJ1snKM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790041893; c=relaxed/simple;
	bh=7Lig+oQa2+WaonC8GcIYhxLPe+RFMDJpYwhPxaabKak=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OtY/nWalbyyfzVP7AU7O9valKM13CB5GzcsiyTENqtcpLGR7Sp/r75xsmbzzG9fmWZS1ZZcTdbeM1gOzjDOGAFSX5XGcV7O27khGU7Llnw+tmNTSg+0dm87wFstF7mjcI1lfNfWh/kMVp1o9Qh4kEEkWDi9gWRUEgFnUOHhHiHM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l+reH2dS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l+reH2dS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF4E71F00899;
	Tue, 22 Sep 2026 01:51:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790041892;
	bh=FBfy5I+ODEEIQhyh0BGbIyXsls2TjLfq/mHRL/EDaoI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=l+reH2dSBbGswdy+nL7wDLje1SPzxUsOY79qPW04D3cV6XFD+ax3gWsz5EnOAWPW0
	 BvF5jy9cDVFwRxRmvvlb7lJbbikT/V67OXs2azVFjFdDsbzZ6aGS4Q1p3bf+XCa05+
	 o7etD040CE9ZBhaLUp0HyoQiUY3bQOsqFJIjfkveBEcTBo3O0zozKCM77KHPu2+SlJ
	 fHJytUOEAdrkXuWludoQzTmEXpbg3Co/qOtWJXvjlnueoHDhcVsVC2PSZAZBOLfaoB
	 tA0OyNmmAsxUBIp6eepNszC8WEPVoEkcFrvi+RbwVAqaU27ayl4KNbhO8K5xI3DHiD
	 iCsFpcDnx6e/g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH v1 3/5] svcrdma: fix a page leak in backchannel sends
Date: Mon, 21 Sep 2026 21:51:26 -0400
Message-ID: <20260922015128.240977-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260922015128.240977-1-cel@kernel.org>
References: <20260922015128.240977-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_rdma_bc_sendto() takes an extra reference on the page that
holds the backchannel Call message, so that the page is not
returned to the allocator while the Send that reads it is still
posted. Send completion once dropped that reference, back when the
page sat in the send context's page array. Commit 99722fe4d5a6
("svcrdma: Persistently allocate and DMA-map Send buffers")
switched the backchannel to svc_rdma_map_reply_msg(), which
DMA-maps the buffer and records no pages. Send completion no
longer touches the page, but the get_page() stayed.

xprt_rdma_bc_free() drops the allocation reference and nothing
drops the extra one, so every backchannel Call sent over RPC/RDMA
leaks its send buffer page.

The extra reference is still needed. A Call at or above
RPCRDMA_PULLUP_THRESH is DMA-mapped in place. The RPC client frees
rq_buffer when the callback task times out or is killed, whether
or not the Send has completed. Record the page in the send
context's page array so that svc_rdma_send_ctxt_release() drops
the reference after Send completion.

Fixes: 99722fe4d5a6 ("svcrdma: Persistently allocate and DMA-map Send buffers")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e5a78b761012..e0768d1ee556 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -85,10 +85,14 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	if (ret < 0)
 		return -EIO;
 
-	/* Bump page refcnt so Send completion doesn't release
-	 * the rq_buffer before all retransmits are complete.
+	/* The RPC client frees rq_buffer when the callback task ends,
+	 * whether or not the Send has completed. Hold the page until the
+	 * send context is released after Send completion.
 	 */
-	get_page(virt_to_page(rqst->rq_buffer));
+	sctxt->sc_pages[0] = virt_to_page(rqst->rq_buffer);
+	get_page(sctxt->sc_pages[0]);
+	sctxt->sc_page_count = 1;
+
 	sctxt->sc_send_wr.opcode = IB_WR_SEND;
 	return svc_rdma_post_send(rdma, sctxt);
 }
-- 
2.55.0

