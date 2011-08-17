Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab1HQAwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 20:52:23 -0400
Date: Tue, 16 Aug 2011 20:52:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, nfsv4@ietf.org
Subject: Re: open() of device special files
Message-ID: <20110817005220.GA11879@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110815212539.GA32181@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110815212539.GA32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Confirmed the fix; I'll apply.

Actually that changed NFS4ERR_INVAL's to NFS4ERR_SYMLINK's all over the
place, which I'd rather not do; the following just affects the OPEN.

--b.

commit 618459ca1f7613f0dde4f09138e9acbe02690264
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Aug 15 16:55:02 2011 -0400

    nfsd4: return nfserr_symlink on v4 OPEN of non-regular file
    
    Without this, an attempt to open a device special file without first
    stat'ing it will fail.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9bf0a66..d784ceb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -168,6 +168,24 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 	return status;
 }
 
+static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
+{
+	umode_t mode = fh->fh_dentry->d_inode->i_mode;
+
+	if (S_ISREG(mode))
+		return nfs_ok;
+	if (S_ISDIR(mode))
+		return nfserr_isdir;
+	/*
+	 * Using err_symlink as our catch-all case may look odd; but
+	 * there's no other obvious error for this case in 4.0, and we
+	 * happen to know that it will cause the linux v4 client to do
+	 * the right thing on attempts to open something other than a
+	 * regular file.
+	 */
+	return nfserr_symlink;
+}
+
 static __be32
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -216,6 +234,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 		status = nfsd_lookup(rqstp, current_fh,
 				     open->op_fname.data, open->op_fname.len, &resfh);
 		fh_unlock(current_fh);
+		if (status)
+			goto out;
+		status = nfsd_check_obj_isreg(&resfh);
 	}
 	if (status)
 		goto out;
