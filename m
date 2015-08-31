Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:14841 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753307AbbHaQTp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 12:19:45 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, etmsys@rit.edu
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: deal with DELEGRETURN racing with CB_RECALL
Date: Mon, 31 Aug 2015 12:06:41 -0400
Message-Id: <1441037201-78787-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have observed the server sending recalls for delegation stateids
that have already been successfully returned. Change
nfsd4_cb_recall_done() to return success if the client has returned
the delegation. While this does not completely eliminate the sending
of recalls for delegations that have already been returned, this
does prevent unnecessarily declaring the callback path to be down.

Reported-by: Eric Meddaugh <etmsys@rit.edu>
Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index de45c2de1668..ac235a7470e3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3509,6 +3509,9 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 {
 	struct nfs4_delegation *dp = cb_to_delegation(cb);
 
+	if (dp->dl_stid.sc_type == NFS4_CLOSED_DELEG_STID)
+	        return 1;
+
 	switch (task->tk_status) {
 	case 0:
 		return 1;
-- 
2.4.6

