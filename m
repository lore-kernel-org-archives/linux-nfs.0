From: andros@netapp.com
Subject: [PATCH 1/1] nfsd41: slots are freed with session
Date: Fri,  1 May 2009 11:33:53 -0400
Message-ID: <1241192033-4493-2-git-send-email-andros@netapp.com>
References: <>
 <1241192033-4493-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757608AbZEAPdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 May 2009 11:33:55 -0400
In-Reply-To: <1241192033-4493-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The session and slots are allocated all in one piece.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c65a27b..3b711f5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -580,7 +580,6 @@ free_session(struct kref *kref)
 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
-	kfree(ses->se_slots);
 	kfree(ses);
 }
 
-- 
1.5.4.3

