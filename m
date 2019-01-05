Return-Path: <SRS0=9vja=PN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EDC9C43387
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 13:07:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFD4620868
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 13:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W8Zv9W+4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726241AbfAENHH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 5 Jan 2019 08:07:07 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:49772 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726108AbfAENHH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jan 2019 08:07:07 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x05CwpeL019369;
        Sat, 5 Jan 2019 13:07:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=fAolkFlxQ7o+meRuZ7tywuIuAqgch6xnuM0hsIQP7IM=;
 b=W8Zv9W+4PZDIoqNkF6cb2PVDyETPENtOIZxWoh1LV8r2pYn4ZTckddwl2znNmyJuK8Mt
 dFmE5Yk6J4KjX0YEo58uLLqRpQXmQx2eRFMTxYXnEkusDvjf8JuxOORvrVbojuRdVuxI
 QpPKLddogvYUYJqcqRNVGw53AQDGIeVvkMLUVg0GM0Ouqtjv7xrYU+AypSUUzmZveAQw
 KbgJdBglvqmrJkvhuKU4kJlBnLZXcGZOejOQJjhX1A0JROurn4cxeDHHSHuyH4whKzz6
 JiSpLmyLT+m6bBBs5fzX0Q95utaYeeQF3PBm4yOMkJ0x6Bd4zcWtPq+GoD2v70GpjsOy oQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2ptn7qgq41-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Jan 2019 13:07:00 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x05D6xvh026136
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 5 Jan 2019 13:06:59 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x05D6xfd020457;
        Sat, 5 Jan 2019 13:06:59 GMT
Received: from kadam (/41.202.241.48)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 05 Jan 2019 05:06:58 -0800
Date:   Sat, 5 Jan 2019 16:06:48 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
Message-ID: <20190105130648.GC3288@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9126 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901050117
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The clean up is handled by the caller, rpcrdma_buffer_create(), so this
call to rpcrdma_sendctxs_destroy() leads to a double free.

Fixes: ae72950abf99 ("xprtrdma: Add data structure to manage RDMA Send arguments")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3dde05892c8e..4994e75945b8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -845,17 +845,13 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
 	for (i = 0; i <= buf->rb_sc_last; i++) {
 		sc = rpcrdma_sendctx_create(&r_xprt->rx_ia);
 		if (!sc)
-			goto out_destroy;
+			return -ENOMEM;
 
 		sc->sc_xprt = r_xprt;
 		buf->rb_sc_ctxs[i] = sc;
 	}
 
 	return 0;
-
-out_destroy:
-	rpcrdma_sendctxs_destroy(buf);
-	return -ENOMEM;
 }
 
 /* The sendctx queue is not guaranteed to have a size that is a
-- 
2.17.1

