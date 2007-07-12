From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Supplemental Patch 01] NFS/RDMA client - use rdma dma
 wrapper api
Date: Thu, 12 Jul 2007 12:15:19 -0400
Message-ID: <EXNANE01KaH4PeGSBkH00000c74@exnane01.hq.netapp.com>
References: <EXNANE013melfSudpuo00000c5f@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I91M2-0006YQ-7T
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 09:17:22 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I91Li-0004AH-Ta
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 09:17:25 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6CGDYkm017391
	for <nfs@lists.sourceforge.net>; Thu, 12 Jul 2007 09:16:17 -0700 (PDT)
In-Reply-To: <EXNANE013melfSudpuo00000c5f@exnane01.hq.netapp.com>
References: <EXNANE013melfSudpuo00000c5f@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I neglected to include the following patch to xprtrdma/verbs.c
which changes it to use the new ib_dma_*() wrappers.

BTW, it appears that some helpful mailer along the way translated
the tabs in my patches to spaces. If this message receives the
same fate I will attempt a different route next time. If anyone
wants the raw patches in the meantime, let me know.

Tom.

-----

RPCRDMA: use ib_dma interface

The rdma verbs have wrapper hooks for the dma api, use them.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 net/sunrpc/xprtrdma/verbs.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6.22/net/sunrpc/xprtrdma/verbs.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprtrdma/verbs.c
+++ linux-2.6.22/net/sunrpc/xprtrdma/verbs.c
@@ -162,8 +162,8 @@ void rpcrdma_event_process(struct ib_wc 
        switch (wc->opcode) {
        case IB_WC_RECV:
                rep->rr_len = wc->byte_len;
-               dma_sync_single_for_cpu(
-                       rdmab_to_ia(rep->rr_buffer)->ri_id->device->dma_device,
+               ib_dma_sync_single_for_cpu(
+                       rdmab_to_ia(rep->rr_buffer)->ri_id->device,
                        rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
                /* Keep (only) the most recent credits, after check validity */
                if (rep->rr_len >= 16) {
@@ -1219,7 +1219,7 @@ rpcrdma_register_internal(struct rpcrdma
        /*
        * All memory passed here was kmalloc'ed, therefore phys-contiguous.
        */
-       iov->addr = dma_map_single(ia->ri_id->device->dma_device,
+       iov->addr = ib_dma_map_single(ia->ri_id->device,
                        va, len, DMA_BIDIRECTIONAL);
        iov->length = len;
 
@@ -1257,7 +1257,7 @@ rpcrdma_deregister_internal(struct rpcrd
 {
        int rc;
 
-       dma_unmap_single(ia->ri_id->device->dma_device,
+       ib_dma_unmap_single(ia->ri_id->device,
                        iov->addr, iov->length, DMA_BIDIRECTIONAL);
 
        if (NULL == mr)
@@ -1279,11 +1279,11 @@ rpcrdma_map_one(struct rpcrdma_ia *ia, s
        seg->mr_dir = writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
        seg->mr_dmalen = seg->mr_len;
        if (seg->mr_page)
-               seg->mr_dma = dma_map_page(ia->ri_id->device->dma_device,
+               seg->mr_dma = ib_dma_map_page(ia->ri_id->device,
                                seg->mr_page, offset_in_page(seg->mr_offset),
                                seg->mr_dmalen, seg->mr_dir);
        else
-               seg->mr_dma = dma_map_single(ia->ri_id->device->dma_device,
+               seg->mr_dma = ib_dma_map_single(ia->ri_id->device,
                                seg->mr_offset,
                                seg->mr_dmalen, seg->mr_dir);
 }
@@ -1292,10 +1292,10 @@ static void
 rpcrdma_unmap_one(struct rpcrdma_ia *ia, struct rpcrdma_mr_seg *seg)
 {
        if (seg->mr_page)
-               dma_unmap_page(ia->ri_id->device->dma_device,
+               ib_dma_unmap_page(ia->ri_id->device,
                                seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
        else
-               dma_unmap_single(ia->ri_id->device->dma_device,
+               ib_dma_unmap_single(ia->ri_id->device,
                                seg->mr_dma, seg->mr_dmalen, seg->mr_dir);
 }
 
@@ -1541,13 +1541,13 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia, s
        send_wr.opcode = IB_WR_SEND;
        send_wr.imm_data = 0;
        if (send_wr.num_sge == 4)       /* no need to sync any pad (constant) */
-               dma_sync_single_for_device(ia->ri_id->device->dma_device,
+               ib_dma_sync_single_for_device(ia->ri_id->device,
                        req->rl_send_iov[3].addr, req->rl_send_iov[3].length,
                        DMA_TO_DEVICE);
-       dma_sync_single_for_device(ia->ri_id->device->dma_device,
+       ib_dma_sync_single_for_device(ia->ri_id->device,
                req->rl_send_iov[1].addr, req->rl_send_iov[1].length,
                DMA_TO_DEVICE);
-       dma_sync_single_for_device(ia->ri_id->device->dma_device,
+       ib_dma_sync_single_for_device(ia->ri_id->device,
                req->rl_send_iov[0].addr, req->rl_send_iov[0].length,
                DMA_TO_DEVICE);
 
@@ -1580,7 +1580,7 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *
        recv_wr.sg_list = &rep->rr_iov;
        recv_wr.num_sge = 1;
 
-       dma_sync_single_for_cpu(ia->ri_id->device->dma_device,
+       ib_dma_sync_single_for_cpu(ia->ri_id->device,
                rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
 
        DECR_CQCOUNT(ep);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
