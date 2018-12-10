Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9E6C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8B93C20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KYsjKX5S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B93C20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728381AbeLJQ37 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:59 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54819 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727705AbeLJQ36 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:58 -0500
Received: by mail-it1-f195.google.com with SMTP id i145so18224473ita.4;
        Mon, 10 Dec 2018 08:29:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=5LEpbexUDkFgqCbAwKULfz+fIHHKTumSNfAylh7oaXk=;
        b=KYsjKX5SDjVihl1SZNiaM96tUBuL9YEieoqfg7UeH11jJwV8pdrFvwwGn9L/hWPpqi
         SC/Y+Dp4FtuHhQjbNtGcACEIGWN8TXTeiX4FbOsmDiq/MalrQPd9kqXg4RghPIBvJ59H
         rbzyP82ctoIHv+aiuZg6DYmNffNMVCEdKPk39CPldbw083D/QEb7mb2JroHdfaxcd6f0
         Ghp8n2wIlv/WgAmeczpEEDj3CIPO5smBAUdkJTtKUXUI8uUw2sDDO/yCdqkpiJRIgjgw
         4ZerCeX9ZmWIK18YIfIROLWgVX0CXhIwbvN3wyeu9kIok2CIRxuKvchBv7X+lWYZI+fy
         ls5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=5LEpbexUDkFgqCbAwKULfz+fIHHKTumSNfAylh7oaXk=;
        b=iA471mfN2HqwMu5BlAtDUWjw6VfmWiZoe+jpcCHQn8NN1qhEadnmJtY1AcdVz66+Nw
         AFVN42m9DOXz2VFpVzKRn/fQnmCto4gJ3mklaMhKAGEOpn0hcdwIqsHO7q0vbyURVkSN
         j8vSo2122/LfhoxZF7QGh2GrpUpRXoJi8RpR5mODbol21nbTapMbfGBpw2MZqeNpawye
         qm1yzAItdOK5rgbVx+WBuudHyVO4R/lzYhz6XqMcdpHGKog1eNlFsLMecymjaiai5t4o
         oimEn3wznvjIFlUWvx1ma8igwNvwZaVLJE0UDif30ecPfOOOcUkT8FrlUWH22RFcjVZZ
         A9kg==
X-Gm-Message-State: AA+aEWb/to14c4153nzRHKgNdV61IItGKE1mJFaGsKRfIZojwANAHFKa
        5HCK1PDtVie9l5Gj0H9sn6RKZlbA
X-Google-Smtp-Source: AFSGD/VPgUFYl/JXOIvJX7EcSxfFYq38klGIq+SRoBv5pEMNluAkF5hijgzZYepIQsjVGkYNxU6idA==
X-Received: by 2002:a24:d587:: with SMTP id a129mr11133402itg.111.1544459397677;
        Mon, 10 Dec 2018 08:29:57 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w16sm6480969ita.38.2018.12.10.08.29.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:57 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTuEF031033;
        Mon, 10 Dec 2018 16:29:56 GMT
Subject: [PATCH v3 07/24] xprtrdma: Recognize XDRBUF_SPARSE_PAGES
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:56 -0500
Message-ID: <20181210162956.4198.69039.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 431f6eb3570f ("SUNRPC: Add a label for RPC calls that require
allocation on receive") didn't update similar logic in rpc_rdma.c.
I don't think this is a bug, per-se; the commit just adds more
careful checking for broken upper layer behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 4cf0855..601dbe5 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -218,11 +218,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = offset_in_page(xdrbuf->page_base);
 	while (len) {
-		if (unlikely(!*ppages)) {
-			/* XXX: Certain upper layer operations do
-			 *	not provide receive buffer pages.
-			 */
-			*ppages = alloc_page(GFP_ATOMIC);
+		/* ACL likes to be lazy in allocating pages - ACLs
+		 * are small by default but can get huge.
+		 */
+		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
+			if (!*ppages)
+				*ppages = alloc_page(GFP_ATOMIC);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

