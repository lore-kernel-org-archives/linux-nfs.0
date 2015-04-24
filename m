Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36618 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030558AbbDXLFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:48 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 40/45] nfs: Remove unused xdr page offsets in getacl/setacl arguments
Date: Fri, 24 Apr 2015 13:04:37 +0200
Message-Id: <082664972e957e6585c059865a397185ba7d5c88.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The arguments passed around for getacl and setacl xdr encoding, struct
nfs_setaclargs and struct nfs_getaclargs, both contain an array of pages, an
offset into the first page, and the length of the page data. The offset is
unused as it is always zero; remove it.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs4proc.c       | 5 ++---
 fs/nfs/nfs4xdr.c        | 4 ++--
 include/linux/nfs_xdr.h | 2 --
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 627f37c..8c50670 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4440,7 +4440,7 @@ static inline int nfs4_server_supports_acls(struct nfs_server *server)
 #define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
 
 static int buf_to_pages_noslab(const void *buf, size_t buflen,
-		struct page **pages, unsigned int *pgbase)
+		struct page **pages)
 {
 	struct page *newpage, **spages;
 	int rc = 0;
@@ -4584,7 +4584,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		goto out_free;
 
 	args.acl_len = npages * PAGE_SIZE;
-	args.acl_pgbase = 0;
 
 	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
@@ -4676,7 +4675,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	if (npages > ARRAY_SIZE(pages))
 		return -ERANGE;
-	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
+	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages);
 	if (i < 0)
 		return i;
 	nfs4_inode_return_delegation(inode);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dd7a800..4372fc4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1644,7 +1644,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
-	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
+	xdr_write_pages(xdr, arg->acl_pages, 0, arg->acl_len);
 }
 
 static void
@@ -2517,7 +2517,7 @@ static int nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
-		args->acl_pages, args->acl_pgbase, args->acl_len);
+		args->acl_pages, 0, args->acl_len);
 
 	encode_nops(&hdr);
 	return 0;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4cb3eaa..92134cf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -640,7 +640,6 @@ struct nfs_setaclargs {
 	struct nfs4_sequence_args	seq_args;
 	struct nfs_fh *			fh;
 	size_t				acl_len;
-	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
 };
 
@@ -652,7 +651,6 @@ struct nfs_getaclargs {
 	struct nfs4_sequence_args 	seq_args;
 	struct nfs_fh *			fh;
 	size_t				acl_len;
-	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
 };
 
-- 
2.1.0

