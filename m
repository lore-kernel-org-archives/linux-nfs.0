Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A749AC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 76CFC217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IRjbH4Yf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727915AbfDPNik (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:40 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:54999 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNij (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:39 -0400
Received: by mail-it1-f195.google.com with SMTP id a190so16266589ite.4;
        Tue, 16 Apr 2019 06:38:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=OTxxhNySCQTlsI29c9OaNlFQiXqCcx30378lVTMDj/s=;
        b=IRjbH4Yf26Znx6mD8Ir8p2ckCLStR5V/xT2ycf2sIoUURk+ZtyikHPYh1Z1fn1RSs+
         R6gOswXwhS/xgXjvRCGUdWAOK6Qdi/Re/qyAqdVz9y22SFurK5YqWyxPgOcCdAYsgQGa
         YQngpmb8yNXNI6rVqJ1/lhXaS1LQBAqgEuqiU6IdcV8j3t5bmgxLWE8Sa/ecka0kwnj9
         pTHrSsW6bG0QJkpDTsrf1NP+JZP4O5gRXIzgCtRrvZXEiYmoYM4SzprIYzVMXZTCcp6u
         6R84xCbizDBC5JVDS1HFxu0Bnrgn68EBlSZa7nfV10GcUZg4oO8dPlM4RVee3cDX9BrO
         vxXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=OTxxhNySCQTlsI29c9OaNlFQiXqCcx30378lVTMDj/s=;
        b=HkD2O+WHU+apu7n6TevSPRvvGN/1pLZFmr2N3/CJ/t/OijDQ2/VwT+5FYcVld/o5AT
         ghgvJwJqkMiTdzBrxy5dI60q9GgND0gbcDVFKTV8JE2CYgF00bXSNgDL8Z7kRntG3bHc
         LyLMuHU5eQw/nhEdxfU7jBbrpPc1gb0laN7MX0SwtZ3Be5UKn/d5Y/wBLy6Y05BCup0s
         oaIu+kRA/oUlTxBuaeCFwd3t6ntsZr41LWSKpsayPL5MyeR3KlTp8YajGlGmHyv52YKx
         VquPcr3Bf9L9vfugel0PjpykHncY4bP9hqbiEIMuINxrzogeDnobMxmqFFU1GntvaUQs
         Gq/g==
X-Gm-Message-State: APjAAAW3blIxZOGEd217A7UVojW/01KdjZaFFRwaOiZ2YqVi2aEcFcns
        qxCHP1nxePOJs4MY9wXoER/GTePj
X-Google-Smtp-Source: APXvYqyPLLw99aEdNme08mLM39xc64dDTy9HSkAcsSbOCYsfeyWzvFyhBD82P2T0TKfXwtAMbeXAMw==
X-Received: by 2002:a24:d88:: with SMTP id 130mr27452675itx.87.1555421918903;
        Tue, 16 Apr 2019 06:38:38 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u13sm19163326iog.80.2019.04.16.06.38.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:38 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDcbLa021256;
        Tue, 16 Apr 2019 13:38:37 GMT
Subject: [PATCH v2 20/21] xprtrdma: Update comments that reference
 ib_drain_qp
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:37 -0400
Message-ID: <20190416133837.23113.49684.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit e1ede312f17e ("xprtrdma: Fix helper that drains the
transport") replaced the ib_drain_qp() call, so update documenting
comments to reflect current operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fcbcd4a..bef5eac 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -83,7 +83,9 @@
 static void rpcrdma_regbuf_free(struct rpcrdma_regbuf *rb);
 static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
-/* Wait for outstanding transport work to finish.
+/* Wait for outstanding transport work to finish. ib_drain_qp
+ * handles the drains in the wrong order for us, so open code
+ * them here.
  */
 static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 {
@@ -792,8 +794,8 @@ void rpcrdma_ep_destroy(struct rpcrdma_xprt *r_xprt)
  */
 
 /* rpcrdma_sendctxs_destroy() assumes caller has already quiesced
- * queue activity, and ib_drain_qp has flushed all remaining Send
- * requests.
+ * queue activity, and rpcrdma_xprt_drain has flushed all remaining
+ * Send requests.
  */
 static void rpcrdma_sendctxs_destroy(struct rpcrdma_buffer *buf)
 {
@@ -1194,7 +1196,7 @@ static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
  * rpcrdma_buffer_destroy - Release all hw resources
  * @buf: root control block for resources
  *
- * ORDERING: relies on a prior ib_drain_qp :
+ * ORDERING: relies on a prior rpcrdma_xprt_drain :
  * - No more Send or Receive completions can occur
  * - All MRs, reps, and reqs are returned to their free lists
  */

