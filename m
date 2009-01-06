From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] configure: Remove inet_ntop(3) check from configure.ac
Date: Tue, 06 Jan 2009 18:22:44 -0500
Message-ID: <20090106232244.24661.66031.stgit@ingres.1015granger.net>
References: <20090106231909.24661.92964.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:63228 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759AbZAFXYs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 18:24:48 -0500
In-Reply-To: <20090106231909.24661.92964.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs-utils no longer uses inet_ntop(3) so remove checks for it from
configure.ac.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 7140f48..4448743 100644
--- a/configure.ac
+++ b/configure.ac
@@ -252,8 +252,6 @@ AC_CHECK_DECL([AI_ADDRCONFIG],
               [ #include <netdb.h> ] )
 
 if test "$enable_ipv6" = yes; then
-  AC_CHECK_FUNC(inet_ntop, , ,
-               AC_MSG_ERROR(Function 'inet_ntop' not found.))
   AC_CHECK_FUNC(getnameinfo, , ,
                AC_MSG_ERROR(Function 'getnameinfo' not found.))
   AC_CHECK_LIB(tirpc, clnt_tli_create, ,
@@ -309,7 +307,7 @@ AC_FUNC_STAT
 AC_FUNC_VPRINTF
 AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                gethostbyaddr gethostbyname gethostname getmntent \
-               inet_ntop getnameinfo getrpcbyname \
+               getnameinfo getrpcbyname \
                bindresvport_sa getnetconfig \
                clnt_create clnt_create_timed \
                clnt_tli_create clnt_vc_create clnt_dg_create xdr_rpcb \

