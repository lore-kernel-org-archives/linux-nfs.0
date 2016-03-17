Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935629AbcCQSf6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2016 14:35:58 -0400
Date: Thu, 17 Mar 2016 14:35:55 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix deadlock secinfo+readdir compound
Message-ID: <20160317183555.GA25906@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

nfsd_lookup_dentry exits with the parent filehandle locked.  fh_put also
unlocks if necessary (nfsd filehandle locking is probably too lenient),
so it gets unlocked eventually, but if the following op in the compound
needs to lock it again, we can deadlock.

A fuzzer ran into this; normal clients don't send a secinfo followed by
a readdir in the same compound.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 410516e9867f..40b912407d51 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -876,6 +876,7 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				    &exp, &dentry);
 	if (err)
 		return err;
+	fh_unlock(&cstate->current_fh);
 	if (d_really_is_negative(dentry)) {
 		exp_put(exp);
 		err = nfserr_noent;
-- 
2.5.0

