Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:48714 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaLPIit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:38:49 -0500
From: Natanael Copa <ncopa@alpinelinux.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 8/9] Fix location of various standard header includes
Date: Tue, 16 Dec 2014 09:28:59 +0100
Message-Id: <1418718540-13667-9-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

poll.h, signal.h, errno.h and fcntl.h are all defined in POSIX
and their location are not under sys/

This fixes various compile warning when building with musl libc like:

In file included from clnt_dg.c:40:0:
/usr/include/sys/poll.h:1:2: warning: #warning redirecting
incorrect #include <sys/poll.h> to <poll.h> [-Wcpp]

In file included from clnt_generic.c:32:0:
/usr/include/sys/fcntl.h:1:2: warning: #warning redirecting
incorrect #include <sys/fcntl.h> to <fcntl.h> [-Wcpp]

In file included from auth_time.c:34:0:
/usr/include/sys/signal.h:1:2: warning: #warning redirecting
incorrect #include <sys/signal.h> to <signal.h> [-Wcpp]

In file included from auth_time.c:35:0:
/usr/include/sys/errno.h:1:2: warning: #warning redirecting
incorrect #include <sys/errno.h> to <errno.h> [-Wcpp]

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 src/auth_time.c    | 4 ++--
 src/clnt_bcast.c   | 2 +-
 src/clnt_dg.c      | 2 +-
 src/clnt_generic.c | 2 +-
 src/clnt_vc.c      | 2 +-
 src/key_call.c     | 2 +-
 src/pmap_rmt.c     | 2 +-
 src/svc.c          | 2 +-
 src/svc_vc.c       | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/src/auth_time.c b/src/auth_time.c
index ace86bf..13717ff 100644
--- a/src/auth_time.c
+++ b/src/auth_time.c
@@ -31,8 +31,8 @@
 #include <stdlib.h>
 #include <unistd.h>
 #include <netdb.h>
-#include <sys/signal.h>
-#include <sys/errno.h>
+#include <signal.h>
+#include <errno.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
diff --git a/src/clnt_bcast.c b/src/clnt_bcast.c
index be05af4..3e79a4b 100644
--- a/src/clnt_bcast.c
+++ b/src/clnt_bcast.c
@@ -45,7 +45,7 @@
 #include <net/if.h>
 #include <netinet/in.h>
 #include <ifaddrs.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <rpc/rpc.h>
 #ifdef PORTMAP
 #include <rpc/pmap_prot.h>
diff --git a/src/clnt_dg.c b/src/clnt_dg.c
index dcc621c..248138b 100644
--- a/src/clnt_dg.c
+++ b/src/clnt_dg.c
@@ -37,7 +37,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <stdint.h>
-#include <sys/poll.h>
+#include <poll.h>
 
 #include <sys/time.h>
 
diff --git a/src/clnt_generic.c b/src/clnt_generic.c
index b9b07bc..3f3dabf 100644
--- a/src/clnt_generic.c
+++ b/src/clnt_generic.c
@@ -29,7 +29,7 @@
 #include <pthread.h>
 #include <reentrant.h>
 #include <sys/types.h>
-#include <sys/fcntl.h>
+#include <fcntl.h>
 #include <fcntl.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 61264d4..a72f9f7 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -48,7 +48,7 @@
 
 #include <reentrant.h>
 #include <sys/types.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <sys/syslog.h>
 #include <sys/un.h>
 #include <sys/uio.h>
diff --git a/src/key_call.c b/src/key_call.c
index 1a6430b..589fd6f 100644
--- a/src/key_call.c
+++ b/src/key_call.c
@@ -56,7 +56,7 @@
 #include <stdlib.h>
 #include <signal.h>
 #include <sys/wait.h>
-#include <sys/fcntl.h>
+#include <fcntl.h>
 
 #include "dump.h"
 
diff --git a/src/pmap_rmt.c b/src/pmap_rmt.c
index b81d771..1c76114 100644
--- a/src/pmap_rmt.c
+++ b/src/pmap_rmt.c
@@ -36,7 +36,7 @@
 
 #include <sys/types.h>
 #include <sys/ioctl.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <sys/socket.h>
 
 #include <net/if.h>
diff --git a/src/svc.c b/src/svc.c
index 8afd15d..32c84f1 100644
--- a/src/svc.c
+++ b/src/svc.c
@@ -40,7 +40,7 @@
 
 #include <reentrant.h>
 #include <sys/types.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <assert.h>
 #include <errno.h>
 #include <stdlib.h>
diff --git a/src/svc_vc.c b/src/svc_vc.c
index 9dba72a..9824631 100644
--- a/src/svc_vc.c
+++ b/src/svc_vc.c
@@ -40,7 +40,7 @@
 #include <sys/socket.h>
 #include <sys/types.h>
 #include <sys/param.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <sys/un.h>
 #include <sys/time.h>
 #include <sys/uio.h>
-- 
2.2.0

