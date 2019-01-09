Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A144C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 15:05:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55236206BB
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 15:05:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NiHikj42"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732167AbfAIPFA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 10:05:00 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37793 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731771AbfAIPFA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2019 10:05:00 -0500
Received: by mail-it1-f195.google.com with SMTP id b5so11400380iti.2
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jan 2019 07:04:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=GaUsYg56BehAbXSsMdBarTAHnYPoZK8wCsww5fiZ0y8=;
        b=NiHikj42CrG7YezPeqnJaWAJ9NNyqKxjW/r1iRB5qys5lZJwoi+cSpdmmvn61bMKe6
         RPL55QpwQS0KGoytWc+J9Is4oMDJfrMStNcRA5+nj/P0sh64YRjjTTzXLDl0d5LBYknN
         h0KwIQe1DZTGDvJPpBFh8Y4zhXDybg1w3D2rsSP1S64oIhaLw1Ygwo8lgl4w2vOwRY1G
         znYP4CaAa4x8ENeEHZE1wJC8B+MwfRywHmDJiX3XAWOeJ5gRUWAQh7OHTYFbhvlMdGKz
         Vl/OEkby9x4ExcoCGiWOIi2sNYQNpBmX2L+ZkU9bTjARaZbqMaTHz3g0DRuKTtWslprS
         KvPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=GaUsYg56BehAbXSsMdBarTAHnYPoZK8wCsww5fiZ0y8=;
        b=SCIYOZOxZ1ctRYEU9z5jAOeLY/LFHWCq6UfVcwrdByhKEJn/wg1Y6hotbFoTDEOSVU
         d0Bq4Sgbqbt6pC3tUTX64PiPt/Wk1h0QS2inLanEF0gGkxYm6xok8ksrw48fAN6xB2xN
         wmgmEDv87M5U45SmdSU1zsC5ENOpGRS3/tOJd1WpkuCfTAyLO6cUtY6sCw+tWPv8c73v
         ySwM6rCHehHZj11ubbh7V8FTz6tZxbaW0Pf7O3gjgp1ngBsXKq5teCIhaMdRz5rWJBUy
         AVAxyBfl6v4Vp21QEnBE34gRqPjSkxruZq4ldTNwECJI/JCq3kih0HIp6fE/wnKEht0B
         kQDg==
X-Gm-Message-State: AJcUukef4yDi5S6hZ0PtljmE7BG00ZY29vH2JkgAwgyM52nSaRokzcFD
        /rqBoGfsllwdazTsxJ1BjJq3iboV
X-Google-Smtp-Source: ALg8bN4RQzEMeejtoqNkLHBq77vWKuZ9N/FliXoyG/1JwKg5fYYbfcJRCr7722Q+9fKdPUPZwLRDag==
X-Received: by 2002:a24:cfc4:: with SMTP id y187mr4298141itf.144.1547046299206;
        Wed, 09 Jan 2019 07:04:59 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id h14sm31963034ior.41.2019.01.09.07.04.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 07:04:58 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x09F4vRt007383
        for <linux-nfs@vger.kernel.org>; Wed, 9 Jan 2019 15:04:57 GMT
Subject: [PATCH RFC] SUNRPC: Address Kerberos performance/behavior regression
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 09 Jan 2019 10:04:57 -0500
Message-ID: <20190109150457.7420.30644.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When using Kerberos with v4.20, I've observed frequent connection
loss on heavy workloads. I traced it down to the client underrunning
the GSS sequence number window -- NFS servers are required to drop
the RPC with the low sequence number, and also drop the connection
to signal that an RPC was dropped.

Bisected to commit 918f3c1fe83c ("SUNRPC: Improve latency for
interactive tasks").

I've got a one-line workaround for this issue, which is easy to
backport to v4.20 while a more permanent solution is being derived.
Essentially, tk_owner-based sorting is disabled for RPCs that carry
a GSS sequence number.

Fixes: 918f3c1fe83c ("SUNRPC: Improve latency for interactive ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 73547d1..943f08b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1177,7 +1177,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 				INIT_LIST_HEAD(&req->rq_xmit2);
 				goto out;
 			}
-		} else {
+		} else if (!req->rq_seqno) {
 			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
 				if (pos->rq_task->tk_owner != task->tk_owner)
 					continue;

