Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35893 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbJBLTG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 07:19:06 -0400
Received: by qgx61 with SMTP id 61so91441280qgx.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 04:19:05 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [RFC PATCH] nfs4: clear delegation from open states when returning delegation voluntarily
Date: Fri,  2 Oct 2015 07:18:59 -0400
Message-Id: <1443784739-8565-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the client goes to return a delegation, it should always update any
nfs4_state currently set up to use that delegation stateid to instead
use the open stateid. It already does do this in some cases,
particularly in the state recovery code, but not currently when the
delegation is voluntarily returned (e.g. in advance of a RENAME).

This causes the client to try to continue using the delegation stateid
after the DELEGRETURN, e.g. in LAYOUTGET. This patch fixes this by
ensuring to set the nfs4_state back to using the open stateid in
nfs_delegation_claim_opens.

That said, this code is quite difficult to follow and it's not 100%
clear to me why the delegreturn handling and the state recovery code are
squashed together like this. So, consider this an RFC patch and please
let me know if there's a better way to fix this.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/delegation.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index be806ead7f4d..aba906c50e8e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -147,6 +147,10 @@ again:
 		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			err = -EAGAIN;
 		mutex_unlock(&sp->so_delegreturn_mutex);
+		write_seqlock(&state->seqlock);
+		nfs4_stateid_copy(&state->stateid, &state->open_stateid);
+		write_sequnlock(&state->seqlock);
+		clear_bit(NFS_DELEGATED_STATE, &state->flags);
 		put_nfs_open_context(ctx);
 		if (err != 0)
 			return err;
-- 
2.4.3

