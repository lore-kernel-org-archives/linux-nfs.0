Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:48712 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaLPIit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:38:49 -0500
From: Natanael Copa <ncopa@alpinelinux.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 5/9] Fix compile error: 'IPPORT_RESERVED' undeclared
Date: Tue, 16 Dec 2014 09:28:56 +0100
Message-Id: <1418718540-13667-6-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The IPPORT_RESERVED is declared in netdb.h. This fixes the following
compile error with musl libc:

bindresvport.c: In function 'bindresvport_sa':
bindresvport.c:67:18: error: 'IPPORT_RESERVED' undeclared (first use in
this function)
 #define ENDPORT (IPPORT_RESERVED - 1)
                   ^
Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 src/bindresvport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/bindresvport.c b/src/bindresvport.c
index 950fbd1..2d8f2bc 100644
--- a/src/bindresvport.c
+++ b/src/bindresvport.c
@@ -36,6 +36,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 
+#include <netdb.h>
 #include <netinet/in.h>
 
 #include <errno.h>
-- 
2.2.0

