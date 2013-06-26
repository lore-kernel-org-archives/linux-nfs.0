Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35132 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561Ab3FZTVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd4: return delegation immediately if lease fails
Date: Wed, 26 Jun 2013 15:21:27 -0400
Message-Id: <1372274488-4752-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This case shouldn't happen--the administrator shouldn't really allow
other applications access to the export until clients have had the
chance to reclaim their state--but if it does then we should set the
"return this lease immediately" bit on the reply.  That still leaves
some small races, but it's the best the protocol allows us to do in the
case a lease is ripped out from under us....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a7d8a11..d44a4bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3143,8 +3143,10 @@ out_free:
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
-	    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
+	    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE) {
 		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
+		open->op_recall = 1;
+	}
 
 	/* 4.1 client asking for a delegation? */
 	if (open->op_deleg_want)
-- 
1.8.1.4

