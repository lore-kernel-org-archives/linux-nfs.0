Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NVg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:36 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 04/12] mount: accept AF_VSOCK in nfs_verify_family()
Date: Fri, 30 Jun 2017 14:21:12 +0100
Message-Id: <20170630132120.31578-5-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b5dcaa5..8f362de 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1419,7 +1419,7 @@ sa_family_t	config_default_family = AF_INET;
 static int
 nfs_verify_family(sa_family_t family)
 {
-	if (family != AF_INET)
+	if (family != AF_INET && family != AF_VSOCK)
 		return 0;
 
 	return 1;
-- 
2.9.4

