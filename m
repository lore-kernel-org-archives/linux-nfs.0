From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 35/35] pnfsd: layoutreturn stateid processing
Date: Mon,  7 Dec 2009 11:37:34 +0200
Message-ID: <1260178654-16161-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@umich.edu>,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@umich.edu>

[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index ba3d96f..9023038 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -702,6 +702,13 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 			goto out;
 		}
 
+		/* Check the stateid */
+		dprintk("%s PROCESS LO_STATEID inode %p\n", __func__, ino);
+		status = nfs4_process_layout_stateid(clp, fp, &lrp->lr_sid,
+						     NULL);
+		if (status)
+			goto out_put_file;
+
 		/* update layouts */
 		layouts_found = pnfs_return_file_layouts(clp, fp, lrp);
 		/* optimize for the all-empty case */
@@ -719,6 +726,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		ex_fsid,
 		lrp->args.lr_seg.offset, lrp->args.lr_seg.length, layouts_found);
 
+out_put_file:
 	if (fp)
 		put_nfs4_file(fp);
 out:
-- 
1.6.5.1

