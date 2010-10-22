Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52149 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757166Ab0JVOOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:47 -0400
Message-ID: <4CC19C56.7030701@netapp.com>
Date: Fri, 22 Oct 2010 10:14:46 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/10] NFS: Readdir plus in v4
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

By requsting more attributes during a readdir, we can mimic the readdir plus
operation that was in NFSv3.

To test, I ran the command `ls -lU --color=none` on directories with various
numbers of files.  Without readdir plus, I see this:

n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
--------+-----------+-----------+-----------+-----------+----------
real    | 0m00.153s | 0m00.589s | 0m05.601s | 0m56.691s | 9m59.128s
user    | 0m00.007s | 0m00.007s | 0m00.077s | 0m00.703s | 0m06.800s
sys     | 0m00.010s | 0m00.070s | 0m00.633s | 0m06.423s | 1m10.005s
access  | 3         | 1         | 1         | 4         | 31
getattr | 2         | 1         | 1         | 1         | 1
lookup  | 104       | 1,003     | 10,003    | 100,003   | 1,000,003
readdir | 2         | 16        | 158       | 1,575     | 15,749
total   | 111       | 1,021     | 10,163    | 101,583   | 1,015,784

With readdir plus enabled, I see this:

n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
--------+-----------+-----------+-----------+-----------+----------
real    | 0m00.115s | 0m00.206s | 0m01.079s | 0m12.521s | 2m07.528s
user    | 0m00.003s | 0m00.003s | 0m00.040s | 0m00.290s | 0m03.296s
sys     | 0m00.007s | 0m00.020s | 0m00.120s | 0m01.357s | 0m17.556s
access  | 3         | 1         | 1         | 1         | 7
getattr | 2         | 1         | 1         | 1         | 1
lookup  | 4         | 3         | 3         | 3         | 3
readdir | 6         | 62        | 630       | 6,300     | 62,993
total   | 15        | 67        | 635       | 6,305     | 63,004

Readdir plus disabled has about a 16x increase in the number of rpc calls and
is 4 - 5 times slower on large directories.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c         |    5 ++-
 fs/nfs/dir.c            |    4 +-
 fs/nfs/internal.h       |    6 ++--
 fs/nfs/nfs2xdr.c        |    2 +-
 fs/nfs/nfs3xdr.c        |    2 +-
 fs/nfs/nfs4_fs.h        |    2 +-
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/nfs4xdr.c        |   55 +++++++++++++++++++++++------------------------
 include/linux/nfs_xdr.h |    3 +-
 9 files changed, 41 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 876ba85..da2f2f0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1358,8 +1358,9 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|
-		NFS_CAP_POSIX_LOCK;
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|NFS_CAP_POSIX_LOCK;
+	if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+			server->caps |= NFS_CAP_READDIRPLUS;
 	server->options = data->options;
 
 	/* Get a client record */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index da3c103..52484be 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -172,7 +172,7 @@ struct nfs_cache_array {
 
 #define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
 
-typedef __be32 * (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, int);
+typedef __be32 * (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 typedef struct {
 	struct file	*file;
 	struct page	*page;
@@ -360,7 +360,7 @@ error:
 static
 int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, struct xdr_stream *stream)
 {
-	__be32 *p = desc->decode(stream, entry, desc->plus);
+	__be32 *p = desc->decode(stream, entry, NFS_SERVER(desc->file->f_path.dentry->d_inode), desc->plus);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7b0e894..db08ff3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -187,15 +187,15 @@ extern void nfs_destroy_directcache(void);
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(int);
 extern struct rpc_procinfo nfs_procedures[];
-extern __be32 *nfs_decode_dirent(struct xdr_stream *, struct nfs_entry *, int);
+extern __be32 *nfs_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
-extern __be32 *nfs3_decode_dirent(struct xdr_stream *, struct nfs_entry *, int);
+extern __be32 *nfs3_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
-extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *entry, int plus);
+extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 #endif
 #ifdef CONFIG_NFS_V4_1
 extern const u32 nfs41_maxread_overhead;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 82f0264..e6bf457 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -454,7 +454,7 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 }
 
 __be32 *
-nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
+nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_server *server, int plus)
 {
 	__be32 *p;
 	p = xdr_inline_decode(xdr, 4);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index dc98eb7..31a44df 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -590,7 +590,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 }
 
 __be32 *
-nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
+nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_server *server, int plus)
 {
 	__be32 *p;
 	struct nfs_entry old = *entry;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c58ea63..9fa4963 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -331,7 +331,7 @@ extern void nfs_free_seqid(struct nfs_seqid *seqid);
 extern const nfs4_stateid zero_stateid;
 
 /* nfs4xdr.c */
-extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *entry, int plus);
+extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 extern struct rpc_procinfo nfs4_procedures[];
 
 struct nfs4_mount_data;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cb33c73..f5ab216 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2832,6 +2832,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.pgbase = 0,
 		.count = count,
 		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask,
+		.plus = plus,
 	};
 	struct nfs4_readdir_res res;
 	struct rpc_message msg = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26ab385..c8fe6a8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1385,12 +1385,20 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 
 static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
-	uint32_t attrs[2] = {
-		FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID,
-		FATTR4_WORD1_MOUNTED_ON_FILEID,
-	};
+	uint32_t attrs[2] = {0, 0};
 	__be32 *p;
 
+	if (readdir->plus) {
+		attrs[0] |= FATTR4_WORD0_TYPE|FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE|
+			FATTR4_WORD0_FSID|FATTR4_WORD0_FILEHANDLE;
+		attrs[1] |= FATTR4_WORD1_MODE|FATTR4_WORD1_NUMLINKS|FATTR4_WORD1_OWNER|
+			FATTR4_WORD1_OWNER_GROUP|FATTR4_WORD1_RAWDEV|
+			FATTR4_WORD1_SPACE_USED|FATTR4_WORD1_TIME_ACCESS|
+			FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+	}
+	attrs[0] |= FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID;
+	attrs[1] |= FATTR4_WORD1_MOUNTED_ON_FILEID;
+
 	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
 	*p++ = cpu_to_be32(OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
@@ -1398,11 +1406,15 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	*p++ = cpu_to_be32(readdir->count >> 1);  /* We're not doing readdirplus */
 	*p++ = cpu_to_be32(readdir->count);
 	*p++ = cpu_to_be32(2);
-	/* Switch to mounted_on_fileid if the server supports it */
-	if (readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
-		attrs[0] &= ~FATTR4_WORD0_FILEID;
-	else
-		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
+
+	if (!readdir->plus) {
+		/* Switch to mounted_on_fileid if the server supports it */
+		if (readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
+			attrs[0] &= ~FATTR4_WORD0_FILEID;
+		else
+			attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
+	}
+
 	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
 	*p = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
 	hdr->nops++;
@@ -5767,7 +5779,8 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-__be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
+__be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
+			   struct nfs_server *server, int plus)
 {
 	uint32_t bitmap[2] = {0};
 	uint32_t len;
@@ -5823,24 +5836,10 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int
 		goto out_overflow;
 	len = XDR_QUADLEN(ntohl(*p++));	/* attribute buffer length */
 	if (len > 0) {
-		if (bitmap[0] & FATTR4_WORD0_RDATTR_ERROR) {
-			bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
-			/* Ignore the return value of rdattr_error for now */
-			p = xdr_inline_decode(xdr, 4);
-			if (unlikely(!p))
-				goto out_overflow;
-		}
-		if (bitmap[0] == 0 && bitmap[1] == FATTR4_WORD1_MOUNTED_ON_FILEID) {
-			p = xdr_inline_decode(xdr, 8);
-			if (unlikely(!p))
-				goto out_overflow;
-			xdr_decode_hyper(p, &entry->ino);
-		} else if (bitmap[0] == FATTR4_WORD0_FILEID) {
-			p = xdr_inline_decode(xdr, 8);
-			if (unlikely(!p))
-				goto out_overflow;
-			xdr_decode_hyper(p, &entry->ino);
-		}
+		if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh, server, 1) < 0)
+			goto out_overflow;
+		if (entry->fattr->valid & NFS_ATTR_FATTR_FILEID)
+			entry->ino = entry->fattr->fileid;
 	}
 
 	p = xdr_inline_peek(xdr, 8);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1b9a17a..efe2eab 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -778,6 +778,7 @@ struct nfs4_readdir_arg {
 	struct page **			pages;	/* zero-copy data */
 	unsigned int			pgbase;	/* zero-copy data */
 	const u32 *			bitmask;
+	int				plus;
 	struct nfs4_sequence_args	seq_args;
 };
 
@@ -1036,7 +1037,7 @@ struct nfs_rpc_ops {
 	int	(*pathconf) (struct nfs_server *, struct nfs_fh *,
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
-	__be32 *(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int plus);
+	__be32 *(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int plus);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
