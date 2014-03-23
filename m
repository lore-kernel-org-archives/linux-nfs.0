Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbaCWBMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/50] nfsd4: fix nfs4err_resource in 4.1 case
Date: Sat, 22 Mar 2014 21:11:39 -0400
Message-Id: <1395537141-10389-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

encode_getattr, for example, can return nfserr_resource to indicate it
ran out of buffer space.  That's not a legal error in the 4.1 case.  And
in the 4.1 case, if we ran out of buffer space, we should have exceeded
a session limit too.
---
 fs/nfsd/nfs4xdr.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 143780d..ea32674 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3626,6 +3626,14 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	/* nfsd4_check_resp_size guarantees enough room for error status */
 	if (!op->status)
 		op->status = nfsd4_check_resp_size(resp, 0);
+	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
+		struct nfsd4_slot *slot = resp->cstate.slot;
+
+		if (slot->sl_flags & NFSD4_SLOT_CACHETHIS)
+			op->status = nfserr_rep_too_big_to_cache;
+		else
+			op->status = nfserr_rep_too_big;
+	}
 	if (so) {
 		so->so_replay.rp_status = op->status;
 		so->so_replay.rp_buflen = (char *)resp->p - (char *)(statp+1);
-- 
1.8.5.3

