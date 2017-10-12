Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751988AbdJLPG5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 11:06:57 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id AAB42883B6
        for <linux-nfs@vger.kernel.org>; Thu, 12 Oct 2017 15:06:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 691BB6C412
        for <linux-nfs@vger.kernel.org>; Thu, 12 Oct 2017 15:06:57 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] sm-notify needs to call res_init() before each try
Date: Thu, 12 Oct 2017 11:06:56 -0400
Message-Id: <20171012150656.5722-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Orion Poplawski <orion@nwra.com>

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=625531

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/statd/sm-notify.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index d216ddb..d961dc0 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -28,6 +28,9 @@
 #include <netdb.h>
 #include <errno.h>
 #include <grp.h>
+#include <netinet/in.h>
+#include <arpa/nameser.h>
+#include <resolv.h>
 
 #include "conffile.h"
 #include "sockaddr.h"
@@ -90,6 +93,7 @@ smn_lookup(const char *name)
 	};
 	int error;
 
+	res_init();
 	error = getaddrinfo(name, NULL, &hint, &ai);
 	if (error != 0) {
 		xlog(D_GENERAL, "getaddrinfo(3): %s", gai_strerror(error));
-- 
2.13.6

