Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932704AbcGHVfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2016 17:35:09 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 254E380E4A
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jul 2016 21:35:09 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-38.rdu2.redhat.com [10.10.116.38])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u68LZ6E2004230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 8 Jul 2016 17:35:08 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] sunrpc: Prevent resvport min/max inversion via sysfs and module parameter
Date: Fri,  8 Jul 2016 16:35:25 -0500
Message-Id: <1468013725-22835-4-git-send-email-sorenson@redhat.com>
In-Reply-To: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
References: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current min/max resvport settings are independently limited
by the entire range of allowed ports, so max_resvport can be
set to a port lower than min_resvport.

Prevent inversion of min/max values when set through sysfs and
module parameter by setting the limits dependent on each other.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/xprtsock.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2674309..83e6f33 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3153,8 +3153,12 @@ static int param_set_uint_minmax(const char *val,
 
 static int param_set_portnr(const char *val, const struct kernel_param *kp)
 {
-	return param_set_uint_minmax(val, kp,
+	if (kp->arg == &xprt_min_resvport)
+		return param_set_uint_minmax(val, kp,
 			RPC_MIN_RESVPORT,
+			xprt_max_resvport);
+	return param_set_uint_minmax(val, kp,
+			xprt_min_resvport,
 			RPC_MAX_RESVPORT);
 }
 
-- 
2.5.5

