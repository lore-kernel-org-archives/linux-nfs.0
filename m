From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 23/47] nfsd41: clear DRC cache on free_session
Date: Fri, 27 Mar 2009 06:16:22 +0300
Message-ID: <1238123782-7664-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24798 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755869AbZC0DQ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:16:27 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 07c869d..37865c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -442,12 +442,19 @@ release_session(struct nfsd4_session *ses)
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

