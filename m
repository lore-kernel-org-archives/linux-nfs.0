Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f54.google.com ([209.85.213.54]:43494 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab3JaRDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 13:03:11 -0400
Received: by mail-yh0-f54.google.com with SMTP id b20so1324885yha.13
        for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 10:03:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: [PATCH] nfs: fix inverted test for delegation in nfs4_reclaim_open_state
Date: Thu, 31 Oct 2013 13:03:04 -0400
Message-Id: <1383238984-11063-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 6686390bab6a0e0 (NFS: remove incorrect "Lock reclaim failed!"
warning.) added a test for a delegation before checking to see if any
reclaimed locks failed. The test however is backward and is only doing
that check when a delegation is held instead of when one isn't.

Cc: NeilBrown <neilb@suse.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 452f4c8..c8e729d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1476,7 +1476,7 @@ restart:
 		if (status >= 0) {
 			status = nfs4_reclaim_locks(state, ops);
 			if (status >= 0) {
-				if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0) {
+				if (!test_bit(NFS_DELEGATED_STATE, &state->flags)) {
 					spin_lock(&state->state_lock);
 					list_for_each_entry(lock, &state->lock_states, ls_locks) {
 						if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
-- 
1.8.3.1

