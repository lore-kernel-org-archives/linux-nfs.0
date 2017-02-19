Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33630 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751630AbdBSVIl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 16:08:41 -0500
Received: by mail-it0-f67.google.com with SMTP id e137so8856330itc.0
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 13:08:41 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 3/8] NFSv4: Replace the open coded decode_opaque_inline() with the new generic
Date: Sun, 19 Feb 2017 16:08:27 -0500
Message-Id: <20170219210832.61213-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170219210832.61213-3-trond.myklebust@primarydata.com>
References: <20170219210832.61213-1-trond.myklebust@primarydata.com>
 <20170219210832.61213-2-trond.myklebust@primarydata.com>
 <20170219210832.61213-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also ensure that we always check that the size of the decoded object
matches the expectation that it must be smaller than NFS4_OPAQUE_LIMIT.
This should be true for all the current users of decode_opaque_inline(),
including decode_ace(), decode_pathname(), decode_attr_fs_locations()
and decode_exchange_id().

Note that this allows us to get rid of a number of existing checks in
decode_exchange_id(),

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4xdr.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5f0a6fcd0030..d10cc2a62dff 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3050,20 +3050,15 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 
 static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
 {
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	*len = be32_to_cpup(p);
-	p = xdr_inline_decode(xdr, *len);
-	if (unlikely(!p))
-		goto out_overflow;
-	*string = (char *)p;
+	ssize_t ret = xdr_stream_decode_opaque_inline(xdr, (void **)string,
+			NFS4_OPAQUE_LIMIT);
+	if (unlikely(ret < 0)) {
+		if (ret == -EBADMSG)
+			print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+	*len = ret;
 	return 0;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 
 static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
@@ -5645,8 +5640,6 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
 		return status;
-	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
-		return -EIO;
 	memcpy(res->server_owner->major_id, dummy_str, dummy);
 	res->server_owner->major_id_sz = dummy;
 
@@ -5654,8 +5647,6 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
 		return status;
-	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
-		return -EIO;
 	memcpy(res->server_scope->server_scope, dummy_str, dummy);
 	res->server_scope->server_scope_sz = dummy;
 
@@ -5670,16 +5661,12 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 		if (unlikely(status))
 			return status;
-		if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
-			return -EIO;
 		memcpy(res->impl_id->domain, dummy_str, dummy);
 
 		/* nii_name */
 		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 		if (unlikely(status))
 			return status;
-		if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
-			return -EIO;
 		memcpy(res->impl_id->name, dummy_str, dummy);
 
 		/* nii_date */
-- 
2.9.3

