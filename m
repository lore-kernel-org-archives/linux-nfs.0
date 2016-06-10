Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34189 "EHLO
	mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932608AbcFJQIp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 12:08:45 -0400
Received: by mail-qt0-f196.google.com with SMTP id 9so2823772qtg.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 09:08:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS/pnfs: handle bad delegation stateids in nfs4_layoutget_handle_exception
Date: Fri, 10 Jun 2016 11:49:57 -0400
Message-Id: <1465573798-80118-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465573798-80118-3-git-send-email-trond.myklebust@primarydata.com>
References: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-2-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must call nfs4_handle_exception() on BAD_STATEID errors. The only
exception is if the stateid argument turns out to be a layout stateid
that is declared invalid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 27fe63b502d5..406dd3eb68e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7924,8 +7924,8 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			break;
 		}
 		lo = NFS_I(inode)->layout;
-		if (lo && nfs4_stateid_match(&lgp->args.stateid,
-					&lo->plh_stateid)) {
+		if (lo && !test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
+		    nfs4_stateid_match_other(&lgp->args.stateid, &lo->plh_stateid)) {
 			LIST_HEAD(head);
 
 			/*
@@ -7936,10 +7936,10 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
+			status = -EAGAIN;
+			goto out;
 		} else
 			spin_unlock(&inode->i_lock);
-		status = -EAGAIN;
-		goto out;
 	}
 
 	status = nfs4_handle_exception(server, status, exception);
-- 
2.5.5

