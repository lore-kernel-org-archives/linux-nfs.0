Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19C56C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D392220821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gj+RZ8gG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D392220821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728226AbeLJQ3s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:48 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:33399 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727705AbeLJQ3s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:48 -0500
Received: by mail-it1-f193.google.com with SMTP id m8so8411349itk.0;
        Mon, 10 Dec 2018 08:29:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Im06Smg/oOSgSAOJJVFfR0OiJ6nn5vpSYwuHFHeZSUo=;
        b=Gj+RZ8gGacWzlwUw0CWIWtW0PazEGUvF4YVUMCgiZEbtnQZMe0jXqPK2F1Z8R0CIUE
         WQubF36QZpxXhSxvtPk3OygnMm7sAejLRLgdbifUO7DEv8ds3UZ2RjaU4pvkE9F1/6hu
         0EPEC+UdydGRLeSoLedyNXOZOfq4A7M/LPkvKUEjPNMoTqX985EaQtUkZBfD48Z+FPdM
         sdemkDOSlmMltdvLRxmhmlsqJvpDn6Ina4akexUSmQHGZ3E8JcosY0p1XcHRDbndsvbL
         UrOSd+iibYwSBdoT5+xg0/wqHqMmrHQSXB6yNX4GbiUXQpY7RBDZgChaCtIDqQWsKkwc
         JpQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Im06Smg/oOSgSAOJJVFfR0OiJ6nn5vpSYwuHFHeZSUo=;
        b=lnOPU4gvWWffDK5jX8y0HR74O/gOptobtlj5Bg1OuWLlWvdPcIvzWePDT899Gi2QnV
         pxiJ/G9P0AGxBDaQeLaLG0Sqy2QDa+ExMcYzmbDrG0+ath3p1IUE5VRAtvwDPpOF6q61
         cwMvA7cN7mWsX3/ReivstwcHY4Tsj81YZduIWsswmR0bimYuNQEoihlcNmMRSMdQMAqL
         u/nnFKu/ugHePlbVYV9vFVV1De85JbkYiXSng8SQ3PWmr/b2iOCCpMTr0Bl8YHDTxUp8
         fBaWHpWeZumI6KsYVKHBpxblb+UtK0RjXKsqpAfTGkdgEvLWZfug7dm1LXwLdY4HT4fI
         KwpA==
X-Gm-Message-State: AA+aEWbt35vFQZiRKwKiAdSfFQ1sN7QNceOWl+6nzKfcVTZ6vNck+lx5
        y4VoDeOuQV5+ZCn+WEp+UQU=
X-Google-Smtp-Source: AFSGD/UtfBGkd8tc0LjUPYBu9fcGBivarMelXitf3dK9TteUJtPo4E0JooWydOsQ5FUg0tY1UZe6Yg==
X-Received: by 2002:a02:1bc5:: with SMTP id 66mr12687032jas.105.1544459386899;
        Mon, 10 Dec 2018 08:29:46 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q76sm5249478iod.35.2018.12.10.08.29.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:46 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTjO7031026;
        Mon, 10 Dec 2018 16:29:45 GMT
Subject: [PATCH v3 05/24] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:45 -0500
Message-ID: <20181210162945.4198.24714.stgit@manet.1015granger.net>
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

Some devices advertise a large max_fast_reg_page_list_len
capability, but perform optimally when MRs are significantly smaller
than that depth -- probably when the MR itself is no larger than a
page.

By default, the RDMA R/W core API uses max_sge_rd as the maximum
page depth for MRs. For some devices, the value of max_sge_rd is
1, which is also not optimal. Thus, when max_sge_rd is larger than
1, use that value. Otherwise use the value of the
max_fast_reg_page_list_len attribute.

I've tested this with a couple of devices, and it reproducibly
improves the throughput of large I/Os by several percent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index ae94de9..72c6d32 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -191,10 +191,17 @@
 	if (attrs->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
 		ia->ri_mrtype = IB_MR_TYPE_SG_GAPS;
 
-	ia->ri_max_frwr_depth =
-			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-			      attrs->max_fast_reg_page_list_len);
-	dprintk("RPC:       %s: device's max FR page list len = %u\n",
+	/* Quirk: Some devices advertise a large max_fast_reg_page_list_len
+	 * capability, but perform optimally when the MRs are not larger
+	 * than a page.
+	 */
+	if (attrs->max_sge_rd > 1)
+		ia->ri_max_frwr_depth = attrs->max_sge_rd;
+	else
+		ia->ri_max_frwr_depth = attrs->max_fast_reg_page_list_len;
+	if (ia->ri_max_frwr_depth > RPCRDMA_MAX_DATA_SEGS)
+		ia->ri_max_frwr_depth = RPCRDMA_MAX_DATA_SEGS;
+	dprintk("RPC:       %s: max FR page list depth = %u\n",
 		__func__, ia->ri_max_frwr_depth);
 
 	/* Add room for frwr register and invalidate WRs.

