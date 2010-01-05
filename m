From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] nfs-utils: add statdb_dump utility
Date: Tue,  5 Jan 2010 10:40:34 -0500
Message-ID: <1262706035-4929-3-git-send-email-jlayton@redhat.com>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878Ab0AEPkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 10:40:41 -0500
In-Reply-To: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To dump contents of statd's monitor DB.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 tests/Makefile.am   |    6 ++++
 tests/statdb_dump.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 0 deletions(-)
 create mode 100644 tests/statdb_dump.c

diff --git a/tests/Makefile.am b/tests/Makefile.am
index 375af80..a20b42b 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -1,5 +1,11 @@
 ## Process this file with automake to produce Makefile.in
 
+check_PROGRAMS = statdb_dump
+statdb_dump_SOURCES = statdb_dump.c
+
+statdb_dump_LDADD = ../support/nfs/libnfs.a \
+		    ../support/nsm/libnsm.a $(LIBCAP)
+
 SUBDIRS = nsm_client
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/tests/statdb_dump.c b/tests/statdb_dump.c
new file mode 100644
index 0000000..655213a
--- /dev/null
+++ b/tests/statdb_dump.c
@@ -0,0 +1,75 @@
+/*
+ * statdb_dump.c -- dump contents of statd's monitor DB
+ *
+ * Copyright (C) 2010  Red Hat, Jeff Layton <jlayton@redhat.com>
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
+ *
+ * Output format is:
+ *
+ * <hostname> <cookie> <mon_name>
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif
+
+#include <stdio.h>
+
+#include "nsm.h"
+#include "xlog.h"
+
+static char cookiebuf[(SM_PRIV_SIZE * 2) + 1];
+
+static _Bool
+error_check(const int len, const size_t buflen)
+{
+        return (len < 0) || ((size_t)len >= buflen);
+}
+
+static unsigned int
+dump_host(const char *hostname, const struct sockaddr *sa, const struct mon *m,
+	  const time_t timestamp)
+{
+	int i, len;
+	char *buf = cookiebuf;
+	size_t remaining = sizeof(cookiebuf);
+
+	/* convert cookie to text string */
+	for (i = 0; i < SM_PRIV_SIZE; i++) {
+		len = snprintf(buf, remaining, "%02x",
+				(unsigned int)(0xff & m->priv[i]));
+		if (error_check(len, remaining))
+			return 0;
+		buf += len;
+		remaining -= (size_t)len;
+	}
+
+	printf("%s %s %s\n", hostname, cookiebuf, m->mon_id.mon_name); 
+	return 1;
+}
+
+int
+main(int argc, char **argv)
+{
+	xlog_syslog(0);
+	xlog_stderr(1);
+	xlog_open(argv[0]);
+	
+	nsm_load_monitor_list(dump_host);
+	return 0;
+}
-- 
1.6.5.2

