Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC7E9C282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 17:21:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9633F20818
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 17:21:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727379AbfBERVE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 12:21:04 -0500
Received: from mx2.suse.de ([195.135.220.15]:54240 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726922AbfBERVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 12:21:04 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 7AC00B6A4;
        Tue,  5 Feb 2019 17:21:03 +0000 (UTC)
From:   Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
Subject: [PATCH v3] xprtrdma: Make sure Send CQ is allocated on an existing
 compvec
To:     linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Message-ID: <9d418664-1f67-c705-19a0-80fc9dc5a12b@suse.com>
Date:   Tue, 5 Feb 2019 18:21:02 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Language: fr
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make sure the device has at least 2 completion vectors
before allocating to compvec#1

Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
Signed-off-by: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
---
Changes since v2:
 - Split line for checkpatch to be happy

 net/sunrpc/xprtrdma/verbs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b725911c0f3f..5fe727a7db82 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -546,7 +546,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
-			     1, IB_POLL_WORKQUEUE);
+			     ia->ri_device->num_comp_vectors > 1 ? 1 : 0,
+			     IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
-- 
2.18.0

