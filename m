Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:48709 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaLPIit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:38:49 -0500
From: Natanael Copa <ncopa@alpinelinux.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 6/9] Define struct rpcent on non GNU libc
Date: Tue, 16 Dec 2014 09:28:57 +0100
Message-Id: <1418718540-13667-7-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes the following compile error with musl libc:
getrpcent.c:65:16: error: field 'rpc' has incomplete type
  struct rpcent rpc;
                ^

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
This patch could probably be better. It assumes that only GNU libc has
the rpcent struct defined, but the BSDs probably has it too.

I am not sure if uClibc has it, but uClibc does define __GLIBC__ so it
might be broken there too.

I looked into using AC_CHECK_MEMBER but I don't think it is a good idea
so depend on config.h since this is a header that will be installed on
the system.

I also found out that struct rpcent is also defined in
/usr/include/gssrpc/netdb.h but I am unsure if we can depend on that
too since GSS is optional.

So I am a bit in doubt what the proper fix is. Meanwhile, this works
for musl libc.

 tirpc/rpc/rpcent.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tirpc/rpc/rpcent.h b/tirpc/rpc/rpcent.h
index 6619cd3..147f909 100644
--- a/tirpc/rpc/rpcent.h
+++ b/tirpc/rpc/rpcent.h
@@ -49,7 +49,7 @@ extern "C" {
 #endif
 
 /* These are defined in /usr/include/rpc/netdb.h */
-#if 0
+#if !defined(__GLIBC__)
 struct rpcent {
 	char	*r_name;	/* name of server for this rpc program */
 	char	**r_aliases;	/* alias list */
-- 
2.2.0

