Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34173 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbaFQKPx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 06:15:53 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so5963797qcx.25
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 03:15:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: sparse endianness warning cleanups
Date: Tue, 17 Jun 2014 06:15:46 -0400
Message-Id: <1403000146-31394-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The signal to noise ratio with sparse's __CHECK_ENDIAN__ flag is pretty
low at the moment for knfsd. This patch just fixes up most of the sparse
warnings in fs/nfsd. There are still a few left, but this should make it
easier to use sparse with __CHECK_ENDIAN__.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 4 ++--
 fs/nfsd/nfs4state.c | 4 ++--
 fs/nfsd/nfscache.c  | 5 +++--
 fs/nfsd/nfsfh.c     | 3 ++-
 fs/nfsd/nfsfh.h     | 6 +++---
 fs/nfsd/vfs.c       | 7 ++++---
 fs/nfsd/vfs.h       | 4 ++--
 7 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6851b003f2a4..adc10273101d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -581,8 +581,8 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 	__be32 verf[2];
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
-	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
+	verf[0] = (__force __be32)nn->nfssvc_boot.tv_sec;
+	verf[1] = (__force __be32)nn->nfssvc_boot.tv_usec;
 	memcpy(verifier->data, verf, sizeof(verifier->data));
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c0d45cec9958..88e61296df28 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1345,8 +1345,8 @@ static void gen_confirm(struct nfs4_client *clp)
 	__be32 verf[2];
 	static u32 i;
 
-	verf[0] = (__be32)get_seconds();
-	verf[1] = (__be32)i++;
+	verf[0] = (__force __be32)get_seconds();
+	verf[1] = (__force __be32)i++;
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 6040da8830ff..2254d2e20c74 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -221,7 +221,8 @@ static void
 hash_refile(struct svc_cacherep *rp)
 {
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
+	hlist_add_head(&rp->c_hash, cache_hash +
+			hash_32((__force u32)rp->c_xid, maskbits));
 }
 
 /*
@@ -356,7 +357,7 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	struct hlist_head 	*rh;
 	unsigned int		entries = 0;
 
-	rh = &cache_hash[hash_32(rqstp->rq_xid, maskbits)];
+	rh = &cache_hash[hash_32((__force u32)rqstp->rq_xid, maskbits)];
 	hlist_for_each_entry(rp, rh, c_hash) {
 		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index ec8393418154..c9fb7ba8f56a 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -162,7 +162,8 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 			/* deprecated, convert to type 3 */
 			len = key_len(FSID_ENCODE_DEV)/4;
 			fh->fh_fsid_type = FSID_ENCODE_DEV;
-			fh->fh_fsid[0] = new_encode_dev(MKDEV(ntohl(fh->fh_fsid[0]), ntohl(fh->fh_fsid[1])));
+			fh->fh_fsid[0] = new_encode_dev(MKDEV(ntohl((__force __be32)fh->fh_fsid[0]),
+							ntohl((__force __be32)fh->fh_fsid[1])));
 			fh->fh_fsid[1] = fh->fh_fsid[2];
 		}
 		data_left -= len;
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 2e89e70ac15c..e9f0046d3d40 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -82,7 +82,7 @@ static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
 	u32 *up;
 	switch(vers) {
 	case FSID_DEV:
-		fsidv[0] = htonl((MAJOR(dev)<<16) |
+		fsidv[0] = (__force __u32)htonl((MAJOR(dev)<<16) |
 				 MINOR(dev));
 		fsidv[1] = ino_t_to_u32(ino);
 		break;
@@ -90,8 +90,8 @@ static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
 		fsidv[0] = fsid;
 		break;
 	case FSID_MAJOR_MINOR:
-		fsidv[0] = htonl(MAJOR(dev));
-		fsidv[1] = htonl(MINOR(dev));
+		fsidv[0] = (__force __u32)htonl(MAJOR(dev));
+		fsidv[1] = (__force __u32)htonl(MINOR(dev));
 		fsidv[2] = ino_t_to_u32(ino);
 		break;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 140c496f612c..960f9e0bb88f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -820,7 +820,8 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
 	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
 }
 
-__be32 nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
+static __be32
+nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
 {
 	if (host_err >= 0) {
 		nfsdstats.io_read += host_err;
@@ -831,7 +832,7 @@ __be32 nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
 		return nfserrno(host_err);
 }
 
-int nfsd_splice_read(struct svc_rqst *rqstp,
+__be32 nfsd_splice_read(struct svc_rqst *rqstp,
 		     struct file *file, loff_t offset, unsigned long *count)
 {
 	struct splice_desc sd = {
@@ -847,7 +848,7 @@ int nfsd_splice_read(struct svc_rqst *rqstp,
 	return nfsd_finish_read(file, count, host_err);
 }
 
-int nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
+__be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
 		unsigned long *count)
 {
 	mm_segment_t oldfs;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 91b6ae3f658b..b84aef50f55d 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -74,9 +74,9 @@ struct raparms;
 __be32		nfsd_get_tmp_read_open(struct svc_rqst *, struct svc_fh *,
 				struct file **, struct raparms **);
 void		nfsd_put_tmp_read_open(struct file *, struct raparms *);
-int		nfsd_splice_read(struct svc_rqst *,
+__be32		nfsd_splice_read(struct svc_rqst *,
 				struct file *, loff_t, unsigned long *);
-int		nfsd_readv(struct file *, loff_t, struct kvec *, int,
+__be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 				unsigned long *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
-- 
1.9.3

