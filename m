Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33488 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933827AbbHDLzx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:53 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 38/40] nfs: Remove unused xdr page offsets in getacl/setacl arguments
Date: Tue,  4 Aug 2015 13:53:36 +0200
Message-Id: <1438689218-6921-39-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The arguments passed around for getacl and setacl xdr encoding, struct
nfs_setaclargs and struct nfs_getaclargs, both contain an array of
pages, an offset into the first page, and the length of the page data.
The offset is unused as it is always zero; remove it.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs4proc.c       | 5 ++---
 fs/nfs/nfs4xdr.c        | 4 ++--
 include/linux/nfs_xdr.h | 2 --
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3acb1eb..f675e92 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4456,7 +4456,7 @@ static inline int nfs4_server_supports_acls(struct nfs_server *server)
 #define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
 
 static int buf_to_pages_noslab(const void *buf, size_t buflen,
-		struct page **pages, unsigned int *pgbase)
+		struct page **pages)
 {
 	struct page *newpage, **spages;
 	int rc = 0;
@@ -4600,7 +4600,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		goto out_free;
 
 	args.acl_len = npages * PAGE_SIZE;
-	args.acl_pgbase = 0;
 
 	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
@@ -4692,7 +4691,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	if (npages > ARRAY_SIZE(pages))
 		return -ERANGE;
-	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
+	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages);
 	if (i < 0)
 		return i;
 	nfs4_inode_return_delegation(inode);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 67197b8..b2a243b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1646,7 +1646,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
-	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
+	xdr_write_pages(xdr, arg->acl_pages, 0, arg->acl_len);
 }
 
 static void
@@ -2478,7 +2478,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
-		args->acl_pages, args->acl_pgbase, args->acl_len);
+		args->acl_pages, 0, args->acl_len);
 
 	encode_nops(&hdr);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7bbe505..f10bbac 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -685,7 +685,6 @@ struct nfs_setaclargs {
 	struct nfs4_sequence_args	seq_args;
 	struct nfs_fh *			fh;
 	size_t				acl_len;
-	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
 };
 
@@ -697,7 +696,6 @@ struct nfs_getaclargs {
 	struct nfs4_sequence_args 	seq_args;
 	struct nfs_fh *			fh;
 	size_t				acl_len;
-	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
 };
 
-- 
2.5.0

