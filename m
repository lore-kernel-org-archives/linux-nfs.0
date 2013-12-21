Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:45963 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab3LUEjO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 23:39:14 -0500
From: Alexander Aring <alex.aring@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, werner@almesberger.net,
        Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH] nfs: fix dead code of ipv6_addr_scope
Date: Sat, 21 Dec 2013 05:39:04 +0100
Message-Id: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The correct way to check on IPV6_ADDR_SCOPE_LINKLOCAL is to check with
the ipv6_addr_src_scope function.

Currently this can't be work, because ipv6_addr_scope returns a int with
a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
is 0x02. So the condition is always false.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
I think ipv6_addr_src_scope should be correct, can somebody from netdev ml
confirm this please?
I stumple over that and I did not compile and test it. Maybe this is something
for stable?

 fs/nfs/nfs4filelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c7c295e5..efac602 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -95,7 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 		b6 = (struct sockaddr_in6 *)addr2;
 
 		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_scope(&a6->sin6_addr) ==
+		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
 		    IPV6_ADDR_SCOPE_LINKLOCAL &&
 		    a6->sin6_scope_id != b6->sin6_scope_id)
 			return false;
-- 
1.8.5.2

