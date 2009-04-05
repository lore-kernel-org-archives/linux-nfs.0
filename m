From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] nfs-utils: make getnameinfo() required for --enable-gss
Date: Sun,  5 Apr 2009 09:42:59 -0400
Message-ID: <1238938983-7347-2-git-send-email-jlayton@redhat.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54321 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbZDENnN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Apr 2009 09:43:13 -0400
In-Reply-To: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Systems that are so old that they don't have getnameinfo() in glibc are
probably also running kernels that are so old that they don't support
gssapi upcalls anyway.

Make --enable-gss dependent on the presence of the getnameinfo()
function.  This allows us to reduce some conditional compilation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index e34b7e2..00aee35 100644
--- a/configure.ac
+++ b/configure.ac
@@ -207,6 +207,8 @@ if test "$enable_nfsv4" = yes; then
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
     AC_RPCSEC_VERSION
+    AC_CHECK_FUNC([getnameinfo], ,
+		  [AC_MSG_ERROR([Function 'getnameinfo' not found.])])
   fi
 fi
 
-- 
1.6.0.6

