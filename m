Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58424 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1KGS3c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 13:29:32 -0500
Message-ID: <4EB82384.7080106@panasas.com>
Date: Mon, 7 Nov 2011 10:29:24 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: Compile warning in pnfs-all-3.1-2011-10-31-1
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix this:
fs/nfsd/nfs4pnfsd.c: In function 'cl_has_file_layout':
fs/nfsd/nfs4pnfsd.c:1093:20: warning: unused variable 'stid' [-Wunused-variable]

Was something forgotten? or It's really not needed any longer?

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d2860c9..ca5c18a 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1090,7 +1090,6 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 static bool
 cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp, stateid_t *lsid)
 {
-	struct nfs4_stid *stid;
 	struct nfs4_layout_state *ls;
 
 	spin_lock(&layout_lock);
-- 
1.7.6.4

