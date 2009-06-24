From: andros@netapp.com
Subject: [PATCH 3/5] nfsd41: reclaim DRC memory on session free
Date: Wed, 24 Jun 2009 15:37:47 -0400
Message-ID: <1245872278-18743-4-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63517 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757332AbZFXTh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:37:59 -0400
In-Reply-To: <1245872278-18743-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b4a536d..991c3cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -583,6 +583,9 @@ free_session(struct kref *kref)
 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
+	spin_lock(&nfsd_drc_lock);
+	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
+	spin_unlock(&nfsd_drc_lock);
 	kfree(ses);
 }
 
-- 
1.5.4.3

