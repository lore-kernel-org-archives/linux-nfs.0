Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:46564 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964942AbaKMVag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 16:30:36 -0500
From: Pieter Smith <pieter@boesman.nl>
To: pieter@boesman.nl
Cc: Josh Triplett <josh@joshtriplett.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...),
        linux-kernel@vger.kernel.org (open list)
Subject: [PATCH 33/56] fs/nfsd: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:10 +0100
Message-Id: <1415913813-362-34-git-send-email-pieter@boesman.nl>
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compile out splice support from nfsd when the splice-family of syscalls is not
supported by the system (i.e. CONFIG_SYSCALL_SPLICE is undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/nfsd/nfs4xdr.c | 4 ++++
 fs/nfsd/vfs.c     | 6 ++++++
 2 files changed, 10 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f9821ce..c4ee0fd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3060,6 +3060,7 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 	return nfserr;
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static __be32 nfsd4_encode_splice_read(
 				struct nfsd4_compoundres *resp,
 				struct nfsd4_read *read,
@@ -3119,6 +3120,7 @@ static __be32 nfsd4_encode_splice_read(
 
 	return 0;
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 struct nfsd4_read *read,
@@ -3216,9 +3218,11 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
+#ifdef CONFIG_SYSCALL_SPLICE
 	if (file->f_op->splice_read && resp->rqstp->rq_splice_ok)
 		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 		err = nfsd4_encode_readv(resp, read, file, maxcount);
 
 	if (!read->rd_filp)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..036db70 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -779,6 +779,7 @@ found:
 	return ra;
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 /*
  * Grab and keep cached pages associated with a file in the svc_rqst
  * so that they can be passed to the network sendmsg/sendpage routines
@@ -818,6 +819,7 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
 {
 	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 static __be32
 nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
@@ -831,6 +833,7 @@ nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
 		return nfserrno(host_err);
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 __be32 nfsd_splice_read(struct svc_rqst *rqstp,
 		     struct file *file, loff_t offset, unsigned long *count)
 {
@@ -846,6 +849,7 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp,
 	host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 	return nfsd_finish_read(file, count, host_err);
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 __be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
 		unsigned long *count)
@@ -864,9 +868,11 @@ static __be32
 nfsd_vfs_read(struct svc_rqst *rqstp, struct file *file,
 	      loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
+#ifdef CONFIG_SYSCALL_SPLICE
 	if (file->f_op->splice_read && rqstp->rq_splice_ok)
 		return nfsd_splice_read(rqstp, file, offset, count);
 	else
+#endif
 		return nfsd_readv(file, offset, vec, vlen, count);
 }
 
-- 
1.9.1

