Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F10FC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 14:44:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4098C20863
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 14:44:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4098C20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726803AbeLABxg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 20:53:36 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53008 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726615AbeLABxg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 20:53:36 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 096B63082E23;
        Fri, 30 Nov 2018 14:44:04 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-28.rdu2.redhat.com [10.10.120.28])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AF3C8649DD;
        Fri, 30 Nov 2018 14:44:03 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 35A9E20272; Fri, 30 Nov 2018 09:44:03 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4: fix "Lock reclaim failed" false positives
Date:   Fri, 30 Nov 2018 09:44:03 -0500
Message-Id: <20181130144403.31621-2-smayhew@redhat.com>
In-Reply-To: <20181130144403.31621-1-smayhew@redhat.com>
References: <20181130144403.31621-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 30 Nov 2018 14:44:04 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

During NFSv4 state recovery, the client attempts to reclaim locks that
are on the flc_posix and flc_flock lists of the file_lock_context of the
inode associated with an nfs4_state.  Then the client walks the
nfs4_state's lock_states list, looking for nfs4_lock_state's that do not
have NFS_LOCK_INITIALIZED set in their ls_flags.  If any are found, a
"Lock reclaim failed!" warning is issued.

Since nfs4_lock_state's are created before the corresponding file_lock
is in place at the vfs layer and removed after the file_lock is released
at the vfs layer, there is the possibility of false-positive warnings if
the client was in the process of acquiring or releasing locks when state
recovery was started.

Add a new nfs4_lock_state->ls_flag called "NFS_LOCK_TRY_RECLAIM" to
indicate the states that the client actually tried to reclaim, and
ignore nfs4_lock_states that do not have that flag when deciding whether
or not to log the "Lock reclaim failed!" warning.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/nfs4_fs.h   | 1 +
 fs/nfs/nfs4state.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1b994b527518..6ed04e8f8953 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -144,6 +144,7 @@ struct nfs4_lock_state {
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 0
 #define NFS_LOCK_LOST        1
+#define NFS_LOCK_TRY_RECLAIM 2
 	unsigned long		ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d8decf2ec48f..bd7a07641bd7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1509,6 +1509,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
 		spin_unlock(&flctx->flc_lock);
+		lsp = fl->fl_u.nfs4_fl.owner;
+		if (lsp)
+			set_bit(NFS_LOCK_TRY_RECLAIM, &lsp->ls_flags);
 		status = ops->recover_lock(state, fl);
 		switch (status) {
 		case 0:
@@ -1592,7 +1595,8 @@ static int __nfs4_reclaim_open_state(struct nfs4_state_owner *sp, struct nfs4_st
 	if (!test_bit(NFS_DELEGATED_STATE, &state->flags)) {
 		spin_lock(&state->state_lock);
 		list_for_each_entry(lock, &state->lock_states, ls_locks) {
-			if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
+			if (test_bit(NFS_LOCK_TRY_RECLAIM, &lock->ls_flags) &&
+			    !test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
 				pr_warn_ratelimited("NFS: %s: Lock reclaim failed!\n", __func__);
 		}
 		spin_unlock(&state->state_lock);
@@ -1693,6 +1697,7 @@ static void nfs4_clear_open_state(struct nfs4_state *state)
 	list_for_each_entry(lock, &state->lock_states, ls_locks) {
 		lock->ls_seqid.flags = 0;
 		clear_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags);
+		clear_bit(NFS_LOCK_TRY_RECLAIM, &lock->ls_flags);
 	}
 	spin_unlock(&state->state_lock);
 }
-- 
2.17.1

