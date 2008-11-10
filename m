From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 49/51] nfsd41: clear DRC cache on free_session
Date: Mon, 10 Nov 2008 22:57:32 +0200
Message-ID: <1226350652-11968-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44373 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYKJU5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:57:45 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a1a9e0a..cefb605 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -478,8 +478,15 @@ void
 free_session(struct kref *kref)
 {
 	struct nfs41_session *ses;
+	int i;
 
 	ses = container_of(kref, struct nfs41_session, se_ref);
+	for (i = 0; i < ses->se_fnumslots; i++) {
+		struct nfs41_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
+		spin_lock(&e->ce_lock);
+		nfsd4_clear_respages(e->ce_respages, e->ce_resused);
+		spin_unlock(&e->ce_lock);
+	}
 	kfree(ses->se_slots);
 	kfree(ses);
 }
-- 
1.6.0.2

