Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F64EC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F357A217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mBq0crVe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729576AbeLSQAa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:30 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:33941 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729503AbeLSQAa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:30 -0500
Received: by mail-it1-f193.google.com with SMTP id x124so11334319itd.1;
        Wed, 19 Dec 2018 08:00:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=P/nO2EcoT+jAHQTgWRUXGGXa4Ij30Kh35hLNAzyaj+Q=;
        b=mBq0crVecqqhjB0DcnoxQ4YmwWC4uhOyWe4K92ZPJMo6lBgRT0Awfuzk6RmdIzGMGc
         3hjLBTX95nNg3Q4VrFQd8ni8bIl+BMK/G1Ixypzqd2n4NBCrNp5vjZOhVwwoiaFdmkSG
         Q+WaQwKBVFMvq9HmxDxQfrLi9KCanyVRtyehM5OxPy1pHNljYRQGUbAaywRg5BdJbhz8
         X49tkITuN93YgZ8SlKBzS5MmCqF3gFV/o3OVX9KUE182odlcsGaqS+kiavK1wtHR1hz6
         sQrunJad68AIt77Vk1oXWGqf4iH7oQbnvj8eQb+DT/Tn5szFIgwZFM6hgY+5soZ6Z2/r
         ZrkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=P/nO2EcoT+jAHQTgWRUXGGXa4Ij30Kh35hLNAzyaj+Q=;
        b=ps02av5FmgzeB9iqRKcqCEDMfCq1BcD86ly/sO3uzNJYqMtrdY5iZ32TAeFqb9E35M
         rEFCAGWGd7/eVb9pdaEyrr/QNx35NejfuEPnD4OkdOUvAR0Wjy3RpbP7dP+YQy6sHpQJ
         pjTzAHXo6ISfBRTmcxrxRzxw4cKkMm7wnOkKaGK9C8Zqf7+WcF8oXNW7kWPZ2o7fMYNc
         Rll3ILjs1q3qPVnjrRjkjxQgKnG5xVQOG53EjaiXV5Ao/8s1Ice5in/xyceTsgsdEb2R
         gYgmQ9YD2bTAkWYaVTz49pvUz5Q6CY3wcy/pzoPh6630qRN/BLf3gOGpGe9JuHZxL/fV
         ktTA==
X-Gm-Message-State: AA+aEWYv6XzLHnTFnqeirhRu7tqAcbFq6LEeGd1vlDbTbVP6wsivX0kf
        xeu9pV5NokDjZZueR3UCOXUw0Q0B
X-Google-Smtp-Source: AFSGD/WKcjQ4MNqbUUZ5jSjApccQUShAbClu556GpLrHi2QzmifwXlM8VffCtlUErIWv03R7JWTCxA==
X-Received: by 2002:a02:7127:: with SMTP id n39mr19966548jac.91.1545235228608;
        Wed, 19 Dec 2018 08:00:28 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k64sm3837732itb.7.2018.12.19.08.00.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:27 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0RVG025844;
        Wed, 19 Dec 2018 16:00:27 GMT
Subject: [PATCH v5 26/30] xprtrdma: Update comments in frwr_op_send
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:27 -0500
Message-ID: <20181219160027.11602.66945.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit f2877623082b ("xprtrdma: Chain Send to FastReg WRs") was
written before commit ce5b37178283 ("xprtrdma: Replace all usage of
"frmr" with "frwr""), but was merged afterwards. Thus it still
refers to FRMR and MWs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 8a0f1a6..35c8f62 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -479,7 +479,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
  * @ia: interface adapter
  * @req: Prepared RPC Call
  *
- * For FRMR, chain any FastReg WRs to the Send WR. Only a
+ * For FRWR, chain any FastReg WRs to the Send WR. Only a
  * single ib_post_send call is needed to register memory
  * and then post the Send WR.
  *
@@ -507,7 +507,7 @@ int frwr_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 	}
 
 	/* If ib_post_send fails, the next ->send_request for
-	 * @req will queue these MWs for recovery.
+	 * @req will queue these MRs for recovery.
 	 */
 	return ib_post_send(ia->ri_id->qp, post_wr, NULL);
 }

