Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F08E6C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 21:04:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AF2372082A
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 21:04:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iX+ivjo5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726486AbfDIVEN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 17:04:13 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:37187 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726479AbfDIVEN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 17:04:13 -0400
Received: by mail-it1-f193.google.com with SMTP id u65so7410298itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 14:04:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=YXvxM6xgwgRrrpFaxo/b/vChiVYlfHibWLfCpLD0rsc=;
        b=iX+ivjo5YarGq/cLpbmOM1P/nBv0arGo8ErgtyLLo/10U5D4Fq2f/K4GfUWJcPavLN
         KBYEOPIEv4z14xyLICDNYue/k7Ixb2MuUppGBRwRLVkGwP6MoSvWHtB5S2HkEw/25zkM
         hVusfvXwrMkvSoDuA+cHCB3LR5rUdJIn6ItTblgvP7lwHB6027lWXnRVPvTNxFzOLNLk
         fJCjlDsVhE7958zyb8lriuv0hIa9f41w+2eMv6SJqP4ngLL1fMXFaji+KwNFSu8Sbk1D
         0hYltzAWKxnlsIHKo8iBkE4zSXZEURe5fEbm81SgcHZqTCcfLEK8IX+JHN+vcMvN4oqN
         LexQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=YXvxM6xgwgRrrpFaxo/b/vChiVYlfHibWLfCpLD0rsc=;
        b=UbRynO++zYA+R9LylHhCx+xY/rS0sqDTkbHfyr/4z/y7FEAcl2RxXK1+onJlnWdeW0
         l98fc8dm3SRjHAvCEpK8u+bv9qvuRi/PruuNqYsuB09lstoDM8ImxDEQju2gPgFS224j
         eIVE+5qeX6QNzoIArHQARbVGvMy0gl8QcsCJlyg91oL4tI0C4gzF4yIInaoi8Yi5hOoY
         1K+LdmMuQdhcbukZHYcle4qWPfgxfrqEWOcM9YlIzSYyHOJ7S3zqAgzqzp+ltw63pZYw
         TZkNfrngIQHzfb1JwXpK0x/DNROYTKMHdeTgwyHma1G7sMyS/maSGpEy3u+qTknz50Ki
         kwHw==
X-Gm-Message-State: APjAAAVZwi84n0rjWR4XH5w0BjuViRX0yQbgx2v6I0iJzqksBMrgGabc
        x9JMxH7jibwYk338xkzxnNx7LFFT
X-Google-Smtp-Source: APXvYqxEiHFhIf27gSaZRZfXoaiz/0FIBkhnMyLZtDJQ4LESu0W9PmKvmPXtIBRM4TBRdCgUQbWuRw==
X-Received: by 2002:a24:3c51:: with SMTP id m78mr320252ita.119.1554843852194;
        Tue, 09 Apr 2019 14:04:12 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id d133sm155070ita.5.2019.04.09.14.04.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 14:04:11 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x39L49TV001662;
        Tue, 9 Apr 2019 21:04:09 GMT
Subject: [PATCH] xprtrdma: Fix helper that drains the transport
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com, trondmy@hammerspace.com
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 09 Apr 2019 17:04:09 -0400
Message-ID: <20190409210349.12565.59298.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We want to drain only the RQ first. Otherwise the transport can
deadlock on ->close if there are outstanding Send completions.

Fixes: 6d2d0ee27c7a ("xprtrdma: Replace rpcrdma_receive_wq ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # v5.0+
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Hi-

Here's another one for v5.1-rc and stable.

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 89a6339..30cfc0e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -90,7 +90,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	/* Flush Receives, then wait for deferred Reply work
 	 * to complete.
 	 */
-	ib_drain_qp(ia->ri_id->qp);
+	ib_drain_rq(ia->ri_id->qp);
 	drain_workqueue(buf->rb_completion_wq);
 
 	/* Deferred Reply processing might have scheduled

