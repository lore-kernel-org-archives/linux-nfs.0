Return-Path: <SRS0=WqcA=WP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB7BC3A5A0
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 22:39:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8A5252070B
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 22:39:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t2oTA9jY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728508AbfHSWjB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Aug 2019 18:39:01 -0400
Received: from mail-oi1-f196.google.com ([209.85.167.196]:35689 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728136AbfHSWjA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2019 18:39:00 -0400
Received: by mail-oi1-f196.google.com with SMTP id a127so2602519oii.2;
        Mon, 19 Aug 2019 15:39:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=9ArGAmPXjVE1LatQBgsFDGnSvkfYJFMMdFUO/FkUeIo=;
        b=t2oTA9jYCBDGjR3YUZqtFbmXXj9r0UGs4aEn6GneWcJRlDBwm0luLwnFgF/BRe/rFp
         AVUpsDMQ8rS20r1ShuHHBgmuCUf9+d9QtGqB3HSq3UZCzdX8y+fLRRsuiUcoRgDqnBmd
         PU9Rp2GacIquWCqZA+cgtdUAMDb9omucAxyp412mcpO5lk2AL7PE7vtG8zqOSkbnhY16
         fs7J63V2elaEL2RF1xxVk1BTXgPrFy+5TsrCcZ3d3kAGhRTrkCjjEkgnCs3/NsOdVGBp
         nj9RCfn4CAHlsq0rBBNXS/05sImjKrslsGRhyWY/TIc1mNt0zigRCSc1VTWALNou5YC9
         vrLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=9ArGAmPXjVE1LatQBgsFDGnSvkfYJFMMdFUO/FkUeIo=;
        b=IFnQprt1QJMa3NmnNIyTDBfBxx/yf11tKNa/OvRDRY5NZuNFJfIPniNBBiYJ4oUvoG
         Ut85B+ZWs3j9nb3XJxC+w7pX1t5R7D6dz4QGyyDYvygdcc8uT1gOJCpbVTa81ZVM6hAE
         4+ZlwyWecMmZEAeCqs+ibxknjxtAsrOfcu2c+SfcSZi2hh4r7OWZTVpwc8yra61Yn8za
         ya4xeXJ+Yavc9Bmy/Nk9FQchtafFaorIR/4uiuKmOvf54dijovs2C3IWcoEXrToXU9gg
         b2+bX6tink5oGadxmzdcilikIyj7xzh4yMhWV5YmO3Sos0GjIINjwPfDXOUDMGXNjMOs
         Ffeg==
X-Gm-Message-State: APjAAAWH0YScYizPqGAx+LZIJDdxh9G9zeYCIgVzDNINw0V18xH7iFVP
        A5NixjpTtldjzI8N0S6rUZwkdrrS
X-Google-Smtp-Source: APXvYqxvlXrxOglFfGM47hXsqhu1EIqUHQ+aOqjgLWlyvGAGupKCjboRCJU9JZxwbt7h78q8aftd/w==
X-Received: by 2002:aca:50cb:: with SMTP id e194mr7646726oib.48.1566254339926;
        Mon, 19 Aug 2019 15:38:59 -0700 (PDT)
Received: from seurat29.1015granger.net ([12.235.16.3])
        by smtp.gmail.com with ESMTPSA id s22sm3344653oij.37.2019.08.19.15.38.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Aug 2019 15:38:59 -0700 (PDT)
Subject: [PATCH v2 04/21] xprtrdma: Update obsolete comment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Mon, 19 Aug 2019 18:38:38 -0400
Message-ID: <156625429858.8161.12698423687311798381.stgit@seurat29.1015granger.net>
In-Reply-To: <156625401091.8161.14744201497689200191.stgit@seurat29.1015granger.net>
References: <156625401091.8161.14744201497689200191.stgit@seurat29.1015granger.net>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Comment was made obsolete by commit 8cec3dba76a4 ("xprtrdma:
rpcrdma_regbuf alignment").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 92ce09fcea74..3b2f2041e889 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -117,9 +117,6 @@ struct rpcrdma_ep {
 #endif
 
 /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV
- *
- * The below structure appears at the front of a large region of kmalloc'd
- * memory, which always starts on a good alignment boundary.
  */
 
 struct rpcrdma_regbuf {

