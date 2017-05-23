Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55552 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965624AbdEWSYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 14:24:46 -0400
Date: Tue, 23 May 2017 14:24:45 -0400
To: linux-nfs@vger.kernel.org
Cc: Scott Mayhew <smayhew@redhat.com>
Subject: [PATCH] nfsd4: fix null dereference on replay
Message-ID: <20170523182445.GC4298@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

if we receive a compound such that:

	- the sessionid, slot, and sequence number in the SEQUENCE op
	  match a cached succesful reply with N ops.
	- the Nth operation of the compound is a PUTFH, PUTPUBFH,
	  PUTROOTFH, or RESTOREFH

then nfsd4_sequence will return 0 and set cstate->status to
nfserr_replay_cache.  The current filehandle will not be set.  This will
cause us to call check_nfsd_access with first argument NULL.

To nfsd4_compound it looks like we just succesfully executed an
operation that set a filehandle, but the current filehandle is not set.

Fix this by moving the nfserr_replay_cache earlier.  There was never any
reason to have it after the encode_op label, since the only case where
he hit that is when opdesc->op_func sets it.

Note that there are two ways we could hit this case:

	- a client is resending a previously sent a compound that ended
	  with one of the four PUTFH-like operations, or
	- a client is sending a *new* compound that (incorrectly) shares
	  sessionid, slot, and sequence number with a previously sent
	  compound, and the length of the previously sent compound
	  happens to match the position of a PUTFH-like operation in the
	  new compound.

The second is obviously incorrect client behavior.  The first is also
very strange--the only purpose of a PUTFH-like operation is to set the
current filehandle to be used by the following operation, so there's no
point in having it as the last in a compound.

So it's likely this requires a buggy or malicious client to reproduce.

Reported-by: Scott Mayhew <smayhew@redhat.com>
Cc: stable@kernel.vger.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c453a1998e00..dadb3bf305b2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1769,6 +1769,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			opdesc->op_get_currentstateid(cstate, &op->u);
 		op->status = opdesc->op_func(rqstp, cstate, &op->u);
 
+		/* Only from SEQUENCE */
+		if (cstate->status == nfserr_replay_cache) {
+			dprintk("%s NFS4.1 replay from cache\n", __func__);
+			status = op->status;
+			goto out;
+		}
 		if (!op->status) {
 			if (opdesc->op_set_currentstateid)
 				opdesc->op_set_currentstateid(cstate, &op->u);
@@ -1779,14 +1785,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			if (need_wrongsec_check(rqstp))
 				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
 		}
-
 encode_op:
-		/* Only from SEQUENCE */
-		if (cstate->status == nfserr_replay_cache) {
-			dprintk("%s NFS4.1 replay from cache\n", __func__);
-			status = op->status;
-			goto out;
-		}
 		if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
 			nfsd4_encode_replay(&resp->xdr, op);
-- 
2.9.3

