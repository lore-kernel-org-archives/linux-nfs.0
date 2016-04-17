Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:57858 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbcDQJLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:11:44 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 30D1320A86
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:11:42 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:11:03 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] Remove dependency on the <sys/param.h> header
Message-ID: <20160417091103.GE2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The header <sys/param.h> is of BSD origin and is mainly used for
system limit constants such as MAXHOSTNAMELEN.

Remove unecessary inclusions of <sys/param.h> and replace limit
constants by equivalent POSIX constants from <limits.h>.

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 configure.ac       | 2 +-
 src/auth_unix.c    | 4 ++--
 src/clnt_simple.c  | 1 -
 src/getpeereid.c   | 1 -
 src/netname.c      | 1 -
 src/netnamer.c     | 1 -
 src/rpc_generic.c  | 1 -
 src/rpc_prot.c     | 2 --
 src/svc_auth_des.c | 4 ++--
 src/svc_vc.c       | 1 -
 src/xdr_float.c    | 1 -
 tirpc/rpc/types.h  | 1 -
 12 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1f80cf7..8e00689 100644
--- a/configure.ac
+++ b/configure.ac
@@ -85,7 +85,7 @@ AC_CONFIG_HEADERS([config.h])
 AC_PROG_LIBTOOL
 AC_HEADER_DIRENT
 AC_PREFIX_DEFAULT(/usr)
-AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h locale.h netdb.h netinet/in.h stddef.h stdint.h stdlib.h string.h sys/ioctl.h sys/param.h sys/socket.h sys/time.h syslog.h unistd.h features.h gssapi/gssapi_ext.h])
+AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h locale.h netdb.h netinet/in.h stddef.h stdint.h stdlib.h string.h sys/ioctl.h sys/socket.h sys/time.h syslog.h unistd.h features.h gssapi/gssapi_ext.h])
 AC_CHECK_LIB([pthread], [pthread_create])
 AC_CHECK_FUNCS([getrpcbyname getrpcbynumber setrpcent endrpcent getrpcent])
 
diff --git a/src/auth_unix.c b/src/auth_unix.c
index fc2be02..c20ae1e 100644
--- a/src/auth_unix.c
+++ b/src/auth_unix.c
@@ -40,7 +40,6 @@
  */
 #include <pthread.h>
 #include <reentrant.h>
-#include <sys/param.h>
 
 #include <assert.h>
 #include <err.h>
@@ -49,6 +48,7 @@
 #include <unistd.h>
 #include <string.h>
 #include <errno.h>
+#include <limits.h>
 
 #include <rpc/clnt.h>
 #include <rpc/types.h>
@@ -183,7 +183,7 @@ AUTH *
 authunix_create_default()
 {
 	int len;
-	char machname[MAXHOSTNAMELEN + 1];
+	char machname[HOST_NAME_MAX + 1];
 	uid_t uid;
 	gid_t gid, *gids;
 	AUTH *result;
diff --git a/src/clnt_simple.c b/src/clnt_simple.c
index 1700060..965717c 100644
--- a/src/clnt_simple.c
+++ b/src/clnt_simple.c
@@ -36,7 +36,6 @@
  */
 #include <pthread.h>
 #include <reentrant.h>
-#include <sys/param.h>
 #include <stdio.h>
 #include <errno.h>
 #include <rpc/rpc.h>
diff --git a/src/getpeereid.c b/src/getpeereid.c
index dd85270..8f71000 100644
--- a/src/getpeereid.c
+++ b/src/getpeereid.c
@@ -25,7 +25,6 @@
  */
 
 
-#include <sys/param.h>
 #include <sys/socket.h>
 #include <sys/un.h>
 
diff --git a/src/netname.c b/src/netname.c
index ea61b1a..96fe2eb 100644
--- a/src/netname.c
+++ b/src/netname.c
@@ -34,7 +34,6 @@
  * the sun NIS domain architecture.
  */
 
-#include <sys/param.h>
 #include <rpc/rpc.h>
 #include "rpc_com.h"
 #ifdef YP
diff --git a/src/netnamer.c b/src/netnamer.c
index 6b6c8e0..2475866 100644
--- a/src/netnamer.c
+++ b/src/netnamer.c
@@ -32,7 +32,6 @@
  * will work with any unix system that has adopted the sun NIS domain
  * architecture.
  */
-#include <sys/param.h>
 #include <rpc/rpc.h>
 #include "rpc_com.h"
 #ifdef YP
diff --git a/src/rpc_generic.c b/src/rpc_generic.c
index 2f09a8f..c2eb702 100644
--- a/src/rpc_generic.c
+++ b/src/rpc_generic.c
@@ -37,7 +37,6 @@
 #include <pthread.h>
 #include <reentrant.h>
 #include <sys/types.h>
-#include <sys/param.h>
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <sys/un.h>
diff --git a/src/rpc_prot.c b/src/rpc_prot.c
index 5841e51..0f5a30a 100644
--- a/src/rpc_prot.c
+++ b/src/rpc_prot.c
@@ -39,8 +39,6 @@
  * routines are also in this program.
  */
 
-#include <sys/param.h>
-
 #include <assert.h>
 
 #include <rpc/rpc.h>
diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
index 2e90146..73de033 100644
--- a/src/svc_auth_des.c
+++ b/src/svc_auth_des.c
@@ -46,12 +46,12 @@
  */
 #include <pthread.h>
 #include <reentrant.h>
+#include <limits.h>
 #include <string.h>
 #include <stdlib.h>
 #include <stdio.h>
 #include <unistd.h>
 #include <rpc/des_crypt.h>
-#include <sys/param.h>
 #include <netinet/in.h>
 #include <rpc/types.h>
 #include <rpc/xdr.h>
@@ -445,7 +445,7 @@ struct bsdcred {
 	short uid;		/* cached uid */
 	short gid;		/* cached gid */
 	short grouplen;	/* length of cached groups */
-	short groups[NGROUPS];	/* cached groups */
+	short groups[NGROUPS_MAX];	/* cached groups */
 };
 
 /*
diff --git a/src/svc_vc.c b/src/svc_vc.c
index 97a76a3..a8df5f0 100644
--- a/src/svc_vc.c
+++ b/src/svc_vc.c
@@ -39,7 +39,6 @@
 #include <reentrant.h>
 #include <sys/socket.h>
 #include <sys/types.h>
-#include <sys/param.h>
 #include <poll.h>
 #include <sys/un.h>
 #include <sys/time.h>
diff --git a/src/xdr_float.c b/src/xdr_float.c
index 26bc865..6bf4189 100644
--- a/src/xdr_float.c
+++ b/src/xdr_float.c
@@ -39,7 +39,6 @@
  */
 
 #include <sys/types.h>
-#include <sys/param.h>
 
 #include <stdio.h>
 
diff --git a/tirpc/rpc/types.h b/tirpc/rpc/types.h
index 52c30a2..fe36204 100644
--- a/tirpc/rpc/types.h
+++ b/tirpc/rpc/types.h
@@ -66,7 +66,6 @@ typedef   int32_t rpc_inline_t;
 #define mem_free(ptr, bsize)	free(ptr)
 
 #include <sys/time.h>
-#include <sys/param.h>
 #include <stdlib.h>
 #include <netconfig.h>
 
-- 
2.7.3

