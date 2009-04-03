From: andros@netapp.com
Subject: [PATCH 02/22] SQUASHME: nfsd41: use cstate session in nfsd4_replay_cache_entry
Date: Thu,  2 Apr 2009 20:19:43 -0400
Message-ID: <1238718003-8764-2-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbZDCAUY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:24 -0400
In-Reply-To: <1238718003-8764-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce
squash into nfsd41: DRC save, restore, and clear functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b7c4ed0..b233efa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1154,7 +1154,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	 * is sent (lease renewal).
 	 */
 	if (seq && nfsd4_no_page_in_cache(resp)) {
-		seq->maxslots = resp->cstate.slot->sl_session->se_fnumslots;
+		seq->maxslots = resp->cstate.session->se_fnumslots;
 		return nfs_ok;
 	}
 
-- 
1.5.4.3

