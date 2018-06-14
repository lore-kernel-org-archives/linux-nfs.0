Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55530 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754819AbeFNTcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:32:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd: update obselete comment referencing the BKL
Date: Thu, 14 Jun 2018 15:32:11 -0400
Message-Id: <1529004733-6022-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004733-6022-1-git-send-email-bfields@redhat.com>
References: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It's inode->i_lock that's now taken in setlease and break_lease, instead
of the big kernel lock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b762054377e0..294b9a433594 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3944,9 +3944,9 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	/*
 	 * We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
-	 * callback (and since the lease code is serialized by the kernel
-	 * lock) we know the server hasn't removed the lease yet, we know
-	 * it's safe to take a reference.
+	 * callback (and since the lease code is serialized by the
+	 * i_lock) we know the server hasn't removed the lease yet, and
+	 * we know it's safe to take a reference.
 	 */
 	refcount_inc(&dp->dl_stid.sc_count);
 	nfsd4_run_cb(&dp->dl_recall);
-- 
2.17.1

