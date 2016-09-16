Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965229AbcIPU1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:27:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 2/9] nfs: check for POSIX lock capability on server even for flock locks
Date: Fri, 16 Sep 2016 16:27:04 -0400
Message-Id: <1474057631-31209-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We may end up in here with a FL_FLOCK lock request. We translate those
to whole-file NFSv4 locks and send them on to the server, so we need to
verify that the server supports them no matter what sort of lock request
this is.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9d38366666f4..a0f25185c78c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6135,8 +6135,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	unsigned char fl_flags = request->fl_flags;
 	int status = -ENOLCK;
 
-	if ((fl_flags & FL_POSIX) &&
-			!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
+	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
 		goto out;
 	/* Is this a delegated open? */
 	status = nfs4_set_lock_state(state, request);
-- 
2.7.4

