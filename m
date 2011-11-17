Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:61660 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab1KQCUy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 21:20:54 -0500
Message-ID: <4EC470B1.5000505@cn.fujitsu.com>
Date: Thu, 17 Nov 2011 10:25:53 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: donot check reclaim for open with filehandle
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Opening file with filehandle, check reclaim is not needed.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fa38336..681dff3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -266,8 +266,9 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
 {
 	__be32 status;
 
-	/* Only reclaims from previously confirmed clients are valid */
-	if ((status = nfs4_check_open_reclaim(&open->op_clientid)))
+	if (open->op_claim_type != NFS4_OPEN_CLAIM_FH
+	    && open->op_claim_type != NFS4_OPEN_CLAIM_DELEG_CUR_FH
+	    && (status = nfs4_check_open_reclaim(&open->op_clientid)))
 		return status;
 
 	/* We don't know the target directory, and therefore can not
-- 
1.7.7


