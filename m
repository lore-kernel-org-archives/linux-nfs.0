Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57117 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751446AbdK0MYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 07:24:32 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B10ED3AAD2
        for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2017 12:24:32 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.79])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 1740A600D5
        for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2017 12:24:31 +0000 (UTC)
Message-ID: <1511785470.3751.6.camel@redhat.com>
Subject: [PATCH] nfs-utils: Tidy up libnfsidmap exported symbols list and API
From: Justin Mitchell <jumitche@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 27 Nov 2017 12:24:30 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prior to its merger with nfs-utils the libnfsidmap library leaked
a lot of internal functions and variables that were not defined
in its API, some of which were used by its various plugins.
This created an accidentally large ABI which restricts attempts to
clean up the code base.

These patches aim to trim the ABI down, whilst adding to the API
only the minimal required to still support both bundled and 3rd
party plugins.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
This adds nfsidmap_plugin.h which packagers will want to pick up,
this can be included by 3rd party plugins to replace copies of 
nfsidmap_internal.h and cfg.h taken from the libnfsidmap source.

Patches for sssd and libnfsidmap-regex available separately which 
are the only 3rd party plugins i have found.

 configure.ac                         |  2 +
 support/nfs/Makefile.am              |  4 +-
 support/nfs/conffile.c               | 20 +++------
 support/nfsidmap/Makefile.am         | 12 +++---
 support/nfsidmap/gums.c              |  5 +--
 support/nfsidmap/libnfsidmap.c       | 67 +++++++++++++-----------------
 support/nfsidmap/nfsidmap_common.c   | 33 +++++++++++++++
 support/nfsidmap/nfsidmap_internal.h | 79 ------------------------------------
 support/nfsidmap/nfsidmap_plugin.h   | 68 +++++++++++++++++++++++++++++++
 support/nfsidmap/nfsidmap_private.h  | 55 +++++++++++++++++++++++++
 support/nfsidmap/nss.c               | 13 +++++-
 support/nfsidmap/static.c            |  2 +-
 support/nfsidmap/umich_ldap.c        |  3 +-
 13 files changed, 217 insertions(+), 146 deletions(-)
 create mode 100644 support/nfsidmap/nfsidmap_common.c
 delete mode 100644 support/nfsidmap/nfsidmap_internal.h
 create mode 100644 support/nfsidmap/nfsidmap_plugin.h
 create mode 100644 support/nfsidmap/nfsidmap_private.h

diff --git a/configure.ac b/configure.ac
index c7651f2..a09c1df 100644
--- a/configure.ac
+++ b/configure.ac
@@ -442,6 +442,8 @@ fi
 AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
 
 AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS -I../../support/nfsidmap")
+AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
+          [Bundled lib always has the `nfs4_set_debug' function.])
 
 dnl Check for IPv6 support
 AC_IPV6
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index e573b69..67e3a8e 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -7,10 +7,10 @@ libnfs_la_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xcommon.c wildmat.c mydaemon.c \
 		   rpc_socket.c getport.c \
 		   svc_socket.c cacheio.c closeall.c nfs_mntent.c \
-		   svc_create.c atomicio.c strlcat.c
+		   svc_create.c atomicio.c strlcat.c strlcpy.c
 libnfs_la_LIBADD = libnfsconf.la
 
-libnfsconf_la_SOURCES = conffile.c xlog.c strlcpy.c
+libnfsconf_la_SOURCES = conffile.c xlog.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index dce8148..29f132d 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -53,9 +53,11 @@
 #include "conffile.h"
 #include "xlog.h"
 
+#pragma GCC visibility push(hidden)
+
 static void conf_load_defaults(void);
 static char * conf_readfile(const char *path);
-int conf_set(int , const char *, const char *, const char *, 
+static int conf_set(int , const char *, const char *, const char *, 
 	const char *, int , int );
 static void conf_parse(int trans, char *buf, 
 	char **section, char **subsection);
@@ -77,10 +79,8 @@ TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
 /*
  * Radix-64 Encoding.
  */
-const uint8_t bin2asc[]
-  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
 
-const uint8_t asc2bin[] =
+static const uint8_t asc2bin[] =
 {
   255, 255, 255, 255, 255, 255, 255, 255,
   255, 255, 255, 255, 255, 255, 255, 255,
@@ -489,10 +489,6 @@ static void conf_free_bindings(void)
 	}
 }
 
-#pragma GCC visibility push(hidden)
-/* these are the real fuinctions, hidden from being exported
- * by libnfsidmap ABI compatability */
-
 /* Open the config file and map it into our address space, then parse it.  */
 static void
 conf_load_file(const char *conf_file)
@@ -560,8 +556,6 @@ conf_cleanup(void)
 	TAILQ_INIT(&conf_trans_queue);
 }
 
-#pragma GCC visibility pop
-
 /*
  * Return the numeric value denoted by TAG in section SECTION or DEF
  * if that tag does not exist.
@@ -577,7 +571,6 @@ conf_get_num(const char *section, const char *tag, int def)
 	return def;
 }
 
-#pragma GCC visibility push(hidden)
 /*
  * Return the Boolean value denoted by TAG in section SECTION, or DEF
  * if that tags does not exist.
@@ -609,7 +602,6 @@ conf_get_bool(const char *section, const char *tag, _Bool def)
 		return false;
 	return def;
 }
-#pragma GCC visibility pop
 
 /* Validate X according to the range denoted by TAG in section SECTION.  */
 int
@@ -655,7 +647,6 @@ conf_get_str_with_def(const char *section, const char *tag, char *def)
 	return result;
 }
 
-#pragma GCC visibility push(hidden)
 /*
  * Find a section that may or may not have an argument
  */
@@ -687,7 +678,6 @@ retry:
 	}
 	return 0;
 }
-#pragma GCC visibility pop
 
 /*
  * Build a list of string values out of the comma separated value denoted by
@@ -882,7 +872,7 @@ conf_trans_node(int transaction, enum conf_op op)
 }
 
 /* Queue a set operation.  */
-int
+static int
 conf_set(int transaction, const char *section, const char *arg,
 	const char *tag, const char *value, int override, int is_default)
 {
diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index 32eb8cf..9466f92 100644
--- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -25,26 +25,28 @@ pkgplugin_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_L
 #  <age> 	The number of previous additional interfaces supported
 #  		by this library.
 
-libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_internal.h
-libnfsidmap_la_LDFLAGS = -version-info 3:0:3
+libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_internal.h nfsidmap_common.c
+libnfsidmap_la_LDFLAGS = -version-info 1:0:0
 libnfsidmap_la_LIBADD = -ldl ../../support/nfs/libnfsconf.la
 
-nsswitch_la_SOURCES = nss.c
+nsswitch_la_SOURCES = nss.c nfsidmap_common.c
 nsswitch_la_LDFLAGS = -module -avoid-version
+nsswitch_la_LIBADD = ../../support/nfs/libnfsconf.la
 
 static_la_SOURCES = static.c
 static_la_LDFLAGS = -module -avoid-version
+static_la_LIBADD = ../../support/nfs/libnfsconf.la
 
 umich_ldap_la_SOURCES = umich_ldap.c
 umich_ldap_la_LDFLAGS = -module -avoid-version
-umich_ldap_la_LIBADD = -lldap
+umich_ldap_la_LIBADD = -lldap ../../support/nfs/libnfsconf.la
 
 gums_la_SOURCES = gums.c
 gums_la_LDFLAGS = -module -avoid-version
 
 man3_MANS = nfs4_uid_to_name.3
 man5_MANS	= idmapd.conf.5
-include_HEADERS = nfsidmap.h
+include_HEADERS = nfsidmap.h nfsidmap_plugin.h
 
 EXTRA_DIST = $(man3_MANS) \
 	     $(man5_MANS) \
diff --git a/support/nfsidmap/gums.c b/support/nfsidmap/gums.c
index 2b12d95..1d6eb31 100644
--- a/support/nfsidmap/gums.c
+++ b/support/nfsidmap/gums.c
@@ -42,8 +42,7 @@
 #include <err.h>
 #include <syslog.h>
 #include "nfsidmap.h"
-#include "nfsidmap_internal.h"
-#include "cfg.h"
+#include "nfsidmap_plugin.h"
 
 #include <voms_apic.h>
 
@@ -232,7 +231,7 @@ static int gums_init(void)
 	char buf[512], type[128], value[256];
 	char *alt_conf = NULL;
 
-	alt_conf = conf_get_str("GUMS", "Conf_File");
+	alt_conf = nfsidmap_config_get("GUMS", "Conf_File");
 	if (alt_conf == NULL)
 		f = fopen(prima_conf, "r");
 	else
diff --git a/support/nfsidmap/libnfsidmap.c b/support/nfsidmap/libnfsidmap.c
index 40011ee..3b44da6 100644
--- a/support/nfsidmap/libnfsidmap.c
+++ b/support/nfsidmap/libnfsidmap.c
@@ -58,14 +58,13 @@
 #include <arpa/nameser_compat.h>
 
 #include "nfsidmap.h"
-#include "nfsidmap_internal.h"
+#include "nfsidmap_private.h"
+#include "nfsidmap_plugin.h"
 #include "conffile.h"
 
+#pragma GCC visibility push(hidden)
+
 static char *default_domain;
-static struct conf_list *local_realms;
-int idmap_verbosity = 0;
-int no_strip = 0;
-int reformat_group = 0;
 static struct mapping_plugin **nfs4_plugins = NULL;
 static struct mapping_plugin **gss_plugins = NULL;
 uid_t nobody_uid = (uid_t)-1;
@@ -89,11 +88,6 @@ gid_t nobody_gid = (gid_t)-1;
 #define NFS4DNSTXTREC "_nfsv4idmapdomain"
 #endif
 
-/* DEPRECATED these are for ABI compatibility only */
-char * conf_path = PATH_IDMAPDCONF;
-void conf_reinit(void);
-void conf_init(void);
-
 /* Default logging fuction */
 static void default_logger(const char *fmt, ...)
 {
@@ -103,7 +97,11 @@ static void default_logger(const char *fmt, ...)
 	vsyslog(LOG_WARNING, fmt, vp);
 	va_end(vp);
 }
+
+#pragma GCC visibility pop
 nfs4_idmap_log_function_t idmap_log_func = default_logger;
+int idmap_verbosity = 2;
+#pragma GCC visibility push(hidden)
 
 static char * toupper_str(char *s)
 {
@@ -329,6 +327,21 @@ out:
 	return ret;
 }
 
+char * get_default_domain(void)
+{
+	int ret;
+
+	if (default_domain)
+		return default_domain;
+	ret = domain_from_dns(&default_domain);
+	if (ret) {
+		IDMAP_LOG(0, ("Unable to determine a default nfsv4 domain; "
+			" consider specifying one in idmapd.conf"));
+		default_domain = "";
+	}
+	return default_domain;
+}
+
 void nfs4_cleanup_name_mapping(void)
 {
 	if (nfs4_plugins)
@@ -338,6 +351,8 @@ void nfs4_cleanup_name_mapping(void)
 	nfs4_plugins = gss_plugins = NULL;
 }
 
+#pragma GCC visibility pop
+
 int nfs4_init_name_mapping(char *conffile)
 {
 	int ret = -ENOENT;
@@ -346,6 +361,7 @@ int nfs4_init_name_mapping(char *conffile)
 	char *nobody_user, *nobody_group;
 	char *nostrip;
 	char *reformatgroup;
+	char *conf_path;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
@@ -518,26 +534,6 @@ out:
 	return ret ? -ENOENT: 0;
 }
 
-char * get_default_domain(void)
-{
-	int ret;
-
-	if (default_domain)
-		return default_domain;
-	ret = domain_from_dns(&default_domain);
-	if (ret) {
-		IDMAP_LOG(0, ("Unable to determine a default nfsv4 domain; "
-			" consider specifying one in idmapd.conf"));
-		default_domain = "";
-	}
-	return default_domain;
-}
-
-struct conf_list *get_local_realms(void)
-{
-	return local_realms;
-}
-
 int
 nfs4_get_default_domain(char *UNUSED(server), char *domain, size_t len)
 {
@@ -711,15 +707,10 @@ void nfs4_set_debug(int dbg_level, void (*logger)(const char *, ...))
 	if (logger)
 		idmap_log_func = logger;
 	idmap_verbosity = dbg_level;
+	IDMAP_LOG(0, ("Setting log level to %d\n", idmap_verbosity));
 }
 
-void conf_reinit(void)
-{
-	conf_init_file(conf_path);
-}
-
-void conf_init(void)
+const char *nfsidmap_config_get(const char *section, const char *tag)
 {
-	conf_init_file(conf_path);
+	return conf_get_section(section, NULL, tag);
 }
-
diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap_common.c
new file mode 100644
index 0000000..891c855
--- /dev/null
+++ b/support/nfsidmap/nfsidmap_common.c
@@ -0,0 +1,33 @@
+/*
+ *  nfsidmap_common.c
+ *
+ *  nfs idmapping library, primarily for nfs4 client/server kernel idmapping
+ *  and for userland nfs4 idmapping by acl libraries.
+ *
+ *  Code common to libnfsidmap and some of its bundled plugins
+ *
+ */
+
+#include "config.h"
+
+#include <sys/types.h>
+#include <unistd.h>
+#include <stdlib.h>
+
+#include "nfsidmap.h"
+#include "nfsidmap_private.h"
+#include "nfsidmap_plugin.h"
+#include "conffile.h"
+
+#pragma GCC visibility push(hidden)
+
+int reformat_group = 0;
+int no_strip = 0;
+
+struct conf_list *local_realms;
+
+struct conf_list *get_local_realms(void)
+{
+	return local_realms;
+}
+
diff --git a/support/nfsidmap/nfsidmap_internal.h b/support/nfsidmap/nfsidmap_internal.h
deleted file mode 100644
index a327862..0000000
--- a/support/nfsidmap/nfsidmap_internal.h
+++ /dev/null
@@ -1,79 +0,0 @@
-/*
- *  nfsidmap_internal.h
- *
- *  nfs idmapping library, primarily for nfs4 client/server kernel idmapping
- *  and for userland nfs4 idmapping by acl libraries.
- *
- *  Copyright (c) 2004 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson <andros@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-char *get_default_domain(void);
-struct conf_list *get_local_realms(void);
-
-typedef struct trans_func * (*libnfsidmap_plugin_init_t)(void);
-
-struct trans_func {
-	char *name;
-	int (*init)(void);
-	int (*princ_to_ids)(char *secname, char *princ, uid_t *uid, gid_t *gid, 
-		extra_mapping_params **ex);
-	int (*name_to_uid)(char *name, uid_t *uid);
-	int (*name_to_gid)(char *name, gid_t *gid);
-	int (*uid_to_name)(uid_t uid, char *domain, char *name, size_t len);
-	int (*gid_to_name)(gid_t gid, char *domain, char *name, size_t len);
-	int (*gss_princ_to_grouplist)(char *secname, char *princ, gid_t *groups,
-		int *ngroups, extra_mapping_params **ex);
-};
-
-struct mapping_plugin {
-	void *dl_handle;
-	struct trans_func *trans;
-};
-
-typedef enum {
-	IDTYPE_USER = 1,
-	IDTYPE_GROUP = 2
-} idtypes;
-
-extern int no_strip;
-extern int reformat_group;
-extern int idmap_verbosity;
-extern nfs4_idmap_log_function_t idmap_log_func;
-/* Level zero always prints, others print depending on verbosity level */
-#define IDMAP_LOG(LVL, MSG) \
-	do { if (LVL <= idmap_verbosity) (*idmap_log_func)MSG; } while (0)
-
-#ifdef __GNUC__
-#define UNUSED(foo) UNUSED_ ## foo __attribute__((__unused__))
-#else
-#define UNUSED(foo) UNUSED_ ## foo
-#endif
-
diff --git a/support/nfsidmap/nfsidmap_plugin.h b/support/nfsidmap/nfsidmap_plugin.h
new file mode 100644
index 0000000..e19efe5
--- /dev/null
+++ b/support/nfsidmap/nfsidmap_plugin.h
@@ -0,0 +1,68 @@
+/*
+ *  nfsidmap_plugin.h
+ *
+ *  Essentials functions and structs required when building
+ *  plugins for libnfsidmap that are otherwise not exposed
+ *  in the public API
+ *
+ *  Copyright (c) 2004 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+struct trans_func {
+	char *name;
+	int (*init)(void);
+	int (*princ_to_ids)(char *secname, char *princ, uid_t *uid, gid_t *gid, 
+		extra_mapping_params **ex);
+	int (*name_to_uid)(char *name, uid_t *uid);
+	int (*name_to_gid)(char *name, gid_t *gid);
+	int (*uid_to_name)(uid_t uid, char *domain, char *name, size_t len);
+	int (*gid_to_name)(gid_t gid, char *domain, char *name, size_t len);
+	int (*gss_princ_to_grouplist)(char *secname, char *princ, gid_t *groups,
+		int *ngroups, extra_mapping_params **ex);
+};
+
+extern int idmap_verbosity;
+extern nfs4_idmap_log_function_t idmap_log_func;
+
+/* Level zero always prints, others print depending on verbosity level */
+#define IDMAP_LOG(LVL, MSG) \
+	do { if (LVL <= idmap_verbosity) (*idmap_log_func)MSG; } while (0)
+
+#ifndef UNUSED
+#ifdef __GNUC__
+#define UNUSED(foo) UNUSED_ ## foo __attribute__((__unused__))
+#else
+#define UNUSED(foo) UNUSED_ ## foo
+#endif
+#endif
+
+extern const char *nfsidmap_config_get(const char *section, const char *tag);
+
diff --git a/support/nfsidmap/nfsidmap_private.h b/support/nfsidmap/nfsidmap_private.h
new file mode 100644
index 0000000..2cc309e
--- /dev/null
+++ b/support/nfsidmap/nfsidmap_private.h
@@ -0,0 +1,55 @@
+/*
+ *  nfsidmap_private.h
+ *
+ *  For use only by bundled plugins, not for external use
+ *
+ *  Copyright (c) 2004 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "conffile.h"
+
+struct conf_list *get_local_realms(void);
+
+typedef enum {
+	IDTYPE_USER = 1,
+	IDTYPE_GROUP = 2
+} idtypes;
+
+extern int no_strip;
+extern int reformat_group;
+extern struct conf_list *local_realms;
+
+typedef struct trans_func * (*libnfsidmap_plugin_init_t)(void);
+
+struct mapping_plugin {
+	void *dl_handle;
+	struct trans_func *trans;
+};
diff --git a/support/nfsidmap/nss.c b/support/nfsidmap/nss.c
index a86d768..6f024dc 100644
--- a/support/nfsidmap/nss.c
+++ b/support/nfsidmap/nss.c
@@ -47,10 +47,19 @@
 #include <limits.h>
 #include <ctype.h>
 #include "nfsidmap.h"
-#include "nfsidmap_internal.h"
-#include "conffile.h"
+#include "nfsidmap_plugin.h"
+#include "nfsidmap_private.h"
 #include <syslog.h>
 
+static char *get_default_domain(void)
+{
+	static char default_domain[NFS4_MAX_DOMAIN_LEN] = "";
+	if (default_domain[0] == 0) {
+		nfs4_get_default_domain(NULL, default_domain, NFS4_MAX_DOMAIN_LEN);
+	}
+	return default_domain;
+}
+
 /*
  * NSS Translation Methods
  *
diff --git a/support/nfsidmap/static.c b/support/nfsidmap/static.c
index c82d7f3..0b1173f 100644
--- a/support/nfsidmap/static.c
+++ b/support/nfsidmap/static.c
@@ -43,7 +43,7 @@
 
 #include "conffile.h"
 #include "nfsidmap.h"
-#include "nfsidmap_internal.h"
+#include "nfsidmap_plugin.h"
 
 /*
  * Static Translation Methods
diff --git a/support/nfsidmap/umich_ldap.c b/support/nfsidmap/umich_ldap.c
index 2258aa8..e82828c 100644
--- a/support/nfsidmap/umich_ldap.c
+++ b/support/nfsidmap/umich_ldap.c
@@ -47,7 +47,8 @@
 #define LDAP_DEPRECATED 1
 #include <ldap.h>
 #include "nfsidmap.h"
-#include "nfsidmap_internal.h"
+#include "nfsidmap_plugin.h"
+#include "nfsidmap_private.h"
 #include "conffile.h"
 
 /* attribute/objectclass default mappings */
-- 
1.8.3.1



