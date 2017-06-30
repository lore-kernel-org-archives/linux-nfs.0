Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NV1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:27 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 01/12] mount: don't use IPPROTO_UDP for address resolution
Date: Fri, 30 Jun 2017 14:21:09 +0100
Message-Id: <20170630132120.31578-2-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although getaddrinfo(3) with IPPROTO_UDP works fine for AF_INET and
AF_INET6, the AF_VSOCK address family does not support IPPROTO_UDP and
produces an error.

Drop IPPROTO_UDP and use the 0 default (TCP) which works for all address
families.  Modern NFS uses TCP anyway so it's strange to specify UDP.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/stropts.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c2a739b..99656dd 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -909,9 +909,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	if (mi->address == NULL) {
-		struct addrinfo hint = {
-			.ai_protocol	= (int)IPPROTO_UDP,
-		};
+		struct addrinfo hint = {};
 		int error;
 		struct addrinfo *address;
 
-- 
2.9.4

