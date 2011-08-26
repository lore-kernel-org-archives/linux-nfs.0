Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53240 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/15] nfsd4: remove redundant is_open_owner check
Date: Fri, 26 Aug 2011 18:28:32 -0400
Message-Id: <1314397716-18602-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When called with OPEN_STATE, preprocess_seqid_op only returns an open
stateid, hence only an open owner.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b8903b5..fc2f5d1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4019,8 +4019,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		status = nfserr_bad_stateid;
 		open_sop = lock->lk_replay_owner;
-		if (!open_sop->so_is_open_owner)
-			goto out;
 		if (!nfsd4_has_session(cstate) &&
 				!same_clid(&open_sop->so_client->cl_clientid,
 						&lock->v.new.clientid))
-- 
1.7.4.1

