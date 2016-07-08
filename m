Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756299AbcGHVfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2016 17:35:08 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 354EB495
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jul 2016 21:35:08 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-38.rdu2.redhat.com [10.10.116.38])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u68LZ6E0004230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 8 Jul 2016 17:35:07 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] sunrpc: Fix reserved port range calculation
Date: Fri,  8 Jul 2016 16:35:23 -0500
Message-Id: <1468013725-22835-2-git-send-email-sorenson@redhat.com>
In-Reply-To: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
References: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The range calculation for choosing the random reserved port will panic
with divide-by-zero when min_resvport == max_resvport, a range of one
port, not zero.

Fix the reserved port range calculation by adding one to the difference.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7e2b2fa..1adda71 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1714,7 +1714,7 @@ static void xs_udp_timer(struct rpc_xprt *xprt, struct rpc_task *task)
 
 static unsigned short xs_get_random_port(void)
 {
-	unsigned short range = xprt_max_resvport - xprt_min_resvport;
+	unsigned short range = xprt_max_resvport - xprt_min_resvport + 1;
 	unsigned short rand = (unsigned short) prandom_u32() % range;
 	return rand + xprt_min_resvport;
 }
-- 
2.5.5

