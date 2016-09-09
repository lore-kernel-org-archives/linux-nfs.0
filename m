Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753226AbcIISry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:47:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/10] nfs: track whether server sets MAY_NOTIFY_LOCK flag
Date: Fri,  9 Sep 2016 14:47:46 -0400
Message-Id: <1473446870-1831-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If it does, then always have the client sleep for the max time before
repolling for the lock. If it doesn't then we can skip all of the
waitqueue handling as well.

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
index 90e8ded0ef82..627a9185822f 100644
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

