Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38651 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757829AbaEKUxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 39/43] nfsd4: really fix nfs4err_resource in 4.1 case
Date: Sun, 11 May 2014 16:52:44 -0400
Message-Id: <1399841568-19716-40-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
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
 fs/nfsd/nfs4xdr.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 91a50a0..5ff7bea 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3900,6 +3900,13 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
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
 	if (op->status == nfserr_resource ||
 	    op->status == nfserr_rep_too_big ||
 	    op->status == nfserr_rep_too_big_to_cache) {
-- 
1.7.9.5

