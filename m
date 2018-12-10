Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC892C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70B8520821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OUzX9SfF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B8520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728486AbeLJQbY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:24 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:40473 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728314AbeLJQbY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:24 -0500
Received: by mail-it1-f195.google.com with SMTP id h193so19090870ita.5;
        Mon, 10 Dec 2018 08:31:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6phxmDZB86RDBH8D8BAj17nOlFF5CSXmgqTYWFiAz8Q=;
        b=OUzX9SfFW7DJADba2i4YBfpI2SNqWTuCpRyPpDCK2TLgwK2apYaSRP/OnuoFkolkgX
         FS9LWnIVnfDlazJ09VBH889E4EvPJJsjswCo70rP657aOiZJWLxhR+1OSk3c4GC0s6QN
         T502ngiKLSVCyzf34UZRtGvv+P2xcpNx80fIm3iAmKokru8SuLuHIx/4Vf6lo54fSgPW
         ZLRpugmfpaHGQ/RKigASaVipOqW1MykhAR9pngXyuCU40e/DX3BwG9mokSiFSwcV6vVD
         Q+KQMIdTs79PloekFb4siOdLZVQrWBVGDyC7nCuGw0/flWmen6/KrZ1ctPy+lnsLKfwl
         BgbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6phxmDZB86RDBH8D8BAj17nOlFF5CSXmgqTYWFiAz8Q=;
        b=piUQ8g7NT6cY/iT9Y9vGw07U3dXQa/FzMf39cTh81jOaMVNVLYFtZsKl4i+gTXnHdO
         P5ha0As9hC/fWHM0uOeDwBpQXANHL6cdwYJUxcWDDvbT5umuNCNi8BYmn+lUpgx5KaVY
         RZv9/RGqij23OTZXuhAczoHNF0IrtTpfhMGMVKYDr6iOO05Y9OLNBOg7/S9N5pFgdDqF
         HQ5V20YKv6vE6mup6cc4oV/n/7CWhr09bC5eZ8rrcA6ttckuVmAWfg43UeuPsd9WiWgA
         xCxt3j/mgo60tEqAp3HQJAW2u36p+aRYfVH6qzd9V+lnjIo5fEU1W1PJCI+mCVZTKUZn
         +WwA==
X-Gm-Message-State: AA+aEWZ6GzSXNKeIl/EPtZrn5b3lmMtw1/2UVuYNIOw6r+G+lLZQO1Nx
        gEv6HbhNktpa4kccDpX3piWmPfrZ
X-Google-Smtp-Source: AFSGD/UI2c0a12hqyGBIuAcJKs30GrOWu1dVygRgivmcy/7w/KaWivgxnQc/IkvJFYslE54m4xmMIg==
X-Received: by 2002:a02:8943:: with SMTP id u3mr11834189jaj.92.1544459483331;
        Mon, 10 Dec 2018 08:31:23 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q23sm4798062ioi.66.2018.12.10.08.31.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:22 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGVLis031092;
        Mon, 10 Dec 2018 16:31:21 GMT
Subject: [PATCH v3 23/24] xprtrdma: Add documenting comment for
 rpcrdma_buffer_destroy
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:21 -0500
Message-ID: <20181210163121.4198.95733.stgit@manet.1015granger.net>
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

Make a note of the function's dependency on an earlier ib_drain_qp.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f403afc..78a1200 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1212,6 +1212,14 @@ struct rpcrdma_req *
 	dprintk("RPC:       %s: released %u MRs\n", __func__, count);
 }
 
+/**
+ * rpcrdma_buffer_destroy - Release all hw resources
+ * @buf: root control block for resources
+ *
+ * ORDERING: relies on a prior ib_drain_qp :
+ * - No more Send or Receive completions can occur
+ * - All MRs, reps, and reqs are returned to their free lists
+ */
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {

