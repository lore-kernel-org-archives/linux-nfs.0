Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:65160 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2ADT5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:57:18 -0500
Received: by mail-vw0-f46.google.com with SMTP id fc26so13670466vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:57:18 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] mountd: Support junction management plug-ins
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:57:16 -0500
Message-ID: <20120104195716.21904.62916.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support FedFS and NFS junctions without introducing additional
build-time or run-time dependencies on nfs-utils, the community has
chosen to use a dynamically loadable library to handle junction
resolution.

There is one plug-in library for mountd that will handle any NFS-
related junction type.  Currently there are two types:

  o nfs-basic	locally stored file set location data, and

  o nfs-fedfs	file set location data stored on an LDAP server

mountd's support for this library is enabled at build time by the
presence of the junction API definition header:

  /usr/include/nfs-plugin.h

If this header is not found on the build system, mountd will build
without junction support, and will operate as before.

Note that mountd does not cache junction resolution results.  NFSD
already caches these results in its exports cache.  Thus each time
NFSD calls up to mountd, it is, in essence, requesting a fresh
junction resolution operation, not a cached response.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac             |    5 +
 utils/mountd/Makefile.am |    2 
 utils/mountd/cache.c     |  225 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 229 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index d3656bf..920e8da 100644
--- a/configure.ac
+++ b/configure.ac
@@ -248,6 +248,8 @@ AC_CHECK_FUNC([getservbyname], ,
 
 AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
 
+AC_CHECK_LIB([dl], [dlclose], [LIBDL="-ldl"])
+
 if test "$enable_nfsv4" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
@@ -298,6 +300,7 @@ AC_SUBST(LIBSOCKET)
 AC_SUBST(LIBCRYPT)
 AC_SUBST(LIBBSD)
 AC_SUBST(LIBBLKID)
+AC_SUBST(LIBDL)
 
 if test "$enable_libmount" != no; then
    AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
@@ -335,7 +338,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
                  stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
                  sys/param.h sys/socket.h sys/time.h sys/vfs.h \
                  syslog.h unistd.h com_err.h et/com_err.h \
-                 ifaddrs.h])
+                 ifaddrs.h nfs-plugin.h])
 
 dnl *************************************************************
 dnl Checks for typedefs, structures, and compiler characteristics
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index eba81fc..5a2d1b6 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -12,7 +12,7 @@ mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.a \
 	       ../../support/misc/libmisc.a \
-	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID)
+	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		  -I$(top_builddir)/support/include \
 		  -I$(top_srcdir)/support/export
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d2ae456..d4f04ab 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -802,6 +802,229 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 	return found;
 }
 
+#ifdef HAVE_NFS_PLUGIN_H
+#include <dlfcn.h>
+#include <nfs-plugin.h>
+
+/*
+ * Walk through a set of FS locations and build a set of export options.
+ * Returns true if all went to plan; otherwise, false.
+ */
+static _Bool
+locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
+		char *options, size_t remaining, int *ttl)
+{
+	char *server, *last_path, *rootpath, *ptr;
+	_Bool seen = false;
+
+	last_path = NULL;
+	rootpath = NULL;
+	server = NULL;
+	ptr = options;
+	*ttl = 0;
+
+	for (;;) {
+		enum jp_status status;
+		int len;
+
+		status = ops->jp_get_next_location(locations, &server,
+							&rootpath, ttl);
+		if (status == JP_EMPTY)
+			break;
+		if (status != JP_OK) {
+			xlog(D_GENERAL, "%s: failed to parse location: %s",
+				__func__, ops->jp_error(status));
+			goto out_false;
+		}
+		xlog(D_GENERAL, "%s: Location: %s:%s",
+			__func__, server, rootpath);
+
+		if (last_path && strcmp(rootpath, last_path) == 0) {
+			len = snprintf(ptr, remaining, "+%s", server);
+			if (len < 0) {
+				xlog(D_GENERAL, "%s: snprintf: %m", __func__);
+				goto out_false;
+			}
+			if ((size_t)len > remaining) {
+				xlog(D_GENERAL, "%s: options buffer overflow", __func__);
+				goto out_false;
+			}
+			remaining -= (size_t)len;
+			ptr += len;
+		} else {
+			if (last_path == NULL)
+				len = snprintf(ptr, remaining, "refer=%s@%s",
+							rootpath, server);
+			else
+				len = snprintf(ptr, remaining, ":%s@%s",
+							rootpath, server);
+			if (len < 0) {
+				xlog(D_GENERAL, "%s: snprintf: %m", __func__);
+				goto out_false;
+			}
+			if ((size_t)len > remaining) {
+				xlog(D_GENERAL, "%s: options buffer overflow",
+					__func__);
+				goto out_false;
+			}
+			remaining -= (size_t)len;
+			ptr += len;
+			last_path = rootpath;
+		}
+
+		seen = true;
+		free(rootpath);
+		free(server);
+	}
+
+	xlog(D_CALL, "%s: options='%s', ttl=%d",
+		__func__, options, *ttl);
+	return seen;
+
+out_false:
+	free(rootpath);
+	free(server);
+	return false;
+}
+
+/*
+ * Walk through the set of FS locations and build an exportent.
+ * Returns pointer to an exportent if "junction" refers to a junction.
+ *
+ * Returned exportent points to static memory.
+ */
+static struct exportent *do_locations_to_export(struct jp_ops *ops,
+		nfs_fsloc_set_t locations, const char *junction,
+		char *options, size_t options_len)
+{
+	struct exportent *exp;
+	int ttl;
+
+	if (!locations_to_options(ops, locations, options, options_len, &ttl))
+		return NULL;
+
+	exp = mkexportent("*", (char *)junction, options);
+	if (exp == NULL) {
+		xlog(L_ERROR, "%s: Failed to construct exportent", __func__);
+		return NULL;
+	}
+
+	exp->e_uuid = NULL;
+	exp->e_ttl = ttl;
+	return exp;
+}
+
+/*
+ * Convert set of FS locations to an exportent.  Returns pointer to
+ * an exportent if "junction" refers to a junction.
+ *
+ * Returned exportent points to static memory.
+ */
+static struct exportent *locations_to_export(struct jp_ops *ops,
+		nfs_fsloc_set_t locations, const char *junction)
+{
+	struct exportent *exp;
+	char *options;
+
+	options = malloc(BUFSIZ);
+	if (options == NULL) {
+		xlog(D_GENERAL, "%s: failed to allocate options buffer",
+			__func__);
+		return NULL;
+	}
+	options[0] = '\0';
+
+	exp = do_locations_to_export(ops, locations, junction,
+						options, BUFSIZ);
+
+	free(options);
+	return exp;
+}
+
+/*
+ * Retrieve locations information in "junction" and dump it to the
+ * kernel.  Returns pointer to an exportent if "junction" refers
+ * to a junction.
+ *
+ * Returned exportent points to static memory.
+ */
+static struct exportent *invoke_junction_ops(void *handle,
+		const char *junction)
+{
+	nfs_fsloc_set_t locations;
+	struct exportent *exp;
+	enum jp_status status;
+	struct jp_ops *ops;
+	char *error;
+
+	ops = (struct jp_ops *)dlsym(handle, "nfs_junction_ops");
+	error = dlerror();
+	if (error != NULL) {
+		xlog(D_GENERAL, "%s: dlsym(jp_junction_ops): %s",
+			__func__, error);
+		return NULL;
+	}
+	if (ops->jp_api_version != JP_API_VERSION) {
+		xlog(D_GENERAL, "%s: unrecognized junction API version: %u",
+			__func__, ops->jp_api_version);
+		return NULL;
+	}
+
+	status = ops->jp_init(false);
+	if (status != JP_OK) {
+		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+			__func__, junction, ops->jp_error(status));
+		return NULL;
+	}
+
+	status = ops->jp_get_locations(junction, &locations);
+	if (status != JP_OK) {
+		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+			__func__, junction, ops->jp_error(status));
+		return NULL;
+	}
+
+	exp = locations_to_export(ops, locations, junction);
+
+	ops->jp_put_locations(locations);
+	ops->jp_done();
+	return exp;
+}
+
+/*
+ * Load the junction plug-in, then try to resolve "pathname".
+ * Returns pointer to an initialized exportent if "junction"
+ * refers to a junction, or NULL if not.
+ *
+ * Returned exportent points to static memory.
+ */
+static struct exportent *lookup_junction(const char *pathname)
+{
+	struct exportent *exp;
+	void *handle;
+
+	handle = dlopen("libnfsjunct.so", RTLD_NOW);
+	if (handle == NULL) {
+		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
+		return NULL;
+	}
+	(void)dlerror();	/* Clear any error */
+
+	exp = invoke_junction_ops(handle, pathname);
+
+	/* We could leave it loaded to make junction resolution
+	 * faster next time.  However, if we want to replace the
+	 * library, that would require restarting mountd. */
+	(void)dlclose(handle);
+	return exp;
+}
+#else	/* !HAVE_NFS_PLUGIN_H */
+static inline struct exportent *lookup_junction(const char *UNUSED(pathname))
+{
+	return NULL;
+}
+#endif	/* !HAVE_NFS_PLUGIN_H */
+
 static void nfsd_export(FILE *f)
 {
 	/* requests are:
@@ -854,7 +1077,7 @@ static void nfsd_export(FILE *f)
 			dump_to_cache(f, dom, path, NULL);
 		}
 	} else {
-		dump_to_cache(f, dom, path, NULL);
+		dump_to_cache(f, dom, path, lookup_junction(path));
 	}
  out:
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);

