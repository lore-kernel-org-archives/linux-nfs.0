Received: from vtj.irix.systems (vtj.irix.systems [82.76.27.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4F2213790B;
	Thu, 15 Oct 2026 12:50:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.76.27.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792068607; cv=none; b=qBlkEIPQiIm8FpycUAh2m6ZkumN3gbKqZ5sGn2Co3kD1UvUx4De2nuDn+fhV7D9dZk58/HpW7nOh1WnxmNoY0+q9VbOef4bwcAvYlmJ3hfZVA457P7etDU+FNzVS/H2H12esqkVMCYpKrdA6MTAWBXaC2fEQscYRJYhehU9E0OE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792068607; c=relaxed/simple;
	bh=4G4e0AdIHQVvZbpTYg7yQ6XgaZNGopUaKezpq293kXM=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Jw3RICCBJYSJBHTP0VyIld9ZLY0P9tCWBzrf8UqAoMLF3nztATngfMpVOTHjLHdRsq5uhmhP6vwzQl774tkW4R39KA+DYWYCwFGg4+YVFzGJnbYk7Kxl+pzn4dv4ZI2yHElqbVdpGeWTW2OGgPiiauCF5NDahbS0DHV70NgftEo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com; spf=pass smtp.mailfrom=andrei-z.com; dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b=ibx9QlmD; arc=none smtp.client-ip=82.76.27.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b="ibx9QlmD"
Received: from MAILGW-HP.hp.vtj.corp.irix.systems (localhost [127.0.0.1])
	by vtj.irix.systems (Proxmox) with ESMTP id AD9F221346;
	Thu, 15 Oct 2026 15:50:03 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=andrei-z.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:from:from:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=sig1; bh=zySgtcOOHU5AmYuLGdUr
	iJ/jGmZzV3yPkVV4S8U+rJE=; b=ibx9QlmDpqvgqCj3aU7rkcQwS23O0HktQRLZ
	ybyA1l8G88knP6R4jNWB1C+lcvl74oiuKg4PGIWvvocuBcQUottQVV9m95qXpN8C
	gYlnO61hsa/0IOOsSJbEoSZ+qB/z6HC78fbZqVcdKZLcLSv9c2Mw5MKUPtDkvU1G
	BPfJOQIRvJVJcQVL1csvcMdUuJq31QY0+ASBbS1Objjg3V0Vq32w59mzIxkRBwSp
	tA04G4nBVd9DJe6dwpbhVM1cAVt3dRAEKQ5jKH4kqJs7n/04q8uUM5ZcWi6YUM+X
	oTRgGHOyttgrn86zTfehuV1EUbeUSD2JZS0ggWzU5PXWvT8XkQ==
Received: from VTJ-MX.corp.irix.systems (unknown [10.57.36.6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vtj.irix.systems (Proxmox) with ESMTPS id B5CB42141D;
	Thu, 15 Oct 2026 15:50:02 +0300 (EEST)
Received: from [10.89.11.73] (10.57.8.14) by VTJ-MX.corp.irix.systems
 (2a02:2f04:1:9c24::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.49; Thu, 15 Oct
 2026 15:50:02 +0300
From: Andrei-Alexandru Bleortu <me@andrei-z.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
CC: Andrei-Alexandru Bleortu <me@andrei-z.com>, <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH 1/1] svcrdma: Post small Replies inline
Date: Thu, 15 Oct 2026 15:50:01 +0300
Message-ID: <20261015125001.2964822-1-me@andrei-z.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261015124830.2963045-1-me@andrei-z.com>
References: <20261015124830.2963045-1-me@andrei-z.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6) To
 VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6)

svcrdma asks for no inline data, so every Reply is posted by
reference and the HCA has to DMA-read it from host memory before
transmitting. When the Reply is the only WR of its ib_post_send(), as
for NFS WRITE, GETATTR and other Replies without a Write list or
Reply chunk, that read is on the latency path of every RPC.

Ask for 256 bytes of inline data per Send WR when accepting a
connection. If the device refuses, ask for less. Intel irdma has a fixed
limit of 216, 101 or 48 bytes, depending on the generation, and Alibaba
erdma one of 96. On those devices, found by vendor ID, try these limits
first, then step down 16 bytes at a time to none. libfabric's verbs
provider also probes the inline limit by trial QP creation.

Post a Send with IB_SEND_INLINE when it is posted alone (sc_wr_chain is
the Send WR), the whole message is in the transport header buffer, and
it fits in the granted size. A Reply that follows chunk RDMA Writes in
the same WR chain, such as an NFS READ reply, is still posted by
reference. On the NVMe/RDMA target, inlining a response posted behind
its data in this way made no measurable difference.

Providers copy inline data from sg_list[].addr as a kernel virtual
address. sc_sges[0] must keep the header buffer's DMA address, which
is synced and unmapped through it, so the inline path uses a second
SGE that holds the buffer's virtual address. The choice is made
before ib_post_send(), and nothing in the send_ctxt changes after the
post.

fio ran 4 KiB random writes at queue depth 1 on an NFSv3 mount of a
tmpfs export, between two Xeon Platinum 8360Y hosts with ConnectX-6 Dx
over RoCEv2 at 100 Gb/s on a 7.0 kernel. An earlier version of this
patch lowered the mean completion latency by 0.2634 us
(95% CI 0.1923-0.3384). With the client's Calls inlined as well, it fell
by 0.5169 us (0.4328-0.6003). That version asked for 512 bytes. It also
inlined READ replies, which on 7.0 were still posted in their own
ib_post_send() after the data.

Assisted-by: LLM
Signed-off-by: Andrei-Alexandru Bleortu <me@andrei-z.com>
---
 include/linux/sunrpc/svc_rdma.h          |  2 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 31 ++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 62 +++++++++++++++++++++++-
 3 files changed, 90 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 60966f92e8c8..c2463c3ae9ed 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -79,6 +79,7 @@ struct svcxprt_rdma {
 	struct rpcrdma_notification sc_rn;	/* removal notification */
 	u32		     sc_ord;		/* RDMA read limit */
 	unsigned int         sc_max_send_sges;
+	unsigned int	     sc_max_inline_data; /* Granted Send inline data */
 	bool		     sc_snd_w_inv;	/* OK to use Send With Invalidate */
 
 	atomic_t             sc_sq_avail;	/* SQEs ready to be consumed */
@@ -251,6 +252,7 @@ struct svc_rdma_send_ctxt {
 	struct svc_rdma_write_info sc_reply_info;
 
 	void			*sc_xprt_buf;
+	struct ib_sge		sc_inline_sge;
 	int			sc_page_count;
 	int			sc_cur_sge_no;
 	unsigned long		sc_maxpages;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index b9eee2150ea1..2d9c610d137b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -155,6 +155,8 @@ svc_rdma_send_ctxt_alloc(struct svcxprt_rdma *rdma)
 	xdr_buf_init(&ctxt->sc_hdrbuf, ctxt->sc_xprt_buf,
 		     rdma->sc_max_req_size);
 	ctxt->sc_sges[0].addr = addr;
+	ctxt->sc_inline_sge.addr = (uintptr_t)buffer;
+	ctxt->sc_inline_sge.lkey = rdma->sc_pd->local_dma_lkey;
 
 	for (i = 0; i < rdma->sc_max_send_sges; i++)
 		ctxt->sc_sges[i].lkey = rdma->sc_pd->local_dma_lkey;
@@ -503,6 +505,29 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	svc_rdma_xprt_deferred_close(rdma);
 }
 
+/* Post a Send inline when it is posted alone, the whole message is
+ * in the transport header buffer, and it fits in the granted inline
+ * size. The CPU then copies it into the send WQE and the HCA does
+ * not DMA-read it. A Send that follows chunk RDMA Writes in the same
+ * WR chain is still posted by reference. Inline data is copied from
+ * a kernel virtual address, hence the separate SGE.
+ */
+static void svc_rdma_prepare_send_inline(const struct svcxprt_rdma *rdma,
+					 struct svc_rdma_send_ctxt *ctxt)
+{
+	struct ib_send_wr *send_wr = &ctxt->sc_send_wr;
+
+	send_wr->sg_list = ctxt->sc_sges;
+	send_wr->send_flags = IB_SEND_SIGNALED;
+	if (ctxt->sc_wr_chain != send_wr || send_wr->num_sge != 1 ||
+	    ctxt->sc_sges[0].length > rdma->sc_max_inline_data)
+		return;
+
+	ctxt->sc_inline_sge.length = ctxt->sc_sges[0].length;
+	send_wr->sg_list = &ctxt->sc_inline_sge;
+	send_wr->send_flags |= IB_SEND_INLINE;
+}
+
 /**
  * svc_rdma_post_send - Post a WR chain to the Send Queue
  * @rdma: transport context
@@ -521,7 +546,6 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 		       struct svc_rdma_send_ctxt *ctxt)
 {
 	struct ib_send_wr *first_wr = ctxt->sc_wr_chain;
-	struct ib_send_wr *send_wr = &ctxt->sc_send_wr;
 	const struct ib_send_wr *bad_wr = first_wr;
 	struct rpc_rdma_cid cid = ctxt->sc_cid;
 	int ret, sqecount = ctxt->sc_sqecount;
@@ -530,9 +554,10 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 
 	/* Sync the transport header buffer */
 	ib_dma_sync_single_for_device(rdma->sc_cm_id->device,
-				      send_wr->sg_list[0].addr,
-				      send_wr->sg_list[0].length,
+				      ctxt->sc_sges[0].addr,
+				      ctxt->sc_sges[0].length,
 				      DMA_TO_DEVICE);
+	svc_rdma_prepare_send_inline(rdma, ctxt);
 
 	ret = svc_rdma_sq_wait(rdma, &cid, sqecount);
 	if (ret < 0)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index df6c3501f97c..233285747711 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -49,6 +49,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/export.h>
+#include <linux/pci_ids.h>
 
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
@@ -64,6 +65,44 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+/* Bytes of inline data (IB_SEND_INLINE) to ask for on each Send WR.
+ * This is unrelated to the RPC-over-RDMA inline threshold.
+ */
+#define RPCRDMA_WQE_INLINE_SIZE	(256)
+#define RPCRDMA_WQE_INLINE_STEP	(16)
+
+/* The verbs API cannot report a device's inline data limit. Some
+ * drivers have a fixed one: Intel irdma 216, 101 or 48 depending on
+ * the generation, Alibaba erdma 96. Try those first, by vendor ID,
+ * then step down RPCRDMA_WQE_INLINE_STEP bytes at a time to zero.
+ * libfabric's verbs provider also probes the limit
+ * (vrb_find_max_inline()).
+ */
+static const struct {
+	u32	vendor_id;
+	u32	max_inline;
+} svc_rdma_inline_limits[] = {
+	{ PCI_VENDOR_ID_INTEL, 216 },
+	{ PCI_VENDOR_ID_INTEL, 101 },
+	{ PCI_VENDOR_ID_INTEL, 48 },
+	{ PCI_VENDOR_ID_ALIBABA, 96 },
+};
+
+/* Inline data size to ask for: on the first try, @size capped at the
+ * vendor's first known limit; after a refusal, the vendor's next
+ * smaller known limit, else one step smaller.
+ */
+static u32 svc_rdma_inline_size(u32 vendor_id, u32 size, bool refused)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(svc_rdma_inline_limits); i++)
+		if (svc_rdma_inline_limits[i].vendor_id == vendor_id &&
+		    (!refused || svc_rdma_inline_limits[i].max_inline < size))
+			return min(svc_rdma_inline_limits[i].max_inline, size);
+	return refused ? size - min(size, RPCRDMA_WQE_INLINE_STEP) : size;
+}
+
 static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 						 struct net *net, int node);
 static int svc_rdma_listen_handler(struct rdma_cm_id *cma_id,
@@ -444,8 +483,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct svcxprt_rdma *newxprt = NULL;
 	struct rdma_conn_param conn_param;
 	struct rpcrdma_connect_private pmsg;
-	struct ib_qp_init_attr qp_attr;
+	struct ib_qp_init_attr qp_attr, attr;
 	struct ib_device *dev;
+	u32 inline_size;
 	int ret = 0;
 
 	listen_rdma = container_of(xprt, struct svcxprt_rdma, sc_xprt);
@@ -547,12 +587,30 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		qp_attr.cap.max_send_sge, qp_attr.cap.max_recv_sge);
 	dprintk("    send CQ depth = %u, recv CQ depth = %u\n",
 		newxprt->sc_sq_depth, rq_depth);
-	ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
+
+	/* Ask for enough inline data to copy small Sends into the send
+	 * WQE (see svc_rdma_prepare_send_inline()), or for as much as the
+	 * device accepts.
+	 */
+	attr = qp_attr;
+	inline_size = svc_rdma_inline_size(dev->attrs.vendor_id,
+					   RPCRDMA_WQE_INLINE_SIZE, false);
+	for (;;) {
+		qp_attr = attr;
+		qp_attr.cap.max_inline_data = inline_size;
+		ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd,
+				     &qp_attr);
+		if (!ret || !inline_size)
+			break;
+		inline_size = svc_rdma_inline_size(dev->attrs.vendor_id,
+						   inline_size, true);
+	}
 	if (ret) {
 		trace_svcrdma_qp_err(newxprt, ret);
 		goto errout;
 	}
 	newxprt->sc_max_send_sges = qp_attr.cap.max_send_sge;
+	newxprt->sc_max_inline_data = qp_attr.cap.max_inline_data;
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 
 	if (!(dev->attrs.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
-- 
2.56.0


