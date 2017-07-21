Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754531AbdGUQiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:08 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 907F64E33A
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:08 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4671817DC0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:08 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/11] present_address: Fixed error path
Date: Fri, 21 Jul 2017 12:37:57 -0400
Message-Id: <20170721163806.15803-3-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When inet_ntop fails do not fall into the AF_INET6
case, instead break out and take the error path out.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/misc/tcpwrapper.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 06b0a46..3128053 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -72,6 +72,7 @@ present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
 	case AF_INET:
 		if (inet_ntop(AF_INET, &sin->sin_addr, buf, len) != 0)
 			return;
+		break;
 	case AF_INET6:
 		if (inet_ntop(AF_INET6, &sin6->sin6_addr, buf, len) != 0)
 			return;
-- 
2.13.3

