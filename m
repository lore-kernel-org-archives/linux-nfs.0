Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322AbaGOPJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:45 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/15] libtirpc: New configurable debugging routines
Date: Tue, 15 Jul 2014 11:09:20 -0400
Message-Id: <1405436974-4161-2-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch added new configurable debugging interface that
will allow existing debugging statements to be enabled
and disabled by the calling application.

    libtirpc_set_debug(char *name, int level, int use_stderr)

       * This is called by the application to set the debugging level.
         If use_stderr is set, all message will go to stderr,
         otherwise syslog() will be used.

    LIBTIRPC_DEBUG(level, msg)
        * This is the macro called by functions within the library.

    libtirpc_log_dbg(char *fmt, ...)
        * This is the routine the LIBTIRPC_DEBUG macro uses to
          log the messages and can be called directly by internal
          routines

    vlibtirpc_log_dbg(int level, const char *fmt, va_list args)
        * This routine is used by existing debugging routines
          that already obtained their arguments using
          stdarg(3) macros.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/Makefile.am |  4 ++--
 src/debug.c     | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 src/debug.h     | 49 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 2 deletions(-)
 create mode 100644 src/debug.c
 create mode 100644 src/debug.h

diff --git a/src/Makefile.am b/src/Makefile.am
index 3029b78..de57c8f 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -5,7 +5,7 @@
 ## program built.  We also don't bother trying to assemble code, or
 ## anything like that.
 
-noinst_HEADERS = rpc_com.h
+noinst_HEADERS = rpc_com.h debug.h
 
 AM_CPPFLAGS = -I$(top_srcdir)/tirpc -DPORTMAP -DINET6 \
 		-D_GNU_SOURCE -Wall -pipe  
@@ -51,7 +51,7 @@ libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c cln
         rpc_callmsg.c rpc_generic.c rpc_soc.c rpcb_clnt.c rpcb_prot.c \
         rpcb_st_xdr.c svc.c svc_auth.c svc_dg.c svc_auth_unix.c svc_auth_none.c \
         svc_generic.c svc_raw.c svc_run.c svc_simple.c svc_vc.c getpeereid.c \
-        auth_time.c auth_des.c authdes_prot.c
+        auth_time.c auth_des.c authdes_prot.c debug.c
 
 ## XDR
 libtirpc_la_SOURCES += xdr.c xdr_rec.c xdr_array.c xdr_float.c xdr_mem.c xdr_reference.c xdr_stdio.c
diff --git a/src/debug.c b/src/debug.c
new file mode 100644
index 0000000..3a9862e
--- /dev/null
+++ b/src/debug.c
@@ -0,0 +1,64 @@
+/*
+ * debug.c -- debugging routines for libtirpc
+ *
+ * Copyright (C) 2014  Red Hat, Steve Dickson <steved@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+#include <sys/types.h>
+#include <stdio.h>
+#include <stdarg.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <string.h>
+
+#include "debug.h"
+
+/* library global debug level */
+int libtirpc_debug_level = 3;
+int  log_stderr = 1; /* log to stderr instead of systlog */
+
+/*
+ * Set the debug level for the entire library.
+ * Different area will used the value to determin
+ * the verbosity of the debugging output.
+ */
+void
+libtirpc_set_debug(char *name, int level, int use_stderr)
+{
+	if (level < 0)
+		level = 0;
+
+	log_stderr = use_stderr;
+	if (!use_stderr)
+		openlog(name, LOG_PID, LOG_DAEMON);
+
+	LIBTIRPC_DEBUG(1, ("libtirpc: debug level %d", level));
+}
+
+void
+libtirpc_log_dbg(char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	if (log_stderr) {
+		vfprintf(stderr, fmt, args);
+		fprintf(stderr, "\n");
+	} else
+		vsyslog(LOG_NOTICE, fmt, args);
+	va_end(args);
+}
diff --git a/src/debug.h b/src/debug.h
new file mode 100644
index 0000000..afc8d57
--- /dev/null
+++ b/src/debug.h
@@ -0,0 +1,49 @@
+/*
+ * debug.h -- debugging routines for libtirpc
+ *
+ * Copyright (C) 2014  Red Hat, Steve Dickson <steved@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _DEBUG_H
+#define _DEBUG_H
+#include <syslog.h>
+
+extern int libtirpc_debug_level;
+extern int  log_stderr;
+
+void    libtirpc_log_dbg(char *format, ...);
+void 	libtirpc_set_debug(char *name, int level, int use_stderr);
+
+#define LIBTIRPC_DEBUG(level, msg) \
+	do { \
+		if (level <= libtirpc_debug_level) \
+			libtirpc_log_dbg msg; \
+	} while (0)
+
+static inline void 
+vlibtirpc_log_dbg(int level, const char *fmt, va_list args)
+{
+	if (level <= libtirpc_debug_level) {
+		if (log_stderr) {
+			vfprintf(stderr, fmt, args);
+			fprintf(stderr, "\n");
+		} else
+			vsyslog(LOG_NOTICE, fmt, args);
+	}
+}
+#endif /* _DEBUG_H */
-- 
1.9.3

