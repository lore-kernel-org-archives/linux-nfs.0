Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1890DC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DBF3121773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WHtcll+I"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730484AbfDXNko (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:44 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:33388 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727755AbfDXNko (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:44 -0400
Received: by mail-io1-f66.google.com with SMTP id u12so5270550iop.0;
        Wed, 24 Apr 2019 06:40:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/wd0eRcXetS/kbSQtf2qtr0ehl30Kq76/qdpsU9VXMI=;
        b=WHtcll+IeUhYEMcdLxG6GM31ahzwfc0Z2GkxIMVlTVf3QGwb7sv4GW82DNRWHjuHwN
         xZ935QNVbiMcJhrHOyI0zIQzy4VlR4o6o3jyWYNlX9S7TFRFiwbdUCzrcJ5cRmfhxw7n
         fAB6v+BStUHwI0XBI0n/uQ13w5GJ+Ay9ln3U9Gw+RJu3Pn4nDWcbsBte+8jpJ/YKedx0
         Xyi8+Cyl1hQoK9kSj5hBk9iXKPbTluzyiPFpfUwgtSYoGa2OLuA1fsn1qD4f9zJbtbyp
         TN783oo0HdMvnPCt2YGEEFYih3FIjQ9AIl+KpXW75UBWH/0w0Qd+itf9VUVjaL73foPo
         Zsgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/wd0eRcXetS/kbSQtf2qtr0ehl30Kq76/qdpsU9VXMI=;
        b=tvoU5VIqUXaCS7rzwQ6BMhpzoUvfnjCKSwaEYxyaKMHn/oKbE7upnITLqYeT45mr8C
         Qtmd0sx09KKzPgjh5R4sY5g1mWfW+k5aIgpZbQ2N0WCHwCrmm+Deeo3YkMk3JfYfKkNV
         FDINJj6MiMV4Af+1VPQrhmVCeFiGmk1HyDyvztmLUM0qiAIEyDs2NE5uzHtMUqpIjKAW
         PWI+FhjCX7rYkAO92j7Y6MKzbg2Ltp2lA+ljAMOjRYAMBIY5m3+WgkW4Mf0zDXekTPJU
         LIJ1CRhUB6PnvywdV0PQmQcltnwPh7z2DKmSxOk6p337yrbnm02e2DGWQsepHbUPdyNl
         69fQ==
X-Gm-Message-State: APjAAAVdy+hljcJBeFR6pnfDWG/ccxwg1BO5Km0UGnNxXnmcSefUL3Al
        PmRk+rCYRTocpNBdx+3cfD0=
X-Google-Smtp-Source: APXvYqwaLSm3zvFUrE7BctuwvikheNeevcqJaxwIZv6bURtBqvah6psy7c7uSwzWmwSxL6nP+cZxZg==
X-Received: by 2002:a6b:e502:: with SMTP id y2mr9454078ioc.73.1556113243226;
        Wed, 24 Apr 2019 06:40:43 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b1sm8783790itd.12.2019.04.24.06.40.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:42 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODefBd011340;
        Wed, 24 Apr 2019 13:40:41 GMT
Subject: [PATCH v3 21/21] xprtrdma: Remove stale comment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:41 -0400
Message-ID: <20190424134041.5077.18063.stgit@manet.1015granger.net>
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

The comment hasn't been accurate for several years.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9e98ee0..d1e0749 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -239,13 +239,6 @@ struct rpcrdma_sendctx {
  *
  * An external memory region is any buffer or page that is registered
  * on the fly (ie, not pre-registered).
- *
- * Each rpcrdma_buffer has a list of free MWs anchored in rb_mrs. During
- * call_allocate, rpcrdma_buffer_get() assigns one to each segment in
- * an rpcrdma_req. Then rpcrdma_register_external() grabs these to keep
- * track of registration metadata while each RPC is pending.
- * rpcrdma_deregister_external() uses this metadata to unmap and
- * release these resources when an RPC is complete.
  */
 enum rpcrdma_frwr_state {
 	FRWR_IS_INVALID,	/* ready to be used */

