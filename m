Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21819 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab1D0TrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 15:47:20 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/3] NFSD: Remove setting unused variable in nfsd_vfs_read()
Date: Wed, 27 Apr 2011 15:47:14 -0400
Message-Id: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Compiling gave me this warning:
fs/nfsd/vfs.c: In function ‘nfsd_vfs_read’:
fs/nfsd/vfs.c:880:16: warning: variable ‘inode’ set but not used
[-Wunused-but-set-variable]

I discovered that a local variable "inode" was being set towards the
beginning of nfsd_vfs_read() and then ignored for the rest of the
function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/vfs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 129f3c9..07b1e58 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -877,13 +877,11 @@ static __be32
 nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
               loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
-	struct inode *inode;
 	mm_segment_t	oldfs;
 	__be32		err;
 	int		host_err;
 
 	err = nfserr_perm;
-	inode = file->f_path.dentry->d_inode;
 
 	if (file->f_op->splice_read && rqstp->rq_splice_ok) {
 		struct splice_desc sd = {
-- 
1.7.4.4

