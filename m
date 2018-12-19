Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC98AC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C51D217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PyPzNW84"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728450AbeLSP6V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:21 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:50526 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728091AbeLSP6V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:21 -0500
Received: by mail-it1-f193.google.com with SMTP id z7so10396467iti.0;
        Wed, 19 Dec 2018 07:58:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=nqihSE1hg4o1H0UcWmtuHnYhVxMpkCBQQUarfYAvFW0=;
        b=PyPzNW84fHCg4eFenASrdsWa/ztAQpVoKkeVezvrB3eIW2m6VRpqOuMPh5it64m4cR
         VKl7H5hTt0ksfCjzIGAL8+KvZx1nrvSuYFk+hv/yL6EcCYM18BDEFG1Ff8WJK226ccyy
         wQysBb3Hcx+fQxTh4JE7tTqt+Ry1UIgps1l4eloRYdOHipDHca67W6HLNnlcFzg1/X8b
         hq8wzd3wama0nFf+ZWTUNxAwuNN4JZ2MF8LO/ITfeEsZ9RBmn6ITCbe3Dq86NalD/+aG
         lcNGaT0pAW9MTZNYs3pt5m9iwNvszGjQLbwxjxUZUO2pvUOIlH+Bkv2So3kUb6VskmS9
         FcDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=nqihSE1hg4o1H0UcWmtuHnYhVxMpkCBQQUarfYAvFW0=;
        b=kEwOipva5Quz1KPeGsy9fRhs6Um6FxCSrRqzS27+jmsETunFuO9KD/0Q/mQ4HvBNjL
         OI9sDTt41+UOHm4mioKMRtb47V3wu0hei7jeLz/rynetlvi2Eb/pTfgxZirop6MhPuP+
         BsZHRUz7oHp/1i5pDtS/3NCjuWkZnD6sE7+ofZHW1/lIUOFVgd/lK8YQEIhoJtiSAYss
         4Dfe6C5YdrIl5hSnuzwwunVnqrxCM6lRXL79hLHQ3Gw7SjJbNnOOaMjvQ8TlRZDwkmGV
         w2aqaB7eXLiUGVmNlh3l2rJ/XAN+NgZB8U1Bd9mBjtWK6nKHemtJpVUP4fOFycPR5P8F
         CtaA==
X-Gm-Message-State: AA+aEWYnoGVcqtjA5jEtMARYEuKi/+9W3CoEcwL3cDvqGfqJyOPrC+DZ
        KnuEkozUd2AGXl+DnWwf0tXji5JK
X-Google-Smtp-Source: AFSGD/XeqgE6ZRgOiMlg0HuqO8XQ08EJYs0SbzFBxw+W6kDvRMDSCqKQZb1e7PH/VZCtXLq16BhxCw==
X-Received: by 2002:a02:6:: with SMTP id 6mr19237213jaa.19.1545235100803;
        Wed, 19 Dec 2018 07:58:20 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b91sm3733984itd.26.2018.12.19.07.58.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:20 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwJKx025762;
        Wed, 19 Dec 2018 15:58:19 GMT
Subject: [PATCH v5 02/30] xprtrdma: Ensure MRs are DMA-unmapped when posting
 LOCAL_INV fails
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:19 -0500
Message-ID: <20181219155819.11602.799.stgit@manet.1015granger.net>
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

The recovery case in frwr_op_unmap_sync needs to DMA unmap each MR.
frwr_release_mr does not DMA-unmap, but the recycle worker does.

Fixes: 61da886bf74e ("xprtrdma: Explicitly resetting MRs is ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 20ced24..27222c0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -563,8 +563,8 @@
 		mr = container_of(frwr, struct rpcrdma_mr, frwr);
 		bad_wr = bad_wr->next;
 
-		list_del(&mr->mr_list);
-		frwr_op_release_mr(mr);
+		list_del_init(&mr->mr_list);
+		rpcrdma_mr_recycle(mr);
 	}
 }
 

