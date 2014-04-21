Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:59026 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbaDUWBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 18:01:06 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V2 02/17] nfs-rdma: Fix for FMR leaks
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Apr 2014 18:01:03 -0400
Message-ID: <20140421220102.12569.95624.stgit@manet.1015granger.net>
In-Reply-To: <20140421214442.12569.8950.stgit@manet.1015granger.net>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Allen Andrews <allen.andrews@emulex.com>

Two memory region leaks were found during testing:

1. rpcrdma_buffer_create: While allocating RPCRDMA_FRMR's
ib_alloc_fast_reg_mr is called and then ib_alloc_fast_reg_page_list is
called.  If ib_alloc_fast_reg_page_list returns an error it bails out of
the routine dropping the last ib_alloc_fast_reg_mr frmr region creating a
memory leak.  Added code to dereg the last frmr if
ib_alloc_fast_reg_page_list fails.

2. rpcrdma_buffer_destroy: While cleaning up, the routine will only free
the MR's on the rb_mws list if there are rb_send_bufs present.  However, in
rpcrdma_buffer_create while the rb_mws list is being built if one of the MR
allocation requests fail after some MR's have been allocated on the rb_mws
list the routine never gets to create any rb_send_bufs but instead jumps to
the rpcrdma_buffer_destroy routine which will never free the MR's on rb_mws
list because the rb_send_bufs were never created.   This leaks all the MR's
on the rb_mws list that were created prior to one of the MR allocations
failing.

Issue(2) was seen during testing. Our adapter had a finite number of MR's
available and we created enough connections to where we saw an MR
allocation failure on our Nth NFS connection request. After the kernel
cleaned up the resources it had allocated for the Nth connection we noticed
that FMR's had been leaked due to the coding error described above.

Issue(1) was seen during a code review while debugging issue(2).

Signed-off-by: Allen Andrews <allen.andrews@emulex.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c |   73 ++++++++++++++++++++++---------------------
 1 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 55fb09a..8f9704e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1081,6 +1081,8 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 				dprintk("RPC:       %s: "
 					"ib_alloc_fast_reg_page_list "
 					"failed %i\n", __func__, rc);
+
+				ib_dereg_mr(r->r.frmr.fr_mr);
 				goto out;
 			}
 			list_add(&r->mw_list, &buf->rb_mws);
@@ -1217,41 +1219,6 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 			kfree(buf->rb_recv_bufs[i]);
 		}
 		if (buf->rb_send_bufs && buf->rb_send_bufs[i]) {
-			while (!list_empty(&buf->rb_mws)) {
-				r = list_entry(buf->rb_mws.next,
-					struct rpcrdma_mw, mw_list);
-				list_del(&r->mw_list);
-				switch (ia->ri_memreg_strategy) {
-				case RPCRDMA_FRMR:
-					rc = ib_dereg_mr(r->r.frmr.fr_mr);
-					if (rc)
-						dprintk("RPC:       %s:"
-							" ib_dereg_mr"
-							" failed %i\n",
-							__func__, rc);
-					ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
-					break;
-				case RPCRDMA_MTHCAFMR:
-					rc = ib_dealloc_fmr(r->r.fmr);
-					if (rc)
-						dprintk("RPC:       %s:"
-							" ib_dealloc_fmr"
-							" failed %i\n",
-							__func__, rc);
-					break;
-				case RPCRDMA_MEMWINDOWS_ASYNC:
-				case RPCRDMA_MEMWINDOWS:
-					rc = ib_dealloc_mw(r->r.mw);
-					if (rc)
-						dprintk("RPC:       %s:"
-							" ib_dealloc_mw"
-							" failed %i\n",
-							__func__, rc);
-					break;
-				default:
-					break;
-				}
-			}
 			rpcrdma_deregister_internal(ia,
 					buf->rb_send_bufs[i]->rl_handle,
 					&buf->rb_send_bufs[i]->rl_iov);
@@ -1259,6 +1226,42 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		}
 	}
 
+	while (!list_empty(&buf->rb_mws)) {
+		r = list_entry(buf->rb_mws.next,
+			struct rpcrdma_mw, mw_list);
+		list_del(&r->mw_list);
+		switch (ia->ri_memreg_strategy) {
+		case RPCRDMA_FRMR:
+			rc = ib_dereg_mr(r->r.frmr.fr_mr);
+			if (rc)
+				dprintk("RPC:       %s:"
+					" ib_dereg_mr"
+					" failed %i\n",
+					__func__, rc);
+			ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
+			break;
+		case RPCRDMA_MTHCAFMR:
+			rc = ib_dealloc_fmr(r->r.fmr);
+			if (rc)
+				dprintk("RPC:       %s:"
+					" ib_dealloc_fmr"
+					" failed %i\n",
+					__func__, rc);
+			break;
+		case RPCRDMA_MEMWINDOWS_ASYNC:
+		case RPCRDMA_MEMWINDOWS:
+			rc = ib_dealloc_mw(r->r.mw);
+			if (rc)
+				dprintk("RPC:       %s:"
+					" ib_dealloc_mw"
+					" failed %i\n",
+					__func__, rc);
+			break;
+		default:
+			break;
+		}
+	}
+
 	kfree(buf->rb_pool);
 }
 

