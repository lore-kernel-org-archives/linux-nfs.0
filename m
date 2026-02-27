Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF61D2BE7CD
	for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2026 14:03:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772201029; cv=none; b=pMSMmN8WvxHiS7u8GgDFKQKSSqepNK8uh2/RTybWSbLfYzVINWSjqH+JREUBml8CSPDVOZo8B/CVr9WtDAmIP5hRqtD3r2dvsVqK2Dryz76XMpavD3dY07Dh1wMaKmwnIVSku6QNuedzCqmlKMs8fqNR76X3BwfWHC107eKRQeU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772201029; c=relaxed/simple;
	bh=BvB0aV5NgBnETd11FBVIFWprvzsEbMtyFr0PAOpN+T0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hYI8P1ThV7kEh+lq081OLLuXxR/lRJ+ndXrx8Cp5scB68p/fatviz8lJ1gsHIwfcRJhz8epF/G7D+6skcmHYDFxBLVpvuktoUFwu3C2TqxMheCuzzL+NJ0sp4poEiFsqB0uPpZNFLVALIQVQnkQP8EeZxp400gfs39WmPAqXtzw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KI+LFRr+; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KI+LFRr+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE7E9C2BCB6;
	Fri, 27 Feb 2026 14:03:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772201029;
	bh=BvB0aV5NgBnETd11FBVIFWprvzsEbMtyFr0PAOpN+T0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=KI+LFRr+ejOJIl8E+ag6kZzyb0Lw75mBW0O4Lw/gYDb/SuOjj2MN9XbQBIAMEfs5k
	 6MVprh/EWL2qNO88l2lLvvL2QQ71MPA0fbwAErLo/z9tT4RziUhkSit7pwvC7Ew/gr
	 flDXrzcJMB55q7nm/c5OTZISDCXSJMAnUld+ivLToV809dVJfHWVxEavUSiMJDIBMG
	 ECnK02bDbLC7ZIUZGUG6ZayDOscrD8G24edal2ILWTZhI+OUhHJniWVDDvz3Tj9I/+
	 oAsk9Sw2c2qKByy57gVtt8+gifsMoHOV9KeCKltZ/OAsDI1ANBrs0qwP5YNuy3LNAV
	 ZqnPWq0O8G1qA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 02/18] svcrdma: Clean up use of rdma->sc_pd->device in Receive paths
Date: Fri, 27 Feb 2026 09:03:29 -0500
Message-ID: <20260227140345.40488-3-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260227140345.40488-1-cel@kernel.org>
References: <20260227140345.40488-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

I can't think of a reason why svcrdma is using the PD's device. Most
other consumers of the IB DMA API use the ib_device pointer from the
connection's rdma_cm_id.

I don't believe there's any functional difference between the two,
but it is a little confusing to see some uses of rdma_cm_id->device
and some of ib_pd->device.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index e7e4a39ca6c6..0b388d324c4f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -118,7 +118,8 @@ svc_rdma_next_recv_ctxt(struct list_head *list)
 static struct svc_rdma_recv_ctxt *
 svc_rdma_recv_ctxt_alloc(struct svcxprt_rdma *rdma)
 {
-	int node = ibdev_to_node(rdma->sc_cm_id->device);
+	struct ib_device *device = rdma->sc_cm_id->device;
+	int node = ibdev_to_node(device);
 	struct svc_rdma_recv_ctxt *ctxt;
 	unsigned long pages;
 	dma_addr_t addr;
@@ -133,9 +134,9 @@ svc_rdma_recv_ctxt_alloc(struct svcxprt_rdma *rdma)
 	buffer = kmalloc_node(rdma->sc_max_req_size, GFP_KERNEL, node);
 	if (!buffer)
 		goto fail1;
-	addr = ib_dma_map_single(rdma->sc_pd->device, buffer,
-				 rdma->sc_max_req_size, DMA_FROM_DEVICE);
-	if (ib_dma_mapping_error(rdma->sc_pd->device, addr))
+	addr = ib_dma_map_single(device, buffer, rdma->sc_max_req_size,
+				 DMA_FROM_DEVICE);
+	if (ib_dma_mapping_error(device, addr))
 		goto fail2;
 
 	svc_rdma_recv_cid_init(rdma, &ctxt->rc_cid);
@@ -167,7 +168,7 @@ svc_rdma_recv_ctxt_alloc(struct svcxprt_rdma *rdma)
 static void svc_rdma_recv_ctxt_destroy(struct svcxprt_rdma *rdma,
 				       struct svc_rdma_recv_ctxt *ctxt)
 {
-	ib_dma_unmap_single(rdma->sc_pd->device, ctxt->rc_recv_sge.addr,
+	ib_dma_unmap_single(rdma->sc_cm_id->device, ctxt->rc_recv_sge.addr,
 			    ctxt->rc_recv_sge.length, DMA_FROM_DEVICE);
 	kfree(ctxt->rc_recv_buf);
 	kfree(ctxt);
@@ -962,7 +963,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 
 	percpu_counter_inc(&svcrdma_stat_recv);
-	ib_dma_sync_single_for_cpu(rdma_xprt->sc_pd->device,
+	ib_dma_sync_single_for_cpu(rdma_xprt->sc_cm_id->device,
 				   ctxt->rc_recv_sge.addr, ctxt->rc_byte_len,
 				   DMA_FROM_DEVICE);
 	svc_rdma_build_arg_xdr(rqstp, ctxt);
-- 
2.53.0

