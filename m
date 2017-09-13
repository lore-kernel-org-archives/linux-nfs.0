Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60718 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751661AbdIMK1E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:04 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 01/14] mount: don't use IPPROTO_UDP for address resolution
Date: Wed, 13 Sep 2017 11:26:37 +0100
Message-Id: <20170913102650.10377-2-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
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
index 1d30d34..033f254 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -919,9 +919,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	if (mi->address == NULL) {
-		struct addrinfo hint = {
-			.ai_protocol	= (int)IPPROTO_UDP,
-		};
+		struct addrinfo hint = {};
 		int error;
 		struct addrinfo *address;
 
-- 
2.13.5

