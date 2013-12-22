Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f175.google.com ([209.85.215.175]:35925 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab3LVXBa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Dec 2013 18:01:30 -0500
From: Alexander Aring <alex.aring@gmail.com>
To: hannes@stressinduktion.org
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, stable@vger.kernel.org,
        werner@almesberger.net, Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2] nfs: fix dead code of ipv6_addr_scope
Date: Mon, 23 Dec 2013 00:01:16 +0100
Message-Id: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch corrects the check on a linklocal address.

Currently this can't be work, because ipv6_addr_scope returns a int with
a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
is 0x02. So the condition is always false.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
- change check on linklocal address from
  (ipv6_addr_src_scope(&a6->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL) to
  (ipv6_addr_scope(&a6->sin6_addr) & IPV6_ADDR_LINKLOCAL) which is a
  little bit faster.
- change commit msg.

 fs/nfs/nfs4filelayoutdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c7c295e5..dc5e9e1 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -95,8 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 		b6 = (struct sockaddr_in6 *)addr2;
 
 		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_scope(&a6->sin6_addr) ==
-		    IPV6_ADDR_SCOPE_LINKLOCAL &&
+		if (ipv6_addr_scope(&a6->sin6_addr) & IPV6_ADDR_LINKLOCAL &&
 		    a6->sin6_scope_id != b6->sin6_scope_id)
 			return false;
 
-- 
1.8.5.2

