Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:34256 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbaGVQli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 12:41:38 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so6752928qaj.7
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 09:41:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: bump dp->dl_time when unhashing delegation
Date: Tue, 22 Jul 2014 12:41:31 -0400
Message-Id: <1406047291-1279-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's a potential race between a lease break and DELEGRETURN call.

Suppose a lease break comes in and queues the workqueue job for a
delegation, but it doesn't run just yet. Then, a DELEGRETURN comes in
finds the delegation and calls destroy_delegation on it to unhash it and
put its primary reference.

Next, the workqueue job runs and queues the delegation back onto the
del_recall_lru list, issues the CB_RECALL and puts the final reference.
With that, the final reference to the delegation is put, but it's still
on the LRU list.

When we go to unhash a delegation, it's because we intend to get rid of
it soon afterward, so we don't want lease breaks to mess with it once
that occurs. Fix this by bumping the dl_time whenever we unhash a
delegation, to ensure that lease breaks don't monkey with it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72da0d44e66b..a3a828d17563 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -660,6 +660,8 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 	spin_lock(&state_lock);
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
+	/* Ensure that deleg break won't try to requeue it */
+	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
-- 
1.9.3

