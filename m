Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E84C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44295217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jgOBexe7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728095AbeLSP6x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:53 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:55781 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP6x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:53 -0500
Received: by mail-it1-f195.google.com with SMTP id m62so10358060ith.5;
        Wed, 19 Dec 2018 07:58:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fZt2sJtHBzkz3cxTvQxkd76ytJ2+vEepYSr4HQtV1IE=;
        b=jgOBexe7mgLWcIJt/O0aNgFAMbn+tCtUCDjCKsDhi8qhkEIZDZ/dt8bJWgdCR+xaVT
         R3BRsTC2my6LGbbXY25qRKSOe4J68vGNVgL35hz2h2L/O82k9z/IOFPTQNJIN/q/UtN2
         2utElo/+70ZLX84uW8lapHQuuB8z/7+A4oZJmGMyfJmYtji1zAvE1U4CB0bpBtUNmT1g
         HUhgJxMWykYKRIuzIIolWulA6bqoi862h/r6u7S5K2/lvYXOfba0Dpxp8caKokp/Q8vg
         9AqJStcSbmBHR1AHGrY21f9T40QXhIlGuSBjpf0oc4cLdulMeDMcDQf9IBNCh4bDoWsQ
         wdiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fZt2sJtHBzkz3cxTvQxkd76ytJ2+vEepYSr4HQtV1IE=;
        b=hrzUPOTyI/v1oTX+TcP/ae9NDTHF/hqWuDlvr8ATYGU/L+RDQtZdEbrcPRcjH3Ycvs
         bFF4nYUhXx0u/P1Ywqn/gq744xy9aCA+Kt61El0AcFg/wLxrjKZIwWlMfWCv9s0P+VBP
         ECtNLz+A76s4/JCzmWQSiGyv7Ec37mlwsSeq91Y4e2Chfh5fI77K5lhozyG5Or8rDOyT
         olbqmnheHaUq1SL4HIzf76cbTeAmiMb520ErygEczQ2wy/2lwJ2w0Ctz3nAstu2IrOq+
         ljd+cEP4q6k0HMuGYw+ZanZkS9Ky9Qy4q0UQ9GQiC2cyUiDvaGNOPZkwkR3HRDNTXYW3
         X+Ug==
X-Gm-Message-State: AA+aEWaTXLbewrszxlpNCWr63hvcctJEUUE6cJn8036EOVzXYBC10L1a
        VjDJ/NTfUIu4JzKMcrbqaoQ=
X-Google-Smtp-Source: AFSGD/Wpe7rgYzKA8XOTXJOB+okFKn2B23jxnBSYJxC0ousTWw7oHYok9ZxBhmRGM/tI+1uHfBPZ5g==
X-Received: by 2002:a02:9b26:: with SMTP id o35mr20264818jak.23.1545235132715;
        Wed, 19 Dec 2018 07:58:52 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id a16sm8486442ioh.48.2018.12.19.07.58.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:52 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwpDj025780;
        Wed, 19 Dec 2018 15:58:51 GMT
Subject: [PATCH v5 08/30] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:51 -0500
Message-ID: <20181219155851.11602.24862.stgit@manet.1015granger.net>
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

Some devices advertise a large max_fast_reg_page_list_len
capability, but perform optimally when MRs are significantly smaller
than that depth -- probably when the MR itself is no larger than a
page.

By default, the RDMA R/W core API uses max_sge_rd as the maximum
page depth for MRs. For some devices, the value of max_sge_rd is
1, which is also not optimal. Thus, when max_sge_rd is larger than
1, use that value. Otherwise use the value of the
max_fast_reg_page_list_len attribute.

I've tested this with CX-3 Pro, FastLinq, and CX-5 devices. It
reproducibly improves the throughput of large I/Os by several
percent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f587e44..16976b0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -193,10 +193,17 @@
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

