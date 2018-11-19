Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 179F7C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:46:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFC2E20851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:45:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tUbFpQ2N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFC2E20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729886AbeKTCJ5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 21:09:57 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:37481 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729795AbeKTCJ4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 21:09:56 -0500
Received: by mail-io1-f67.google.com with SMTP id a3so15860709ioc.4;
        Mon, 19 Nov 2018 07:45:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=DSaksjaPkkb7porQgZ1b/gss5qlB0j25PIJ9WHuWVjg=;
        b=tUbFpQ2NSrpx1kACmmHMrRuhaASLHsd/jEMsCpcWt8hxUZSkqPjxz1TGQh+eiK4JFp
         vAm3aEfoLzinb1A6Fgt/L8oF6gwf7z4jK+abFJpOshZN1VWBXqYvTYn/agCQ8G92JHDE
         8fb5ER64H9R79Fa7+cHr9r3LsOHeAnVzPOsZ02FIZO4apIyqeAodf6j3w8E0vy7WUWgA
         l+9hxL/owfZrYbMcj8a/8bEC+h3wsQCbAv+V3SnSe4aLcDdDoKM3tFQP4+tsKN+SM5KV
         NtnsX+7w2EdT3vMXY13JjPk6A6F9okv58QBLXto2j53QtNVFpo5neZPnNzAoc8m6uA68
         dPyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=DSaksjaPkkb7porQgZ1b/gss5qlB0j25PIJ9WHuWVjg=;
        b=TWSTMfspdZzAZ5Ep7J0urjBa3B5DF5r1CdglqJw9JDXRPF8VW8s3qXX0fkAKmagWP2
         NBbUwy2pqSbAmPJUJg3xm9I9jA+7SwyjJj37wju2RdU/lb+egzB/dJ19hi1v675g2eb+
         72KdKUpXwEjjHjHoO3lVyFSuL7tYcmZ0H4ocnUcQGtHJRp26QEYN0TpSg6bg3lEJPlDW
         LCKH/BRbLtqxWJyPug8Oq1dXoBuCw3WeJrl/tX2yZKQhP8kuS1Gpwn/48wp1f0juiUZX
         ntdQfePoh/2dz5BZnXBI1pAXmonLtqyvkja9YXxbYXJcnHEf6i0iNhXrBylvoGq/j8vE
         5L6Q==
X-Gm-Message-State: AA+aEWZrRoRHjL9gojcEcULezjkgDA9UDLVAr8K4Ugf4tifBS0W+gMgl
        So78x9AWYIPsFcRL1fSe9AW84+mZ
X-Google-Smtp-Source: AFSGD/Vsm2ZWda4qP18LgfT+hbZ0kDfZNRm62CUixRlJyFLzsQY4xME7teSA62Rwh5ErTwDySBYGJw==
X-Received: by 2002:a6b:c806:: with SMTP id y6mr17520407iof.79.1542642358046;
        Mon, 19 Nov 2018 07:45:58 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id p74sm7659669iod.14.2018.11.19.07.45.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:45:57 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAJFjucE023002;
        Mon, 19 Nov 2018 15:45:56 GMT
Subject: [PATCH v1 2/4] xprtrdma: mrs_create off-by-one
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Nov 2018 10:45:56 -0500
Message-ID: <20181119154556.10832.39180.stgit@manet.1015granger.net>
In-Reply-To: <20181119153707.10832.42881.stgit@manet.1015granger.net>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

With certain combinations of krb5i/p and MR size, one extra
segment is needed per RPC.

Fixes: c421ece68f6 ("xprtrdma: Create more MRs at a time")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fc6378cc..448e063 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -242,7 +242,7 @@
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				ia->ri_max_frwr_depth);
-	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
+	ia->ri_max_segs += 3;	/* segments for head and tail buffers */
 	return 0;
 }
 

