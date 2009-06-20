From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfsd41: Do not renew state on error
Date: Fri, 19 Jun 2009 20:08:16 -0700
Message-ID: <1245467296-23871-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org, bhalevy-C4P08NqkoRlAfugRpC6u6w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20456 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbZFTDNU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jun 2009 23:13:20 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_sequence() should not renew the client state if the session was not
found or if there was a bad slot.  This will also avoid dereferencing a
null session pointer.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c845365..e239c6e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1425,12 +1425,16 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	spin_lock(&sessionid_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
-	if (!session)
-		goto out;
+	if (!session) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	status = nfserr_badslot;
-	if (seq->slotid >= session->se_fchannel.maxreqs)
-		goto out;
+	if (seq->slotid >= session->se_fchannel.maxreqs) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
-- 
1.5.4.3

