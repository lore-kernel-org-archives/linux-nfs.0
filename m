From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] rpcbind: Squelch make warnings
Date: Tue, 21 Oct 2008 18:04:55 -0400
Message-ID: <20081021220455.19488.65634.stgit@manray.1015granger.net>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38790 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbYJUWFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:05:51 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate make warnings when building rpcbind and rpcinfo:

make[3]: Circular security.o <- security.o dependency dropped.
make[3]: Circular util.o <- security.o dependency dropped.
make[3]: Circular util.o <- util.o dependency dropped.
make[3]: Circular util.o <- check_bound.o dependency dropped.
make[3]: Circular pmap_svc.o <- security.o dependency dropped.
make[3]: Circular pmap_svc.o <- util.o dependency dropped.
make[3]: Circular pmap_svc.o <- check_bound.o dependency dropped.
make[3]: Circular pmap_svc.o <- pmap_svc.o dependency dropped.

and so on.

Apparently src/Makefile.am needs either a list of source files or a
list of object files, but not both.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 src/Makefile.am |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index d66b43f..cc0a85b 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -31,9 +31,4 @@ rpcbind_LDFLAGS = -lpthread -ltirpc
 rpcbind_LDADD = $(LIB_TIRPC)
 AM_CPPFLAGS = -I/usr/include/tirpc -DCHECK_LOCAL -DPORTMAP \
                        -DFACILITY=LOG_MAIL -DSEVERITY=LOG_INFO
-
-$(rpcbind_OBJECTS) :    security.o util.o check_bound.o pmap_svc.o \
-                        rpcb_svc.o rpcb_svc_com.o rpcb_svc_4.o \
-                        rpcb_stat.o rpcbind.o warmstart.o 
-$(rpcinfo_OBJECTS) :    rpcinfo.o                       
      

