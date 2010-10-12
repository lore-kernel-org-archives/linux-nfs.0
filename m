Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab0JLB3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 21:29:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: fix default value for --enable-tirpc
Date: Mon, 11 Oct 2010 21:29:51 -0400
Message-Id: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The patch I originally proposed to make --enable-tirpc the default had
the default for $enable_tirpc as a blank string. When it was merged
however, that value was changed to a 'yes'. This broke the ability for
autoconf to detect and autodisable building with tirpc. When tirpc isn't
present now, the configure step fails unless someone explicitly
specifies --disable-libtirpc.

We need $enable_tirpc to be a tristate. 'yes' means that someone
explicitly requested building with tirpc. 'no' means that it was
explicitly disabled. Anything else means that no one specified a value.

Fix it by setting the value to a blank string so that the default is
properly undefined.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3058be6..5408e85 100644
--- a/configure.ac
+++ b/configure.ac
@@ -136,7 +136,7 @@ AC_ARG_ENABLE(tirpc,
 	[AC_HELP_STRING([--enable-tirpc],
 			[enable use of TI-RPC @<:@default=yes@:>@])],
 	enable_tirpc=$enableval,
-	enable_tirpc='yes')
+	enable_tirpc='')
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--enable-ipv6],
                         [enable support for IPv6 @<:@default=no@:>@])],
-- 
1.7.1

