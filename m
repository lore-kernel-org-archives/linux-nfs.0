Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:16 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 05/14] mount: accept AF_VSOCK in nfs_verify_family()
Date: Wed, 13 Sep 2017 11:26:41 +0100
Message-Id: <20170913102650.10377-6-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 0fa9029..7b0bc97 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1430,7 +1430,7 @@ sa_family_t	config_default_family = AF_INET;
 static int
 nfs_verify_family(sa_family_t family)
 {
-	if (family != AF_INET)
+	if (family != AF_INET && family != AF_VSOCK)
 		return 0;
 
 	return 1;
-- 
2.13.5

