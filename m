From: andros@netapp.com
Subject: [PATCH 03/22] SQUASHME nfsd41: use cstate session in nfsd4_sequence
Date: Thu,  2 Apr 2009 20:19:44 -0400
Message-ID: <1238718003-8764-3-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679AbZDCAUZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:25 -0400
In-Reply-To: <1238718003-8764-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 reveiw by Bruce
squash into nfsd41: sequence operation

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b233efa..2b8d3ba 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1537,7 +1537,7 @@ replay_cache:
 	 * nfsd4_put_session called only if the cstate slot is set.
 	 */
 	renew_client(session->se_client);
-	nfsd4_get_session(slot->sl_session);
+	nfsd4_get_session(session);
 out:
 	spin_unlock(&sessionid_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
-- 
1.5.4.3

