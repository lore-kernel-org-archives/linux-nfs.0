Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48166 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab1CFROT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Mar 2011 12:14:19 -0500
Received: by yxs7 with SMTP id 7so1353079yxs.19
        for <linux-nfs@vger.kernel.org>; Sun, 06 Mar 2011 09:14:18 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: close NFSv4 COMMIT vs. CLOSE race
Date: Sun,  6 Mar 2011 12:14:13 -0500
Message-Id: <1299431653-11741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I've been adding in more artificial delays in the NFSv4 commit and close
codepaths to uncover races. The kernel I'm testing has the patch to
close the race in __rpc_wait_for_completion_task that's in Trond's
cthon2011 branch. The reproducer I've been using does this in a loop:

	mkdir("DIR");
	fd = open("DIR/FILE", O_WRONLY|O_CREAT|O_EXCL, 0644);
	write(fd, "abcdefg", 7);
	close(fd);
	unlink("DIR/FILE");
	rmdir("DIR");

The above reproducer shouldn't result in any silly-renaming. However,
when I add a "msleep(100)" just after the nfs_commit_clear_lock call in
nfs_commit_release, I can almost always force one to occur. If I can
force it to occur with that, then it can happen without that delay
given the right timing.

nfs_commit_inode waits for the NFS_INO_COMMIT bit to clear when called
with FLUSH_SYNC set. nfs_commit_rpcsetup on the other hand does not wait
for the task to complete before putting its reference to it, so the last
reference get put in rpc_release task and gets queued to a workqueue.

In this situation, the last open context reference may be put by the
COMMIT release instead of the close() syscall. The close() syscall
returns too quickly and the unlink runs while the d_count is still
high since the COMMIT release hasn't put its dentry reference yet.

Fix this by having rpc_commit_rpcsetup wait for the RPC call to complete
before putting the task reference when FLUSH_SYNC is set. With this, the
last reference is put by the process that's initiating the FLUSH_SYNC
commit and the race is closed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8278f4..42b92d7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1292,6 +1292,8 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	if (how & FLUSH_SYNC)
+		rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 	return 0;
 }
-- 
1.7.4

