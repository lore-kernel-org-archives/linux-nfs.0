Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44194 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944Ab1JKQlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 12:41:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 1/4] nfsd4: ignore WANT bits in open downgrade
Date: Tue, 11 Oct 2011 12:41:00 -0400
Message-Id: <1318351263-14918-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1318351263-14918-1-git-send-email-bfields@redhat.com>
References: <1318351263-14918-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't use WANT bits yet--and sending them can probably trigger a
BUG() further down.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 683885b..a39a542 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3574,6 +3574,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	if (!access_valid(od->od_share_access, cstate->minorversion)
 			|| !deny_valid(od->od_share_deny))
 		return nfserr_inval;
+	/* We don't yet support WANT bits: */
+	od->od_share_access &= NFS4_SHARE_ACCESS_MASK;
 
 	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
-- 
1.7.4.1

