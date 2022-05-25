Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C618C433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 25 May 2022 15:47:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S245265AbiEYPrg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 May 2022 11:47:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58406 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233702AbiEYPrf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2022 11:47:35 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0318834649
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 08:47:35 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 9895560FCF
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 15:47:34 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED610C385B8
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 15:47:33 +0000 (UTC)
Subject: [PATCH v3 1/4] NFSD: Fix possible sleep during
 nfsd4_release_lockowner()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 25 May 2022 11:47:33 -0400
Message-ID: <165349365296.4205.8927782660830418561.stgit@bazille.1015granger.net>
In-Reply-To: <165349272692.4205.8499763565429173274.stgit@bazille.1015granger.net>
References: <165349272692.4205.8499763565429173274.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfsd4_release_lockowner() holds clp->cl_lock when it calls
check_for_locks(). However, check_for_locks() calls nfsd_file_get()
/ nfsd_file_put() to access the backing inode's flc_posix list, and
nfsd_file_put() can sleep if the inode was recently removed.

Let's instead rely on the stateowner's reference count to gate
whether the release is permitted. This should be a reliable
indication of locks-in-use since file lock operations and
->lm_get_owner take appropriate references, which are released
appropriately when file locks are removed.

Reported-by: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
---
 fs/nfsd/nfs4state.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a280256cbb03..4e0850a10550 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7557,16 +7557,12 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		if (sop->so_is_open_owner || !same_owner_str(sop, owner))
 			continue;
 
-		/* see if there are still any locks associated with it */
-		lo = lockowner(sop);
-		list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-			if (check_for_locks(stp->st_stid.sc_file, lo)) {
-				status = nfserr_locks_held;
-				spin_unlock(&clp->cl_lock);
-				return status;
-			}
+		if (atomic_read(&sop->so_count) != 1) {
+			spin_unlock(&clp->cl_lock);
+			return nfserr_locks_held;
 		}
 
+		lo = lockowner(sop);
 		nfs4_get_stateowner(sop);
 		break;
 	}


