Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56470 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752574Ab1F3Acb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2011 20:32:31 -0400
From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] Include config.h in more source files
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2011 20:32:30 -0400
Message-ID: <20110630003230.6143.28663.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Commit 9acc85db makes it necessary to include config.h in
source files.  umich_ldap.c needs ENABLE_LDAP defined to
do anything useful.  Since it doesn't include config.h,
nothing is compiled, and the plugin fails to load with
the following messages:

rpc.idmapd[8117]: libnfsidmap: Unable to get init function:
  /lib64/libnfsidmap/umich_ldap.so: undefined symbol:
  libnfsidmap_plugin_init
rpc.idmapd[8117]: libnfsidmap: requested translation method,
  'umich_ldap', is not available
---

 cfg.c        |    2 ++
 gums.c       |    2 ++
 libtest.c    |    2 ++
 nss.c        |    2 ++
 static.c     |    2 ++
 umich_ldap.c |    2 ++
 6 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/cfg.c b/cfg.c
index c615d24..3fe1b1c 100644
--- a/cfg.c
+++ b/cfg.c
@@ -30,6 +30,8 @@
  * This code was written under funding by Ericsson Radio Systems.
  */
 
+#include "config.h"
+
 #include <sys/param.h>
 #include <sys/mman.h>
 #include <sys/socket.h>
diff --git a/gums.c b/gums.c
index 2b12d95..db2c8af 100644
--- a/gums.c
+++ b/gums.c
@@ -32,6 +32,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "config.h"
+
 #include <sys/types.h>
 #include <errno.h>
 #include <unistd.h>
diff --git a/libtest.c b/libtest.c
index 1c717b8..e88e6be 100644
--- a/libtest.c
+++ b/libtest.c
@@ -44,6 +44,8 @@
  *
  */
 
+#include "config.h"
+
 #include <stdio.h>
 #include <string.h>
 #include <sys/types.h>
diff --git a/nss.c b/nss.c
index 04aff19..58a3df4 100644
--- a/nss.c
+++ b/nss.c
@@ -34,6 +34,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "config.h"
+
 #include <sys/types.h>
 #include <errno.h>
 #include <unistd.h>
diff --git a/static.c b/static.c
index fffd458..f14cf9c 100644
--- a/static.c
+++ b/static.c
@@ -32,6 +32,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "config.h"
+
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
diff --git a/umich_ldap.c b/umich_ldap.c
index f482b0a..b1ab602 100644
--- a/umich_ldap.c
+++ b/umich_ldap.c
@@ -32,6 +32,8 @@
  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "config.h"
+
 #ifdef ENABLE_LDAP
 
 #include <sys/types.h>

