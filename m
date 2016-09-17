Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35863 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcIQFNi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:38 -0400
Received: by mail-io0-f194.google.com with SMTP id z135so2380093ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 02/25] NFSv4: Don't report revoked delegations as valid in nfs_have_delegation()
Date: Sat, 17 Sep 2016 01:13:10 -0400
Message-Id: <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the delegation is revoked, then it can't be used for caching.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 322c2585bc34..86d2c748140b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -51,6 +51,7 @@ nfs4_do_check_delegation(struct inode *inode, fmode_t flags, bool mark)
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation != NULL && (delegation->type & flags) == flags &&
+	    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) &&
 	    !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags)) {
 		if (mark)
 			nfs_mark_delegation_referenced(delegation);
-- 
2.7.4

