Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38571 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbaJPTjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:39:05 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so292462igc.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:39:04 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id y2sm2165735igl.8.2014.10.16.12.39.03
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:39:04 -0700 (PDT)
Subject: [PATCH v1 06/16] xprtrdma: spin CQ completion vectors
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:39:03 -0400
Message-ID: <20141016193903.13414.79847.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A pair of CQs is created for each xprtrdma transport. One transport
instance is created per NFS mount point.

Both Shirley Ma and Steve Wise have observed that the adapter
interrupt workload sticks with a single MSI-X and CPU core unless
manual steps are taken to move it to other CPUs. This tends to limit
performance once the interrupt workload consumes an entire core.

Sagi Grimwald suggested one way to get better dispersal of
interrupts is to use the completion vector argument of the
ib_create_cq() API to assign new CQs to different adapter ingress
queues. Currently, xprtrdma sets this argument to 0 unconditionally,
which leaves all xprtrdma CQs consuming the same small pool of
resources.

Each CQ will still be nailed to one completion vector.  This won't help
a "single mount point" workload, but when multiple mount points are in
play, the RDMA provider will see to it that adapter interrupts are
better spread over available resources.

We also take a little trouble to stay off of vector 0, which is used
by many other kernel RDMA consumers such as IPoIB.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   45 ++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9105524..dc4c8e3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -49,6 +49,8 @@
 
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/random.h>
+
 #include <asm/bitops.h>
 
 #include "xprt_rdma.h"
@@ -666,6 +668,42 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 }
 
 /*
+ * Select a provider completion vector to assign a CQ to.
+ *
+ * This is an attempt to spread CQs across available CPUs. The counter
+ * is shared between all adapters on a system. Multi-adapter systems
+ * are rare, and this is still better for them than leaving all CQs on
+ * one completion vector.
+ *
+ * We could put the send and receive CQs for the same transport on
+ * different vectors. However, this risks assigning them to cores on
+ * different sockets in larger systems, which could have disasterous
+ * performance effects due to NUMA.
+ */
+static int
+rpcrdma_cq_comp_vec(struct rpcrdma_ia *ia)
+{
+	int num_comp_vectors = ia->ri_id->device->num_comp_vectors;
+	int vector = 0;
+
+	if (num_comp_vectors > 1) {
+		static DEFINE_SPINLOCK(rpcrdma_cv_lock);
+		static unsigned int rpcrdma_cv_counter;
+
+		spin_lock(&rpcrdma_cv_lock);
+		vector = rpcrdma_cv_counter++ % num_comp_vectors;
+		/* Skip 0, as it is commonly used by other RDMA consumers */
+		if (vector == 0)
+			vector = rpcrdma_cv_counter++ % num_comp_vectors;
+		spin_unlock(&rpcrdma_cv_lock);
+	}
+
+	dprintk("RPC:       %s: adapter has %d vectors, using vector %d\n",
+		__func__, num_comp_vectors, vector);
+	return vector;
+}
+
+/*
  * Create unconnected endpoint.
  */
 int
@@ -674,7 +712,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 {
 	struct ib_device_attr devattr;
 	struct ib_cq *sendcq, *recvcq;
-	int rc, err;
+	int rc, err, comp_vec;
 
 	rc = ib_query_device(ia->ri_id->device, &devattr);
 	if (rc) {
@@ -759,9 +797,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
+	comp_vec = rpcrdma_cq_comp_vec(ia);
 	sendcq = ib_create_cq(ia->ri_id->device, rpcrdma_sendcq_upcall,
 				  rpcrdma_cq_async_error_upcall, ep,
-				  ep->rep_attr.cap.max_send_wr + 1, 0);
+				  ep->rep_attr.cap.max_send_wr + 1, comp_vec);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
@@ -778,7 +817,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	recvcq = ib_create_cq(ia->ri_id->device, rpcrdma_recvcq_upcall,
 				  rpcrdma_cq_async_error_upcall, ep,
-				  ep->rep_attr.cap.max_recv_wr + 1, 0);
+				  ep->rep_attr.cap.max_recv_wr + 1, comp_vec);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
 		dprintk("RPC:       %s: failed to create recv CQ: %i\n",

