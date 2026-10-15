Received: from vtj.irix.systems (vtj.irix.systems [82.76.27.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76180524B18;
	Thu, 15 Oct 2026 12:48:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.76.27.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792068519; cv=none; b=eDTp3DSHeazU0DhX7wCp/ZNw6SvWOsRq/FQyXiixQzA0jR8yyuAAp2ok3RKlwnX2OwGeU4DJHCqXYHGiOZPIiYxcpsUp6zd4M5F0LtABfC+t1XIV2wBNIjJkxB0GRNEwD6wZ0uo7y4Vc1VOV4EUhA87Z/1b9VSLrgR0aSuUulfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792068519; c=relaxed/simple;
	bh=FseEkCanpOgbxQAyKdiEv5ho8wK112c10/JmvYr7s6Y=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=BVz8kIEMHuRLmoWBlD3wu4Hmr792oh5QDADaWHdSv6ILWtHKtkpw0bDVt/AKEPvY0rwIzO7id+KYSyCQ0T+hr4Z3k2TmwzxLAzc/r6HT5L8VuvmI5zjDH+DYXXI9PTzcFOvpaVPAytBbfV5p2TwlrrsnJ7AfOqK2i3BnGXzjBQ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com; spf=pass smtp.mailfrom=andrei-z.com; dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b=ar7A8el0; arc=none smtp.client-ip=82.76.27.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b="ar7A8el0"
Received: from MAILGW-DELL.dell.vtj.corp.irix.systems (localhost [127.0.0.1])
	by vtj.irix.systems (Proxmox) with ESMTP id AA74921A81;
	Thu, 15 Oct 2026 15:48:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=andrei-z.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:from:from:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=sig1; bh=RC0Tk3/Pc2DkyEH2bwu7
	JAjjb8ZJe7ybOToTyxn+K0U=; b=ar7A8el0+ERxHCCjkpt4rmjrfBPck6cJ+Pjy
	DyV5kB9c0UBsVsrzImoajJgArMah6lQklxLcKLWkwsB3vifZ2SrS53JK9EEHz2oQ
	OabUBPhFG97wBRwanS6DdRVjOXpYI7BGrj/mMedpMgDPM/fa+60+0o5YaWvZY2fj
	D8rRbrqJR8ZTmzMLHkcDIRtdBejarpTGECVYpeIKPNCYjWl3o0riCBSOKNmzm9Ty
	eM0DyyUDEpwDeIqMhkoDnbBYBWUBEYM8nHg4oHtPeIFMBLcpuhNB3okERKCl37wN
	fzjFYszgEq9M4GINS2iunV3P9ai/8VbUGQ2kGF8u8AFnjLrSpQ==
Received: from VTJ-MX.corp.irix.systems (unknown [IPv6:2a02:2f04:1:9c24::6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vtj.irix.systems (Proxmox) with ESMTPS id 90FCB21A1D;
	Thu, 15 Oct 2026 15:48:27 +0300 (EEST)
Received: from [10.89.11.73] (10.57.8.14) by VTJ-MX.corp.irix.systems
 (2a02:2f04:1:9c24::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.49; Thu, 15 Oct
 2026 15:48:27 +0300
From: Andrei-Alexandru Bleortu <me@andrei-z.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	<linux-nfs@vger.kernel.org>
CC: Andrei-Alexandru Bleortu <me@andrei-z.com>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, <linux-kernel@vger.kernel.org>
Subject: [PATCH 1/1] xprtrdma: Post small RPC Calls inline
Date: Thu, 15 Oct 2026 15:48:26 +0300
Message-ID: <20261015124826.2962950-2-me@andrei-z.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261015124826.2962950-1-me@andrei-z.com>
References: <20261015124826.2962950-1-me@andrei-z.com>
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

rpcrdma_ep_create() asks for no inline data, so every RPC Call is
posted by reference. Before the HCA can transmit a Call it has to
DMA-read the transport header and the RPC message from host memory,
and for a small Call that read is on the latency path of every RPC.

Ask for 256 bytes of inline data per Send WR when creating the QP. If
the device refuses, ask for less. Intel irdma has a fixed limit of 216,
101 or 48 bytes, depending on the generation, and Alibaba erdma one of
96. On those devices, found by vendor ID, try these limits first, then
step down 16 bytes at a time to none. libfabric's verbs provider also
probes the inline limit by trial QP creation.

Post a Call with IB_SEND_INLINE when its SGEs cover only the
persistently mapped transport header and head buffers and it fits in the
granted size. Calls with page or tail SGEs, and larger Calls, are posted
by reference as before. IB_SEND_INLINE is unrelated to the RPC-over-RDMA
inline threshold.

Providers copy inline data from sg_list[].addr as a kernel virtual
address, so on the inline path the SGEs point at the regbufs' virtual
addresses. These SGEs are rebuilt for every Send and are not used for
unmapping: rpcrdma_sendctx_dma_unmap() starts at the third SGE, and the
regbufs stay mapped.

fio ran 4 KiB direct I/O at queue depth 1 on an NFSv3 mount of a tmpfs
export, between two Xeon Platinum 8360Y hosts with ConnectX-6 Dx over
RoCEv2 at 100 Gb/s on a 7.0 kernel. An earlier version of this patch
lowered the mean completion latency of random writes by 0.1923 us
(95% CI 0.1139-0.2769) and of random reads by 0.2705 us (0.1908-0.3502).
That version made the same check in frwr_send() and asked for 512
bytes. The largest Call in those runs was 216 bytes.

Assisted-by: LLM
Signed-off-by: Andrei-Alexandru Bleortu <me@andrei-z.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 30 ++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c    | 58 +++++++++++++++++++++++++++++++++-
 2 files changed, 87 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 7e5713367291..9c0ef7303439 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -732,6 +732,33 @@ static bool rpcrdma_prepare_readch(struct rpcrdma_xprt *r_xprt,
 	return true;
 }
 
+/* Post a Send inline when its SGEs cover only the transport header
+ * and head buffers and it fits in the granted inline size. The CPU
+ * then copies it into the send WQE and the HCA does not DMA-read it.
+ * Inline data is copied from kernel virtual addresses, so point the
+ * SGEs there. The buffers stay DMA-mapped and are not unmapped
+ * through these SGEs.
+ */
+static void rpcrdma_prepare_send_inline(struct rpcrdma_xprt *r_xprt,
+					struct rpcrdma_req *req)
+{
+	struct ib_sge *sge = req->rl_wr.sg_list;
+	unsigned int len = 0;
+	int i;
+
+	if (req->rl_sendctx->sc_unmap_count)
+		return;
+	for (i = 0; i < req->rl_wr.num_sge; i++)
+		len += sge[i].length;
+	if (len > r_xprt->rx_ep->re_attr.cap.max_inline_data)
+		return;
+
+	sge[0].addr = (uintptr_t)rdmab_data(req->rl_rdmabuf);
+	if (req->rl_wr.num_sge > 1)
+		sge[1].addr = (uintptr_t)rdmab_data(req->rl_sendbuf);
+	req->rl_wr.send_flags |= IB_SEND_INLINE;
+}
+
 /**
  * rpcrdma_prepare_send_sges - Construct SGEs for a Send WR
  * @r_xprt: controlling transport
@@ -760,6 +787,7 @@ inline int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 	req->rl_wr.sg_list = req->rl_sendctx->sc_sges;
 	req->rl_wr.num_sge = 0;
 	req->rl_wr.opcode = IB_WR_SEND;
+	req->rl_wr.send_flags &= ~IB_SEND_INLINE;
 
 	rpcrdma_prepare_hdr_sge(r_xprt, req, hdrlen);
 
@@ -783,6 +811,8 @@ inline int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 		goto out_unmap;
 	}
 
+	rpcrdma_prepare_send_inline(r_xprt, req);
+
 	/* The Send-side owner releases this reference when the
 	 * Send has completed.
 	 */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 54957295a631..2e8a7fb6b1a6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -55,6 +55,7 @@
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/log2.h>
+#include <linux/pci_ids.h>
 
 #include <asm/barrier.h>
 
@@ -63,6 +64,44 @@
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
 
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
+} rpcrdma_inline_limits[] = {
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
+static u32 rpcrdma_inline_size(u32 vendor_id, u32 size, bool refused)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(rpcrdma_inline_limits); i++)
+		if (rpcrdma_inline_limits[i].vendor_id == vendor_id &&
+		    (!refused || rpcrdma_inline_limits[i].max_inline < size))
+			return min(rpcrdma_inline_limits[i].max_inline, size);
+	return refused ? size - min(size, RPCRDMA_WQE_INLINE_STEP) : size;
+}
+
 static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_sendctxs_destroy(struct rpcrdma_xprt *r_xprt);
 static unsigned long rpcrdma_sendctx_next(struct rpcrdma_buffer *buf,
@@ -392,8 +431,10 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_connect_private *pmsg;
 	struct ib_device *device;
+	struct ib_qp_init_attr attr;
 	struct rdma_cm_id *id;
 	struct rpcrdma_ep *ep;
+	u32 inline_size;
 	int rc;
 
 	ep = kzalloc_obj(*ep, XPRTRDMA_GFP_FLAGS);
@@ -487,7 +528,22 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 		goto out_destroy;
 	}
 
-	rc = rdma_create_qp(id, ep->re_pd, &ep->re_attr);
+	/* Ask for enough inline data to copy small Sends into the send
+	 * WQE (see rpcrdma_prepare_send_inline()), or for as much as the
+	 * device accepts.
+	 */
+	attr = ep->re_attr;
+	inline_size = rpcrdma_inline_size(device->attrs.vendor_id,
+					  RPCRDMA_WQE_INLINE_SIZE, false);
+	for (;;) {
+		ep->re_attr = attr;
+		ep->re_attr.cap.max_inline_data = inline_size;
+		rc = rdma_create_qp(id, ep->re_pd, &ep->re_attr);
+		if (!rc || !inline_size)
+			break;
+		inline_size = rpcrdma_inline_size(device->attrs.vendor_id,
+						  inline_size, true);
+	}
 	if (rc)
 		goto out_destroy;
 
-- 
2.56.0


