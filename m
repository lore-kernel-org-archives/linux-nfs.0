Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752955AbdGSUx5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:53:57 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 26D34FED4
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D366517C14
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:56 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/11] rpcdebug.c: remove a warning
Date: Wed, 19 Jul 2017 16:53:44 -0400
Message-Id: <20170719205354.10006-2-steved@redhat.com>
In-Reply-To: <20170719205354.10006-1-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcdebug.c:77:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/rpcdebug/rpcdebug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index 18b1622..68206cc 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -74,7 +74,8 @@ main(int argc, char **argv)
 			opt_c = 1;
 			break;
 		case 'h':
-			usage(0, module);
+			usage(0, module); /* usage does not return */
+			break;
 		case 'm':
 			module = optarg;
 			break;
-- 
2.13.3

