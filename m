From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 1/1] nfsd41: renew_client() needs to be called with the client_mutex held
Date: Wed, 17 Jun 2009 18:50:45 -0700
Message-ID: <1245289845-12118-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62843 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358AbZFRBz3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 21:55:29 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

renew_client() manipulates the client queue for lease renewal.  Need to
obtain the client_mutex before manipulating it.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cb5d1d..18258d7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1537,7 +1537,9 @@ replay_cache:
 	 * Hold a session reference until done processing the compound:
 	 * nfsd4_put_session called only if the cstate slot is set.
 	 */
+	nfs4_lock_state();
 	renew_client(session->se_client);
+	nfs4_unlock_state();
 	nfsd4_get_session(session);
 out:
 	spin_unlock(&sessionid_lock);
-- 
1.5.4.3

