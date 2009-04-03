From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 17/35] nfsd41: clear DRC cache on free_session
Date: Fri,  3 Apr 2009 08:28:25 +0300
Message-ID: <1238736505-17610-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21357 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755589AbZDCF2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:31 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e20d434..f25a7d2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -441,12 +441,19 @@ release_session(struct nfsd4_session *ses)
 	nfsd4_put_session(ses);
 }
 
+static void nfsd4_release_respages(struct page **respages, short resused);
+
 void
 free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
+	int i;
 
 	ses = container_of(kref, struct nfsd4_session, se_ref);
+	for (i = 0; i < ses->se_fnumslots; i++) {
+		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
+		nfsd4_release_respages(e->ce_respages, e->ce_resused);
+	}
 	kfree(ses->se_slots);
 	kfree(ses);
 }
-- 
1.6.2.1

