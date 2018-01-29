Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:39993 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbeA2X3W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jan 2018 18:29:22 -0500
Received: by mail-it0-f42.google.com with SMTP id 196so11294353iti.5
        for <linux-nfs@vger.kernel.org>; Mon, 29 Jan 2018 15:29:21 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r186sm6595583itb.13.2018.01.29.15.29.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 15:29:20 -0800 (PST)
Subject: [PATCH v4 4/5] mountd: Solder in support for NFS basic junctions
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 29 Jan 2018 18:29:20 -0500
Message-ID: <20180129232920.10141.5558.stgit@manet.1015granger.net>
In-Reply-To: <20180129232527.10141.69789.stgit@manet.1015granger.net>
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch does two things:

1. Reverts ab74900ff59e ("mountd: Support junction management
plug-ins")

2. Re-implements support for NFS basic junctions directly in mountd

So no more support for FedFS junctions, and no more need to have a
dynamically load component installed from another package.

The downside is that mountd has to be linked with libxml2 to get
this support. Thus to make the use of libxml2 optional, built-in
support for junctions is enabled only when --enable-junction is
specified on the command line.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 configure.ac             |    5 -
 utils/mountd/Makefile.am |    8 ++
 utils/mountd/cache.c     |  189 ++++++++++++++++++++++------------------------
 3 files changed, 98 insertions(+), 104 deletions(-)

diff --git a/configure.ac b/configure.ac
index 8e7f036..d2e48a5 100644
--- a/configure.ac
+++ b/configure.ac
@@ -308,8 +308,6 @@ AC_CHECK_FUNC([getservbyname], ,
 
 AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
 
-AC_CHECK_LIB([dl], [dlclose], [LIBDL="-ldl"])
-
 if test "$enable_nfsv4" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
@@ -372,7 +370,6 @@ AC_SUBST(LIBSOCKET)
 AC_SUBST(LIBCRYPT)
 AC_SUBST(LIBBSD)
 AC_SUBST(LIBBLKID)
-AC_SUBST(LIBDL)
 
 if test "$enable_libmount" = yes; then
    AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
@@ -466,7 +463,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
                  stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
                  sys/param.h sys/socket.h sys/time.h sys/vfs.h \
                  syslog.h unistd.h com_err.h et/com_err.h \
-                 ifaddrs.h nfs-plugin.h libio.h])
+                 ifaddrs.h libio.h])
 
 dnl *************************************************************
 dnl Checks for typedefs, structures, and compiler characteristics
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index 153a90a..73eeb3f 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -1,5 +1,10 @@
 ## Process this file with automake to produce Makefile.in
 
+OPTLIBS		=
+if CONFIG_JUNCTION
+OPTLIBS		+= ../../support/junction/libjunction.la $(LIBXML2)
+endif
+
 man8_MANS	= mountd.man
 EXTRA_DIST	= $(man8_MANS)
 
@@ -13,7 +18,8 @@ mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.la \
 	       ../../support/misc/libmisc.a \
-	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL) $(LIBTIRPC)
+	       $(OPTLIBS) \
+	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBTIRPC)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		  -I$(top_builddir)/support/include \
 		  -I$(top_srcdir)/support/export
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index e49300d..6f42512 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -976,10 +976,15 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 	return found;
 }
 
-#ifdef HAVE_NFS_PLUGIN_H
-#include <dlfcn.h>
-#include <link.h>
-#include <nfs-plugin.h>
+#ifdef CONFIG_JUNCTION
+
+#include "junction.h"
+
+struct nfs_fsloc_set {
+	int			 ns_ttl;
+	struct nfs_fsloc	*ns_current;
+	struct nfs_fsloc	*ns_list;
+};
 
 /*
  * Find the export entry for the parent of "pathname".
@@ -1035,13 +1040,39 @@ out_default:
 	return mkexportent("*", "/", "insecure");
 }
 
+static int get_next_location(struct nfs_fsloc_set *locset,
+		char **hostname, char **export_path, int *ttl)
+{
+	char *hostname_tmp, *export_path_tmp;
+	struct nfs_fsloc *fsloc;
+
+	if (locset->ns_current == NULL)
+		return ENOENT;
+	fsloc = locset->ns_current;
+
+	hostname_tmp = strdup(fsloc->nfl_hostname);
+	if (hostname_tmp == NULL)
+		return ENOMEM;
+
+	if (nsdb_path_array_to_posix(fsloc->nfl_rootpath,
+					&export_path_tmp)) {
+		free(hostname_tmp);
+		return EINVAL;
+	}
+
+	*hostname = hostname_tmp;
+	*export_path = export_path_tmp;
+	*ttl = locset->ns_ttl;
+	locset->ns_current = locset->ns_current->nfl_next;
+	return 0;
+}
+
 /*
  * Walk through a set of FS locations and build an e_fslocdata string.
  * Returns true if all went to plan; otherwise, false.
  */
-static bool locations_to_fslocdata(struct jp_ops *ops,
-		nfs_fsloc_set_t locations, char *fslocdata,
-		size_t remaining, int *ttl)
+static bool locations_to_fslocdata(struct nfs_fsloc_set *locations,
+		char *fslocdata, size_t remaining, int *ttl)
 {
 	char *server, *last_path, *rootpath, *ptr;
 	_Bool seen = false;
@@ -1056,13 +1087,13 @@ static bool locations_to_fslocdata(struct jp_ops *ops,
 		enum jp_status status;
 		int len;
 
-		status = ops->jp_get_next_location(locations, &server,
+		status = get_next_location(locations, &server,
 							&rootpath, ttl);
-		if (status == JP_EMPTY)
+		if (status == ENOENT)
 			break;
-		if (status != JP_OK) {
+		if (status) {
 			xlog(D_GENERAL, "%s: failed to parse location: %s",
-				__func__, ops->jp_error(status));
+				__func__, strerror(status));
 			goto out_false;
 		}
 		xlog(D_GENERAL, "%s: Location: %s:%s",
@@ -1159,116 +1190,73 @@ out_nomem:
  * Walk through the set of FS locations and build an exportent.
  * Returns pointer to an exportent if "junction" refers to a junction.
  */
-static struct exportent *locations_to_export(struct jp_ops *ops,
-		nfs_fsloc_set_t locations, const char *junction,
-		struct exportent *parent)
+static struct exportent *locations_to_export(struct nfs_fsloc_set *locations,
+		const char *junction, struct exportent *parent)
 {
 	static char fslocdata[BUFSIZ];
 	int ttl;
 
 	fslocdata[0] = '\0';
-	if (!locations_to_fslocdata(ops, locations,
-					fslocdata, sizeof(fslocdata), &ttl))
+	if (!locations_to_fslocdata(locations, fslocdata, sizeof(fslocdata), &ttl))
 		return NULL;
 	return create_junction_exportent(parent, junction, fslocdata, ttl);
 }
 
-/*
- * Retrieve locations information in "junction" and dump it to the
- * kernel.  Returns pointer to an exportent if "junction" refers
- * to a junction.
- */
-static struct exportent *invoke_junction_ops(void *handle, char *dom,
-		const char *junction, struct addrinfo *ai)
+static int
+nfs_get_basic_junction(const char *junct_path, struct nfs_fsloc_set **locset)
 {
-	struct exportent *parent, *exp = NULL;
-	nfs_fsloc_set_t locations;
-	enum jp_status status;
-	struct jp_ops *ops;
-	char *error;
-
-	ops = (struct jp_ops *)dlsym(handle, "nfs_junction_ops");
-	error = dlerror();
-	if (error != NULL) {
-		xlog(D_GENERAL, "%s: dlsym(jp_junction_ops): %s",
-			__func__, error);
-		return NULL;
-	}
-#ifdef JP_API_VERSION
-	if (ops->jp_api_version != JP_API_VERSION) {
-		xlog(D_GENERAL, "%s: unrecognized junction API version: %u",
-			__func__, ops->jp_api_version);
-		return NULL;
-	}
-#endif
-	status = ops->jp_init(false);
-	if (status != JP_OK) {
-		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
-			__func__, junction, ops->jp_error(status));
-		return NULL;
+	struct nfs_fsloc_set *new;
+	FedFsStatus retval;
+
+	new = calloc(1, sizeof(struct nfs_fsloc_set));
+	if (new == NULL)
+		return ENOMEM;
+
+	retval = nfs_get_locations(junct_path, &new->ns_list);
+	if (retval) {
+		nfs_free_locations(new->ns_list);
+		free(new);
+		return EINVAL;
 	}
 
-	status = ops->jp_get_locations(junction, &locations);
-	switch (status) {
-	case JP_OK:
-		break;
-	case JP_NOTJUNCTION:
+	locset->ns_current = locset->ns_list;
+	new->ns_ttl = 300;
+	*locset = new;
+	return 0;
+}
+
+static struct exportent *lookup_junction(char *dom, const char *pathname,
+		struct addrinfo *ai)
+{
+	struct exportent *parent, *exp = NULL;
+	struct nfs_fsloc_set *locations;
+	int status;
+
+	xmlInitParser();
+
+	if (nfs_is_junction(pathname)) {
 		xlog(D_GENERAL, "%s: %s is not a junction",
-			__func__, junction);
+			__func__, pathname);
 		goto out;
-	default:
+	}
+	status = nfs_get_basic_junction(pathname, &locations);
+	switch (status) {
 		xlog(L_WARNING, "Dangling junction %s: %s",
-			junction, ops->jp_error(status));
+			pathname, strerro(status));
 		goto out;
 	}
 
-	parent = lookup_parent_export(dom, junction, ai);
+	parent = lookup_parent_export(dom, pathname, ai);
 	if (parent == NULL)
 		goto out;
 
-	exp = locations_to_export(ops, locations, junction, parent);
+	exp = locations_to_export(locations, pathname, parent);
 
-	ops->jp_put_locations(locations);
+	nfs_free_locations(locset->ns_list);
+	free(locset);
 
 out:
-	ops->jp_done();
-	return exp;
-}
-
-/*
- * Load the junction plug-in, then try to resolve "pathname".
- * Returns pointer to an initialized exportent if "junction"
- * refers to a junction, or NULL if not.
- */
-static struct exportent *lookup_junction(char *dom, const char *pathname,
-		struct addrinfo *ai)
-{
-	struct exportent *exp;
-	struct link_map *map;
-	void *handle;
-
-#ifdef JP_NFSPLUGIN_SONAME
-	handle = dlopen(JP_NFSPLUGIN_SONAME, RTLD_NOW);
-#else
-	handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
-#endif
-	if (handle == NULL) {
-		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
-		return NULL;
-	}
-
-	if (dlinfo(handle, RTLD_DI_LINKMAP, &map) == 0)
-		xlog(D_GENERAL, "%s: loaded plug-in %s",
-			__func__, map->l_name);
-
-	(void)dlerror();	/* Clear any error */
-
-	exp = invoke_junction_ops(handle, dom, pathname, ai);
-
-	/* We could leave it loaded to make junction resolution
-	 * faster next time.  However, if we want to replace the
-	 * library, that would require restarting mountd. */
-	(void)dlclose(handle);
+	xmlCleanupParser();
 	return exp;
 }
 
@@ -1284,13 +1272,16 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
 	exportent_release(eep);
 	free(eep);
 }
-#else	/* !HAVE_NFS_PLUGIN_H */
+
+#else	/* !CONFIG_JUNCTION */
+
 static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
 		struct addrinfo *UNUSED(ai))
 {
 	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
 }
-#endif	/* !HAVE_NFS_PLUGIN_H */
+
+#endif	/* !CONFIG_JUNCTION */
 
 static void nfsd_export(int f)
 {

