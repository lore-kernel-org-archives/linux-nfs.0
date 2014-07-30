Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f172.google.com ([209.85.217.172]:37115 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaG3LXe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:34 -0400
Received: by mail-lb0-f172.google.com with SMTP id z11so759660lbi.31
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:33 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 07/11] Allow usage of getrpcbynumber() when getrpcbynumber_r() is unavailable
Date: Wed, 30 Jul 2014 13:23:15 +0200
Message-Id: <1406719399-1735-8-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 configure.ac             | 6 +-----
 support/nfs/svc_socket.c | 6 ++++++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/configure.ac b/configure.ac
index 408f4c8..42cd3e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -247,9 +247,6 @@ AC_CHECK_FUNC([connect], ,
 AC_CHECK_FUNC([getaddrinfo], ,
               [AC_MSG_ERROR([Function 'getaddrinfo' not found.])])
 
-AC_CHECK_FUNC([getrpcbynumber], ,
-              [AC_MSG_ERROR([Function 'getrpcbynumber' not found.])])
-
 AC_CHECK_FUNC([getservbyname], ,
               [AC_MSG_ERROR([Function 'getservbyname' not found.])])
 
@@ -408,12 +405,11 @@ AC_FUNC_STAT
 AC_FUNC_VPRINTF
 AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                gethostbyaddr gethostbyname gethostname getmntent \
-               getnameinfo getrpcbyname getifaddrs \
+               getnameinfo getrpcbyname getrpcbynumber getrpcbynumber_r getifaddrs \
                gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
                ppoll realpath rmdir select socket strcasecmp strchr strdup \
                strerror strrchr strtol strtoul sigprocmask name_to_handle_at])
 
-
 dnl *************************************************************
 dnl Check for data sizes
 dnl *************************************************************
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index f56f310..61ccf5b 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -42,8 +42,14 @@ int getservport(u_long number, const char *proto)
 	struct servent servbuf, *servp = NULL;
 	int ret;
 
+#if HAVE_GETRPCBYNUMBER_R
 	ret = getrpcbynumber_r(number, &rpcbuf, rpcdata, sizeof rpcdata,
 				&rpcp);
+#else
+	rpcp = getrpcbynumber(number);
+	ret = 0;
+#endif
+
 	if (ret == 0 && rpcp != NULL) {
 		/* First try name.  */
 		ret = getservbyname_r(rpcp->r_name, proto, &servbuf, servdata,
-- 
2.0.3

