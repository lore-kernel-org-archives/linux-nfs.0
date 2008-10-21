From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] rpcbind: Squelch a compiler warning
Date: Tue, 21 Oct 2008 18:04:41 -0400
Message-ID: <20081021220441.19488.97578.stgit@manray.1015granger.net>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38503 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbYJUWFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:05:07 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Include <nss.h> to get a forward declaration of __nss_configure_lookup(=
).
This eliminates the compiler warning:

rpcbind.c: In function =E2=80=98main=E2=80=99:
rpcbind.c:163: warning: implicit declaration of function
	=E2=80=98__nss_configure_lookup=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.in  |    2 +-
 src/rpcbind.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 9ff0bc7..69f4169 100644
--- a/configure.in
+++ b/configure.in
@@ -48,7 +48,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h netdb.h \
                   netinet/in.h stdlib.h string.h \
                   sys/param.h sys/socket.h \
                   sys/time.h syslog.h \
-                  unistd.h])                   =20
+                  unistd.h nss.h])
=20
 AC_CHECK_LIB([pthread], [pthread_create])
 AC_CHECK_LIB([tirpc], [clnt_create])
diff --git a/src/rpcbind.c b/src/rpcbind.c
index e0e7ddf..71b372d 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -68,6 +68,7 @@
 #include <pwd.h>
 #include <string.h>
 #include <errno.h>
+#include <nss.h>
 #include "config.h"
 #include "rpcbind.h"
=20

