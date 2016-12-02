Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45384 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758116AbcLBBKY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 20:10:24 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 12:09:44 +1100
Subject: [PATCH 3/4] Remove all use of the nfsctl system call.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148064098414.9179.11922660107685819744.stgit@noble>
In-Reply-To: <148064084082.9179.6570593128436337540.stgit@noble>
References: <148064084082.9179.6570593128436337540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This systemcall was deprecated early in the 2.6 series
as it was replaced by an in-kernel cache which was refilled
using an upcall.  All communication to kernel is now through
the nfsd filesystem.

The nfsctl systemcall itself was removed in 3.1.

It is unlikely to have been used for over a decade.

To remove all uses for the nfsctl systemcall, and call code that only
runs when "new_cache" is false.  We now assume "new_cache" is always true.

This allows the removal of several files as well as assorted functions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/export/Makefile.am |    2 -
 support/export/export.c    |   56 ------------------
 support/export/nfsctl.c    |  118 ---------------------------------------
 support/export/rmtab.c     |   98 --------------------------------
 support/export/xtab.c      |   16 -----
 support/include/exportfs.h |    7 --
 support/include/nfs/nfs.h  |  120 ---------------------------------------
 support/include/nfslib.h   |   16 -----
 support/nfs/Makefile.am    |    4 +
 support/nfs/cacheio.c      |   12 ----
 support/nfs/getfh.c        |  134 --------------------------------------------
 support/nfs/nfsclient.c    |   34 -----------
 support/nfs/nfsctl.c       |   32 -----------
 support/nfs/nfsexport.c    |  134 --------------------------------------------
 support/nfs/rmtab.c        |   21 -------
 utils/exportfs/exportfs.c  |   84 +---------------------------
 utils/mountd/auth.c        |   15 +----
 utils/mountd/mountd.c      |   57 ++++---------------
 utils/nfsd/nfsd.c          |    2 -
 utils/nfsd/nfssvc.c        |   26 ++-------
 utils/nfsd/nfssvc.h        |    2 -
 21 files changed, 29 insertions(+), 961 deletions(-)
 delete mode 100644 support/export/nfsctl.c
 delete mode 100644 support/export/rmtab.c
 delete mode 100644 support/nfs/getfh.c
 delete mode 100644 support/nfs/nfsclient.c
 delete mode 100644 support/nfs/nfsctl.c
 delete mode 100644 support/nfs/nfsexport.c

diff --git a/support/export/Makefile.am b/support/export/Makefile.am
index 1ea15397c3a9..be3de6902dd5 100644
--- a/support/export/Makefile.am
+++ b/support/export/Makefile.am
@@ -10,7 +10,7 @@ GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
 EXTRA_DIST	= mount.x
 
 noinst_LIBRARIES = libexport.a
-libexport_a_SOURCES = client.c export.c hostname.c nfsctl.c rmtab.c \
+libexport_a_SOURCES = client.c export.c hostname.c \
 		      xtab.c mount_clnt.c mount_xdr.c
 BUILT_SOURCES 	= $(GENFILES)
 
diff --git a/support/export/export.c b/support/export/export.c
index 15e91cb3eb71..fbe68e84e5b3 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -29,9 +29,6 @@ static void	export_init(nfs_export *exp, nfs_client *clp,
 static void	export_add(nfs_export *exp);
 static int	export_check(const nfs_export *exp, const struct addrinfo *ai,
 				const char *path);
-static nfs_export *
-		export_allowed_internal(const struct addrinfo *ai,
-				const char *path);
 
 void
 exportent_release(struct exportent *eep)
@@ -296,59 +293,6 @@ export_find(const struct addrinfo *ai, const char *path)
 	return NULL;
 }
 
-static nfs_export *
-export_allowed_internal(const struct addrinfo *ai, const char *path)
-{
-	nfs_export	*exp;
-	int		i;
-
-	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
-			if (!exp->m_mayexport ||
-			    !export_check(exp, ai, path))
-				continue;
-			return exp;
-		}
-	}
-
-	return NULL;
-}
-
-/**
- * export_allowed - determine if this export is allowed
- * @ai: pointer to addrinfo for client
- * @path: '\0'-terminated ASCII string containing export path
- *
- * Returns a pointer to nfs_export data matching @ai and @path,
- * or NULL if the export is not allowed.
- */
-nfs_export *
-export_allowed(const struct addrinfo *ai, const char *path)
-{
-	nfs_export		*exp;
-	char			epath[MAXPATHLEN+1];
-	char			*p = NULL;
-
-	if (path [0] != '/') return NULL;
-
-	strncpy(epath, path, sizeof (epath) - 1);
-	epath[sizeof (epath) - 1] = '\0';
-
-	/* Try the longest matching exported pathname. */
-	while (1) {
-		exp = export_allowed_internal(ai, epath);
-		if (exp)
-			return exp;
-		/* We have to treat the root, "/", specially. */
-		if (p == &epath[1]) break;
-		p = strrchr(epath, '/');
-		if (p == epath) p++;
-		*p = '\0';
-	}
-
-	return NULL;
-}
-
 /**
  * export_lookup - search hash table for export entry
  * @hname: '\0'-terminated ASCII string containing client hostname to look for
diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
deleted file mode 100644
index 2950a90e8a6f..000000000000
--- a/support/export/nfsctl.c
+++ /dev/null
@@ -1,118 +0,0 @@
-/*
- * support/export/nfsctl.c
- *
- * Communicate export information to knfsd.
- *
- * Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <sys/stat.h>
-#include <stdlib.h>
-#include <errno.h>
-#include <string.h>
-#include <ctype.h>
-#include "nfslib.h"
-#include "exportfs.h"
-#include "xio.h"
-
-static int	expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport);
-static int	cltsetup(struct nfsctl_client *cltarg, nfs_client *clp);
-
-int
-export_export(nfs_export *exp)
-{
-	nfs_client *	clp = exp->m_client;
-	struct nfsctl_export	exparg;
-	struct nfsctl_client	cltarg;
-
-	if (!clp->m_exported && (clp->m_type != MCL_GSS)) {
-		if (!cltsetup(&cltarg, clp))
-			return 0;
-		if (nfsaddclient(&cltarg) < 0)
-			return 0;
-		clp->m_exported = 1;
-	}
-	if (!expsetup(&exparg, exp, 0))
-		return 0;
-	if (nfsexport(&exparg) < 0)
-		return 0;
-	exp->m_exported = 1;
-	return 1;
-}
-
-int
-export_unexport(nfs_export *exp)
-{
-	struct nfsctl_export	exparg;
-
-	if (!expsetup(&exparg, exp, 1) || nfsunexport(&exparg) < 0)
-		return 0;
-	exp->m_exported = 0;
-	return 1;
-}
-
-static void
-str_tolower(char *s)
-{
-	for ( ; *s; s++)
-		if (isupper(*s))
-			*s = tolower(*s);
-}
-
-static int
-cltsetup(struct nfsctl_client *cltarg, nfs_client *clp)
-{
-	int i, j;
-
-	if (clp->m_type != MCL_FQDN) {
-		xlog(L_ERROR, "internal: can't export non-FQDN host");
-		return 0;
-	}
-	memset(cltarg, 0, sizeof(*cltarg));
-	strncpy(cltarg->cl_ident, clp->m_hostname,
-		sizeof (cltarg->cl_ident) - 1);
-	str_tolower(cltarg->cl_ident);
-
-	j = 0;
-	for (i = 0; i < clp->m_naddr && i < NFSCLNT_ADDRMAX; i++) {
-		const struct sockaddr_in *sin = get_addrlist_in(clp, i);
-		if (sin->sin_family == AF_INET)
-			cltarg->cl_addrlist[j++] = sin->sin_addr;
-	}
-	if (j == 0) {
-		xlog(L_ERROR, "internal: no supported addresses in nfs_client");
-		return 0;
-	}
-
-	cltarg->cl_naddr = j;
-	return 1;
-}
-
-static int
-expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport)
-{
-	nfs_client		*clp = exp->m_client;
-	struct stat		stb;
-
-	if (stat(exp->m_export.e_path, &stb) < 0)
-		return 0;
-
-	memset(exparg, 0, sizeof(*exparg));
-	strncpy(exparg->ex_path, exp->m_export.e_path,
-		sizeof (exparg->ex_path) - 1);
-	strncpy(exparg->ex_client, clp->m_hostname,
-		sizeof (exparg->ex_client) - 1);
-	str_tolower(exparg->ex_client);
-	exparg->ex_flags    = exp->m_export.e_flags;
-	exparg->ex_dev      = (!unexport && (exp->m_export.e_flags & NFSEXP_FSID)) ?
-			(__nfsd_dev_t)exp->m_export.e_fsid : stb.st_dev;
-	exparg->ex_ino      = stb.st_ino;
-	exparg->ex_anon_uid = exp->m_export.e_anonuid;
-	exparg->ex_anon_gid = exp->m_export.e_anongid;
-
-	return 1;
-}
diff --git a/support/export/rmtab.c b/support/export/rmtab.c
deleted file mode 100644
index d16b3b33b692..000000000000
--- a/support/export/rmtab.c
+++ /dev/null
@@ -1,98 +0,0 @@
-/*
- * support/export/rmtab.c
- *
- * Interface to the rmtab file.
- *
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <stdlib.h>
-#include <string.h>
-#include <errno.h>
-
-#include "misc.h"
-#include "nfslib.h"
-#include "exportfs.h"
-#include "xio.h"
-#include "xlog.h"
-
-/*
- * See if the entry already exists.  If not,
- * this was an instantiated wild card, and we
- * must add it.
- */
-static void
-rmtab_read_wildcard(struct rmtabent *rep)
-{
-	nfs_export *exp, *exp2;
-	struct addrinfo *ai;
-
-	ai = host_addrinfo(rep->r_client);
-	if (ai == NULL)
-		return;
-
-	exp = export_allowed(ai, rep->r_path);
-	freeaddrinfo(ai);
-	if (exp == NULL)
-		return;
-
-	exp2 = export_lookup(rep->r_client, exp->m_export.e_path, 0);
-	if (exp2 == NULL) {
-		struct exportent ee;
-
-		memset(&ee, 0, sizeof(ee));
-		dupexportent(&ee, &exp->m_export);
-
-		ee.e_hostname = rep->r_client;
-		exp2 = export_create(&ee, 0);
-		exp2->m_changed = exp->m_changed;
-	}
-	exp2->m_mayexport = 1;
-}
-
-int
-rmtab_read(void)
-{
-	struct rmtabent		*rep;
-
-	setrmtabent("r");
-	while ((rep = getrmtabent(1, NULL)) != NULL) {
-		int			htype;
-
-		htype = client_gettype(rep->r_client);
-		if (htype == MCL_FQDN || htype == MCL_SUBNETWORK)
-			rmtab_read_wildcard(rep);
-	}
-
-	if (errno == EINVAL) {
-		/* Something goes wrong. We need to fix the rmtab
-		   file. */
-		int	lockid;
-		FILE	*fp;
-		if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
-			return -1;
-		rewindrmtabent();
-		if (!(fp = fsetrmtabent(_PATH_RMTABTMP, "w"))) {
-			endrmtabent ();
-			xfunlock(lockid);
-			return -1;
-		}
-		while ((rep = getrmtabent(0, NULL)) != NULL) {
-			fputrmtabent(fp, rep, NULL);
-		}
-		if (rename(_PATH_RMTABTMP, _PATH_RMTAB) < 0) {
-			xlog(L_ERROR, "couldn't rename %s to %s",
-			     _PATH_RMTABTMP, _PATH_RMTAB);
-		}
-		endrmtabent();
-		fendrmtabent(fp);
-		xfunlock(lockid);
-	}
-	else {
-		endrmtabent();
-	}
-	return 0;
-}
diff --git a/support/export/xtab.c b/support/export/xtab.c
index 10d9dbc5db15..22cf539363e6 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -63,22 +63,6 @@ xtab_read(char *xtab, char *lockfn, int is_export)
 }
 
 int
-xtab_mount_read(void)
-{
-	int fd;
-	if ((fd=open(_PATH_PROC_EXPORTS, O_RDONLY))>=0) {
-		close(fd);
-		return xtab_read(_PATH_PROC_EXPORTS,
-				 _PATH_PROC_EXPORTS, 0);
-	} else if ((fd=open(_PATH_PROC_EXPORTS_ALT, O_RDONLY) >= 0)) {
-		close(fd);
-		return xtab_read(_PATH_PROC_EXPORTS_ALT,
-				 _PATH_PROC_EXPORTS_ALT, 0);
-	} else
-		return 0;
-}
-
-int
 xtab_export_read(void)
 {
 	return xtab_read(_PATH_ETAB, _PATH_ETABLCK, 1);
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 08ef30a2f580..8af47a84afc8 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -140,15 +140,10 @@ void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(const struct addrinfo *ai,
 						const char *path);
-nfs_export *			export_allowed(const struct addrinfo *ai,
-						const char *path);
 nfs_export *			export_create(struct exportent *, int canonical);
 void				exportent_release(struct exportent *);
 void				export_freeall(void);
-int				export_export(nfs_export *);
-int				export_unexport(nfs_export *);
 
-int				xtab_mount_read(void);
 int				xtab_export_read(void);
 int				xtab_export_write(void);
 
@@ -167,8 +162,6 @@ struct addrinfo *		host_reliable_addrinfo(const struct sockaddr *sap);
 __attribute__((__malloc__))
 struct addrinfo *		host_numeric_addrinfo(const struct sockaddr *sap);
 
-int				rmtab_read(void);
-
 struct nfskey *			key_lookup(char *hname);
 
 struct export_features {
diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 27054e52beef..15ecc6bfc485 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -23,27 +23,7 @@ struct nfs_fh_len {
 	int		fh_size;
 	u_int8_t	fh_handle[NFS3_FHSIZE];
 };
-struct nfs_fh_old {
-	u_int8_t	fh_handle[NFS_FHSIZE];
-};
-
-/*
- * Version of the syscall interface
- */
-#define NFSCTL_VERSION		0x0201
 
-/*
- * These are the commands understood by nfsctl().
- */
-#define NFSCTL_SVC		0	/* This is a server process. */
-#define NFSCTL_ADDCLIENT	1	/* Add an NFS client. */
-#define NFSCTL_DELCLIENT	2	/* Remove an NFS client. */
-#define NFSCTL_EXPORT		3	/* export a file system. */
-#define NFSCTL_UNEXPORT		4	/* unexport a file system. */
-#define NFSCTL_UGIDUPDATE	5	/* update a client's uid/gid map. */
-#define NFSCTL_GETFH		6	/* get an fh (used by mountd) */
-#define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
-#define NFSCTL_GETFS		8	/* get an fh by path with max size (used by mountd) */
 
 #define NFSCTL_UDPBIT		      (1 << (17 - 1))
 #define NFSCTL_TCPBIT		      (1 << (18 - 1))
@@ -64,104 +44,4 @@ struct nfs_fh_old {
 #define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | NFSCTL_TCPBIT))
 #define NFSCTL_ALLBITS (~0)
 
-/* SVC */
-struct nfsctl_svc {
-	unsigned short		svc_port;
-	int			svc_nthreads;
-};
-
-/* ADDCLIENT/DELCLIENT */
-struct nfsctl_client {
-	char			cl_ident[NFSCLNT_IDMAX+1];
-	int			cl_naddr;
-	struct in_addr		cl_addrlist[NFSCLNT_ADDRMAX];
-	int			cl_fhkeytype;
-	int			cl_fhkeylen;
-	unsigned char		cl_fhkey[NFSCLNT_KEYMAX];
-};
-
-/* IN 2.5.6? __kernel_dev_t changed size, and __kernel_old_dev_t was left
- * with the old value.  We need to make sure we use the right one.
- *
- */
-#include <linux/version.h>
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,70)
-# define __nfsd_dev_t  __kernel_old_dev_t
-#else
-# define __nfsd_dev_t  __kernel_dev_t
-#endif
-
-/* EXPORT/UNEXPORT */
-struct nfsctl_export {
-	char			ex_client[NFSCLNT_IDMAX+1];
-	char			ex_path[NFS_MAXPATHLEN+1];
-	__nfsd_dev_t		ex_dev;
-	__kernel_ino_t		ex_ino;
-	int			ex_flags;
-	__kernel_uid_t		ex_anon_uid;
-	__kernel_gid_t		ex_anon_gid;
-};
-
-/* UGIDUPDATE */
-struct nfsctl_uidmap {
-	char *			ug_ident;
-	__kernel_uid_t		ug_uidbase;
-	int			ug_uidlen;
-	__kernel_uid_t *	ug_udimap;
-	__kernel_gid_t		ug_gidbase;
-	int			ug_gidlen;
-	__kernel_gid_t *	ug_gdimap;
-};
-
-/* GETFH */
-struct nfsctl_fhparm {
-	struct sockaddr		gf_addr;
-	__nfsd_dev_t		gf_dev;
-	__kernel_ino_t		gf_ino;
-	int			gf_version;
-};
-
-/* GETFD */
-struct nfsctl_fdparm {
-	struct sockaddr		gd_addr;
-	char			gd_path[NFS_MAXPATHLEN+1];
-	int			gd_version;
-};
-
-/* GETFS - GET Filehandle with Size */
-struct nfsctl_fsparm {
-	struct sockaddr		gd_addr;
-	char			gd_path[NFS_MAXPATHLEN+1];
-	int			gd_maxlen;
-};
-
-/*
- * This is the argument union.
- */
-struct nfsctl_arg {
-	int			ca_version;	/* safeguard */
-	union {
-		struct nfsctl_svc	u_svc;
-		struct nfsctl_client	u_client;
-		struct nfsctl_export	u_export;
-		struct nfsctl_uidmap	u_umap;
-		struct nfsctl_fhparm	u_getfh;
-		struct nfsctl_fdparm	u_getfd;
-		struct nfsctl_fsparm	u_getfs;
-	} u;
-#define ca_svc		u.u_svc
-#define ca_client	u.u_client
-#define ca_export	u.u_export
-#define ca_umap		u.u_umap
-#define ca_getfh	u.u_getfh
-#define ca_getfd	u.u_getfd
-#define ca_getfs	u.u_getfs
-#define ca_authd	u.u_authd
-};
-
-union nfsctl_res {
-	struct nfs_fh_old	cr_getfh;
-	struct nfs_fh_len	cr_getfs;
-};
-
 #endif /* _NFS_NFS_H */
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 777f398c1486..1498977d1f79 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -129,25 +129,9 @@ void daemon_ready(void);
  */
 int			wildmat(char *text, char *pattern);
 
-/*
- * nfsd library functions.
- */
-int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfsaddclient(struct nfsctl_client *clp);
-int			nfsdelclient(struct nfsctl_client *clp);
-int			nfsexport(struct nfsctl_export *exp);
-int			nfsunexport(struct nfsctl_export *exp);
-
-struct nfs_fh_len *	getfh_old(const struct sockaddr_in *sin,
-					const dev_t dev, const ino_t ino);
-struct nfs_fh_len *	getfh(const struct sockaddr_in *sin, const char *path);
-struct nfs_fh_len *	getfh_size(const struct sockaddr_in *sin,
-					const char *path, int const size);
-
 int qword_get(char **bpp, char *dest, int bufsize);
 int qword_get_int(char **bpp, int *anint);
 void cache_flush(int force);
-int check_new_cache(void);
 void qword_add(char **bpp, int *lp, char *str);
 void qword_addhex(char **bpp, int *lp, char *buf, int blen);
 void qword_addint(char **bpp, int *lp, int n);
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index fb9b8c109723..b74c8700e057 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -2,8 +2,8 @@
 
 noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
-		   xlog.c xcommon.c wildmat.c mydaemon.c nfsclient.c \
-		   nfsexport.c getfh.c nfsctl.c rpc_socket.c getport.c \
+		   xlog.c xcommon.c wildmat.c mydaemon.c \
+		   rpc_socket.c getport.c \
 		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
 		   svc_create.c atomicio.c strlcpy.c strlcat.c
 
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 42e2502f915a..e5e25795a23e 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -198,18 +198,6 @@ int qword_get_uint(char **bpp, unsigned int *anint)
 	return 0;
 }
 
-/* Check if we should use the new caching interface
- * This succeeds iff the "nfsd" filesystem is mounted on
- * /proc/fs/nfs
- */
-int
-check_new_cache(void)
-{
-	return	(access("/proc/fs/nfs/filehandle", F_OK) == 0) ||
-		(access("/proc/fs/nfsd/filehandle", F_OK) == 0);
-}	
-
-
 /* flush the kNFSd caches.
  * Set the flush time to the mtime of _PATH_ETAB or
  * if force, to now.
diff --git a/support/nfs/getfh.c b/support/nfs/getfh.c
deleted file mode 100644
index 611459ba73c1..000000000000
--- a/support/nfs/getfh.c
+++ /dev/null
@@ -1,134 +0,0 @@
-/*
- * support/nfs/getfh.c
- *
- * Get the FH for a given client and directory. This function takes
- * the NFS protocol version number as an additional argument.
- *
- * This function has nothing in common with the SunOS getfh function,
- * which is a front-end to the RPC mount call.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <string.h>
-#include <sys/types.h>
-#include <errno.h>
-#include "nfslib.h"
-
-/**
- * getfh_old - ask the kernel for an NFSv2 file handle via nfsctl()
- * @sin: pointer to IPv4 address of a client
- * @dev: device number of device where requested object resides
- * @ino: inode number of requested object
- *
- * Returns a pointer to an NFSv2 file handle, or NULL if some error
- * occurred.  errno is set to reflect the specifics of the error.
- */
-struct nfs_fh_len *
-getfh_old(const struct sockaddr_in *sin, const dev_t dev, const ino_t ino)
-{
-	union nfsctl_res	res;
-	struct nfsctl_arg	arg;
-	static struct nfs_fh_len rfh;
-
-	if (sin->sin_family != AF_INET) {
-		errno = EAFNOSUPPORT;
-		return NULL;
-	}
-
-	memset(&arg, 0, sizeof(arg));
-	memset(&res, 0, sizeof(res));
-
-	arg.ca_version = NFSCTL_VERSION;
-	arg.ca_getfh.gf_version = 2;	/* obsolete */
-	arg.ca_getfh.gf_dev = dev;
-	arg.ca_getfh.gf_ino = ino;
-	memcpy(&arg.ca_getfh.gf_addr, sin, sizeof(*sin));
-
-	if (nfsctl(NFSCTL_GETFH, &arg, &res) < 0)
-		return NULL;
-
-	memset(&rfh, 0, sizeof(rfh));
-	rfh.fh_size = 32;
-	memcpy(rfh.fh_handle, &res.cr_getfh, 32);
-	return &rfh;
-}
-
-/**
- * getfh - ask the kernel for an NFSv2 file handle via nfsctl()
- * @sin: pointer to IPv4 address of a client
- * @path: pointer to a '\0'-terminated ASCII string containing an pathname
- *
- * Returns a pointer to an NFSv2 file handle, or NULL if some error
- * occurred.  errno is set to reflect the specifics of the error.
- */
-struct nfs_fh_len *
-getfh(const struct sockaddr_in *sin, const char *path)
-{
-	static union nfsctl_res res;
-        struct nfsctl_arg       arg;
-	static struct nfs_fh_len rfh;
-
-	if (sin->sin_family != AF_INET) {
-		errno = EAFNOSUPPORT;
-		return NULL;
-	}
-
-	memset(&arg, 0, sizeof(arg));
-	memset(&res, 0, sizeof(res));
-
-        arg.ca_version = NFSCTL_VERSION;
-        arg.ca_getfd.gd_version = 2;    /* obsolete */
-        strncpy(arg.ca_getfd.gd_path, path,
-		sizeof(arg.ca_getfd.gd_path) - 1);
-	arg.ca_getfd.gd_path[sizeof (arg.ca_getfd.gd_path) - 1] = '\0';
-	memcpy(&arg.ca_getfd.gd_addr, sin, sizeof(*sin));
-
-        if (nfsctl(NFSCTL_GETFD, &arg, &res) < 0)
-                return NULL;
-
-	memset(&rfh, 0, sizeof(rfh));
-	rfh.fh_size = 32;
-	memcpy(rfh.fh_handle, &res.cr_getfh, 32);
-	return &rfh;
-}
-
-/**
- * getfh_size - ask the kernel for a file handle via nfsctl()
- * @sin: pointer to IPv4 address of a client
- * @path: pointer to a '\0'-terminated ASCII string containing an pathname
- * @size: maximum size, in bytes, of the returned file handle
- *
- * Returns a pointer to an NFSv3 file handle, or NULL if some error
- * occurred.  errno is set to reflect the specifics of the error.
- */
-struct nfs_fh_len *
-getfh_size(const struct sockaddr_in *sin, const char *path, const int size)
-{
-        static union nfsctl_res res;
-        struct nfsctl_arg       arg;
-
-	if (sin->sin_family != AF_INET) {
-		errno = EAFNOSUPPORT;
-		return NULL;
-	}
-
-	memset(&arg, 0, sizeof(arg));
-	memset(&res, 0, sizeof(res));
-
-        arg.ca_version = NFSCTL_VERSION;
-        strncpy(arg.ca_getfs.gd_path, path,
-		sizeof(arg.ca_getfs.gd_path) - 1);
-	arg.ca_getfs.gd_path[sizeof (arg.ca_getfs.gd_path) - 1] = '\0';
-	memcpy(&arg.ca_getfs.gd_addr, sin, sizeof(*sin));
-	arg.ca_getfs.gd_maxlen = size;
-
-        if (nfsctl(NFSCTL_GETFS, &arg, &res) < 0)
-                return NULL;
-
-        return &res.cr_getfs;
-}
diff --git a/support/nfs/nfsclient.c b/support/nfs/nfsclient.c
deleted file mode 100644
index 532240930ad0..000000000000
--- a/support/nfs/nfsclient.c
+++ /dev/null
@@ -1,34 +0,0 @@
-/*
- * support/nfs/client.c
- *
- * Add or delete an NFS client in knfsd.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <string.h>
-#include "nfslib.h"
-
-int
-nfsaddclient(struct nfsctl_client *clp)
-{
-	struct nfsctl_arg	arg;
-
-	arg.ca_version = NFSCTL_VERSION;
-	memcpy(&arg.ca_client, clp, sizeof(arg.ca_client));
-	return nfsctl(NFSCTL_ADDCLIENT, &arg, NULL);
-}
-
-int
-nfsdelclient(struct nfsctl_client *clp)
-{
-	struct nfsctl_arg	arg;
-
-	arg.ca_version = NFSCTL_VERSION;
-	memcpy(&arg.ca_client, clp, sizeof(arg.ca_client));
-	return nfsctl(NFSCTL_DELCLIENT, &arg, NULL);
-}
diff --git a/support/nfs/nfsctl.c b/support/nfs/nfsctl.c
deleted file mode 100644
index fec775f913d6..000000000000
--- a/support/nfs/nfsctl.c
+++ /dev/null
@@ -1,32 +0,0 @@
-/*
- * support/nfs/nfsctl.c
- *
- * Central syscall to the nfsd kernel module.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <unistd.h>
-#include <errno.h>
-#include <asm/unistd.h>
-#include "nfslib.h"
-
-/* compatibility hack... */
-#if !defined(__NR_nfsctl) && defined(__NR_nfsservctl)
-#define __NR_nfsctl	__NR_nfsservctl
-#endif
-
-int
-nfsctl (int cmd, struct nfsctl_arg * argp, union nfsctl_res * resp)
-{
-#ifdef __NR_nfsctl
-  return syscall (__NR_nfsctl, cmd, argp, resp);
-#else
-  errno = ENOSYS;
-  return -1;
-#endif
-}
diff --git a/support/nfs/nfsexport.c b/support/nfs/nfsexport.c
deleted file mode 100644
index 4b13265e6748..000000000000
--- a/support/nfs/nfsexport.c
+++ /dev/null
@@ -1,134 +0,0 @@
-/*
- * support/nfs/export.c
- *
- * Add or delete an NFS export in knfsd.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <string.h>
-#include <sys/types.h>
-#include <asm/types.h>
-#include <sys/stat.h>
-#include <unistd.h>
-#include <fcntl.h>
-
-#include "nfslib.h"
-#include "misc.h"
-#include "xcommon.h"
-
-	/* if /proc/net/rpc/... exists, then 
-	 * write to it, as that interface is more stable.
-	 * Write:
-	 *  client fsidtype fsid path
-	 * to /proc/net/rpc/nfsd.fh/channel
-	 * and
-	 *  client path expiry flags anonuid anongid fsid
-	 * to /proc/net/rpc/nfsd.export/channel
-	 */
-
-static int
-exp_unexp(struct nfsctl_export *exp, int export)
-{
-	char buf[RPC_CHAN_BUF_SIZE], *bp;
-	struct stat stb;
-	__u32 fsid;
-	char fsidstr[8];
-	__u16 dev;
-	__u32 inode;
-	int err = 0, f, blen;
-
-	f = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
-	if (f < 0) return -1;
-
-	bp = buf; blen = sizeof(buf);
-	qword_add(&bp, &blen, exp->ex_client);
-	qword_add(&bp, &blen, exp->ex_path);
-	if (export) {
-		qword_addint(&bp, &blen, 0x7fffffff);
-		qword_addint(&bp, &blen, exp->ex_flags);
-		qword_addint(&bp, &blen, exp->ex_anon_uid);
-		qword_addint(&bp, &blen, exp->ex_anon_gid);
-		qword_addint(&bp, &blen, exp->ex_dev);
-	} else
-		qword_addint(&bp, &blen, 1);
-	qword_addeol(&bp, &blen);
-	if (blen <= 0 || write(f, buf, bp - buf) != bp - buf)
-		err = -1;
-	close(f);
-
-	if (stat(exp->ex_path, &stb) != 0)
-		return -1;
-
-	f = open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY);
-	if (f < 0) return -1;
-	if (exp->ex_flags & NFSEXP_FSID) {
-		bp = buf; blen = sizeof(buf);
-		qword_add(&bp, &blen, exp->ex_client);
-		qword_addint(&bp, &blen, 1);
-		fsid = exp->ex_dev;
-		qword_addhex(&bp, &blen, (char*)&fsid, 4);
-		if (export) {
-			qword_addint(&bp, &blen, 0x7fffffff);
-			qword_add(&bp, &blen, exp->ex_path);
-		} else
-			qword_addint(&bp, &blen, 1);
-		qword_addeol(&bp, &blen);
-		if (blen <= 0 || write(f, buf, bp - buf) != bp - buf)
-			err = -1;
-	}
-
-	bp = buf; blen = sizeof(buf);
-	qword_add(&bp, &blen, exp->ex_client);
-	qword_addint(&bp, &blen, 0);
-	dev = htons(major(stb.st_dev)); memcpy(fsidstr, &dev, 2);
-	dev = htons(minor(stb.st_dev)); memcpy(fsidstr+2, &dev, 2);
-	inode = stb.st_ino; memcpy(fsidstr+4, &inode, 4);
-	
-	qword_addhex(&bp, &blen, fsidstr, 8);
-	if (export) {
-		qword_addint(&bp, &blen, 0x7fffffff);
-		qword_add(&bp, &blen, exp->ex_path);
-	} else
-		qword_addint(&bp, &blen, 1);
-	qword_addeol(&bp, &blen);
-	if (blen <= 0 || write(f, buf, bp - buf) != bp - buf)
-		err = -1;
-	close(f);
-
-	return err;
-}
-
-int
-nfsexport(struct nfsctl_export *exp)
-{
-	struct nfsctl_arg	arg;
-	int fd;
-	if ((fd=open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY))>= 0) {
-		close(fd);
-		return exp_unexp(exp, 1);
-	}
-	arg.ca_version = NFSCTL_VERSION;
-	memcpy(&arg.ca_export, exp, sizeof(arg.ca_export));
-	return nfsctl(NFSCTL_EXPORT, &arg, NULL);
-}
-
-int
-nfsunexport(struct nfsctl_export *exp)
-{
-	struct nfsctl_arg	arg;
-
-	int fd;
-	if ((fd=open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY))>= 0) {
-		close(fd);
-		return exp_unexp(exp, 0);
-	}
-
-	arg.ca_version = NFSCTL_VERSION;
-	memcpy(&arg.ca_export, exp, sizeof(arg.ca_export));
-	return nfsctl(NFSCTL_UNEXPORT, &arg, NULL);
-}
diff --git a/support/nfs/rmtab.c b/support/nfs/rmtab.c
index ca789a32c6a8..59dfbdf61823 100644
--- a/support/nfs/rmtab.c
+++ b/support/nfs/rmtab.c
@@ -152,27 +152,8 @@ endrmtabent(void)
 void
 fendrmtabent(FILE *fp)
 {
-	if (fp) {
-		static int have_new_cache = -1;
-		if (have_new_cache == -1) /* check only once */
-			have_new_cache = check_new_cache();
-
-		if (!have_new_cache) {
-			/*
-			 * If we are using the old caching interface: exportfs
-			 * uses the rmtab to determine what should be exported,
-			 * so it is important that it be up-to-date.
-			 *
-			 * If we are using the new caching interface: the rmtab
-			 * is ignored by exportfs and the fdatasync only serves
-			 * to slow us down.
-			 */
-			fflush(fp);
-			fdatasync(fileno(fp));
-		}
-
+	if (fp)
 		fclose(fp);
-	}
 }
 
 void
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 18167962b733..b7a910efe353 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -40,9 +40,7 @@
 static void	export_all(int verbose);
 static void	exportfs(char *arg, char *options, int verbose);
 static void	unexportfs(char *arg, int verbose);
-static void	exports_update(int verbose);
 static void	dump(int verbose, int export_format);
-static void	error(nfs_export *exp, int err);
 static void	usage(const char *progname, int n);
 static void	validate_export(nfs_export *exp);
 static int	matchhostname(const char *hostname1, const char *hostname2);
@@ -94,7 +92,6 @@ main(int argc, char **argv)
 	int	f_reexport = 0;
 	int	f_ignore = 0;
 	int	i, c;
-	int	new_cache = 0;
 	int	force_flush = 0;
 
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -157,17 +154,9 @@ main(int argc, char **argv)
 		xlog(L_ERROR, "-r and -u are incompatible");
 		return 1;
 	}
-	new_cache = check_new_cache();
 	if (optind == argc && ! f_all) {
 		if (force_flush) {
-			if (new_cache)
-				cache_flush(1);
-			else {
-				xlog(L_ERROR, "-f is available only "
-					"with new cache controls. "
-					"Mount /proc/fs/nfsd first");
-				return 1;
-			}
+			cache_flush(1);
 			return 0;
 		} else {
 			xtab_export_read();
@@ -209,71 +198,13 @@ main(int argc, char **argv)
 		if (!f_export)
 			for (i = optind ; i < argc ; i++)
 				unexportfs(argv[i], f_verbose);
-		if (!new_cache)
-			rmtab_read();
-	}
-	if (!new_cache) {
-		xtab_mount_read();
-		exports_update(f_verbose);
 	}
 	xtab_export_write();
-	if (new_cache)
-		cache_flush(force_flush);
+	cache_flush(force_flush);
 
 	return export_errno;
 }
 
-static void
-exports_update_one(nfs_export *exp, int verbose)
-{
-		/* check mountpoint option */
-	if (exp->m_mayexport &&
-	    exp->m_export.e_mountpoint &&
-	    !is_mountpoint(exp->m_export.e_mountpoint[0]?
-			   exp->m_export.e_mountpoint:
-			   exp->m_export.e_path)) {
-		printf("%s not exported as %s not a mountpoint.\n",
-		       exp->m_export.e_path, exp->m_export.e_mountpoint);
-		exp->m_mayexport = 0;
-	}
-	if (exp->m_mayexport && exp->m_changed) {
-		if (verbose)
-			printf("%sexporting %s:%s to kernel\n",
-			       exp->m_exported ?"re":"",
-			       exp->m_client->m_hostname,
-			       exp->m_export.e_path);
-		if (!export_export(exp))
-			error(exp, errno);
-	}
-	if (exp->m_exported && ! exp->m_mayexport) {
-		if (verbose)
-			printf("unexporting %s:%s from kernel\n",
-			       exp->m_client->m_hostname,
-			       exp->m_export.e_path);
-		if (!export_unexport(exp))
-			error(exp, errno);
-	}
-}
-
-
-/* we synchronise intention with reality.
- * entries with m_mayexport get exported
- * entries with m_exported but not m_mayexport get unexported
- * looking at m_client->m_type == MCL_FQDN and m_client->m_type == MCL_GSS only
- */
-static void
-exports_update(int verbose)
-{
-	nfs_export 	*exp;
-
-	for (exp = exportlist[MCL_FQDN].p_head; exp; exp=exp->m_next) {
-		exports_update_one(exp, verbose);
-	}
-	for (exp = exportlist[MCL_GSS].p_head; exp; exp=exp->m_next) {
-		exports_update_one(exp, verbose);
-	}
-}
-
 /*
  * export_all finds all entries and
  *    marks them xtabent and mayexport so that they get exported
@@ -438,10 +369,6 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 					exp->m_client->m_hostname,
 					exp->m_export.e_path);
 		}
-#if 0
-		if (exp->m_exported && !export_unexport(exp))
-			error(exp, errno);
-#endif
 		exp->m_xtabent = 0;
 		exp->m_mayexport = 0;
 		success = 1;
@@ -809,13 +736,6 @@ dump(int verbose, int export_format)
 }
 
 static void
-error(nfs_export *exp, int err)
-{
-	xlog(L_ERROR, "%s:%s: %s", exp->m_client->m_hostname,
-		exp->m_export.e_path, strerror(err));
-}
-
-static void
 usage(const char *progname, int n)
 {
 	fprintf(stderr, "usage: %s [-adfhioruvs] [host:/path]\n", progname);
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index b612d88b6143..d0658300e884 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -39,7 +39,6 @@ static void		auth_fixpath(char *path);
 static nfs_export my_exp;
 static nfs_client my_client;
 
-extern int new_cache;
 extern int use_ipaddr;
 
 void
@@ -210,17 +209,9 @@ auth_authenticate_internal(const struct sockaddr *caller, const char *path,
 {
 	nfs_export *exp;
 
-	if (new_cache) {
-		exp = auth_authenticate_newcache(caller, path, ai, error);
-		if (!exp)
-			return NULL;
-	} else {
-		exp = export_find(ai, path);
-		if (exp == NULL) {
-			*error = no_entry;
-			return NULL;
-		}
-	}
+	exp = auth_authenticate_newcache(caller, path, ai, error);
+	if (!exp)
+		return NULL;
 	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
 		     nfs_get_port(caller) >= IPPORT_RESERVED) {
 		*error = illegal_port;
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 981abd456d91..a0ab2935136a 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -35,7 +35,6 @@ static exports		get_exportlist(void);
 static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, nfs_export **, mountstat3 *, int v3);
 
 int reverse_resolve = 0;
-int new_cache = 0;
 int manage_gids;
 int use_ipaddr = -1;
 
@@ -495,8 +494,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		return NULL;
 	}
 	if (estb.st_dev != stb.st_dev
-		   && (!new_cache
-			   || !(exp->m_export.e_flags & NFSEXP_CROSSMOUNT))) {
+	    && !(exp->m_export.e_flags & NFSEXP_CROSSMOUNT)) {
 		xlog(L_WARNING, "request to export directory %s below nearest filesystem %s",
 		     p, exp->m_export.e_path);
 		*error = MNT3ERR_ACCES;
@@ -512,45 +510,18 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		return NULL;
 	}
 
-	if (new_cache) {
-		/* This will be a static private nfs_export with just one
-		 * address.  We feed it to kernel then extract the filehandle,
-		 * 
-		 */
+	/* This will be a static private nfs_export with just one
+	 * address.  We feed it to kernel then extract the filehandle,
+	 */
 
-		if (cache_export(exp, p)) {
-			*error = MNT3ERR_ACCES;
-			return NULL;
-		}
-		fh = cache_get_filehandle(exp, v3?64:32, p);
-		if (fh == NULL) {
-			*error = MNT3ERR_ACCES;
-			return NULL;
-		}
-	} else {
-		int did_export = 0;
-	retry:
-
-		if (v3)
-			fh = getfh_size((struct sockaddr_in *)sap, p, 64);
-		if (!v3 || (fh == NULL && errno == EINVAL)) {
-			/* We first try the new nfs syscall. */
-			fh = getfh((struct sockaddr_in *)sap, p);
-			if (fh == NULL && errno == EINVAL)
-				/* Let's try the old one. */
-				fh = getfh_old((struct sockaddr_in *)sap,
-						stb.st_dev, stb.st_ino);
-		}
-		if (fh == NULL && !did_export) {
-			exp->m_exported = 0;
-			goto retry;
-		}
-
-		if (fh == NULL) {
-			xlog(L_WARNING, "getfh failed: %s", strerror(errno));
-			*error = MNT3ERR_ACCES;
-			return NULL;
-		}
+	if (cache_export(exp, p)) {
+		*error = MNT3ERR_ACCES;
+		return NULL;
+	}
+	fh = cache_get_filehandle(exp, v3?64:32, p);
+	if (fh == NULL) {
+		*error = MNT3ERR_ACCES;
+		return NULL;
 	}
 	*error = MNT_OK;
 	mountlist_add(host_ntop(sap, buf, sizeof(buf)), p);
@@ -827,9 +798,7 @@ main(int argc, char **argv)
 	if (!foreground)
 		closeall(3);
 
-	new_cache = check_new_cache();
-	if (new_cache)
-		cache_open();
+	cache_open();
 
 	unregister_services();
 	if (version2()) {
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 2165744d7b53..7b5e67a09bd2 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -315,7 +315,7 @@ set_threads:
 	}
 	closeall(3);
 
-	if ((error = nfssvc_threads(portnum, count)) < 0)
+	if ((error = nfssvc_threads(count)) < 0)
 		xlog(L_ERROR, "error starting threads: errno %d (%m)", errno);
 out:
 	free(port);
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index dcb430a6b2e9..07f6ff1204d1 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -45,8 +45,7 @@ char buf[128];
 /*
  * Using the "new" interfaces for nfsd requires that /proc/fs/nfsd is
  * actually mounted. Make an attempt to mount it here if it doesn't appear
- * to be. If the mount attempt fails, no big deal -- fall back to using nfsctl
- * instead.
+ * to be.
  */
 void
 nfssvc_mount_nfsdfs(char *progname)
@@ -118,9 +117,8 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 	char *proto, *family;
 
 	/*
-	 * if file can't be opened, then assume that it's not available and
-	 * that the caller should just fall back to the old nfsctl interface
- 	 */
+	 * if file can't be opened, fail.
+	 */
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
 		return 0;
@@ -368,10 +366,8 @@ nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorv
 }
 
 int
-nfssvc_threads(unsigned short port, const int nrservs)
+nfssvc_threads(const int nrservs)
 {
-	struct nfsctl_arg	arg;
-	struct servent *ent;
 	ssize_t n;
 	int fd;
 
@@ -390,17 +386,5 @@ nfssvc_threads(unsigned short port, const int nrservs)
 		else
 			return 0;
 	}
-
-	if (!port) {
-		ent = getservbyname("nfs", "udp");
-		if (ent != NULL)
-			port = ntohs(ent->s_port);
-		else
-			port = NFS_PORT;
-	}
-
-	arg.ca_version = NFSCTL_VERSION;
-	arg.ca_svc.svc_nthreads = nrservs;
-	arg.ca_svc.svc_port = port;
-	return nfsctl(NFSCTL_SVC, &arg, NULL);
+	return -1;
 }
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 7d70f0de0a9e..cd5a7e84dc7e 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -27,4 +27,4 @@ int	nfssvc_set_sockets(const unsigned int protobits,
 void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);
-int	nfssvc_threads(unsigned short port, int nrservs);
+int	nfssvc_threads(int nrservs);


