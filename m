Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:34159 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995AbaFQLo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 07:44:26 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so6138822qcx.36
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 04:44:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 3/4] nfsd: nfsd_splice_read and nfsd_readv should return __be32
Date: Tue, 17 Jun 2014 07:44:13 -0400
Message-Id: <1403005454-7319-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
References: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The callers expect a __be32 return and the functions they call return
__be32, so having these return int is just wrong. Also, nfsd_finish_read
can be made static.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/vfs.c | 7 ++++---
 fs/nfsd/vfs.h | 4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

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

