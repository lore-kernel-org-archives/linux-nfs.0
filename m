Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 918A7545DB5
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576143; cv=none; b=JPhAxIbIeMB3RsfIiMogtJsuHIcwEev01GbQh3GsKPyyQ+PaUB5R1UKn7igjnQbfFvH4HUB9edVvP1e36Ug/80+iA+i4+WuR3vq8c5vrUk6Ahkkgt1eLDgr7oK2Gx/o5HUHf/Oc2EKE2WRuwAxn/6LMr7p50P5s1o0ZTdFd66iA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576143; c=relaxed/simple;
	bh=+aH39AI5CmcMbZgiH9xFHXQAR/8wLy13sbu3mTQ3g5w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Bk45HkoGB5vBWU4c6ZAGDJI9yz7YDa4yppgSnPQgT1Y1bF3nPpMJnro68qvUyLecNpKcVZbqXkwL4aN/4BLqVRp7QpfnakuQMcLrgQSwtam+TteevLERYdgKOlwgSIKQKWglZyjUqZE89QIMHKvBrz6wxJwYlBBXwIH5FzPI/+4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kcq5CAi7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kcq5CAi7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DDBA71F000FF;
	Wed, 16 Sep 2026 16:29:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576141;
	bh=zOzMkyzcX6ghfhKoM7CbV4WmgST48OBnAjf9lFPY4+w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kcq5CAi7Sv1fMTwBG2m2GCdcv6IBa44ejdwD9a4RQpYC6ur2tyGohYO4mZG2+qpTb
	 WQZTjMoWEJOg794Mbq8cIkg/WMNjmu873iLYIIdhHBSXKdXnuuNx5M3ToZsWogGTeF
	 97d0UyiGm7wT3vPW8b5yfNV7nUSeZb+Buv5KdMZMwLYf8j2y3LB1dlQvw/dhAJAhWZ
	 ITk8bvK+EHRGY3kYvnu+5IrVdGuvZaX+Q2o/jeJ81fnp6QFmRL9/JwGMpgNGxRHRJc
	 lK4zHeC6qQ2v6zX2PDqh87hIdRkahq/ucp8BVDP/m9oCGfwASZeZLnGqMaYxOTC18B
	 TYJA7l2t9Oq8Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 01/27] Documentation: Add the RPC language description of NFSv2
Date: Wed, 16 Sep 2026 12:28:30 -0400
Message-ID: <20260916162859.2051-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In order to generate source code to encode and decode NFSv2 protocol
elements, include a copy of the RPC language description of NFSv2
for xdrgen to process. The language description is an amalgam of
RFC 1094 and the Open Group's XNFS specification:

 https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm

The goals of replacing hand-written XDR functions with ones that
are tool-generated are to improve memory safety and make XDR
encoding and decoding less brittle to maintain. Parts of the
NFSv4 protocol are still being extended actively. Tool-generated
XDR code reduces the time it takes to get a working implementation
of new protocol elements.

The xdrgen utility derives both the type definitions and the
encode/decode functions directly from protocol specifications,
using names and symbols familiar to anyone who knows those specs.
Unlike hand-written code that can inadvertently diverge from the
specification, xdrgen guarantees that the generated code matches
the specification exactly.

We would eventually like xdrgen to generate Rust code as well,
making the conversion of the kernel's NFS stacks to use Rust just
a little easier for us.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x | 237 ++++++++++++++++++++++++++++++++
 1 file changed, 237 insertions(+)
 create mode 100644 Documentation/sunrpc/xdr/nfs2.x

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
new file mode 100644
index 000000000000..8a05975ad65a
--- /dev/null
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -0,0 +1,237 @@
+/*
+ * This document was extracted by hand from RFC 1094. Several errors
+ * and omissions were corrected. Additional sources for this protocol
+ * specification include:
+ *
+ *   https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
+ *
+ * Note that RFC 1094's official date of publication (March 1989) is
+ * before the IETF required its RFCs to carry an explicit copyright
+ * or other IP ownership notice.
+ */
+
+const NFS_MAXDATA = 8192;
+const NFS_MAXPATHLEN = 1024;
+const NFS_MAXNAMLEN = 255;
+const NFS_COOKIESIZE = 4;
+const NFS_FHSIZE = 32;
+
+/*
+ * RFC 1094 calls the following enum "stat". That name conflicts with
+ * the Linux kernel's "struct stat" because in C, struct, union, and
+ * enum tags all share a single tag namespace. Details are specified
+ * in the C11 standard, Section 6.2.3.
+ */
+enum nfsstat {
+	NFS_OK			= 0,
+	NFSERR_PERM		= 1,
+	NFSERR_NOENT		= 2,
+	NFSERR_IO		= 5,
+	NFSERR_NXIO		= 6,
+	NFSERR_ACCES		= 13,
+	NFSERR_EXIST		= 17,
+	NFSERR_NODEV		= 19,
+	NFSERR_NOTDIR		= 20,
+	NFSERR_ISDIR		= 21,
+	NFSERR_FBIG		= 27,
+	NFSERR_NOSPC		= 28,
+	NFSERR_ROFS		= 30,
+	NFSERR_NAMETOOLONG	= 63,
+	NFSERR_NOTEMPTY		= 66,
+	NFSERR_DQUOT		= 69,
+	NFSERR_STALE		= 70,
+	NFSERR_WFLUSH		= 99
+};
+
+enum ftype {
+	NFNON		= 0,
+	NFREG		= 1,
+	NFDIR		= 2,
+	NFBLK		= 3,
+	NFCHR		= 4,
+	NFLNK		= 5
+};
+
+typedef opaque		fhandle[NFS_FHSIZE];
+typedef opaque		nfscookie[NFS_COOKIESIZE];
+
+struct timeval {
+	unsigned int	seconds;
+	unsigned int	useconds;
+};
+
+struct fattr {
+	ftype		type;
+	unsigned int	mode;
+	unsigned int	nlink;
+	unsigned int	uid;
+	unsigned int	gid;
+	unsigned int	size;
+	unsigned int	blocksize;
+	unsigned int	rdev;
+	unsigned int	blocks;
+	unsigned int	fsid;
+	unsigned int	fileid;
+	timeval		atime;
+	timeval		mtime;
+	timeval		ctime;
+};
+
+struct sattr {
+	unsigned int	mode;
+	unsigned int	uid;
+	unsigned int	gid;
+	unsigned int	size;
+	timeval		atime;
+	timeval		mtime;
+};
+
+typedef string		filename<NFS_MAXNAMLEN>;
+typedef string		path<NFS_MAXPATHLEN>;
+
+union attrstat switch (nfsstat status) {
+	case NFS_OK:
+		fattr		attributes;
+	default:
+		void;
+};
+
+struct diropargs {
+	fhandle		dir;
+	filename	name;
+};
+
+struct diropok {
+	fhandle		file;
+	fattr		attributes;
+};
+
+union diropres switch (nfsstat status) {
+	case NFS_OK:
+		diropok		diropok;
+	default:
+		void;
+};
+
+struct sattrargs {
+	fhandle		file;
+	sattr		attributes;
+};
+
+union readlinkres switch (nfsstat status) {
+	case NFS_OK:
+		path		data;
+	default:
+		void;
+};
+
+struct readargs {
+	fhandle		file;
+	unsigned int	offset;
+	unsigned int	count;
+	unsigned int	totalcount;
+};
+
+struct readresok {
+	fattr		attributes;
+	opaque		data<NFS_MAXDATA>;
+};
+
+union readres switch (nfsstat status) {
+	case NFS_OK:
+		readresok	readresok;
+	default:
+		void;
+};
+
+struct writeargs {
+	fhandle		file;
+	unsigned int	beginoffset;
+	unsigned int	offset;
+	unsigned int	totalcount;
+	opaque		data<NFS_MAXDATA>;
+};
+
+struct createargs {
+	diropargs	where;
+	sattr		attributes;
+};
+
+struct renameargs {
+	diropargs	from;
+	diropargs	to;
+};
+
+struct linkargs {
+	fhandle		from;
+	diropargs	to;
+};
+
+struct symlinkargs {
+	diropargs	from;
+	path		to;
+	sattr		attributes;
+};
+
+struct readdirargs {
+	fhandle		dir;
+	nfscookie	cookie;
+	unsigned int	count;
+};
+
+struct entry {
+	unsigned int	fileid;
+	filename	name;
+	nfscookie	cookie;
+	entry		*nextentry;
+};
+
+struct readdirok {
+	entry		*entries;
+	bool		eof;
+};
+
+union readdirres switch (nfsstat status) {
+	case NFS_OK:
+		readdirok	readdirok;
+	default:
+		void;
+};
+
+struct info {
+	unsigned int	tsize;
+	unsigned int	bsize;
+	unsigned int	blocks;
+	unsigned int	bfree;
+	unsigned int	bavail;
+};
+
+union statfsres switch (nfsstat status) {
+	case NFS_OK:
+		info		info;
+	default:
+		void;
+};
+
+program NFS_PROGRAM {
+	version NFS_VERSION {
+		void		NFSPROC_NULL(void) = 0;
+		attrstat	NFSPROC_GETATTR(fhandle) = 1;
+		attrstat	NFSPROC_SETATTR(sattrargs) = 2;
+		void		NFSPROC_ROOT(void) = 3;
+		diropres	NFSPROC_LOOKUP(diropargs) = 4;
+		readlinkres	NFSPROC_READLINK(fhandle) = 5;
+		readres		NFSPROC_READ(readargs) = 6;
+		void		NFSPROC_WRITECACHE(void) = 7;
+		attrstat	NFSPROC_WRITE(writeargs) = 8;
+		diropres	NFSPROC_CREATE(createargs) = 9;
+		nfsstat		NFSPROC_REMOVE(diropargs) = 10;
+		nfsstat		NFSPROC_RENAME(renameargs) = 11;
+		nfsstat		NFSPROC_LINK(linkargs) = 12;
+		nfsstat		NFSPROC_SYMLINK(symlinkargs) = 13;
+		diropres	NFSPROC_MKDIR(createargs) = 14;
+		nfsstat		NFSPROC_RMDIR(diropargs) = 15;
+		readdirres	NFSPROC_READDIR(readdirargs) = 16;
+		statfsres	NFSPROC_STATFS(fhandle) = 17;
+	} = 2;
+} = 100003;
-- 
2.55.0

