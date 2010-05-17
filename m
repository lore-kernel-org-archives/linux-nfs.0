From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/24] NFS: Introduce XDR helpers for basic NFSv2 data types
Date: Sun, 16 May 2010 22:45:55 -0400
Message-ID: <20100517024554.20258.47010.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab0EQCp5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:45:57 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:45:57 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new set of XDR encoding/decoding functions for NFSv2 basic
types that operate on xdr_streams.  Use coding style similar to what's
in fs/nfs/nfs4xdr.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |  342 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 342 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 279883c..9d5159f 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -3,6 +3,11 @@
  *
  * XDR functions to encode/decode NFS RPC arguments and results.
  *
+ * NFSv2 argument and result types are defined in section 2.2 of
+ * RFC 1094: "NFS: Network File System Protocol Specification".
+ * Basic data types are defined in section 2.3 of RFC 1094.
+ *
+ *
  * Copyright (C) 1992, 1993, 1994  Rick Sladkey
  * Copyright (C) 1996 Olaf Kirch
  * 04 Aug 1998  Ion Badulescu <ionut-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
@@ -61,6 +66,343 @@
 #define NFS_readdirres_sz	(1)
 #define NFS_statfsres_sz	(1+NFS_info_sz)
 
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("NFS: %s: prematurely hit end of receive buffer. "
+		"Remaining buffer length is %tu workds.\n",
+		func, xdr->end - xdr->p);
+}
+
+/*
+ * Encode/decode NFSv2 basic data types
+ *
+ * Not all basic data types have their own encoding and decoding
+ * functions.  For run-time efficiency, some data types are encoded
+ * or decoded inline.
+ */
+
+/*
+ * 2.3.1.  stat
+ *
+ *	enum stat {
+ *		NFS_OK = 0,
+ *		...
+ *	}
+ */
+static int decode_stat(struct xdr_stream *xdr, enum nfs_stat *status)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+	*status = be32_to_cpup(p);
+	return 0;
+}
+
+/*
+ * 2.3.3.  fhandle
+ *
+ *	typedef opaque fhandle[FHSIZE];
+ */
+static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	BUG_ON(unlikely(fh->size != NFS2_FHSIZE));
+	p = xdr_reserve_space(xdr, NFS2_FHSIZE);
+	BUG_ON(unlikely(p == NULL));
+	xdr_encode_opaque_fixed(p, &fh->data, NFS2_FHSIZE);
+}
+
+static int decode_fhandle(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS2_FHSIZE);
+	if (unlikely(p == NULL)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+	memcpy(&fh->data, p, NFS2_FHSIZE);
+	fh->size = NFS2_FHSIZE;
+	return 0;
+}
+
+/*
+ * 2.3.4.  timeval
+ *
+ *	struct timeval {
+ *		unsigned int seconds;
+ *		unsigned int useconds;
+ *	};
+ */
+static void encode_timeval(struct xdr_stream *xdr, const struct timespec *timep)
+{
+	__be32 *p;
+	u32 usec;
+
+	p = xdr_reserve_space(xdr, 8);
+	BUG_ON(unlikely(p == NULL));
+	usec = timep->tv_nsec ? (timep->tv_nsec / NSEC_PER_USEC) : 0;
+	*p++ = cpu_to_be32(timep->tv_sec);
+	*p = cpu_to_be32(usec);
+}
+
+/*
+ * Passing the invalid value useconds=1000000 is a Sun convention
+ * for "set to current server time".  It's needed to make
+ * permissions checks for the "touch" program across v2 mounts to
+ * Solaris and Irix servers work correctly.  Note that this is not
+ * discussed in RFC 1094; see description of sattr in section 6.1
+ * of "NFS Illustrated" by Brent Callaghan, Addison-Wesley,
+ * ISBN 0-201-32750-5
+ */
+static void encode_current_server_timeval(struct xdr_stream *xdr,
+					  const struct timespec *timep)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 8);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(timep->tv_sec);
+	*p = cpu_to_be32(1000000);
+}
+
+/*
+ * 2.3.5.  fattr
+ *
+ *	struct fattr {
+ *		ftype		type;
+ *		unsigned int	mode;
+ *		unsigned int	nlink;
+ *		unsigned int	uid;
+ *		unsigned int	gid;
+ *		unsigned int	size;
+ *		unsigned int	blocksize;
+ *		unsigned int	rdev;
+ *		unsigned int	blocks;
+ *		unsigned int	fsid;
+ *		unsigned int	fileid;
+ *		timeval		atime;
+ *		timeval		mtime;
+ *		timeval		ctime;
+ *	};
+ *
+ */
+static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	u32 rdev, type;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS_fattr_sz << 2);
+	if (unlikely(p == NULL)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+
+	fattr->valid |= NFS_ATTR_FATTR;
+
+	type			= be32_to_cpup(p++);	/* 2.3.2. ftype */
+	if (unlikely(type > NF2FIFO))
+		type = NFBAD;
+
+	fattr->mode		= be32_to_cpup(p++);
+	fattr->nlink		= be32_to_cpup(p++);
+	fattr->uid		= be32_to_cpup(p++);
+	fattr->gid		= be32_to_cpup(p++);
+	fattr->size		= be32_to_cpup(p++);
+	fattr->du.nfs2.blocksize = be32_to_cpup(p++);
+	rdev			= be32_to_cpup(p++);
+	fattr->rdev		= new_decode_dev(rdev);
+	fattr->du.nfs2.blocks	= be32_to_cpup(p++);
+	fattr->fsid.major	= be32_to_cpup(p++);
+	fattr->fsid.minor	= 0;
+	fattr->fileid		= be32_to_cpup(p++);
+
+	/* 2.3.4. timeval */
+	fattr->atime.tv_sec	= be32_to_cpup(p++);
+	fattr->atime.tv_nsec	= be32_to_cpup(p++) * NSEC_PER_USEC;
+
+	/* 2.3.4. timeval */
+	fattr->mtime.tv_sec	= be32_to_cpup(p++);
+	fattr->mtime.tv_nsec	= be32_to_cpup(p++) * NSEC_PER_USEC;
+
+	/* 2.3.4. timeval */
+	fattr->ctime.tv_sec	= be32_to_cpup(p++);
+	fattr->ctime.tv_nsec	= be32_to_cpup(p++) * NSEC_PER_USEC;
+
+	/*
+	 * RFC 1094 section 2.3.2 suggests that NF2SOCK and NF2FIFO
+	 * are not supported by version 2 of the protocol.
+	 */
+	if (type == (u32)NFCHR && rdev == (u32)NFS2_FIFO_DEV) {
+		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
+		fattr->rdev = 0;
+	}
+
+	return 0;
+}
+
+/*
+ * 2.3.6.  sattr
+ *
+ *	struct sattr {
+ *		unsigned int	mode;
+ *		unsigned int	uid;
+ *		unsigned int	gid;
+ *		unsigned int	size;
+ *		timeval		atime;
+ *		timeval		mtime;
+ *	};
+ */
+
+#define NFS2_SATTR_NOT_SET	(0xffffffff)
+
+static void encode_time_not_set(struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 8);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	*p = cpu_to_be32(NFS2_SATTR_NOT_SET);
+}
+
+static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
+{
+	unsigned int valid = attr->ia_valid;
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 16);
+	BUG_ON(unlikely(p == NULL));
+	if (valid & ATTR_MODE)
+		*p++ = cpu_to_be32(attr->ia_mode);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (valid & ATTR_UID)
+		*p++ = cpu_to_be32(attr->ia_uid);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (valid & ATTR_GID)
+		*p++ = cpu_to_be32(attr->ia_gid);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (valid & ATTR_SIZE)
+		*p++ = cpu_to_be32((u32)attr->ia_size);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+
+	if (valid & ATTR_ATIME_SET)
+		encode_timeval(xdr, &attr->ia_atime);
+	else if (valid & ATTR_ATIME)
+		encode_current_server_timeval(xdr, &attr->ia_atime);
+	else
+		encode_time_not_set(xdr);
+	if (valid & ATTR_MTIME_SET)
+		encode_timeval(xdr, &attr->ia_mtime);
+	else if (valid & ATTR_MTIME)
+		encode_current_server_timeval(xdr, &attr->ia_mtime);
+	else
+		encode_time_not_set(xdr);
+}
+
+/*
+ * 2.3.7.  filename
+ *
+ *	typedef string filename<MAXNAMLEN>;
+ */
+static void encode_filename(struct xdr_stream *xdr, const char *name, u32 count)
+{
+	__be32 *p;
+
+	BUG_ON(unlikely(count > NFS2_MAXNAMLEN));
+	p = xdr_reserve_space(xdr, 4 + count);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(count);
+	xdr_encode_opaque_fixed(p, name, count);
+}
+
+/*
+ * 2.3.8.  path
+ *
+ *	typedef string path<MAXPATHLEN>;
+ */
+static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 count)
+{
+	__be32 *p;
+
+	BUG_ON(count > NFS_MAXPATHLEN);
+	p = xdr_reserve_space(xdr, 4);
+	BUG_ON(unlikely(p == NULL));
+	*p = cpu_to_be32(count);
+	xdr_write_pages(xdr, pages, 0, count);
+}
+
+static int decode_path(struct xdr_stream *xdr)
+{
+	u32 recvd, count;
+	size_t hdrlen;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+	count = be32_to_cpup(p);
+
+	if (count >= xdr->buf->page_len || count > NFS_MAXPATHLEN) {
+		dprintk("NFS: server returned giant pathname!\n");
+		return -ENAMETOOLONG;
+	}
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (count > recvd) {
+		dprintk("NFS: server cheating in pathname result: "
+			"count %u > recvd %u\n", count, recvd);
+		return -EIO;
+	}
+
+	xdr_read_pages(xdr, count);
+	xdr_terminate_string(xdr->buf, count);
+	return 0;
+}
+
+/*
+ * 2.3.10.  diropargs
+ *
+ *	struct diropargs {
+ *		fhandle  dir;
+ *		filename name;
+ *	};
+ */
+static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
+			     const char *name, u32 count)
+{
+	encode_fhandle(xdr, fh);
+	encode_filename(xdr, name, count);
+}
+
+/*
+ * 2.3.11.  diropok
+ *
+ *	struct {
+ *		fhandle file;
+ *		fattr   attributes;
+ *	} diropok;
+ */
+static int decode_diropok(struct xdr_stream *xdr, struct nfs_fh *fh,
+			  struct nfs_fattr *fattr)
+{
+	if (decode_fhandle(xdr, fh) != 0)
+		return -EIO;
+	return decode_fattr(xdr, fattr);
+}
+
+
 /*
  * Common NFS XDR functions as inlines
  */

