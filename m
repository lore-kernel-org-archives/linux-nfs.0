Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45206 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965462AbcIPU1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:27:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 5/9] nfs: track whether server sets MAY_NOTIFY_LOCK flag
Date: Fri, 16 Sep 2016 16:27:07 -0400
Message-Id: <1474057631-31209-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to handle the two cases differently, such that we poll more
aggressively when we don't expect a callback.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4_fs.h  | 1 +
 fs/nfs/nfs4proc.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9bf64eacba5b..91e4f135a5f2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -156,6 +156,7 @@ enum {
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
+	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
 };
 
 struct nfs4_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 253b0c09fb02..c8ccf13e3ffb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2537,6 +2537,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		goto out;
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
+	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
+		set_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags);
 
 	dentry = opendata->dentry;
 	if (d_really_is_negative(dentry)) {
-- 
2.7.4

