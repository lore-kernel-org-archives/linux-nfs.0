Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47847 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbaCWBMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/50] nfsd4: minor nfsd4_replay_cache_entry cleanup
Date: Sat, 22 Mar 2014 21:11:35 -0400
Message-Id: <1395537141-10389-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Maybe this is comment true, who cares?  Handle this like any other
error.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 613f7cd..cb4cc4a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1609,9 +1609,8 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
 	dprintk("--> %s slot %p\n", __func__, slot);
 
-	/* Either returns 0 or nfserr_retry_uncached */
 	status = nfsd4_enc_sequence_replay(resp->rqstp->rq_argp, resp);
-	if (status == nfserr_retry_uncached_rep)
+	if (status)
 		return status;
 
 	/* The sequence operation has been encoded, cstate->datap set. */
-- 
1.8.5.3

