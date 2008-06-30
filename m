From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] nfs-utils: Add dependency for getaddrinfo(3) in
	configure.ac
Date: Mon, 30 Jun 2008 13:10:30 -0400
Message-ID: <20080630171029.9905.60870.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30001 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbYF3RLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:11:39 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lots of parts of nfs-utils already depend on getaddrinfo(3).

We could find each instance where getaddrinfo(3) is invoked, wrap it with
#ifdef HAVE_GETADDRINFO, and provide equivalent logic without it, but that's
a whole lot of work... and no-one has complained about this so far.

So as a clean-up, let's simply add a hard dependency for it in configure.ac,
and call it a day.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/configure.ac b/configure.ac
index 6ecbf55..d508c28 100644
--- a/configure.ac
+++ b/configure.ac
@@ -172,6 +172,9 @@ AC_CHECK_FUNC(connect, ,
       AC_CHECK_LIB(socket, connect, [LIBSOCKET="-lsocket"],
                 AC_MSG_ERROR(Function 'socket' not found.), $LIBNSL))
 
+AC_CHECK_FUNC(getaddrinfo, , ,
+                AC_MSG_ERROR(Function 'getaddrinfo' not found.))
+
 AC_CHECK_LIB(crypt, crypt, [LIBCRYPT="-lcrypt"])
 if test "$enable_nfsv4" = yes; then
     AC_CHECK_LIB(event, event_dispatch, [libevent=1], AC_MSG_ERROR([libevent needed for nfsv4 support]))

