From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 07/39] nfs41: New backchannel helper routines
Date: Fri,  1 May 2009 02:20:10 +0300
Message-ID: <1241133610-517-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29081 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755332AbZD3XUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:17 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

This patch introduces support to setup the callback xprt on the client side.
It allocates/ destroys the preallocated memory structures used to process
backchannel requests.

At setup time, xprt_setup_backchannel() is invoked to allocate one or
more rpc_rqst structures and substructures.  This ensures that they
are available when an RPC callback arrives.  The rpc_rqst structures
are maintained in a linked list attached to the rpc_xprt structure.
We keep track of the number of allocations so that they can be correctly
removed when the channel is destroyed.

When an RPC callback arrives, xprt_alloc_bc_request() is invoked to
obtain a preallocated rpc_rqst structure.  An rpc_xprt structure is
returned, and its RPC_BC_PREALLOC_IN_USE bit is set in
rpc_xprt->bc_flags.  The structure is removed from the the list
since it is now in use, and it will be later added back when its
user is done with it.

After the RPC callback replies, the rpc_rqst structure is returned
by invoking xprt_free_bc_request().  This clears the
RPC_BC_PREALLOC_IN_USE bit and adds it back to the list, allowing it
to be reused by a subsequent RPC callback request.

To be consistent with the reception of RPC messages, the backchannel requests
should be placed into the 'struct rpc_rqst' rq_rcv_buf, which is then in turn
copied to the 'struct rpc_rqst' rq_private_buf.

[nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xprt.h   |    1 +
 net/sunrpc/Makefile           |    1 +
 net/sunrpc/backchannel_rqst.c |  270 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 272 insertions(+), 0 deletions(-)
 create mode 100644 net/sunrpc/backchannel_rqst.c

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b0867e4..6b37724 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -183,6 +183,7 @@ struct rpc_xprt {
 #if defined(CONFIG_NFS_V4_1)
 	struct svc_serv		*bc_serv;       /* The RPC service which will */
 						/* process the callback */
+	unsigned int		bc_alloc_count;	/* Total number of preallocs */
 	spinlock_t		bc_pa_lock;	/* Protects the preallocated
 						 * items */
 	struct list_head	bc_pa_list;	/* List of preallocated
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 5369aa3..4a01f96 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -13,5 +13,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
 	    svc_xprt.o
+sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
new file mode 100644
index 0000000..7d7708a
--- /dev/null
+++ b/net/sunrpc/backchannel_rqst.c
@@ -0,0 +1,270 @@
+/******************************************************************************
+
+(c) 2007 Network Appliance, Inc.  All Rights Reserved.
+
+Network Appliance provides this source code under the GPL v2 License.
+The GPL v2 license is available at
+http://opensource.org/licenses/gpl-license.php.
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+******************************************************************************/
+
+#include <linux/tcp.h>
+#include <linux/sunrpc/xprt.h>
+
+#ifdef RPC_DEBUG
+#define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+#if defined(CONFIG_NFS_V4_1)
+
+/*
+ * Helper routines that track the number of preallocation elements
+ * on the transport.
+ */
+static inline int xprt_need_to_requeue(struct rpc_xprt *xprt)
+{
+	return xprt->bc_alloc_count > 0;
+}
+
+static inline void xprt_inc_alloc_count(struct rpc_xprt *xprt, unsigned int n)
+{
+	xprt->bc_alloc_count += n;
+}
+
+static inline int xprt_dec_alloc_count(struct rpc_xprt *xprt, unsigned int n)
+{
+	return xprt->bc_alloc_count -= n;
+}
+
+/*
+ * Free the preallocated rpc_rqst structure and the memory
+ * buffers hanging off of it.
+ */
+static void xprt_free_allocation(struct rpc_rqst *req)
+{
+	struct xdr_buf *xbufp;
+
+	dprintk("RPC:        free allocations for req= %p\n", req);
+	BUG_ON(test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
+	xbufp = &req->rq_private_buf;
+	free_page((unsigned long)xbufp->head[0].iov_base);
+	xbufp = &req->rq_snd_buf;
+	free_page((unsigned long)xbufp->head[0].iov_base);
+	list_del(&req->rq_bc_pa_list);
+	kfree(req);
+}
+
+/*
+ * Preallocate up to min_reqs structures and related buffers for use
+ * by the backchannel.  This function can be called multiple times
+ * when creating new sessions that use the same rpc_xprt.  The
+ * preallocated buffers are added to the pool of resources used by
+ * the rpc_xprt.  Anyone of these resources may be used used by an
+ * incoming callback request.  It's up to the higher levels in the
+ * stack to enforce that the maximum number of session slots is not
+ * being exceeded.
+ */
+int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
+{
+	struct page *page_rcv = NULL, *page_snd = NULL;
+	struct xdr_buf *xbufp = NULL;
+	struct rpc_rqst *req, *tmp;
+	struct list_head tmp_list;
+	int i;
+
+	dprintk("RPC:       setup backchannel transport\n");
+
+	/*
+	 * We use a temporary list to keep track of the preallocated
+	 * buffers.  Once we're done building the list we splice it
+	 * into the backchannel preallocation list off of the rpc_xprt
+	 * struct.  This helps minimize the amount of time the list
+	 * lock is held on the rpc_xprt struct.  It also makes cleanup
+	 * easier in case of memory allocation errors.
+	 */
+	INIT_LIST_HEAD(&tmp_list);
+	for (i = 0; i < min_reqs; i++) {
+		/* Pre-allocate one backchannel rpc_rqst */
+		req = kzalloc(sizeof(struct rpc_rqst), GFP_KERNEL);
+		if (req == NULL) {
+			printk(KERN_ERR "Failed to create bc rpc_rqst\n");
+			goto out_free;
+		}
+
+		/* Add the allocated buffer to the tmp list */
+		dprintk("RPC:       adding req= %p\n", req);
+		list_add(&req->rq_bc_pa_list, &tmp_list);
+
+		req->rq_xprt = xprt;
+		INIT_LIST_HEAD(&req->rq_list);
+		INIT_LIST_HEAD(&req->rq_bc_list);
+
+		/* Preallocate one XDR receive buffer */
+		page_rcv = alloc_page(GFP_KERNEL);
+		if (page_rcv == NULL) {
+			printk(KERN_ERR "Failed to create bc receive xbuf\n");
+			goto out_free;
+		}
+		xbufp = &req->rq_rcv_buf;
+		xbufp->head[0].iov_base = page_address(page_rcv);
+		xbufp->head[0].iov_len = PAGE_SIZE;
+		xbufp->tail[0].iov_base = NULL;
+		xbufp->tail[0].iov_len = 0;
+		xbufp->page_len = 0;
+		xbufp->len = PAGE_SIZE;
+		xbufp->buflen = PAGE_SIZE;
+
+		/* Preallocate one XDR send buffer */
+		page_snd = alloc_page(GFP_KERNEL);
+		if (page_snd == NULL) {
+			printk(KERN_ERR "Failed to create bc snd xbuf\n");
+			goto out_free;
+		}
+
+		xbufp = &req->rq_snd_buf;
+		xbufp->head[0].iov_base = page_address(page_snd);
+		xbufp->head[0].iov_len = 0;
+		xbufp->tail[0].iov_base = NULL;
+		xbufp->tail[0].iov_len = 0;
+		xbufp->page_len = 0;
+		xbufp->len = 0;
+		xbufp->buflen = PAGE_SIZE;
+	}
+
+	/*
+	 * Add the temporary list to the backchannel preallocation list
+	 */
+	spin_lock_bh(&xprt->bc_pa_lock);
+	list_splice(&tmp_list, &xprt->bc_pa_list);
+	xprt_inc_alloc_count(xprt, min_reqs);
+	spin_unlock_bh(&xprt->bc_pa_lock);
+
+	dprintk("RPC:       setup backchannel transport done\n");
+	return 0;
+
+out_free:
+	/*
+	 * Memory allocation failed, free the temporary list
+	 */
+	list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list)
+		xprt_free_allocation(req);
+
+	dprintk("RPC:       setup backchannel transport failed\n");
+	return -1;
+}
+EXPORT_SYMBOL(xprt_setup_backchannel);
+
+/*
+ * Destroys the backchannel preallocated structures.
+ * Since these structures may have been allocated by multiple calls
+ * to xprt_setup_backchannel, we only destroy up to the maximum number
+ * of reqs specified by the caller.
+ * @xprt:	the transport holding the preallocated strucures
+ * @max_reqs	the maximum number of preallocated structures to destroy
+ */
+void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
+{
+	struct rpc_rqst *req = NULL, *tmp = NULL;
+
+	dprintk("RPC:        destroy backchannel transport\n");
+
+	BUG_ON(max_reqs == 0);
+	spin_lock_bh(&xprt->bc_pa_lock);
+	xprt_dec_alloc_count(xprt, max_reqs);
+	list_for_each_entry_safe(req, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
+		dprintk("RPC:        req=%p\n", req);
+		xprt_free_allocation(req);
+		if (--max_reqs == 0)
+			break;
+	}
+	spin_unlock_bh(&xprt->bc_pa_lock);
+
+	dprintk("RPC:        backchannel list empty= %s\n",
+		list_empty(&xprt->bc_pa_list) ? "true" : "false");
+}
+EXPORT_SYMBOL(xprt_destroy_backchannel);
+
+/*
+ * One or more rpc_rqst structure have been preallocated during the
+ * backchannel setup.  Buffer space for the send and private XDR buffers
+ * has been preallocated as well.  Use xprt_alloc_bc_request to allocate
+ * to this request.  Use xprt_free_bc_request to return it.
+ *
+ * Return an available rpc_rqst, otherwise NULL if non are available.
+ */
+struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
+{
+	struct rpc_rqst *req;
+
+	dprintk("RPC:       allocate a backchannel request\n");
+	spin_lock_bh(&xprt->bc_pa_lock);
+	if (!list_empty(&xprt->bc_pa_list)) {
+		req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
+				rq_bc_pa_list);
+		list_del(&req->rq_bc_pa_list);
+	} else {
+		req = NULL;
+	}
+	spin_unlock_bh(&xprt->bc_pa_lock);
+
+	if (req != NULL) {
+		set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
+		req->rq_received = 0;
+		req->rq_bytes_sent = 0;
+		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
+			sizeof(req->rq_private_buf));
+	}
+	dprintk("RPC:       backchannel req=%p\n", req);
+	return req;
+}
+
+/*
+ * Return the preallocated rpc_rqst structure and XDR buffers
+ * associated with this rpc_task.
+ */
+void xprt_free_bc_request(struct rpc_rqst *req)
+{
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	dprintk("RPC:       free backchannel req=%p\n", req);
+
+	smp_mb__before_clear_bit();
+	BUG_ON(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
+	clear_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
+	smp_mb__after_clear_bit();
+
+	if (!xprt_need_to_requeue(xprt)) {
+		/*
+		 * The last remaining session was destroyed while this
+		 * entry was in use.  Free the entry and don't attempt
+		 * to add back to the list because there is no need to
+		 * have anymore preallocated entries.
+		 */
+		dprintk("RPC:       Last session removed req=%p\n", req);
+		xprt_free_allocation(req);
+		return;
+	}
+
+	/*
+	 * Return it to the list of preallocations so that it
+	 * may be reused by a new callback request.
+	 */
+	spin_lock_bh(&xprt->bc_pa_lock);
+	list_add(&req->rq_bc_pa_list, &xprt->bc_pa_list);
+	spin_unlock_bh(&xprt->bc_pa_lock);
+}
+EXPORT_SYMBOL(xprt_free_bc_request);
+
+#endif /* CONFIG_NFS_V4_1 */
-- 
1.6.2.1

