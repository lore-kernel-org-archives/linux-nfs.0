Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:54427 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934686AbaDJUbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:31:13 -0400
Received: by mail-qc0-f172.google.com with SMTP id i8so5067126qcq.31
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:31:12 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] gssd: move hostbased name routines into separate file
Date: Thu, 10 Apr 2014 16:31:01 -0400
Message-Id: <1397161863-29266-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll need gssd to call into this code as well as
svcgssd. Move it into a common file that both can link in.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/Makefile.am    |   2 +
 utils/gssd/gss_names.c    | 123 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/gss_names.h    |  34 +++++++++++++
 utils/gssd/svcgssd_proc.c |  66 +------------------------
 4 files changed, 160 insertions(+), 65 deletions(-)
 create mode 100644 utils/gssd/gss_names.c
 create mode 100644 utils/gssd/gss_names.h

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index a9a3e42de19d..af597918e8e0 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -18,11 +18,13 @@ COMMON_SRCS = \
 	context_lucid.c \
 	gss_util.c \
 	gss_oids.c \
+	gss_names.c \
 	err_util.c \
 	\
 	context.h \
 	err_util.h \
 	gss_oids.h \
+	gss_names.h \
 	gss_util.h
 
 gssd_SOURCES = \
diff --git a/utils/gssd/gss_names.c b/utils/gssd/gss_names.c
new file mode 100644
index 000000000000..aa61e4d7a851
--- /dev/null
+++ b/utils/gssd/gss_names.c
@@ -0,0 +1,123 @@
+/*
+  Copyright (c) 2000 The Regents of the University of Michigan.
+  All rights reserved.
+
+  Copyright (c) 2002 Bruce Fields <bfields@UMICH.EDU>
+
+  Redistribution and use in source and binary forms, with or without
+  modification, are permitted provided that the following conditions
+  are met:
+
+  1. Redistributions of source code must retain the above copyright
+     notice, this list of conditions and the following disclaimer.
+  2. Redistributions in binary form must reproduce the above copyright
+     notice, this list of conditions and the following disclaimer in the
+     documentation and/or other materials provided with the distribution.
+  3. Neither the name of the University nor the names of its
+     contributors may be used to endorse or promote products derived
+     from this software without specific prior written permission.
+
+  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+*/
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
+#include <sys/param.h>
+#include <sys/stat.h>
+#include <rpc/rpc.h>
+
+#include <pwd.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <ctype.h>
+#include <string.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <nfsidmap.h>
+#include <nfslib.h>
+#include <time.h>
+
+#include "svcgssd.h"
+#include "gss_util.h"
+#include "err_util.h"
+#include "context.h"
+#include "misc.h"
+#include "gss_oids.h"
+#include "svcgssd_krb5.h"
+
+static int
+get_krb5_hostbased_name(gss_buffer_desc *name, char **hostbased_name)
+{
+	char *p, *sname = NULL;
+	if (strchr(name->value, '@') && strchr(name->value, '/')) {
+		if ((sname = calloc(name->length, 1)) == NULL) {
+			printerr(0, "ERROR: get_krb5_hostbased_name failed "
+				 "to allocate %d bytes\n", name->length);
+			return -1;
+		}
+		/* read in name and instance and replace '/' with '@' */
+		sscanf(name->value, "%[^@]", sname);
+		p = strrchr(sname, '/');
+		if (p == NULL) {    /* The '@' preceeded the '/' */
+			free(sname);
+			return -1;
+		}
+		*p = '@';
+	}
+	*hostbased_name = sname;
+	return 0;
+}
+
+int
+get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
+			  char **hostbased_name)
+{
+	u_int32_t	maj_stat, min_stat;
+	gss_buffer_desc	name;
+	gss_OID		name_type = GSS_C_NO_OID;
+	char		*cname;
+	int		res = -1;
+
+	*hostbased_name = NULL;	    /* preset in case we fail */
+
+	/* Get the client's gss authenticated name */
+	maj_stat = gss_display_name(&min_stat, client_name, &name, &name_type);
+	if (maj_stat != GSS_S_COMPLETE) {
+		pgsserr("get_hostbased_client_name: gss_display_name",
+			maj_stat, min_stat, mech);
+		goto out_err;
+	}
+	if (name.length >= 0xffff) {	    /* don't overflow */
+		printerr(0, "ERROR: get_hostbased_client_name: "
+			 "received gss_name is too long (%d bytes)\n",
+			 name.length);
+		goto out_rel_buf;
+	}
+
+	/* For Kerberos, transform the NT_KRB5_PRINCIPAL name to
+	 * an NT_HOSTBASED_SERVICE name */
+	if (g_OID_equal(&krb5oid, mech)) {
+		if (get_krb5_hostbased_name(&name, &cname) == 0)
+			*hostbased_name = cname;
+	} else {
+		printerr(1, "WARNING: unknown/unsupport mech OID\n");
+	}
+
+	res = 0;
+out_rel_buf:
+	gss_release_buffer(&min_stat, &name);
+out_err:
+	return res;
+}
diff --git a/utils/gssd/gss_names.h b/utils/gssd/gss_names.h
new file mode 100644
index 000000000000..1d5f49c1c1d2
--- /dev/null
+++ b/utils/gssd/gss_names.h
@@ -0,0 +1,34 @@
+/*
+  Copyright (c) 2000 The Regents of the University of Michigan.
+  All rights reserved.
+
+  Copyright (c) 2002 Bruce Fields <bfields@UMICH.EDU>
+
+  Redistribution and use in source and binary forms, with or without
+  modification, are permitted provided that the following conditions
+  are met:
+
+  1. Redistributions of source code must retain the above copyright
+     notice, this list of conditions and the following disclaimer.
+  2. Redistributions in binary form must reproduce the above copyright
+     notice, this list of conditions and the following disclaimer in the
+     documentation and/or other materials provided with the distribution.
+  3. Neither the name of the University nor the names of its
+     contributors may be used to endorse or promote products derived
+     from this software without specific prior written permission.
+
+  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+*/
+
+extern int get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
+					char **hostbased_name);
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 3757d5191041..5bdb438650d4 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -59,6 +59,7 @@
 #include "misc.h"
 #include "gss_oids.h"
 #include "svcgssd_krb5.h"
+#include "gss_names.h"
 
 extern char * mech2file(gss_OID mech);
 #define SVCGSSD_CONTEXT_CHANNEL "/proc/net/rpc/auth.rpcsec.context/channel"
@@ -315,71 +316,6 @@ print_hexl(const char *description, unsigned char *cp, int length)
 }
 #endif
 
-static int
-get_krb5_hostbased_name (gss_buffer_desc *name, char **hostbased_name)
-{
-	char *p, *sname = NULL;
-	if (strchr(name->value, '@') && strchr(name->value, '/')) {
-		if ((sname = calloc(name->length, 1)) == NULL) {
-			printerr(0, "ERROR: get_krb5_hostbased_name failed "
-				 "to allocate %d bytes\n", name->length);
-			return -1;
-		}
-		/* read in name and instance and replace '/' with '@' */
-		sscanf(name->value, "%[^@]", sname);
-		p = strrchr(sname, '/');
-		if (p == NULL) {    /* The '@' preceeded the '/' */
-			free(sname);
-			return -1;
-		}
-		*p = '@';
-	}
-	*hostbased_name = sname;
-	return 0;
-}
-
-static int
-get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
-			  char **hostbased_name)
-{
-	u_int32_t	maj_stat, min_stat;
-	gss_buffer_desc	name;
-	gss_OID		name_type = GSS_C_NO_OID;
-	char		*cname;
-	int		res = -1;
-
-	*hostbased_name = NULL;	    /* preset in case we fail */
-
-	/* Get the client's gss authenticated name */
-	maj_stat = gss_display_name(&min_stat, client_name, &name, &name_type);
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("get_hostbased_client_name: gss_display_name",
-			maj_stat, min_stat, mech);
-		goto out_err;
-	}
-	if (name.length >= 0xffff) {	    /* don't overflow */
-		printerr(0, "ERROR: get_hostbased_client_name: "
-			 "received gss_name is too long (%d bytes)\n",
-			 name.length);
-		goto out_rel_buf;
-	}
-
-	/* For Kerberos, transform the NT_KRB5_PRINCIPAL name to
-	 * an NT_HOSTBASED_SERVICE name */
-	if (g_OID_equal(&krb5oid, mech)) {
-		if (get_krb5_hostbased_name(&name, &cname) == 0)
-			*hostbased_name = cname;
-	} else {
-		printerr(1, "WARNING: unknown/unsupport mech OID\n");
-	}
-
-	res = 0;
-out_rel_buf:
-	gss_release_buffer(&min_stat, &name);
-out_err:
-	return res;
-}
-
 void
 handle_nullreq(FILE *f) {
 	/* XXX initialize to a random integer to reduce chances of unnecessary
-- 
1.9.0

