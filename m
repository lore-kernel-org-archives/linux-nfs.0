Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA5DC7EE24
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Jun 2023 13:11:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232465AbjFENLw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Jun 2023 09:11:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58416 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232736AbjFENLu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jun 2023 09:11:50 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 89889A6;
        Mon,  5 Jun 2023 06:11:39 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 118A161403;
        Mon,  5 Jun 2023 13:11:39 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 329FEC433D2;
        Mon,  5 Jun 2023 13:11:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1685970698;
        bh=Tx2k1Lic7n4XBWBsPunFUYSJp+SqNd9zIEWtd6k85yE=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=Xtbb0Gu8SwIkRIJXib2Y5e0ew/Q6zDJtNyiH8VxD7fO7EtwiolfHPoaW0jDS8FpQg
         AJ+7pVlJsWDjBO69huW4d6z9t8NIfjiTrGZvPyQ+o6cJAx997pW2cfLHetC+kCEyP4
         cJhukV4QztIGhjy/pINHWg+cRvZnb25xgIUC+ERc1YdJ8VXpK+6dgFzS5Hy1rtXudV
         eGoI+ZnV7D8p5UKvJ9Ddp3Ovpp3V9miWzJYAb5zoiO5xJLmRkcLvD5hC3RX1m8/PIK
         iw+xZSuPtZ2MZMJl6KeYZsclL4rbFXdQ3CMvbKTI68S8lrC5v5AMvyKFUpGfNwTWvh
         vJiGcZVR+YcKg==
Subject: [PATCH v1 3/4] svcrdma: Clean up allocation of svc_rdma_send_ctxt
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        tom@talpey.com
Date:   Mon, 05 Jun 2023 09:11:37 -0400
Message-ID: <168597069727.7694.6817108128932819545.stgit@manet.1015granger.net>
In-Reply-To: <168597050247.7694.8719658227499409307.stgit@manet.1015granger.net>
References: <168597050247.7694.8719658227499409307.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

The physical device's favored NUMA node ID is available when
allocating a send_ctxt. Use that value instead of relying on the
assumption that the memory allocation happens to be running on a
node close to the device.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 22a871e6fe4d..a35d1e055b1a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -123,18 +123,17 @@ static void svc_rdma_send_cid_init(struct svcxprt_rdma *rdma,
 static struct svc_rdma_send_ctxt *
 svc_rdma_send_ctxt_alloc(struct svcxprt_rdma *rdma)
 {
+	int node = ibdev_to_node(rdma->sc_cm_id->device);
 	struct svc_rdma_send_ctxt *ctxt;
 	dma_addr_t addr;
 	void *buffer;
-	size_t size;
 	int i;
 
-	size = sizeof(*ctxt);
-	size += rdma->sc_max_send_sges * sizeof(struct ib_sge);
-	ctxt = kmalloc(size, GFP_KERNEL);
+	ctxt = kmalloc_node(struct_size(ctxt, sc_sges, rdma->sc_max_send_sges),
+			    GFP_KERNEL, node);
 	if (!ctxt)
 		goto fail0;
-	buffer = kmalloc(rdma->sc_max_req_size, GFP_KERNEL);
+	buffer = kmalloc_node(rdma->sc_max_req_size, GFP_KERNEL, node);
 	if (!buffer)
 		goto fail1;
 	addr = ib_dma_map_single(rdma->sc_pd->device, buffer,


