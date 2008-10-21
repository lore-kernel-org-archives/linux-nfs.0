From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] rpcbind: Squelch autotool warning
Date: Tue, 21 Oct 2008 18:05:03 -0400
Message-ID: <20081021220503.19488.46702.stgit@manray.1015granger.net>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38789 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbYJUWFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:05:51 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change order of AC_PROG_LIBTOOL macro invocation in configure.in to
eliminate autotool warning:

   Remember to add `AC_PROG_LIBTOOL' to `configure.in'.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index 69f4169..d529ea5 100644
--- a/configure.in
+++ b/configure.in
@@ -5,14 +5,14 @@
 AC_CONFIG_SRCDIR([src/rpcbind.c])
  AC_PROG_CC
  AM_CONFIG_HEADER(config.h)
- AC_PROG_LIBTOOL
- ##AC_PROG_RANLIB
  AC_HEADER_DIRENT
  AC_PREFIX_DEFAULT(/usr)
 
 AC_CONFIG_SRCDIR([src/config.h.in])
 AC_CONFIG_HEADERS([src/config.h])
 
+AC_PROG_LIBTOOL
+
 AC_ARG_ENABLE(debug,[  --enable-debug      Turns on rpcbind debugging], 
 	[case "${enableval}" in
 		yes) debug=true ;;

