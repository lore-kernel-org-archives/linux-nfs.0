Return-Path: <SRS0=9vja=PN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62406C43387
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 13:06:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2727920868
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 13:06:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lL8mF2oG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726235AbfAENGd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 5 Jan 2019 08:06:33 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:34566 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726108AbfAENGd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jan 2019 08:06:33 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x05CwgXb058799;
        Sat, 5 Jan 2019 13:06:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=CvkRLHB7qP39+rJYBs4e8yetWnxpwuQajJ4as3DtX74=;
 b=lL8mF2oG7ffreQXMKxQyYS2B9iuhFAeyeX3SubskyyM73uJmSg52CCnMdUe+PjGAvnbx
 qwlf+xQbV4NoE45yxSQTNYy7ZLyaG9THTUYVPEVBxkeKwj6ixdv3q0B+w3lFkQzByPYK
 nKHEcpMXtYCYlGYC0lu5xFP8Kw6wizWTOqIh1AI29RZIPrED//7YPIreqFuM/sx8/KZH
 OvU9w4gVur21TxPAyMEHhHKNf1zfpvmc4TCCh8rCaWrXtHVYtCXg5vuKFt6MFEHV+SWk
 Bg8qu2hHP/YV4+YitB5R/pUvZ1WvRIlyGfUtJFHKC0rMenU7ZEGEcNtnM3NRrsJ1vWTo AQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2ptm0tru9d-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Jan 2019 13:06:26 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x05D6IdC009831
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 5 Jan 2019 13:06:19 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x05D6Fcx006711;
        Sat, 5 Jan 2019 13:06:15 GMT
Received: from kadam (/41.202.241.48)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 05 Jan 2019 05:06:15 -0800
Date:   Sat, 5 Jan 2019 16:06:07 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH 1/2] xprtrdma: Fix error code in rpcrdma_buffer_create()
Message-ID: <20190105130607.GB3288@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9126 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901050117
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This should return -ENOMEM if __alloc_workqueue_key() fails, but it
returns success.

Fixes: 6d2d0ee27c7a ("xprtrdma: Replace rpcrdma_receive_wq with a per-xprt workqueue")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7749a2bf6887..3dde05892c8e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1113,8 +1113,10 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 						WQ_MEM_RECLAIM | WQ_HIGHPRI,
 						0,
 			r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
-	if (!buf->rb_completion_wq)
+	if (!buf->rb_completion_wq) {
+		rc = -ENOMEM;
 		goto out;
+	}
 
 	return 0;
 out:
-- 
2.17.1

