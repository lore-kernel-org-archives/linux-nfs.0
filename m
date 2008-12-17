From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] mount command: use gethostbyname(3) when building on old
	systems
Date: Wed, 17 Dec 2008 15:37:24 -0500
Message-ID: <20081217203724.14933.48660.stgit@ingres.1015granger.net>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:37198 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYLQUie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:34 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Glibc's getaddrinfo(3) implementation was added over time.  Some old
versions support AI_ADDRCONFIG, but don't define it in header files.
Some older versions don't support AI_ADDRCONFIG at all.

Let's add specific checks to configure.ac to see that the local
getaddrinfo(3) implementation is complete.  If it isn't, we will make
available a resolver that uses gethostbyname(3) and disable IPv6
entirely.

This patch should apply to 1.1.4 as well as the current nfs-utils repo.
The next patch has a fix for the getaddrinfo(3) call added since 1.1.4
in support/nfs/getport.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac          |    8 +++++++
 utils/mount/network.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 48d76d7..1b83296 100644
--- a/configure.ac
+++ b/configure.ac
@@ -246,6 +246,11 @@ if test "$enable_gss" = yes; then
 
 fi
 
+AC_CHECK_DECL([AI_ADDRCONFIG],
+              AC_DEFINE([HAVE_DECL_AI_ADDRCONFIG], 1,
+                         [Define this to 1 if AI_ADDRCONFIG macro is defined]), ,
+              [ #include <netdb.h> ] )
+
 if test "$enable_ipv6" = yes; then
   AC_CHECK_FUNC(inet_ntop, , ,
                AC_MSG_ERROR(Function 'inet_ntop' not found.))
@@ -255,6 +260,9 @@ if test "$enable_ipv6" = yes; then
                AC_MSG_ERROR([libtirpc needed for IPv6 support]))
   AC_CHECK_HEADERS(tirpc/netconfig.h, ,
                AC_MSG_ERROR([libtirpc-devel needed for IPv6 support]))
+  AC_CHECK_DECL([AI_ADDRCONFIG], ,
+               AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
+               [ #include <netdb.h> ] )
 fi
 
 dnl *************************************************************
diff --git a/utils/mount/network.c b/utils/mount/network.c
index afa47a4..a82c338 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -157,6 +157,7 @@ static void nfs_set_port(struct sockaddr *sap, const unsigned short port)
 	}
 }
 
+#ifdef HAVE_DECL_AI_ADDRCONFIG
 /**
  * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
  * @hostname: pointer to C string containing DNS hostname to resolve
@@ -210,6 +211,61 @@ int nfs_name_to_address(const char *hostname,
 	freeaddrinfo(gai_results);
 	return ret;
 }
+#else	/* HAVE_DECL_AI_ADDRCONFIG */
+/**
+ * nfs_name_to_address - resolve hostname to an IPv4 socket address
+ * @hostname: pointer to C string containing DNS hostname to resolve
+ * @af_hint: hint to restrict resolution to one address family
+ * @sap: pointer to buffer to fill with socket address
+ * @len: IN: size of buffer to fill; OUT: size of socket address
+ *
+ * Returns 1 and places a socket address at @sap if successful;
+ * otherwise zero.
+ *
+ * Some older getaddrinfo(3) implementations don't support
+ * AI_ADDRCONFIG or AI_V4MAPPED properly.  For those cases, a DNS
+ * resolver based on the traditional gethostbyname(3) is provided.
+ */
+int nfs_name_to_address(const char *hostname,
+			const sa_family_t af_hint,
+			struct sockaddr *sap, socklen_t *salen)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	socklen_t len = *salen;
+	struct hostent *hp;
+
+	*salen = 0;
+
+	if (af_hint != AF_INET) {
+		nfs_error(_("%s: address family not supported by DNS resolver\n"),
+				progname, hostname);
+		return 0;
+	}
+
+	sin->sin_family = AF_INET;
+	if (inet_aton(hostname, &sin->sin_addr)) {
+		*salen = sizeof(*sin);
+		return 1;
+	}
+
+	hp = gethostbyname(hostname);
+	if (hp == NULL) {
+		nfs_error(_("%s: DNS resolution failed for %s: %s"),
+				progname, hostname, hstrerror(h_errno));
+		return 0;
+	}
+
+	if (hp->h_length > len) {
+		nfs_error(_("%s: DNS resolution results too long for buffer\n"),
+				progname);
+		return 0;
+	}
+
+	memcpy(&sin->sin_addr, hp->h_addr, hp->h_length);
+	*salen = hp->h_length;
+	return 1;
+}
+#endif	/* HAVE_DECL_AI_ADDRCONFIG */
 
 /**
  * nfs_gethostbyname - resolve a hostname to an IPv4 address

