Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51526 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755247Ab2JOVbv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:31:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/13] NFS: Remove asserts from the NFS XDR code
Date: Mon, 15 Oct 2012 17:30:55 -0400
Message-Id: <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the ones that are not trivial to check into WARN_ON_ONCE().
Remove checks for things such as NFS2_MAXPATHLEN, which are trivially
done by the caller.

Add a comment to the case of nfs3_xdr_enc_setacl3args. What is being
done there is just wrong...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs2xdr.c | 4 +---
 fs/nfs/nfs3xdr.c | 7 +++----
 fs/nfs/nfs4xdr.c | 6 ++----
 3 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index d04f0df..06b9df4 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -195,7 +195,6 @@ static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
 {
 	__be32 *p;
 
-	BUG_ON(fh->size != NFS2_FHSIZE);
 	p = xdr_reserve_space(xdr, NFS2_FHSIZE);
 	memcpy(p, fh->data, NFS2_FHSIZE);
 }
@@ -388,7 +387,7 @@ static void encode_filename(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	BUG_ON(length > NFS2_MAXNAMLEN);
+	WARN_ON_ONCE(length > NFS2_MAXNAMLEN);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, name, length);
 }
@@ -428,7 +427,6 @@ static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
 {
 	__be32 *p;
 
-	BUG_ON(length > NFS2_MAXPATHLEN);
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(length);
 	xdr_write_pages(xdr, pages, 0, length);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 6cbe894..bffc324 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -198,7 +198,7 @@ static void encode_filename3(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	BUG_ON(length > NFS3_MAXNAMLEN);
+	WARN_ON_ONCE(length > NFS3_MAXNAMLEN);
 	p = xdr_reserve_space(xdr, 4 + length);
 	xdr_encode_opaque(p, name, length);
 }
@@ -238,7 +238,6 @@ out_overflow:
 static void encode_nfspath3(struct xdr_stream *xdr, struct page **pages,
 			    const u32 length)
 {
-	BUG_ON(length > NFS3_MAXPATHLEN);
 	encode_uint32(xdr, length);
 	xdr_write_pages(xdr, pages, 0, length);
 }
@@ -388,7 +387,6 @@ out_overflow:
  */
 static void encode_ftype3(struct xdr_stream *xdr, const u32 type)
 {
-	BUG_ON(type > NF3FIFO);
 	encode_uint32(xdr, type);
 }
 
@@ -443,7 +441,7 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
 {
 	__be32 *p;
 
-	BUG_ON(fh->size > NFS3_FHSIZE);
+	WARN_ON_ONCE(fh->size > NFS3_FHSIZE);
 	p = xdr_reserve_space(xdr, 4 + fh->size);
 	xdr_encode_opaque(p, fh->data, fh->size);
 }
@@ -1339,6 +1337,7 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 	error = nfsacl_encode(xdr->buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
 			    args->acl_access : NULL, 1, 0);
+	/* FIXME: this is just broken */
 	BUG_ON(error < 0);
 	error = nfsacl_encode(xdr->buf, base + error, args->inode,
 			    (args->mask & NFS_DFACL) ?
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 40836ee..672d9b0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -936,7 +936,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	 * but this is not required as a MUST for the server to do so. */
 	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
 
-	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
+	WARN_ON_ONCE(hdr->taglen > NFS4_MAXTAGLEN);
 	encode_string(xdr, hdr->taglen, hdr->tag);
 	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(hdr->minorversion);
@@ -955,7 +955,7 @@ static void encode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 op,
 
 static void encode_nops(struct compound_hdr *hdr)
 {
-	BUG_ON(hdr->nops > NFS4_MAX_OPS);
+	WARN_ON_ONCE(hdr->nops > NFS4_MAX_OPS);
 	*hdr->nops_p = htonl(hdr->nops);
 }
 
@@ -1403,7 +1403,6 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 		*p = cpu_to_be32(NFS4_OPEN_NOCREATE);
 		break;
 	default:
-		BUG_ON(arg->claim != NFS4_OPEN_CLAIM_NULL);
 		*p = cpu_to_be32(NFS4_OPEN_CREATE);
 		encode_createmode(xdr, arg);
 	}
@@ -1621,7 +1620,6 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
-	BUG_ON(arg->acl_len % 4);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
-- 
1.7.11.7

