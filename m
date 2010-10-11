Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAEy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:04:54 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:04:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/15] mount.nfs: Eliminate compiler warning in
	utils/mount/mount.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:04:51 -0400
Message-ID: <20101011000451.6667.59777.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

In file included from mount.c:41:
mount_config.h:35: warning: no previous prototype for ‘mount_config_opts’

Functions defined in include files are usually declared as "static
inline," eliminating the need for a forward declaration.

While I was there, I also fixed the macro that prevents including
mount_config.h multiple times, and fixed some white space damage.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount_config.h |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/utils/mount/mount_config.h b/utils/mount/mount_config.h
index 3023306..e86b4ba 100644
--- a/utils/mount/mount_config.h
+++ b/utils/mount/mount_config.h
@@ -1,7 +1,7 @@
-#ifndef _LINUX_MOUNT__CONFIG_H
-#define _LINUX_MOUNT_CONFIG__H
+#ifndef _LINUX_MOUNT_CONFIG_H
+#define _LINUX_MOUNT_CONFIG_H
 /*
- * mount_config.h -- mount configuration file routines 
+ * mount_config.h -- mount configuration file routines
  * Copyright (C) 2008 Red Hat, Inc <nfs@redhat.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -16,15 +16,13 @@
  *
  */
 
-inline void mount_config_init(char *);
-
 #ifdef MOUNT_CONFIG
 #include "conffile.h"
 #include "xlog.h"
 
 extern char *conf_get_mntopts(char *, char *, char *);
 
-inline void mount_config_init(char *program)
+static inline void mount_config_init(char *program)
 {
 	xlog_open(program);
 	/*
@@ -32,19 +30,22 @@ inline void mount_config_init(char *program)
 	 */
 	conf_init();
 }
-inline char *mount_config_opts(char *spec, 
+
+static inline char *mount_config_opts(char *spec,
 		char *mount_point, char *mount_opts)
 {
 	return conf_get_mntopts(spec, mount_point, mount_opts);
 }
+
 #else /* MOUNT_CONFIG */
 
-inline void mount_config_init(char *program) { }
+static inline void mount_config_init(char *program) { }
 
-inline char *mount_config_opts(char *spec, 
+static inline char *mount_config_opts(char *spec,
 		char *mount_point, char *mount_opts)
 {
 	return mount_opts;
 }
 #endif /* MOUNT_CONFIG */
-#endif
+
+#endif	/* _LINUX_MOUNT_CONFIG_H */

