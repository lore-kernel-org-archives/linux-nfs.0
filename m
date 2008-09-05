From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/19] sm-notify command: include <config.h>
Date: Fri, 05 Sep 2008 17:07:24 -0400
Message-ID: <20080905210724.10001.35814.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41149 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbYIEVID (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:08:03 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Include config.h as other source files do; instead of using
"config.h" use the HAVE_CONFIG_H macro and include <config.h>.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index b75f11b..5a02394 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -4,6 +4,10 @@
  * Copyright (C) 2004-2006 Olaf Kirch <okir@suse.de>
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
@@ -24,8 +28,6 @@
 #include <errno.h>
 #include <grp.h>
 
-#include "config.h"
-
 #ifndef BASEDIR
 # ifdef NFS_STATEDIR
 #  define BASEDIR		NFS_STATEDIR

