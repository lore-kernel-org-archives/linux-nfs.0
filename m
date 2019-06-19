Return-Path: <SRS0=PSJf=US=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0677EC43613
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Jun 2019 21:06:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D990D20823
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Jun 2019 21:06:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726244AbfFSVGZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Jun 2019 17:06:25 -0400
Received: from fieldses.org ([173.255.197.46]:42516 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726175AbfFSVGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jun 2019 17:06:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 8E4681E19; Wed, 19 Jun 2019 17:06:24 -0400 (EDT)
Date:   Wed, 19 Jun 2019 17:06:24 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: [PATCH] Replace Jeff by Chuck as nfsd co-maintainer
Message-ID: <20190619210624.GC3044@fieldses.org>
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

Jeff's picking up more responsibilities elsewhere, and Chuck's agreed to
take over.

For now, as before, nothing's changing day-to-day, but I want to have a
co-maintainer if only for bus factor.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 429c6c624861..7bbc77ba85e7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8553,7 +8553,7 @@ S:	Odd Fixes
 
 KERNEL NFSD, SUNRPC, AND LOCKD SERVERS
 M:	"J. Bruce Fields" <bfields@fieldses.org>
-M:	Jeff Layton <jlayton@kernel.org>
+M:	Chuck Lever <chuck.lever@oracle.com>
 L:	linux-nfs@vger.kernel.org
 W:	http://nfs.sourceforge.net/
 T:	git git://linux-nfs.org/~bfields/linux.git
-- 
2.21.0

