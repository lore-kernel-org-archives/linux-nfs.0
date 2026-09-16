Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F32AA595749
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576175; cv=none; b=kdXmLTsdpfLSNkUuzJigQZh/PpRf8PgEOGRLivgergMAvtQ284KTK5yL5UEZ/zRXhFm8JcG7OwY11uKa4U088tmxkX1rmQAzWoeJC+7458/TOAdGaWTwXXjp/qhToR1EDRBPjq45bP3RyIR6BAlszPkwDphBOUoOhf2iUz8vZk4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576175; c=relaxed/simple;
	bh=Ngs0wMMmUu1Xz+f69pT128YfCbnQW1J4bBbON35xqyc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JTWwk5s+/eLgjWUBCSEnD/FeVjyb1M6kyNjD7hCV3RNR8yTTCMP0537cYQJM1u21Gi6XMo/xZ8lpUH34+JrYKJ53rQg7AqyDrYy0mFnxxMns/bvTEEyf4s1gZ5RyFzLvuMOPL37FIk71JC9TQZZdBjLC62ex0X04ZfenpmSNA5k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bgXnhQ7j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bgXnhQ7j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 407551F0089C;
	Wed, 16 Sep 2026 16:29:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576169;
	bh=68DcHadcq7ycoOJXbW69Z5SIENW1fAmnCBrPzM/H9fE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bgXnhQ7jgaOedNdj6FfiPF9N8m08EiBPoKlvSNF1EbVjmffggrhXdT7ZnZUi8wVdk
	 Ei+I6DwEwMpK+aXVWWovzDvfUdPgEFHSqC9uxD/aVcN3KYgkOOcQ1DwKSh3GF7Rm/O
	 wDzDvUFDEN/GvfNNZGHUSPj0THi71+bGM3IugI4trqJ0VmyVdP2k85qheIRxMkHU1b
	 zpLYnXYAZNvcX+8jeFgceX4Lqyfuo5Mngf2u2HDKTbbeu/2YuhKYwIIuFcaESOzh/X
	 LBWbVxCfbU1XxUEgdn87bMtX62Yl2aJGX4N+K7Yusnj+6XP5GQYeyHpbvObojsO3IO
	 b0WMwQvk+vyPg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 27/27] NFSD: Use xdrgen XDR functions for NFSv2 READDIR results
Date: Wed, 16 Sep 2026 12:28:58 -0400
Message-ID: <20260916162859.2051-30-cel@kernel.org>
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

READDIR is the last NFSv2 procedure whose reply is still produced by
a hand-written encoder. Its entry list is the value-follows form of
RFC 1094's "entry *entries" -- each entry prefixed by TRUE, the
sequence closed by FALSE -- streamed straight from the directory as
it is read rather than from a materialized array. The generated
encoder could not drive that: the union encoder writes the reply
status word before the entry list, yet a streamed read does not learn
the status until the directory has been read, and the aggregate loop
was bounded by a count the begin hook had to supply up front.

The preceding patches remove both obstacles. The optional-data
aggregate encoder now pulls entries until the hook signals end, so no
count is needed, and the streaming directory reader yields one entry
at a time during encode. Mark readdirok's entry list as an aggregate
and regenerate; the struct definitions stay the verbatim RFC 1094
types, and the lone "pragma aggregate readdirok entries" selects the
hook-driven codec.

Split the read across the two phases so the generated encoder owns
the framing. nfsd_proc_readdir() opens the directory, where an open
error becomes the reply status the union encoder then writes, and the
encode hooks stream the entries: each pull reserves a placeholder
cookie and back-patches the preceding entry's cookie once the
following entry's resume offset is known; the end hook back-patches
the final cookie and reports eof. nfssvc_release_readdirres() closes
the reader and releases the file handle. The decode hooks are stubs
-- a server never decodes a READDIR result -- present only to satisfy
the generated decoder's linkage.

Retire struct nfsd_readdirres for an embedded struct readdirres so
the RPC dispatch layer can cast the response to its xdrgen type.
The directory's svc_fh moves into that wrapper and struct
readdirargs_wrapper goes away. svc_process() zeroes the result buffer
before decode but leaves the argument buffer as the previous request
left it, and ->pc_release runs even when decoding fails. A file
handle kept in the argument wrapper would reach fh_put() on that path
uninitialized.

The generated encoder reserves reply space through the xdr_stream,
which does not advance rq_next_page as it moves onto the next page.
svcrdma retains only the pages below rq_next_page across Send
completion, so the end hook sets rq_next_page past the last page the
reply uses, as nfsd4_encode_operation() does.

A host error during the streamed read cannot retract entries already
on the wire, so it ends the list as a truncated, non-eof reply rather
than an error status; an error opening the directory is still
reported as the reply status. The bytes on the wire are otherwise
unchanged.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |  10 ++
 fs/nfsd/nfs2xdr_gen.c              |  35 ++++-
 fs/nfsd/nfs2xdr_gen.h              |  13 +-
 fs/nfsd/nfsproc.c                  |  67 +++------
 fs/nfsd/nfsxdr.c                   | 231 +++++++++++++++++++----------
 fs/nfsd/xdr.h                      |  35 +++--
 include/linux/sunrpc/xdrgen/nfs2.h |   2 +-
 7 files changed, 246 insertions(+), 147 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index 932968c24d99..30e9782c17ce 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -198,6 +198,16 @@ struct readdirok {
 	bool		eof;
 };
 
+/*
+ * A spike encoding the entry list through the aggregate codec.  The
+ * list encodes as the value-follows form -- each entry prefixed by
+ * TRUE, the sequence closed by FALSE -- and the encode hooks stream it
+ * straight from the directory during reply encoding rather than from a
+ * materialized array.  The struct definitions above are the verbatim
+ * RFC 1094 types; only this pragma selects the hook-driven codec.
+ */
+pragma aggregate readdirok entries;
+
 union readdirres switch (nfsstat status) {
 	case NFS_OK:
 		readdirok	readdirok;
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index 0ddfd9bc4a99..8a3e8ee8db0e 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:26:14 2026
+// XDR specification modification time: Tue Sep  8 11:26:28 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -363,11 +363,7 @@ xdrgen_decode_entry(struct xdr_stream *xdr, struct entry *ptr)
 static bool __maybe_unused
 xdrgen_decode_readdirok(struct xdr_stream *xdr, struct readdirok *ptr)
 {
-	if (!xdrgen_decode_entry(xdr, ptr->entries))
-		return false;
-	if (!xdrgen_decode_bool(xdr, &ptr->eof))
-		return false;
-	return true;
+	return false;
 }
 
 static bool __maybe_unused
@@ -892,8 +888,31 @@ xdrgen_encode_entry(struct xdr_stream *xdr, const struct entry *value)
 static bool __maybe_unused
 xdrgen_encode_readdirok(struct xdr_stream *xdr, const struct readdirok *value)
 {
-	if (!xdrgen_encode_entry(xdr, value->entries))
-		return false;
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS2_READDIROK_ENTRIES,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs2_readdirok_encode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; ; cursor.index++) {
+			struct entry element = {};
+
+			if (!nfs2_readdirok_encode(&cursor, &element))
+				break;
+			if (!xdrgen_encode_entry(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (ok && !xdrgen_encode_entry(xdr, NULL))
+			ok = false;
+		if (!nfs2_readdirok_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_encode_bool(xdr, value->eof))
 		return false;
 	return true;
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index c3641ba63bb3..7d259aa31191 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:26:14 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:28 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
@@ -13,6 +13,17 @@
 #include <linux/sunrpc/xdrgen/_builtins.h>
 #include <linux/sunrpc/xdrgen/nfs2.h>
 
+enum {
+	NFS2_READDIROK_ENTRIES,
+};
+
+bool nfs2_readdirok_encode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs2_readdirok_encode(struct xdrgen_aggregate_cursor *c, struct entry *out);
+bool nfs2_readdirok_encode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+bool nfs2_readdirok_decode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs2_readdirok_decode(struct xdrgen_aggregate_cursor *c, const struct entry *in);
+bool nfs2_readdirok_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+
 bool nfs_svc_decode_fhandle(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index df610fe3977d..1f74008bc06a 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -116,13 +116,6 @@ struct statfsres_wrapper {
 
 static_assert(offsetof(struct statfsres_wrapper, xdrgen) == 0);
 
-struct readdirargs_wrapper {
-	struct readdirargs	xdrgen;
-	struct svc_fh		fh;
-};
-
-static_assert(offsetof(struct readdirargs_wrapper, xdrgen) == 0);
-
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -1124,28 +1117,16 @@ static __be32 nfsd_proc_rmdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static void nfsd_init_dirlist_pages(struct svc_rqst *rqstp,
-				    struct nfsd_readdirres *resp,
-				    u32 count)
-{
-	struct xdr_buf *buf = &resp->dirlist;
-	struct xdr_stream *xdr = &resp->xdr;
-
-	memset(buf, 0, sizeof(*buf));
-
-	/* Reserve room for the NULL ptr & eof flag (-2 words) */
-	buf->buflen = clamp(count, (u32)(XDR_UNIT * 2), (u32)PAGE_SIZE);
-	buf->buflen -= XDR_UNIT * 2;
-	buf->pages = rqstp->rq_next_page;
-	rqstp->rq_next_page++;
-
-	xdr_init_encode_pages(xdr, buf);
-}
-
 /**
  * nfsd_proc_readdir - READDIR: Read from directory
  * @rqstp: RPC transaction context
  *
+ * The directory is opened here so the reply status reflects any open
+ * error before the generated encoder writes the status word.  The
+ * entry list is streamed from the reply wrapper's directory reader
+ * during encode; nfssvc_release_readdirres() closes the reader and
+ * releases the file handle.
+ *
  * Return:
  *   %rpc_success:		RPC executed successfully
  *
@@ -1154,24 +1135,19 @@ static void nfsd_init_dirlist_pages(struct svc_rqst *rqstp,
  */
 static __be32 nfsd_proc_readdir(struct svc_rqst *rqstp)
 {
-	struct readdirargs_wrapper *argp = rqstp->rq_argp;
-	struct nfsd_readdirres *resp = rqstp->rq_resp;
-	loff_t offset = be32_to_cpup((__be32 *)argp->xdrgen.cookie);
-	struct svc_fh *fhp = &argp->fh;
+	struct readdirargs *argp = rqstp->rq_argp;
+	struct readdirres_wrapper *resp = rqstp->rq_resp;
+	loff_t offset = be32_to_cpup((__be32 *)argp->cookie);
+	struct svc_fh *fhp = &resp->fh;
+	__be32 status;
 
-	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.dir);
-	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.count, offset);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->dir);
+	trace_nfsd_vfs_readdir(rqstp, fhp, argp->count, offset);
 
-	nfsd_init_dirlist_pages(rqstp, resp, argp->xdrgen.count);
+	resp->count = argp->count;
+	status = nfsd_readdir_open(rqstp, fhp, &offset, &resp->iter);
 
-	resp->common.err = nfs_ok;
-	resp->cookie_offset = 0;
-	resp->status = nfsd_readdir(rqstp, fhp, &offset,
-				    &resp->common, nfssvc_encode_entry);
-	nfssvc_encode_nfscookie(&resp->xdr, resp->cookie_offset, offset);
-
-	fh_put(fhp);
-	resp->status = nfsd_map_status(resp->status);
+	resp->xdrgen.status = nfsd_map_status(status);
 	return rpc_success;
 }
 
@@ -1401,10 +1377,11 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 	[NFSPROC_READDIR] = {
 		.pc_func	= nfsd_proc_readdir,
 		.pc_decode	= nfs_svc_decode_readdirargs,
-		.pc_encode	= nfssvc_encode_readdirres,
-		.pc_argsize	= sizeof(struct readdirargs_wrapper),
+		.pc_encode	= nfs_svc_encode_readdirres,
+		.pc_release	= nfssvc_release_readdirres,
+		.pc_argsize	= sizeof(struct readdirargs),
 		.pc_argzero	= 0,
-		.pc_ressize	= sizeof(struct nfsd_readdirres),
+		.pc_ressize	= sizeof(struct readdirres_wrapper),
 		.pc_cachetype	= RC_NOCACHE,
 		.pc_name	= "READDIR",
 	},
@@ -1434,12 +1411,12 @@ union nfsd_xdrstore {
 	struct renameargs_wrapper	renameargs;
 	struct linkargs_wrapper		linkargs;
 	struct symlinkargs_wrapper	symlinkargs;
-	struct readdirargs_wrapper	readdirargs;
+	struct readdirargs	readdirargs;
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
 	struct readlinkres	readlinkres;
 	struct readres		readres;
-	struct nfsd_readdirres	readdirres;
+	struct readdirres_wrapper	readdirres;
 	struct statfsres_wrapper	statfsres;
 };
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 3476ebe14c45..d3c0c84c0e98 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -12,6 +12,7 @@
 #include "xdr.h"
 #include "nfs2xdr_gen.h"
 #include "auth.h"
+#include "trace.h"
 
 /*
  * Linux-internal ftype values for socket and unknown inodes, not
@@ -194,37 +195,26 @@ nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_readdirres *resp = rqstp->rq_resp;
-	struct xdr_buf *dirlist = &resp->dirlist;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		svcxdr_encode_opaque_pages(rqstp, xdr, dirlist->pages, 0,
-					   dirlist->len);
-		/* no more entries */
-		if (xdr_stream_encode_item_absent(xdr) < 0)
-			return false;
-		if (xdr_stream_encode_bool(xdr, resp->common.err == nfserr_eof) < 0)
-			return false;
-		break;
-	}
-
-	return true;
-}
+/*
+ * READDIR reply entry list (RFC 1094).  The entry list is the
+ * value-follows form of "entry *entries": each entry prefixed by TRUE,
+ * the sequence closed by FALSE.  xdrgen's aggregate codec owns that
+ * framing; the hooks below stream one entry at a time straight from the
+ * directory into the live reply, mirroring nfsd4_encode_dirlist4.  The
+ * directory was opened in nfsd_proc_readdir(), so reading and encoding
+ * happen together here during reply encoding.
+ */
 
 /**
- * nfssvc_encode_nfscookie - Encode a directory cookie
- * @xdr: stream into which to encode the cookie
- * @pos: byte position in the stream
- * @cookie: cookie to be encoded
+ * nfssvc_encode_nfscookie - Back-patch a directory entry cookie
+ * @xdr: stream holding the reserved cookie slot
+ * @pos: byte position of the cookie slot, or 0 when there is none
+ * @cookie: cookie value to write
  *
- * The buffer space for the offset cookie has already been reserved
- * by svcxdr_encode_entry_common().
+ * An NFSv2 entry's cookie is the offset at which the following entry is
+ * read.  That offset is not known until the following entry is pulled,
+ * so each entry is encoded with a placeholder cookie that a later call
+ * overwrites once the resume offset is known.
  */
 void nfssvc_encode_nfscookie(struct xdr_stream *xdr, unsigned int pos,
 			     u32 cookie)
@@ -236,71 +226,146 @@ void nfssvc_encode_nfscookie(struct xdr_stream *xdr, unsigned int pos,
 	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT);
 }
 
-static bool
-svcxdr_encode_entry_common(struct nfsd_readdirres *resp, const char *name,
-			   int namlen, loff_t offset, u64 ino)
+/**
+ * nfs2_readdirok_encode_begin - size the streaming entry budget
+ * @c: aggregate cursor for the entry list
+ *
+ * Derive the entry byte budget from the space left in the live reply
+ * and the client's count hint, reserving room for the list terminator
+ * and the eof flag that follow the entries.
+ *
+ * Return: true.
+ */
+bool nfs2_readdirok_encode_begin(struct xdrgen_aggregate_cursor *c)
 {
-	struct xdr_buf *dirlist = &resp->dirlist;
-	struct xdr_stream *xdr = &resp->xdr;
-
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	/* fileid */
-	if (xdr_stream_encode_u32(xdr, (u32)ino) < 0)
-		return false;
-	/* name */
-	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS_MAXNAMLEN)) < 0)
-		return false;
-	/* cookie */
-	resp->cookie_offset = dirlist->len;
-	if (xdr_stream_encode_u32(xdr, ~0U) < 0)
-		return false;
+	struct svc_rqst *rqstp = c->ctx;
+	struct readdirres_wrapper *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+	int bytes_left;
 
+	/* Reserve the terminator FALSE and the eof bool (two words). */
+	bytes_left = xdr->buf->buflen - xdr->buf->len - XDR_UNIT * 2;
+	if (bytes_left < 0)
+		bytes_left = 0;
+	resp->space_left = min_t(u32, bytes_left,
+				 clamp(resp->count, (u32)(XDR_UNIT * 2),
+				       (u32)PAGE_SIZE) - XDR_UNIT * 2);
+	resp->cookie_offset = 0;
 	return true;
 }
 
 /**
- * nfssvc_encode_entry - encode one NFSv2 READDIR entry
- * @data: directory context
- * @name: name of the object to be encoded
- * @namlen: length of that name, in bytes
- * @offset: the offset of the previous entry
- * @ino: the fileid of this entry
- * @d_type: unused
+ * nfs2_readdirok_encode - stream the next READDIR entry
+ * @c: aggregate cursor for the entry list
+ * @out: OUT: entry the framing encodes when one is produced
  *
- * Return values:
- *   %0: Entry was successfully encoded.
- *   %-EINVAL: An encoding problem occurred, secondary status code in resp->common.err
+ * Back-patch the previous entry's placeholder cookie with this entry's
+ * resume offset, then, if the reply budget allows, project the next
+ * directory entry into @out for the generated per-entry encoder.
  *
- * On exit, the following fields are updated:
- *   - resp->xdr
- *   - resp->common.err
- *   - resp->cookie_offset
+ * Return: true when @out holds an entry to encode; false to end the
+ * list -- because the directory is exhausted, a host error struck, or
+ * the reply budget filled.  On budget exhaustion the previous entry's
+ * cookie already points at the rejected entry, the client's resume
+ * point.
  */
-int nfssvc_encode_entry(void *data, const char *name, int namlen,
-			loff_t offset, u64 ino, unsigned int d_type)
+bool nfs2_readdirok_encode(struct xdrgen_aggregate_cursor *c,
+			   struct entry *out)
 {
-	struct readdir_cd *ccd = data;
-	struct nfsd_readdirres *resp = container_of(ccd,
-						    struct nfsd_readdirres,
-						    common);
-	unsigned int starting_length = resp->dirlist.len;
+	struct svc_rqst *rqstp = c->ctx;
+	struct readdirres_wrapper *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+	struct buffered_dirent *de;
+	int namlen;
+	u32 need;
 
-	/* The offset cookie for the previous entry */
-	nfssvc_encode_nfscookie(&resp->xdr, resp->cookie_offset, offset);
+	/*
+	 * The previous entry was just encoded; commit the stream and note
+	 * its cookie slot -- the entry's last XDR word -- so it can be
+	 * back-patched once this entry's resume offset is known.
+	 */
+	if (c->index) {
+		xdr_commit_encode(xdr);
+		resp->cookie_offset = xdr->buf->len - XDR_UNIT;
+	}
 
-	if (!svcxdr_encode_entry_common(resp, name, namlen, offset, ino))
-		goto out_toosmall;
+	de = nfsd_readdir_next(&resp->iter);
+	if (!de)
+		return false;
 
-	xdr_commit_encode(&resp->xdr);
-	resp->common.err = nfs_ok;
-	return 0;
+	/* The previous entry's cookie is this entry's resume offset. */
+	nfssvc_encode_nfscookie(xdr, resp->cookie_offset, (u32)de->offset);
 
-out_toosmall:
-	resp->cookie_offset = 0;
-	resp->common.err = nfserr_toosmall;
-	resp->dirlist.len = starting_length;
-	return -EINVAL;
+	namlen = min_t(int, de->namlen, NFS_MAXNAMLEN);
+
+	/* value-follows + fileid + name (length + data) + cookie */
+	need = XDR_UNIT * (4 + XDR_QUADLEN(namlen));
+	if (need > resp->space_left)
+		return false;
+	resp->space_left -= need;
+
+	out->fileid = (u32)de->ino;
+	out->name.len = namlen;
+	out->name.data = (unsigned char *)de->name;
+	memset(out->cookie, 0, sizeof(out->cookie));	/* back-patched later */
+
+	trace_nfsd_dirent(resp->iter.fhp, de->ino, de->name, namlen);
+	return true;
+}
+
+/**
+ * nfs2_readdirok_encode_end - finish the streamed entry list
+ * @c: aggregate cursor for the entry list
+ * @ok: false if the framing hit a wire error while encoding the list
+ *
+ * Back-patch the final entry's cookie with the directory's resume
+ * offset and report eof.  A list cut short by the reply budget or a
+ * host error reports eof false, so the client reads the rest with a
+ * follow-up request.
+ *
+ * Return: true.
+ */
+bool nfs2_readdirok_encode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct readdirres_wrapper *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+
+	if (ok)
+		nfssvc_encode_nfscookie(xdr, resp->cookie_offset,
+					(u32)resp->iter.offset);
+	resp->xdrgen.u.readdirok.eof = resp->iter.eof;
+
+	/*
+	 * The xdr_stream primitives don't manage rq_next_page, and
+	 * svcrdma retains only the pages below it for Send completion.
+	 * The eof word that follows starts a new page when this one is
+	 * full.
+	 */
+	rqstp->rq_next_page = xdr->page_ptr + 1;
+	if (xdr->p == xdr->end)
+		rqstp->rq_next_page++;
+	return true;
+}
+
+/*
+ * A server never decodes a READDIR result; these satisfy the linkage
+ * of the generated (unused) decoder.
+ */
+bool nfs2_readdirok_decode_begin(struct xdrgen_aggregate_cursor *c)
+{
+	return false;
+}
+
+bool nfs2_readdirok_decode(struct xdrgen_aggregate_cursor *c,
+			   const struct entry *in)
+{
+	return false;
+}
+
+bool nfs2_readdirok_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	return false;
 }
 
 /*
@@ -312,3 +377,11 @@ void nfssvc_release_attrstat(struct svc_rqst *rqstp)
 
 	fh_put(&resp->fh);
 }
+
+void nfssvc_release_readdirres(struct svc_rqst *rqstp)
+{
+	struct readdirres_wrapper *resp = rqstp->rq_resp;
+
+	nfsd_readdir_close(&resp->iter);
+	fh_put(&resp->fh);
+}
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 57dbf5166599..9da15a9ff242 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -14,28 +14,37 @@ struct nfsd_attrstat {
 	struct kstat		stat;
 };
 
-struct nfsd_readdirres {
-	/* Components of the reply */
-	__be32			status;
+/*
+ * Declared here rather than in nfsproc.c with the other proc wrappers
+ * because READDIR's encode hooks in nfsxdr.c reference it. The xdrgen
+ * field must be first so the struct can be cast to its XDR type for the
+ * RPC dispatch layer.
+ *
+ * The file handle lives here rather than in an argument wrapper: the
+ * RPC layer zeroes the result before decode, so ->pc_release can run on
+ * a request that failed to decode.
+ */
+struct readdirres_wrapper {
+	struct readdirres	xdrgen;
+	struct svc_fh		fh;
 
-	int			count;
-
-	/* Used to encode the reply's entry list */
-	struct xdr_stream	xdr;
-	struct xdr_buf		dirlist;
-	struct readdir_cd	common;
-	unsigned int		cookie_offset;
+	/* Streaming state for encoding the reply's entry list */
+	struct nfsd_readdir_iter iter;		/* directory reader */
+	u32			count;		/* client's reply size hint */
+	u32			space_left;	/* remaining entry budget */
+	unsigned int		cookie_offset;	/* prev entry's cookie slot */
 };
 
+static_assert(offsetof(struct readdirres_wrapper, xdrgen) == 0);
+
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfssvc_encode_nfscookie(struct xdr_stream *xdr, unsigned int pos,
 			     u32 cookie);
-int nfssvc_encode_entry(void *data, const char *name, int namlen,
-			loff_t offset, u64 ino, unsigned int d_type);
+
+void nfssvc_release_readdirres(struct svc_rqst *rqstp);
 
 void nfssvc_release_attrstat(struct svc_rqst *rqstp);
 
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index 8f7b79983e3e..1d26de39ac69 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:26:14 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:28 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
-- 
2.55.0

