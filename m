Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77355C43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 19:09:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4721E206B7
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 19:09:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="riiILGsk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727098AbfAGTJW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 14:09:22 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:60366 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727008AbfAGTJW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2019 14:09:22 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x07J3kjU155662;
        Mon, 7 Jan 2019 19:09:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type : in-reply-to;
 s=corp-2018-07-02; bh=DrvXldxHVvWpGSpnrOECS/G9fjeGjnOXTOINge1ppzI=;
 b=riiILGskaIfti+zYc1rDYrmsvdKx/r8HQvvLGLZY1OyePqGsn3pr3t/aelAKWzw7IWkL
 yPXKg2sJGz+kfRBmvcRfthEJZiSmA6EyAbHLNe5roMyLrh+AUVgPgbU1AnKsqvsi6fXQ
 mlz/T1Gyuptt5KyXCTSjcVdQ9kI0GLgM2Ru4OY7qnywP3hZaQuPreswgM/RufH/LbF0D
 8GHIpZGKxGYrczIgWHZpyRxQ3jBzWVP6PBk4ek0QAisIPZjiM62mzkHHEW+9cZ4WCKe6
 OjIoVOEuNRsojhXnWbgm1QsHkjqHgjW98avQQRkL6oTX9kHceyEXLNgk78Gb+0q5WSpz sQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2ptm0tykvc-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 07 Jan 2019 19:09:17 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x07J9BYv025436
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 7 Jan 2019 19:09:12 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x07J9BBx014795;
        Mon, 7 Jan 2019 19:09:11 GMT
Received: from kadam (/10.175.22.59)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 07 Jan 2019 11:09:11 -0800
Date:   Mon, 7 Jan 2019 22:08:06 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH] xprtrdma: Make rpcrdma_sendctxs_destroy() more robust
Message-ID: <20190107190806.GA6094@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9129 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901070160
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There was a double free in the error handling here recently.  It was
a bit subtle which function was supposed to call rpcrdma_sendctxs_destroy()
so it was called in both.

This patch makes it so we can call rpcrdma_sendctxs_destroy() twice
in a row without crashing.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7749a2bf6887..d05f4885548d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -802,9 +802,12 @@ static void rpcrdma_sendctxs_destroy(struct rpcrdma_buffer *buf)
 {
 	unsigned long i;
 
+	if (!buf->rb_sc_ctxs)
+		return;
 	for (i = 0; i <= buf->rb_sc_last; i++)
 		kfree(buf->rb_sc_ctxs[i]);
 	kfree(buf->rb_sc_ctxs);
+	buf->rb_sc_ctxs = NULL;
 }
 
 static struct rpcrdma_sendctx *rpcrdma_sendctx_create(struct rpcrdma_ia *ia)
-- 
2.17.1

