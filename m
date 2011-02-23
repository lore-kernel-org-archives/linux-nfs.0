Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54287 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab1BWRz7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 12:55:59 -0500
Message-ID: <4D654A30.5020303@panasas.com>
Date: Wed, 23 Feb 2011 09:56:00 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfsd-lexp: recall layout on truncate
References: <1298419783-27791-1-git-send-email-bhalevy@panasas.com> <4D654174.3000101@panasas.com>
In-Reply-To: <4D654174.3000101@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-23 09:18, Boaz Harrosh wrote:
> On 02/22/2011 04:09 PM, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> @@ -384,6 +385,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>>  					NFSD_MAY_TRUNC|NFSD_MAY_OWNER_OVERRIDE);
>>  			if (err)
>>  				goto out;
>> +#if defined(CONFIG_PNFSD_LOCAL_EXPORT)
>> +			pnfsd_lexp_recall_layout(inode);
> 
> Ha, I just realized, this is not good, for when CONFIG_PNFSD_LOCAL_EXPORT is set
> but the actual sb is pnfs-exported by the file system like gfs2 and exofs.
> You need to check if the FS is owned by the PNFSD_LOCAL_EXPORT.

Good point.  Can you please test the following patch?

>From 9afc5e82390fe889aee2770eb217613146ddc9de Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Wed, 23 Feb 2011 09:53:15 -0800
Subject: [PATCH] SQUASHME: pnfsd-lexp: recall layout on truncate only if inode is exported over pnfsd-lexp

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/pnfsd.h      |    1 +
 fs/nfsd/pnfsd_lexp.c |    6 ++++++
 fs/nfsd/vfs.c        |    3 ++-
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 51dd982..c11d93d 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -139,6 +139,7 @@ extern struct sockaddr pnfsd_lexp_addr;
 extern size_t pnfs_lexp_addr_len;
 
 extern void pnfsd_lexp_init(struct inode *);
+extern bool is_inode_pnfsd_lexp(struct inode *);
 extern int pnfsd_lexp_recall_layout(struct inode *);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 736cc3f..71d503e 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -232,6 +232,12 @@ pnfsd_lexp_init(struct inode *inode)
 		init_waitqueue_head(&lo_recall_wq);
 }
 
+bool
+is_inode_pnfsd_lexp(struct inode *inode)
+{
+	return inode->i_sb->s_pnfs_op == &pnfsd_lexp_ops;
+}
+
 static bool
 has_no_layout(struct nfs4_file *fp)
 {
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 021e89e..2a3eff2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -386,7 +386,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 			if (err)
 				goto out;
 #if defined(CONFIG_PNFSD_LOCAL_EXPORT)
-			pnfsd_lexp_recall_layout(inode);
+			if (is_inode_pnfsd_lexp(inode))
+				pnfsd_lexp_recall_layout(inode);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 #if defined(CONFIG_SPNFS_BLOCK)
 			if (pnfs_block_enabled(inode, 0)) {
-- 
1.7.3.4

