Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34806 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751745AbdBSS7U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 13:59:20 -0500
Received: by mail-io0-f194.google.com with SMTP id c80so3081695iod.1
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 10:59:19 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/8] NFSv4: Replace ad-hoc xdr encode/decode helpers with xdr_stream_* generics
Date: Sun, 19 Feb 2017 13:58:57 -0500
Message-Id: <20170219185903.42043-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170219185903.42043-2-trond.myklebust@primarydata.com>
References: <20170219185903.42043-1-trond.myklebust@primarydata.com>
 <20170219185903.42043-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c                  |  8 ++------
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 +----
 fs/nfs/nfs4xdr.c                       | 33 +++++++++------------------------
 3 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index eb094c6011d8..e732a65db546 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -582,12 +582,8 @@ static __be32 decode_notify_lock_args(struct svc_rqst *rqstp, struct xdr_stream
 
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, 4 + len);
-	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
-	xdr_encode_opaque(p, str, len);
+	if (unlikely(xdr_stream_encode_opaque(xdr, str, len) < 0))
+		return cpu_to_be32(NFS4ERR_RESOURCE);
 	return 0;
 }
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 42e3e9daa328..471efdc2589d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1966,10 +1966,7 @@ static int ff_layout_encode_ioerr(struct xdr_stream *xdr,
 static void
 encode_opaque_fixed(struct xdr_stream *xdr, const void *buf, size_t len)
 {
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, len);
-	xdr_encode_opaque_fixed(p, buf, len);
+	WARN_ON_ONCE(xdr_stream_encode_opaque_fixed(xdr, buf, len) < 0);
 }
 
 static void
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e9255cb453e6..5f0a6fcd0030 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -924,34 +924,22 @@ static __be32 *reserve_space(struct xdr_stream *xdr, size_t nbytes)
 
 static void encode_opaque_fixed(struct xdr_stream *xdr, const void *buf, size_t len)
 {
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, len);
-	xdr_encode_opaque_fixed(p, buf, len);
+	WARN_ON_ONCE(xdr_stream_encode_opaque_fixed(xdr, buf, len) < 0);
 }
 
 static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4 + len);
-	xdr_encode_opaque(p, str, len);
+	WARN_ON_ONCE(xdr_stream_encode_opaque(xdr, str, len) < 0);
 }
 
 static void encode_uint32(struct xdr_stream *xdr, u32 n)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(n);
+	WARN_ON_ONCE(xdr_stream_encode_u32(xdr, n) < 0);
 }
 
 static void encode_uint64(struct xdr_stream *xdr, u64 n)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 8);
-	xdr_encode_hyper(p, n);
+	WARN_ON_ONCE(xdr_stream_encode_u64(xdr, n) < 0);
 }
 
 static void encode_nfs4_seqid(struct xdr_stream *xdr,
@@ -4294,15 +4282,12 @@ static int decode_access(struct xdr_stream *xdr, u32 *supported, u32 *access)
 
 static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
 {
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, len);
-	if (likely(p)) {
-		memcpy(buf, p, len);
-		return 0;
+	ssize_t ret = xdr_stream_decode_opaque_fixed(xdr, buf, len);
+	if (unlikely(ret < 0)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
 	}
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	return 0;
 }
 
 static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
-- 
2.9.3

