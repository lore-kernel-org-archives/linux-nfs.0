Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752816AbaEVTcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 47/52] nfsd4: really fix nfs4err_resource in 4.1 case
Date: Thu, 22 May 2014 15:32:22 -0400
Message-Id: <1400787148-25941-48-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

encode_getattr, for example, can return nfserr_resource to indicate it
ran out of buffer space.  That's not a legal error in the 4.1 case.
And in the 4.1 case, if we ran out of buffer space, we should have
exceeded a session limit too.

(Note in 1bc49d83c37cfaf46be357757e592711e67f9809 "nfsd4: fix
nfs4err_resource in 4.1 case" we originally tried fixing this error
return before fixing the problem that we could error out while we still
had lots of available space.  The result was to trade one illegal error
for another in those cases.  We decided that was helpful, so reverted
the change in fc208d026be0c7d60db9118583fc62f6ca97743d, and are only
reinstating it now that we've elimited almost all of those cases.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f3eb7fa..5fc3ba0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3903,6 +3903,14 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 			space_needed = COMPOUND_ERR_SLACK_SPACE;
 		op->status = nfsd4_check_resp_size(resp, space_needed);
 	}
+	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
+		struct nfsd4_slot *slot = resp->cstate.slot;
+
+		if (slot->sl_flags & NFSD4_SLOT_CACHETHIS)
+			op->status = nfserr_rep_too_big_to_cache;
+		else
+			op->status = nfserr_rep_too_big;
+	}
 	if (op->status == nfserr_resource ||
 	    op->status == nfserr_rep_too_big ||
 	    op->status == nfserr_rep_too_big_to_cache) {
-- 
1.9.0

