Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751549AbcJGKFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:05:01 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CC718A0CC1
        for <linux-nfs@vger.kernel.org>; Fri,  7 Oct 2016 10:04:05 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 3/4] mount: accept AF_VSOCK in nfs_verify_family()
Date: Fri,  7 Oct 2016 11:01:42 +0100
Message-Id: <1475834503-3984-4-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since AF_VSOCK is now a supported address family it needs to be accepted
by nfs_verify_family().

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index dcc38ca..e4c6e1d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1417,7 +1417,7 @@ sa_family_t	config_default_family = AF_INET;
 static int
 nfs_verify_family(sa_family_t family)
 {
-	if (family != AF_INET)
+	if (family != AF_INET && family != AF_VSOCK)
 		return 0;
 
 	return 1;
-- 
2.7.4

