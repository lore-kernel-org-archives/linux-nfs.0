Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932480AbcGHVfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2016 17:35:09 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A28C064472
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jul 2016 21:35:08 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-38.rdu2.redhat.com [10.10.116.38])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u68LZ6E1004230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 8 Jul 2016 17:35:08 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] sunrpc: Prevent resvport min/max inversion via sysctl
Date: Fri,  8 Jul 2016 16:35:24 -0500
Message-Id: <1468013725-22835-3-git-send-email-sorenson@redhat.com>
In-Reply-To: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
References: <1468013725-22835-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current min/max resvport settings are independently limited
by the entire range of allowed ports, so max_resvport can be
set to a port lower than min_resvport.

Prevent inversion of min/max values when set through sysctl by
setting the limits dependent on each other.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1adda71..2674309 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -124,7 +124,7 @@ static struct ctl_table xs_tunables_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &xprt_min_resvport_limit,
-		.extra2		= &xprt_max_resvport_limit
+		.extra2		= &xprt_max_resvport
 	},
 	{
 		.procname	= "max_resvport",
@@ -132,7 +132,7 @@ static struct ctl_table xs_tunables_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &xprt_min_resvport_limit,
+		.extra1		= &xprt_min_resvport,
 		.extra2		= &xprt_max_resvport_limit
 	},
 	{
-- 
2.5.5

