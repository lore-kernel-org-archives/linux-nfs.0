Return-Path: <SRS0=PSJf=US=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 569DAC43613
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Jun 2019 21:11:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 32BE3215EA
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Jun 2019 21:11:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726230AbfFSVLK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Jun 2019 17:11:10 -0400
Received: from fieldses.org ([173.255.197.46]:42524 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726175AbfFSVLK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jun 2019 17:11:10 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3B9C11E19; Wed, 19 Jun 2019 17:11:10 -0400 (EDT)
Date:   Wed, 19 Jun 2019 17:11:10 -0400
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix out-of-date connectathon talk URL
Message-ID: <20190619211110.GD3044@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Reported-by: David Wysochanski <dwysocha@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 869ce7737997..de3c077733a7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -35,7 +35,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt);
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
  * 6 minutes
- *   http://www.connectathon.org/talks96/nfstcp.pdf
+ *   http://nfsv4bat.org/Documents/ConnectAThon/1996/nfstcp.pdf
  */
 static int svc_conn_age_period = 6*60;
 
-- 
2.21.0

