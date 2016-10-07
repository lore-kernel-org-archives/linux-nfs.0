Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752292AbcJGKDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:03:01 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1ECC27EAA2
        for <linux-nfs@vger.kernel.org>; Fri,  7 Oct 2016 10:03:00 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 1/4] mount: don't use IPPROTO_UDP for address resolution
Date: Fri,  7 Oct 2016 11:01:40 +0100
Message-Id: <1475834503-3984-2-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although getaddrinfo(3) with IPPROTO_UDP works fine for AF_INET and
AF_INET6, the AF_VSOCK address family does not support IPPROTO_UDP and
produces an error.

Drop IPPROTO_UDP and use the 0 default (TCP) which works for all address
families.  Modern NFS uses TCP anyway so it's strange to specify UDP.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/stropts.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d5dfb5e..ab2d37b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -885,9 +885,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	int result = 0;
 
 	if (mi->address == NULL) {
-		struct addrinfo hint = {
-			.ai_protocol	= (int)IPPROTO_UDP,
-		};
+		struct addrinfo hint = {};
 		int error;
 		struct addrinfo *address;
 
-- 
2.7.4

