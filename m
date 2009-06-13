From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] NFS: Add separate mountd status code decoders for each
	mountd version
Date: Sat, 13 Jun 2009 19:26:01 -0400
Message-ID: <20090613232601.3225.86496.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:16879 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830AbZFMX0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:35 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce data structures and xdr_stream-based decoding functions for
unmarshalling mountd status codes properly.

Mountd version 3 uses specific standard error return codes that are
not errno values and not NFS3ERR_ values.  These have a well-defined
standard mapping to local errno values.  Introduce data structures
and a decoder function that map these status codes to local errno
values properly.  This is new functionality (but not used yet).

Version 1 mountd status values are defined by RFC 1094 as UNIX error
values (errno values).  Errno values on heterogeneous systems do not
necessarily match each other.  To avoid exposing possibly incorrect
errno values to upper layers, the current XDR decoder converts all
non-zero MNT version 1 status codes to -EACCES.

The OpenGroup XNFS standard provides a mapping similar to but smaller
than the version 3 error codes.  Implement a decoder that uses the XNFS
error codes, replacing the current decoder.

For both mountd protocol versions, map unrecognized errors to -EACCES.

Finally we introduce a replacement data structure for mnt_fhstatus
at this time, which is used by the new XDR decoders.  In addition to
documenting that the status value returned by the XDR decoders is
always an errno, this new structure will be expanded in subsequent
patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 79b5954..8429885 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -29,6 +29,8 @@
  * XDR data type sizes
  */
 #define encode_dirpath_sz	(1 + XDR_QUADLEN(MNTPATHLEN))
+#define MNT_status_sz		(1)
+#define MNT_fhs_status_sz	(1)
 
 /*
  * XDR argument and result sizes
@@ -61,6 +63,65 @@ enum {
 
 static struct rpc_program	mnt_program;
 
+/*
+ * Defined by OpenGroup XNFS Version 3W, chapter 8
+ */
+enum mountstat {
+	MNT_OK			= 0,
+	MNT_EPERM		= 1,
+	MNT_ENOENT		= 2,
+	MNT_EACCES		= 13,
+	MNT_EINVAL		= 22,
+};
+
+static struct {
+	u32 status;
+	int errno;
+} mnt_errtbl[] = {
+	{ .status = MNT_OK,			.errno = 0,		},
+	{ .status = MNT_EPERM,			.errno = -EPERM,	},
+	{ .status = MNT_ENOENT,			.errno = -ENOENT,	},
+	{ .status = MNT_EACCES,			.errno = -EACCES,	},
+	{ .status = MNT_EINVAL,			.errno = -EINVAL,	},
+};
+
+/*
+ * Defined by RFC 1813, section 5.1.5
+ */
+enum mountstat3 {
+	MNT3_OK			= 0,		/* no error */
+	MNT3ERR_PERM		= 1,		/* Not owner */
+	MNT3ERR_NOENT		= 2,		/* No such file or directory */
+	MNT3ERR_IO		= 5,		/* I/O error */
+	MNT3ERR_ACCES		= 13,		/* Permission denied */
+	MNT3ERR_NOTDIR		= 20,		/* Not a directory */
+	MNT3ERR_INVAL		= 22,		/* Invalid argument */
+	MNT3ERR_NAMETOOLONG	= 63,		/* Filename too long */
+	MNT3ERR_NOTSUPP		= 10004,	/* Operation not supported */
+	MNT3ERR_SERVERFAULT	= 10006,	/* A failure on the server */
+};
+
+static struct {
+	u32 status;
+	int errno;
+} mnt3_errtbl[] = {
+	{ .status = MNT3_OK,			.errno = 0,		},
+	{ .status = MNT3ERR_PERM,		.errno = -EPERM,	},
+	{ .status = MNT3ERR_NOENT,		.errno = -ENOENT,	},
+	{ .status = MNT3ERR_IO,			.errno = -EIO,		},
+	{ .status = MNT3ERR_ACCES,		.errno = -EACCES,	},
+	{ .status = MNT3ERR_NOTDIR,		.errno = -ENOTDIR,	},
+	{ .status = MNT3ERR_INVAL,		.errno = -EINVAL,	},
+	{ .status = MNT3ERR_NAMETOOLONG,	.errno = -ENAMETOOLONG,	},
+	{ .status = MNT3ERR_NOTSUPP,		.errno = -ENOTSUPP,	},
+	{ .status = MNT3ERR_SERVERFAULT,	.errno = -ESERVERFAULT,	},
+};
+
+struct mountres {
+	int errno;
+	struct nfs_fh *fh;
+};
+
 struct mnt_fhstatus {
 	u32 status;
 	struct nfs_fh *fh;
@@ -179,6 +240,61 @@ static int xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+/*
+ * RFC 1094: "A non-zero status indicates some sort of error.  In this
+ * case, the status is a UNIX error number."  This can be problematic
+ * if the server and client use different errno values for the same
+ * error.
+ *
+ * However, the OpenGroup XNFS spec provides a simple mapping that is
+ * independent of local errno values on the server and the client.
+ */
+static int decode_status(struct xdr_stream *xdr, struct mountres *res)
+{
+	unsigned int i;
+	u32 status;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, sizeof(status));
+	if (unlikely(p == NULL))
+		return -EIO;
+	status = ntohl(*p);
+
+	for (i = 0; i <= ARRAY_SIZE(mnt_errtbl); i++) {
+		if (mnt_errtbl[i].status == status) {
+			res->errno = mnt_errtbl[i].errno;
+			return 0;
+		}
+	}
+
+	dprintk("NFS: unrecognized MNT status code: %u\n", status);
+	res->errno = -EACCES;
+	return 0;
+}
+
+static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
+{
+	unsigned int i;
+	u32 status;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, sizeof(status));
+	if (unlikely(p == NULL))
+		return -EIO;
+	status = ntohl(*p);
+
+	for (i = 0; i <= ARRAY_SIZE(mnt3_errtbl); i++) {
+		if (mnt3_errtbl[i].status == status) {
+			res->errno = mnt3_errtbl[i].errno;
+			return 0;
+		}
+	}
+
+	dprintk("NFS: unrecognized MNT3 status code: %u\n", status);
+	res->errno = -EACCES;
+	return 0;
+}
+
 static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 				struct mnt_fhstatus *res)
 {

