Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38458 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab0IMRVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:21:02 -0400
Received: by yxp4 with SMTP id 4so2096287yxp.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:21:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/12] libnfs.a: Fix API for getfh() & friends
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:20:58 -0400
Message-ID: <20100913172058.19017.26973.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is more of a clean-up than a behavioral change.

POSIX requires that a "struct sockaddr" is the same size as a "struct
sockaddr_in".  Therefore, a variable or field of type "struct sockaddr"
cannot contain an AF_INET6 address.  However, "struct sockaddr *" is
often used to reference a generic (ie non-address family specific)
socket address, generating some confusion about this.

The nfsctl_arg struct uses a struct sockaddr (not a pointer) to pass
the client's IP address to the kernel.  This means the legacy nfsctl()
kernel API can never support IPv6.  Fortunately for us, this legacy
interface was replaced by a text-based cache interface a few years
back.  We don't need to support non-AF_INET addresses here.

The getfh() functions in nfs-utils provide a handy C API for the
kernel's nfsctl interface.  The getfh() functions still take a struct
sockaddr *, though, and that can imply that a non-IPv4 address can be
passed via this API.  To make it abundantly clear that only IPv4
addresses can be used with this interface, change the synopses of
getfh() and friends to take a struct sockaddr_in * instead of a struct
sockaddr * .

This makes these functions conform with other places in mountd and
exportfs that already grok the difference between a struct sockaddr
and a struct sockaddr_in.

While we're here...

Introduce some nice documenting comments for the get_fh() functions,
and...

Since mountd will support IPv6 in the near future, assert that the
family of client addresses passed to this API is indeed AF_INET, in
order to prevent non-AF_INET addresses from ever being passed to the
legacy nfsctl() interface.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfslib.h |    9 ++++--
 support/nfs/getfh.c      |   64 ++++++++++++++++++++++++++++++++++++++++++----
 utils/mountd/mountd.c    |    7 ++---
 3 files changed, 67 insertions(+), 13 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index af242d3..3db5bec 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -134,9 +134,12 @@ int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
 int			nfsunexport(struct nfsctl_export *exp);
-struct nfs_fh_len *	getfh_old(struct sockaddr *addr, dev_t dev, ino_t ino);
-struct nfs_fh_len *	getfh(struct sockaddr *addr, const char *);
-struct nfs_fh_len *	getfh_size(struct sockaddr *addr, const char *, int size);
+
+struct nfs_fh_len *	getfh_old(const struct sockaddr_in *sin,
+					const dev_t dev, const ino_t ino);
+struct nfs_fh_len *	getfh(const struct sockaddr_in *sin, const char *path);
+struct nfs_fh_len *	getfh_size(const struct sockaddr_in *sin,
+					const char *path, int const size);
 
 void qword_print(FILE *f, char *str);
 void qword_printhex(FILE *f, char *str, int slen);
diff --git a/support/nfs/getfh.c b/support/nfs/getfh.c
index 81266fd..611459b 100644
--- a/support/nfs/getfh.c
+++ b/support/nfs/getfh.c
@@ -19,60 +19,112 @@
 #include <errno.h>
 #include "nfslib.h"
 
+/**
+ * getfh_old - ask the kernel for an NFSv2 file handle via nfsctl()
+ * @sin: pointer to IPv4 address of a client
+ * @dev: device number of device where requested object resides
+ * @ino: inode number of requested object
+ *
+ * Returns a pointer to an NFSv2 file handle, or NULL if some error
+ * occurred.  errno is set to reflect the specifics of the error.
+ */
 struct nfs_fh_len *
-getfh_old (struct sockaddr *addr, dev_t dev, ino_t ino)
+getfh_old(const struct sockaddr_in *sin, const dev_t dev, const ino_t ino)
 {
 	union nfsctl_res	res;
 	struct nfsctl_arg	arg;
 	static struct nfs_fh_len rfh;
 
+	if (sin->sin_family != AF_INET) {
+		errno = EAFNOSUPPORT;
+		return NULL;
+	}
+
+	memset(&arg, 0, sizeof(arg));
+	memset(&res, 0, sizeof(res));
+
 	arg.ca_version = NFSCTL_VERSION;
 	arg.ca_getfh.gf_version = 2;	/* obsolete */
 	arg.ca_getfh.gf_dev = dev;
 	arg.ca_getfh.gf_ino = ino;
-	memcpy(&arg.ca_getfh.gf_addr, addr, sizeof(struct sockaddr_in));
+	memcpy(&arg.ca_getfh.gf_addr, sin, sizeof(*sin));
 
 	if (nfsctl(NFSCTL_GETFH, &arg, &res) < 0)
 		return NULL;
 
+	memset(&rfh, 0, sizeof(rfh));
 	rfh.fh_size = 32;
 	memcpy(rfh.fh_handle, &res.cr_getfh, 32);
 	return &rfh;
 }
 
+/**
+ * getfh - ask the kernel for an NFSv2 file handle via nfsctl()
+ * @sin: pointer to IPv4 address of a client
+ * @path: pointer to a '\0'-terminated ASCII string containing an pathname
+ *
+ * Returns a pointer to an NFSv2 file handle, or NULL if some error
+ * occurred.  errno is set to reflect the specifics of the error.
+ */
 struct nfs_fh_len *
-getfh(struct sockaddr *addr, const char *path)
+getfh(const struct sockaddr_in *sin, const char *path)
 {
 	static union nfsctl_res res;
         struct nfsctl_arg       arg;
 	static struct nfs_fh_len rfh;
 
+	if (sin->sin_family != AF_INET) {
+		errno = EAFNOSUPPORT;
+		return NULL;
+	}
+
+	memset(&arg, 0, sizeof(arg));
+	memset(&res, 0, sizeof(res));
+
         arg.ca_version = NFSCTL_VERSION;
         arg.ca_getfd.gd_version = 2;    /* obsolete */
         strncpy(arg.ca_getfd.gd_path, path,
 		sizeof(arg.ca_getfd.gd_path) - 1);
 	arg.ca_getfd.gd_path[sizeof (arg.ca_getfd.gd_path) - 1] = '\0';
-        memcpy(&arg.ca_getfd.gd_addr, addr, sizeof(struct sockaddr_in));
+	memcpy(&arg.ca_getfd.gd_addr, sin, sizeof(*sin));
 
         if (nfsctl(NFSCTL_GETFD, &arg, &res) < 0)
                 return NULL;
 
+	memset(&rfh, 0, sizeof(rfh));
 	rfh.fh_size = 32;
 	memcpy(rfh.fh_handle, &res.cr_getfh, 32);
 	return &rfh;
 }
 
+/**
+ * getfh_size - ask the kernel for a file handle via nfsctl()
+ * @sin: pointer to IPv4 address of a client
+ * @path: pointer to a '\0'-terminated ASCII string containing an pathname
+ * @size: maximum size, in bytes, of the returned file handle
+ *
+ * Returns a pointer to an NFSv3 file handle, or NULL if some error
+ * occurred.  errno is set to reflect the specifics of the error.
+ */
 struct nfs_fh_len *
-getfh_size(struct sockaddr *addr, const char *path, int size)
+getfh_size(const struct sockaddr_in *sin, const char *path, const int size)
 {
         static union nfsctl_res res;
         struct nfsctl_arg       arg;
 
+	if (sin->sin_family != AF_INET) {
+		errno = EAFNOSUPPORT;
+		return NULL;
+	}
+
+	memset(&arg, 0, sizeof(arg));
+	memset(&res, 0, sizeof(res));
+
         arg.ca_version = NFSCTL_VERSION;
         strncpy(arg.ca_getfs.gd_path, path,
 		sizeof(arg.ca_getfs.gd_path) - 1);
 	arg.ca_getfs.gd_path[sizeof (arg.ca_getfs.gd_path) - 1] = '\0';
-        memcpy(&arg.ca_getfs.gd_addr, addr, sizeof(struct sockaddr_in));
+	memcpy(&arg.ca_getfs.gd_addr, sin, sizeof(*sin));
 	arg.ca_getfs.gd_maxlen = size;
 
         if (nfsctl(NFSCTL_GETFS, &arg, &res) < 0)
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index dc84404..78f26c2 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -484,14 +484,13 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 			xtab_append(exp);
 
 		if (v3)
-			fh = getfh_size ((struct sockaddr *) sin, p, 64);
+			fh = getfh_size(sin, p, 64);
 		if (!v3 || (fh == NULL && errno == EINVAL)) {
 			/* We first try the new nfs syscall. */
-			fh = getfh ((struct sockaddr *) sin, p);
+			fh = getfh(sin, p);
 			if (fh == NULL && errno == EINVAL)
 				/* Let's try the old one. */
-				fh = getfh_old ((struct sockaddr *) sin,
-						stb.st_dev, stb.st_ino);
+				fh = getfh_old(sin, stb.st_dev, stb.st_ino);
 		}
 		if (fh == NULL && !did_export) {
 			exp->m_exported = 0;

