From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 08/35] pnfsd: add pnfs export option
Date: Mon,  7 Dec 2009 11:31:30 +0200
Message-ID: <1260178290-14922-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41732 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934839AbZLGJae (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:30:34 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a boolean for now. When more layouttypes are supported, this can
change to "pnfs=", similar to "sec=".

The ctl interface is not enhanced.

Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: test pnfs export option in check_export]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/export.c            |   21 ++++++++++++++++++---
 include/linux/nfsd/export.h |    1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f82ed90..ca745cc 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -356,7 +356,8 @@ static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int flags, unsigned char *uuid)
+static int check_export(struct inode *inode, int flags, unsigned char *uuid,
+			bool ex_pnfs)
 {
 
 	/*
@@ -388,6 +389,14 @@ static int check_export(struct inode *inode, int flags, unsigned char *uuid)
 		return -EINVAL;
 	}
 
+	dprintk("%s: s_pnfs_op %p ex_pnfs %d\n", __func__,
+		inode->i_sb->s_pnfs_op, ex_pnfs);
+
+	if (!ex_pnfs) {
+		inode->i_sb->s_pnfs_op = NULL;
+		return 0;
+	}
+
 	return 0;
 
 }
@@ -579,6 +588,8 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 					if (exp.ex_uuid == NULL)
 						err = -ENOMEM;
 				}
+			} else if (strcmp(buf, "pnfs") == 0) {
+				exp.ex_pnfs = 1;
 			} else if (strcmp(buf, "secinfo") == 0)
 				err = secinfo_parse(&mesg, buf, &exp);
 			else
@@ -592,7 +603,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		}
 
 		err = check_export(exp.ex_path.dentry->d_inode, exp.ex_flags,
-				   exp.ex_uuid);
+				   exp.ex_uuid, exp.ex_pnfs);
 		if (err)
 			goto out4;
 	}
@@ -653,6 +664,8 @@ static int svc_export_show(struct seq_file *m,
 				seq_printf(m, "%02x", exp->ex_uuid[i]);
 			}
 		}
+		if (exp->ex_pnfs)
+			seq_puts(m, ",pnfs");
 		show_secinfo(m, exp);
 	}
 	seq_puts(m, ")\n");
@@ -680,6 +693,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
+	new->ex_pnfs = 0;
 }
 
 static void export_update(struct cache_head *cnew, struct cache_head *citem)
@@ -692,6 +706,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_anon_uid = item->ex_anon_uid;
 	new->ex_anon_gid = item->ex_anon_gid;
 	new->ex_fsid = item->ex_fsid;
+	new->ex_pnfs = item->ex_pnfs;
 	new->ex_uuid = item->ex_uuid;
 	item->ex_uuid = NULL;
 	new->ex_pathname = item->ex_pathname;
@@ -1030,7 +1045,7 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	}
 
-	err = check_export(path.dentry->d_inode, nxp->ex_flags, NULL);
+	err = check_export(path.dentry->d_inode, nxp->ex_flags, NULL, false);
 	if (err) goto finish;
 
 	err = -ENOMEM;
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 3f17228..268391e 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -98,6 +98,7 @@ struct svc_export {
 	uid_t			ex_anon_uid;
 	gid_t			ex_anon_gid;
 	int			ex_fsid;
+	int			ex_pnfs;
 	unsigned char *		ex_uuid; /* 16 byte fsid */
 	struct nfsd4_fs_locations ex_fslocs;
 	int			ex_nflavors;
-- 
1.6.5.1

