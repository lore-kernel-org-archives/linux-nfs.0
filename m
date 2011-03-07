Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39720 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab1CGQgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2011 11:36:04 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1PwdPf-0001rO-Qg
	for linux-nfs@vger.kernel.org; Mon, 07 Mar 2011 11:36:03 -0500
Date: Mon, 7 Mar 2011 11:36:03 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix bad pointer on failure to find delegation
Message-ID: <20110307163603.GB6718@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

In case of a nonempty list, the return on error here is obviously bogus;
it ends up being a pointer to the list head instead of to any valid
delegation on the list.

In particular, if nfsd4_delegreturn() hits this case, and you're quite unlucky,
then renew_client may oops, and it may take an embarassingly long time to
figure out why.  Facepalm.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000090
IP: [<ffffffff81292965>] nfsd4_delegreturn+0x125/0x200
...

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 54b60bf..7b566ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2445,15 +2445,16 @@ nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
 static struct nfs4_delegation *
 find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 {
-	struct nfs4_delegation *dp = NULL;
+	struct nfs4_delegation *dp;
 
 	spin_lock(&recall_lock);
-	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
-		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
-			break;
-	}
+	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
+		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid) {
+			spin_unlock(&recall_lock);
+			return dp;
+		}
 	spin_unlock(&recall_lock);
-	return dp;
+	return NULL;
 }
 
 int share_access_to_flags(u32 share_access)
-- 
1.7.1

