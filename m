Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2A79C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 88DC320821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hnZv5A2K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88DC320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728569AbeLJQac (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:32 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:34841 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726261AbeLJQaa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:30 -0500
Received: by mail-it1-f193.google.com with SMTP id p197so19122693itp.0;
        Mon, 10 Dec 2018 08:30:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=RT9fEOnCP8fxzowXgYqOJRgbr1fLDSnkcGiwkNSrjPw=;
        b=hnZv5A2KLhNBU06cQ6yQNVaTPKMqJt6Oho7LBti69YnW+3FtfS3PaqiMyI96qXK0w+
         j0V6+tQ//Jl7Cj+UHMWL2d6fgKlVM2ZXXbHZ264YPjhCVuKN3l77OPTZTU5xD/btX/LZ
         WmBqv75qCYdqwCRvgUIUeWjAohAI7DEWeFuD/5hpfSjNL+DfSSfmugTNncE/oogB+fAV
         TMTQUdI8md/7fcwXApSMjZ5iVubdfPqHCJZghTVK4bXy2Wt8NRCFQfqy8X/jILpJrnAW
         lxzautHcsTB5KHk0sh+JHgD7o/rWhSUtmU5LAsl10+5JPST8STd3204TF6EqRTTgnmHE
         r/jA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=RT9fEOnCP8fxzowXgYqOJRgbr1fLDSnkcGiwkNSrjPw=;
        b=q16CaArehAXl2ArLR/C6UB8b2lkfqj1lPAXY3IJhEWM+ad6zeyG0glN9SZYawvF2Cx
         bIcmnE/Iz4XNs/SHBgAb9bBFtRfqYiVB10guC/8PuLRNpxREPphPaQkGyCl4ht4t9S3I
         DGdfOZhqdJreXhqyQOzIYe2qrQ8EV3aiYa7+IkJ6DB9LxGrBUINyM/HD2qnxFkEie0z1
         MEhxVfsVFQoA7ZLtS/fkGE5+hsfdKxaSCbLiCcwgYkKNKaAMHRyAcFZiW9tId7K5Kcff
         RyN09F0t2ukjWc1rYQs0PRCyQmcgnxVQtIoNSloxIa9nEj0cF0I5rdWqKdykxFUUR7qC
         ifPg==
X-Gm-Message-State: AA+aEWY+sgHfQREILyhYPYEn3W0hdxb0BeAR0UhqooxtJh21Wsxk/Ke3
        G1eIxC5GpGsTvSfaBTbYmqA=
X-Google-Smtp-Source: AFSGD/Wu3auj10ZNEXP+TKRJDvi+1upkvDfgRrZdoJzOitj95o+6Y1iYX63YtGzQiKqfo8eMVt/lhA==
X-Received: by 2002:a02:2b2d:: with SMTP id h45mr12171093jaa.75.1544459429974;
        Mon, 10 Dec 2018 08:30:29 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id f10sm5893153itf.41.2018.12.10.08.30.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:29 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUSrJ031061;
        Mon, 10 Dec 2018 16:30:28 GMT
Subject: [PATCH v3 13/24] xprtrdma: Relocate the xprtrdma_mr_map trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:28 -0500
Message-ID: <20181210163028.4198.14435.stgit@manet.1015granger.net>
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

The mr_map trace points were capturing information about the previous
use of the MR rather than about the segment that was just mapped.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e758c0d..6d6cc80 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -394,7 +394,6 @@
 	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
-	trace_xprtrdma_mr_map(mr);
 
 	ibmr = frwr->fr_mr;
 	n = ib_map_mr_sg(ibmr, mr->mr_sg, mr->mr_nents, NULL, PAGE_SIZE);
@@ -416,6 +415,7 @@
 	mr->mr_handle = ibmr->rkey;
 	mr->mr_length = ibmr->length;
 	mr->mr_offset = ibmr->iova;
+	trace_xprtrdma_mr_map(mr);
 
 	*out = mr;
 	return seg;

