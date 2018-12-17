Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBB26C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB9282133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZNyjqZUx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388326AbeLQQlo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:44 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:39253 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQln (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:43 -0500
Received: by mail-io1-f68.google.com with SMTP id k7so10458700iob.6;
        Mon, 17 Dec 2018 08:41:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=P/nO2EcoT+jAHQTgWRUXGGXa4Ij30Kh35hLNAzyaj+Q=;
        b=ZNyjqZUxRUWM5ThDn2TrKT00tEE/WAS/pUtinsEKhy+nLzsJ/Ik/gxhLhIaRMJpbIF
         yQOhLO1rXqr9pbInKyXYDmcBk5x78JVpM/WEKhTnSgpq56Wf2OsnD/dq3RV4wyLKCWXu
         63Ev7k3NSMmjlAvN0xmfpgiowxmgM8J71zE2esViDN/RCThsxG/ugrafjrLN2ylo5WRl
         ywZjHFx3ew+s09F97zxK11kDEBc9TOaAFNs//C0gy0mmjPAyT9SBaGuvxOZd3Kc9rmoZ
         17WjhS0SsEifS/9dg6Uq8NwTlk9ddW0pfKLxsMmDuM4Qjs9zINMPt1IJRsMVVjWLRaJC
         dnpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=P/nO2EcoT+jAHQTgWRUXGGXa4Ij30Kh35hLNAzyaj+Q=;
        b=MiSgt4r1Vvokqc6+LDzSMzQkTZEqmuXgeNp6ha123bSSzUbtHTLf/L2gU20m3DVoUx
         IXAV3IW4zgHyQwnVC8O8784Md7TKNINZVDaSErwS0QiCinRhXLA4bixNif4dQTDIgqLp
         ++2m0ZprEO+rdlB+iPamW8FeRdbKfERPYkt7Ssn/jcLTKHKT/CyaFlNn4qdoujORyq/2
         rD93Z2OAP1a9czmBX8jBW29FoeR6thCClhCWKIS+trtpNLY7tO9Qm/d7l8MQWLYBDLKb
         Vg9YcGMN37MmwImWrDqJpbaMz0B9HL/Xdq9xgDosRScfnLJPF4i4B/qjhzOqnGtA0VRH
         tCeg==
X-Gm-Message-State: AA+aEWZ7Bijay/9Ag9FFHzN3xZqSgEQJPxkQhE6Nrb8GQlLcPuoeARK5
        SHitbiJ8iWKu8Aw0RsMd9tWBYTN9
X-Google-Smtp-Source: AFSGD/Vvuuwl8DzYTya0o3VZEul2kR7+tejMeXo/2oN1Sx77X/bnySY+w6fbjxd5fyc5+0mVW/Q/lQ==
X-Received: by 2002:a6b:d20f:: with SMTP id q15mr12354834iob.100.1545064901464;
        Mon, 17 Dec 2018 08:41:41 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l11sm5828081iob.24.2018.12.17.08.41.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:40 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfers018657;
        Mon, 17 Dec 2018 16:41:40 GMT
Subject: [PATCH v4 26/30] xprtrdma: Update comments in frwr_op_send
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:40 -0500
Message-ID: <20181217164140.24133.39887.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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

