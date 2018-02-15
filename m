Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:44823 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033275AbeBOUWK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 15:22:10 -0500
Received: by mail-io0-f196.google.com with SMTP id z6so1960970iob.11
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 12:22:10 -0800 (PST)
Subject: [PATCH RFC 1/3] Add an internal helper for binding to a
 dynamically-assigned port
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Thu, 15 Feb 2018 15:22:08 -0500
Message-ID: <20180215202208.16924.50214.stgit@klimt.1015granger.net>
In-Reply-To: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
References: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a helper function akin to bindresvport(3) that instead binds
to a dynamically assigned port. It uses the rules in RFC 6335
Section 6 to avoid all IANA-assigned service port numbers, even
when the caller has the CAP_NET_ADMIN_BIND privilege.

This is intended to remain an internal helper for the time being, so
this commit provides no header declaration.

All internal bindresvport(3) call sites manufacture an INADDR_ANY-
type address to pass to bind(2), so the helper handles that as well,
to avoid code duplication. This means that callers do not need to
pass in a sockaddr. Only an open socket is required.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 src/Makefile.am   |    5 +-
 src/binddynport.c |  132 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+), 2 deletions(-)
 create mode 100644 src/binddynport.c

diff --git a/src/Makefile.am b/src/Makefile.am
index fba2aa4..932414d 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -15,8 +15,9 @@ lib_LTLIBRARIES = libtirpc.la
 libtirpc_la_LDFLAGS = @LDFLAG_NOUNDEFINED@ -no-undefined -lpthread
 libtirpc_la_LDFLAGS += -version-info @LT_VERSION_INFO@
 
-libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c clnt_bcast.c \
-        clnt_dg.c clnt_generic.c clnt_perror.c clnt_raw.c clnt_simple.c \
+libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c \
+        binddynport.c bindresvport.c \
+        clnt_bcast.c clnt_dg.c clnt_generic.c clnt_perror.c clnt_raw.c clnt_simple.c \
         clnt_vc.c rpc_dtablesize.c getnetconfig.c getnetpath.c getrpcent.c \
         getrpcport.c mt_misc.c pmap_clnt.c pmap_getmaps.c pmap_getport.c \
         pmap_prot.c pmap_prot2.c pmap_rmt.c rpc_prot.c rpc_commondata.c \
diff --git a/src/binddynport.c b/src/binddynport.c
new file mode 100644
index 0000000..1580117
--- /dev/null
+++ b/src/binddynport.c
@@ -0,0 +1,132 @@
+/*
+ * Copyright (c) 2018, Oracle America, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ * - Redistributions of source code must retain the above copyright notice,
+ *   this list of conditions and the following disclaimer.
+ * - Redistributions in binary form must reproduce the above copyright notice,
+ *   this list of conditions and the following disclaimer in the documentation
+ *   and/or other materials provided with the distribution.
+ * - Neither the name of "Oracle America, Inc." nor the names of its
+ *   contributors may be used to endorse or promote products derived
+ *   from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include <netdb.h>
+#include <netinet/in.h>
+
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+
+#include <rpc/rpc.h>
+
+#include "reentrant.h"
+#include "rpc_com.h"
+
+extern pthread_mutex_t port_lock;
+
+/*
+ * Dynamic port range as defined in RFC 6335 Section 6.
+ * This range avoids all IANA-assigned service port
+ * numbers.
+ */
+enum {
+	LOWPORT		= 49152,
+	ENDPORT		= 65534,
+	NPORTS		= ENDPORT - LOWPORT + 1,
+};
+
+/*
+ * Bind a socket to a dynamically-assigned IP port.
+ *
+ * @fd is an open but unbound socket.
+ *
+ * On each call, a port number is chosen at random from
+ * within the dynamic/private port range, even if the
+ * caller has CAP_NET_ADMIN_BIND.
+ *
+ * Returns 0 on success, -1 on failure. errno may be
+ * set to a non-determinant value.
+ *
+ * This function is re-entrant.
+ */
+int __binddynport(int fd)
+{
+	struct sockaddr_storage ss;
+#ifdef INET6
+	struct sockaddr_in6 *sin6;
+#endif
+	struct sockaddr_in *sin;
+	in_port_t port, *portp;
+	struct sockaddr *sap;
+	socklen_t salen;
+	unsigned int seed;
+	int i, res;
+
+	if (__rpc_sockisbound(fd))
+		return 0;
+
+	res = -1;
+	sap = (struct sockaddr *)(void *)&ss;
+	memset(sap, 0, sizeof(ss));
+
+	mutex_lock(&port_lock);
+
+	if (getsockname(fd, sap, &salen) == -1)
+		goto out;
+
+	switch (ss.ss_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)(void *)&ss;
+		portp = &sin->sin_port;
+		salen = sizeof(struct sockaddr_in);
+		break;
+#ifdef INET6
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)(void *)&ss;
+		portp = &sin6->sin6_port;
+		salen = sizeof(struct sockaddr_in6);
+		break;
+#endif
+	default:
+		goto out;
+	}
+
+	seed = time(NULL);
+	port = (rand_r(&seed) % NPORTS) + LOWPORT;
+	for (i = 0; i < NPORTS; ++i) {
+		*portp = htons(port++);
+		res = bind(fd, sap, salen);
+		if (res >= 0) {
+			res = 0;
+			break;
+		}
+		if (errno != EADDRINUSE)
+			break;
+		if (port > ENDPORT)
+			port = LOWPORT;
+	}
+
+out:
+	mutex_unlock(&port_lock);
+	return res;
+}

