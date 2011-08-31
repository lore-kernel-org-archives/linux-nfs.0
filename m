Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937Ab1HaToA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Aug 2011 15:44:00 -0400
Date: Wed, 31 Aug 2011 15:44:00 -0400
To: linux-nfs@vger.kernel.org
Cc: Rick Macklem <rmacklem@uoguelph.ca>
Subject: [PATCH] nfsd4: fix off-by-one-error in SEQUENCE reply
Message-ID: <20110831194400.GC19223@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

The values here represent highest slotid numbers.  Since slotid's are
numbered starting from zero, the highest should be one less than the
number of slots.

Reported-by: Rick Macklem <rmacklem@uoguelph.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

Queuing up for 3.2.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1aa6270..fc506e0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3224,9 +3224,9 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(seq->seqid);
 	WRITE32(seq->slotid);
-	WRITE32(seq->maxslots);
-	/* For now: target_maxslots = maxslots */
-	WRITE32(seq->maxslots);
+	/* Note slotid's are numbered from zero: */
+	WRITE32(seq->maxslots - 1); /* sr_highest_slotid */
+	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
 	WRITE32(seq->status_flags);
 
 	ADJUST_ARGS();
-- 
1.7.4.1

