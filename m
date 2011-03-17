Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:55125 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab1CQB3U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 21:29:20 -0400
From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] nfs-utils: Add support to svcgssd to limit the negotiated
	enctypes
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 16 Mar 2011 21:29:19 -0400
Message-ID: <20110317012919.7982.12281.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Recent versions of Kerberos libraries negotiate and use
an "acceptor subkey".  This negotiation does not consider
that a service may have limited the encryption keys in its
keytab.  A patch (http://src.mit.edu/fisheye/changelog/krb5/?cs=24603)
has been added to the MIT Kerberos code to allow an application
to indicate that it wants to limit the encryption types negotiated.
(This functionality has been available on the client/initiator
side for a while.  The new patch adds this support to the
server/acceptor side.)

This patch adds support to read a recently added nfsd
proc file to determine the encryption types supported by
the kernel and calls the function to limit encryption
types negotiated for the acceptor subkey.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/Makefile.am    |    2 
 utils/gssd/gss_util.c     |   25 +++---
 utils/gssd/krb5_util.h    |    1 
 utils/gssd/svcgssd.c      |    7 ++
 utils/gssd/svcgssd_krb5.c |  200 +++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/svcgssd_krb5.h |   36 ++++++++
 utils/gssd/svcgssd_proc.c |    5 +
 7 files changed, 266 insertions(+), 10 deletions(-)
 create mode 100644 utils/gssd/svcgssd_krb5.c
 create mode 100644 utils/gssd/svcgssd_krb5.h

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 95a2bd0..d7888ad 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -51,7 +51,9 @@ svcgssd_SOURCES = \
 	svcgssd_main_loop.c \
 	svcgssd_mech2file.c \
 	svcgssd_proc.c \
+	svcgssd_krb5.c \
 	\
+	svcgssd_krb5.h \
 	svcgssd.h
 
 svcgssd_LDADD = \
diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 8fe1e9b..46d48a5 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -199,20 +199,25 @@ gssd_acquire_cred(char *server_name, const gss_OID oid)
 	u_int32_t ignore_maj_stat, ignore_min_stat;
 	gss_buffer_desc pbuf;
 
-	name.value = (void *)server_name;
-	name.length = strlen(server_name);
+	/* If server_name is NULL, get cred for GSS_C_NO_NAME */
+	if (server_name == NULL) {
+		target_name = GSS_C_NO_NAME;
+	} else {
+		name.value = (void *)server_name;
+		name.length = strlen(server_name);
 
-	maj_stat = gss_import_name(&min_stat, &name,
-			oid,
-			&target_name);
+		maj_stat = gss_import_name(&min_stat, &name,
+				oid,
+				&target_name);
 
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_import_name", maj_stat, min_stat, g_mechOid);
-		return (FALSE);
+		if (maj_stat != GSS_S_COMPLETE) {
+			pgsserr("gss_import_name", maj_stat, min_stat, g_mechOid);
+			return (FALSE);
+		}
 	}
 
-	maj_stat = gss_acquire_cred(&min_stat, target_name, 0,
-			GSS_C_NULL_OID_SET, GSS_C_ACCEPT,
+	maj_stat = gss_acquire_cred(&min_stat, target_name, GSS_C_INDEFINITE,
+			GSS_C_NO_OID_SET, GSS_C_ACCEPT,
 			&gssd_creds, NULL, NULL);
 
 	if (maj_stat != GSS_S_COMPLETE) {
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index b42b91e..0d6019c 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -37,6 +37,7 @@ void gssd_k5_get_default_realm(char **def_realm);
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 int limit_krb5_enctypes(struct rpc_gss_sec *sec);
+int limit_svcgssd_krb5_enctypes();
 #endif
 
 /*
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 9b463f3..89d4cf0 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -262,6 +262,13 @@ main(int argc, char *argv[])
 				"/etc/krb5.keytab?\n");
 			exit(1);
 		}
+	} else {
+		status = gssd_acquire_cred(NULL,
+			(const gss_OID)GSS_C_NT_HOSTBASED_SERVICE);
+		if (status == FALSE) {
+			printerr(0, "unable to obtain nameless credentials\n");
+			exit(1);
+		}
 	}
 
 	if (!fg)
diff --git a/utils/gssd/svcgssd_krb5.c b/utils/gssd/svcgssd_krb5.c
new file mode 100644
index 0000000..fc67a6f
--- /dev/null
+++ b/utils/gssd/svcgssd_krb5.c
@@ -0,0 +1,200 @@
+/*
+ * COPYRIGHT (c) 2011
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+
+#include <stdio.h>
+#include <errno.h>
+#include <gssapi/gssapi.h>
+#include <krb5.h>
+
+#include "gss_util.h"
+#include "gss_oids.h"
+#include "err_util.h"
+#include "svcgssd_krb5.h"
+
+#define MYBUFLEN 1024
+
+char *supported_enctypes_filename = "/proc/fs/nfsd/supported_krb5_enctypes";
+int parsed_num_enctypes = 0;
+krb5_enctype *parsed_enctypes = NULL;
+char *cached_enctypes = NULL;
+
+/*==========================*/
+/*===  Internal routines ===*/
+/*==========================*/
+
+/*
+ * Parse the supported encryption type information
+ */
+static int
+parse_enctypes(char *enctypes)
+{
+	int n = 0;
+	char *curr, *comma;
+	int i;
+
+	/* Don't parse the same string over and over... */
+	if (cached_enctypes && strcmp(cached_enctypes, enctypes) == 0)
+		return 0;
+
+	/* Free any existing cached_enctypes */
+	free(cached_enctypes);
+
+	if (parsed_enctypes != NULL) {
+		free(parsed_enctypes);
+		parsed_enctypes = NULL;
+		parsed_num_enctypes = 0;
+	}
+
+	/* count the number of commas */
+	for (curr = enctypes; curr && *curr != '\0'; curr = ++comma) {
+		comma = strchr(curr, ',');
+		if (comma != NULL)
+			n++;
+		else
+			break;
+	}
+
+	/* If no more commas and we're not at the end, there's one more value */
+	if (*curr != '\0')
+		n++;
+
+	/* Empty string, return an error */
+	if (n == 0)
+		return ENOENT;
+
+	/* Allocate space for enctypes array */
+	if ((parsed_enctypes = (int *) calloc(n, sizeof(int))) == NULL) {
+		return ENOMEM;
+	}
+
+	/* Now parse each value into the array */
+	for (curr = enctypes, i = 0; curr && *curr != '\0'; curr = ++comma) {
+		parsed_enctypes[i++] = atoi(curr);
+		comma = strchr(curr, ',');
+		if (comma == NULL)
+			break;
+	}
+
+	parsed_num_enctypes = n;
+	if ((cached_enctypes = malloc(strlen(enctypes)+1)))
+		strcpy(cached_enctypes, enctypes);
+
+	return 0;
+}
+
+static void
+get_kernel_supported_enctypes(void)
+{
+	FILE *s_e;
+	int ret;
+	char buffer[MYBUFLEN + 1];
+
+	memset(buffer, '\0', sizeof(buffer));
+
+	s_e = fopen(supported_enctypes_filename, "r");
+	if (s_e == NULL)
+		goto out_clean_parsed;
+
+	ret = fread(buffer, 1, MYBUFLEN, s_e);
+	if (ret < 0) {
+		fclose(s_e);
+		goto out_clean_parsed;
+	}
+	fclose(s_e);
+	if (parse_enctypes(buffer)) {
+		goto out_clean_parsed;
+	}
+out:
+	return;
+
+out_clean_parsed:
+	if (parsed_enctypes != NULL) {
+		free(parsed_enctypes);
+		parsed_num_enctypes = 0;
+	}
+	goto out;
+}
+
+/*==========================*/
+/*===  External routines ===*/
+/*==========================*/
+
+/*
+ * Get encryption types supported by the kernel, and then
+ * call gss_krb5_set_allowable_enctypes() to limit the
+ * encryption types negotiated.
+ *
+ * Returns:
+ *	0 => all went well
+ *     -1 => there was an error
+ */
+
+int
+svcgssd_limit_krb5_enctypes(void)
+{
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+	u_int maj_stat, min_stat;
+	krb5_enctype default_enctypes[] = { ENCTYPE_DES_CBC_CRC,
+					    ENCTYPE_DES_CBC_MD5,
+					    ENCTYPE_DES_CBC_MD4 };
+	int default_num_enctypes =
+		sizeof(default_enctypes) / sizeof(default_enctypes[0]);
+	krb5_enctype *enctypes;
+	int num_enctypes;
+
+	get_kernel_supported_enctypes();
+
+	if (parsed_enctypes != NULL) {
+		enctypes = parsed_enctypes;
+		num_enctypes = parsed_num_enctypes;
+	} else {
+		enctypes = default_enctypes;
+		num_enctypes = default_num_enctypes;
+	}
+
+	maj_stat = gss_set_allowable_enctypes(&min_stat, gssd_creds,
+			&krb5oid, num_enctypes, enctypes);
+	if (maj_stat != GSS_S_COMPLETE) {
+		printerr(1, "WARNING: gss_set_allowable_enctypes failed\n");
+		pgsserr("svcgssd_limit_krb5_enctypes: gss_set_allowable_enctypes",
+			maj_stat, min_stat, &krb5oid);
+		return -1;
+	}
+#endif
+	return 0;
+}
diff --git a/utils/gssd/svcgssd_krb5.h b/utils/gssd/svcgssd_krb5.h
new file mode 100644
index 0000000..07d5eb9
--- /dev/null
+++ b/utils/gssd/svcgssd_krb5.h
@@ -0,0 +1,36 @@
+/*
+ * COPYRIGHT (c) 2011
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+#ifndef SVCGSSD_KRB5_H
+#define SVCGSSD_KRB5_H
+
+int svcgssd_limit_krb5_enctypes(void);
+
+#endif /* SVCGSSD_KRB5_H */
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 3894078..65c472d 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -57,6 +57,7 @@
 #include "err_util.h"
 #include "context.h"
 #include "gss_oids.h"
+#include "svcgssd_krb5.h"
 
 extern char * mech2file(gss_OID mech);
 #define SVCGSSD_CONTEXT_CHANNEL "/proc/net/rpc/auth.rpcsec.context/channel"
@@ -443,6 +444,10 @@ handle_nullreq(FILE *f) {
 		memcpy(&ctx, in_handle.value, in_handle.length);
 	}
 
+	if (svcgssd_limit_krb5_enctypes()) {
+		goto out_err;
+	}
+
 	maj_stat = gss_accept_sec_context(&min_stat, &ctx, gssd_creds,
 			&in_tok, GSS_C_NO_CHANNEL_BINDINGS, &client_name,
 			&mech, &out_tok, &ret_flags, NULL, NULL);

