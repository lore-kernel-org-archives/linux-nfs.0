From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] nfs41: Move initialization of nfs4_opendata seq_res to nfs4_init_opendata_res
Date: Thu, 18 Jun 2009 22:01:23 -0400
Message-ID: <1245376884-3711-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from linux-nfs.citi.umich.edu ([141.211.133.37]:58950 "EHLO
	linux-nfs.citi.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbZFSCL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 22:11:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_open_recover_helper clears opendata->o_res
before calling nfs4_init_opendata_res, thus causing
NFSv4.0 OPEN operations to be sent rather than nfsv4.1.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
Trond, please add these two patches to the nfs41-for-2.6.31 series.
Also availble on git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-2.6.31

 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57dabb8..04da834 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -680,6 +680,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 	p->o_res.server = p->o_arg.server;
 	nfs_fattr_init(&p->f_attr);
 	nfs_fattr_init(&p->dir_attr);
+	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
@@ -711,7 +712,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
-	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	if (flags & O_EXCL) {
 		u32 *s = (u32 *) p->o_arg.u.verifier.data;
 		s[0] = jiffies;
-- 
1.6.3.1

