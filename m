From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd-files: verify_stateid's return status is __be32
Date: Tue, 29 Jun 2010 15:41:41 +0300
Message-ID: <1277815301-14292-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3828 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753330Ab0F2Mln (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:41:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Therefore nfs4_process_layout_stateid should check for != 0
rather than < 0.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 5043878..cee9aff 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -255,7 +255,7 @@ find_get_layout_state(struct nfs4_client *clp, struct nfs4_file *fp)
 	return NULL;
 }
 
-static int
+static __be32
 verify_stateid(struct nfs4_file *fp, stateid_t *stateid)
 {
 	struct nfs4_stateid *local = NULL;
@@ -316,7 +316,7 @@ nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
 
 		/* verify input stateid */
 		status = verify_stateid(fp, stateid);
-		if (status < 0) {
+		if (status) {
 			dprintk("%s ERROR: invalid open/deleg/lock stateid\n",
 				__func__);
 			goto out;
-- 
1.6.6.1

