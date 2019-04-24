Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 754ACC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44FCA218D2
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kKUCdCmW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730481AbfDXNki (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:38 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:45179 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728760AbfDXNki (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:38 -0400
Received: by mail-io1-f68.google.com with SMTP id e8so3562975ioe.12;
        Wed, 24 Apr 2019 06:40:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=OTxxhNySCQTlsI29c9OaNlFQiXqCcx30378lVTMDj/s=;
        b=kKUCdCmWuDQakBp0Qn2TMWXO7i1UEOPVaoCrliE484q+1qCEoGDHMSvXRoTL8BqgPW
         jE+EfCePH3PpCPdxa2YfwEar9otnJRoUfUFNZUVRvrxsI/2tA0/w6WyqVoEw9JouCOmK
         yQ8p2ENH/raYhQ3XEJeqXAIj17C4Sdsg0RPtfcYeRY4BOMZDErRyFl+uuM/YZk0b7d07
         bTXrkZjb0nBVsb0dG7tl9Mp/sSCuobcD99k4sp1N4DaX0JZpBohaBnDtUCO1BxIVsmMb
         mAirqzeg6nLbjbH+PBiownNVUXfgYYGFkI3QJd7vr1pjoQDJsdf4DCheWvI2mrlXSBQo
         6P3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=OTxxhNySCQTlsI29c9OaNlFQiXqCcx30378lVTMDj/s=;
        b=cXnI6x7V7QCJrksducGbBKKxK+csg9Ayf2phqlnojwpJ38kZXx3c5L0RHNXaKGPq8c
         hPrpCo3m2sPQiGFHcp7o4Xz6uqLRNT3X65LLY4UoBWj0FtzRu8bRaZQ4QqIzRKFNUnHz
         L7nyGOccRmWXyDUYnQ7H1s+UwXUSszsQdAuN/9sqAtxsL8nNkc/g0T5O6DQ4baqbx8gz
         XbpignkzC+9r/fXHT0vhUufOSO181DbHCXQKJswKzdFZ7sb+jfxsmC/USdYaLseHiuDI
         kekAIWsu6QwcOwV7uEw5Qp2pMz4IZUNib8YxmY8ncz4EiWOLP50qUGyxPuQAPLPRQDZV
         jfew==
X-Gm-Message-State: APjAAAU3uon6kBNhXC2y3azBlIDODbBmLOO5AxlNNINM6zrfchd/8DW1
        ldImpfMUGGsK1TOBOAT6Ftc=
X-Google-Smtp-Source: APXvYqzoserNloWOkjozhHxsgLbnylf2ZNObu3KOkdh6O7RC1Ac5mCraM3GHXwv3VFhqslRcXjYmHg==
X-Received: by 2002:a5d:9ccc:: with SMTP id w12mr9243015iow.253.1556113237726;
        Wed, 24 Apr 2019 06:40:37 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i12sm9153008itb.11.2019.04.24.06.40.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:37 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODeaIc011337;
        Wed, 24 Apr 2019 13:40:36 GMT
Subject: [PATCH v3 20/21] xprtrdma: Update comments that reference
 ib_drain_qp
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:36 -0400
Message-ID: <20190424134036.5077.55951.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
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

