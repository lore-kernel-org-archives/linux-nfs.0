From: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
Subject: [PATCH 1/1] sunrpc: potential memory leak in function rdma_read_xdr
Date: Sun, 14 Jun 2009 00:05:26 +0200
Message-ID: <20090614000526.56036335@frequentis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org, linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.frequentis.com ([212.186.194.131]:54664 "EHLO
	mail.frequentis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbZFMW1Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 18:27:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>

In case the check on ch_count fails the cleanup path is skipped and the
previously allocated memory 'rpl_map', 'chl_map' is not freed.

Signed-off-by: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
--
Reported by Coverity.

--- linux-2.6.29.4/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c.orig	2009-06-13 23:41:16.000000000 +0200
+++ linux-2.6.29.4/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c	2009-06-13 23:40:21.000000000 +0200
@@ -397,14 +397,14 @@ static int rdma_read_xdr(struct svcxprt_
 	if (!ch)
 		return 0;
 
-	/* Allocate temporary reply and chunk maps */
-	rpl_map = svc_rdma_get_req_map();
-	chl_map = svc_rdma_get_req_map();
-
 	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
 	if (ch_count > RPCSVC_MAXPAGES)
 		return -EINVAL;
 
+ 	/* Allocate temporary reply and chunk maps */
+	rpl_map = svc_rdma_get_req_map();
+	chl_map = svc_rdma_get_req_map();
+
 	if (!xprt->sc_frmr_pg_list_len)
 		sge_count = map_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
 					    rpl_map, chl_map, ch_count,
