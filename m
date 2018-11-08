Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50A53C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 01:55:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E34C20827
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 01:55:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E34C20827
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727724AbeKHL2a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 06:28:30 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:57074 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728527AbeKHL2a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 06:28:30 -0500
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 570E06488771;
        Thu,  8 Nov 2018 09:55:21 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Thu, 8 Nov 2018 09:55:13 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David Miller" <davem@davemloft.net>,
        Jeff Layton <jlayton@kernel.org>
CC:     YueHaibing <yuehaibing@huawei.com>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
Subject: [PATCH net-next] SUNRPC: drop pointless static qualifier in xdr_get_next_encode_buffer()
Date:   Thu, 8 Nov 2018 02:04:57 +0000
Message-ID: <1541642697-33860-1-git-send-email-yuehaibing@huawei.com>
X-Mailer: git-send-email 1.8.3.1
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There is no need to have the '__be32 *p' variable static since new value
always be assigned before use it.

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/sunrpc/xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 2bbb8d3..d80b156 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -546,7 +546,7 @@ void xdr_commit_encode(struct xdr_stream *xdr)
 static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 		size_t nbytes)
 {
-	static __be32 *p;
+	__be32 *p;
 	int space_left;
 	int frag1bytes, frag2bytes;



