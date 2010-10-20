Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:53265 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab0JTVf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 17:35:57 -0400
Date: Wed, 20 Oct 2010 17:35:54 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: Check for strlcat/cpy and compile our private
 version only if it's needed.
Message-ID: <20101020213554.GA27541@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 configure.ac             |    2 +-
 support/include/nfslib.h |    2 ++
 support/nfs/strlcat.c    |    2 ++
 support/nfs/strlcpy.c    |    2 ++
 4 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3058be6..0e56b30 100644
--- a/configure.ac
+++ b/configure.ac
@@ -347,7 +347,7 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                getnameinfo getrpcbyname getifaddrs \
                gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
                realpath rmdir select socket strcasecmp strchr strdup \
-               strerror strrchr strtol strtoul sigprocmask])
+               strerror strlcat strrchr strtol strtoul sigprocmask])
 
 
 dnl *************************************************************
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 53ece0e..ba2d52a 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -164,8 +164,10 @@ int			svctcp_socket (u_long __number, int __reuse);
 int			svcudp_socket (u_long __number);
 
 /* Misc shared code prototypes */
+#ifndef HAVE_STRLCAT
 size_t  strlcat(char *, const char *, size_t);
 size_t  strlcpy(char *, const char *, size_t);
+#endif /* HAVE_STRLCAT */
 ssize_t atomicio(ssize_t (*f) (int, void*, size_t),
 		 int, void *, size_t);
 
diff --git a/support/nfs/strlcat.c b/support/nfs/strlcat.c
index daedd7a..d469a69 100644
--- a/support/nfs/strlcat.c
+++ b/support/nfs/strlcat.c
@@ -27,6 +27,7 @@
  * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#ifndef HAVE_STRLCAT
 #if defined(LIBC_SCCS) && !defined(lint)
 static char *rcsid = "$OpenBSD: strlcat.c,v 1.8 2001/05/13 15:40:15 deraadt Exp $";
 #endif /* LIBC_SCCS and not lint */
@@ -74,3 +75,4 @@ strlcat(char *dst,
 
 	return(dlen + (s - src));	/* count does not include NUL */
 }
+#endif /* HAVE_STRLCAT */
diff --git a/support/nfs/strlcpy.c b/support/nfs/strlcpy.c
index a2653ee..754c51a 100644
--- a/support/nfs/strlcpy.c
+++ b/support/nfs/strlcpy.c
@@ -27,6 +27,7 @@
  * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#ifndef HAVE_STRLCAT
 #if defined(LIBC_SCCS) && !defined(lint)
 static char *rcsid = "$OpenBSD: strlcpy.c,v 1.5 2001/05/13 15:40:16 deraadt Exp $";
 #endif /* LIBC_SCCS and not lint */
@@ -70,3 +71,4 @@ strlcpy(char *dst,
 
 	return(s - src - 1);	/* count does not include NUL */
 }
+#endif /* HAVE_STRLCAT */
-- 
1.7.0.4

