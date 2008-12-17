From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] mount command: Random clean up
Date: Wed, 17 Dec 2008 15:37:35 -0500
Message-ID: <20081217203735.14933.4533.stgit@ingres.1015granger.net>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26696 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbYLQUib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:31 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix some documenting comments and an error message in configure.ac.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac          |    2 +-
 utils/mount/network.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1b83296..48061e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ if test "$enable_ipv6" = yes; then
   AC_CHECK_LIB(tirpc, clnt_tli_create, ,
                AC_MSG_ERROR([libtirpc needed for IPv6 support]))
   AC_CHECK_HEADERS(tirpc/netconfig.h, ,
-               AC_MSG_ERROR([libtirpc-devel needed for IPv6 support]))
+               AC_MSG_ERROR([libtirpc headers needed for IPv6 support]))
   AC_CHECK_DECL([AI_ADDRCONFIG], ,
                AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
                [ #include <netdb.h> ] )
diff --git a/utils/mount/network.c b/utils/mount/network.c
index a82c338..d262e94 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -161,6 +161,7 @@ static void nfs_set_port(struct sockaddr *sap, const unsigned short port)
 /**
  * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
  * @hostname: pointer to C string containing DNS hostname to resolve
+ * @af_hint: hint to restrict resolution to one address family
  * @sap: pointer to buffer to fill with socket address
  * @len: IN: size of buffer to fill; OUT: size of socket address
  *
@@ -270,7 +271,7 @@ int nfs_name_to_address(const char *hostname,
 /**
  * nfs_gethostbyname - resolve a hostname to an IPv4 address
  * @hostname: pointer to a C string containing a DNS hostname
- * @saddr: returns an IPv4 address 
+ * @sin: returns an IPv4 address 
  *
  * Returns 1 if successful, otherwise zero.
  */

