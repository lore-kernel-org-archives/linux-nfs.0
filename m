Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52958 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2COS3d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 14:29:33 -0400
From: Vivek Trivedi <vtrivedi018@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Vivek Trivedi <vtrivedi018@gmail.com>, Namjae Jeon <linkinjeon@gmail.com>
Subject: [PATCH 1/1] NFS: fix sb->s_id in nfs debug prints
Date: Thu, 15 Mar 2012 23:58:52 +0530
Message-Id: <1331836132-2053-1-git-send-email-vtrivedi018@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS bdi flush thread in ps output is printed like "flush-<major number
in decimal>:<minor number in decimal>"
For example:
$ ps aux | grep flush
 2079 root         0 SW   [flush-0:18]
                                 ^^^^

nfs_bdi_register()
==> bdi_register_dev()
==> bdi_register(bdi, NULL, "%u:%u", MAJOR(dev), MINOR(dev));
                             ^^^^^

However, NFS sb->s_id store major:minor number in hex:

nfs_initialise_sb()
==>         snprintf(sb->s_id, sizeof(sb->s_id),
                 "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
                  ^^^^^

If we enable nfs debug prints using command:
$ rpcdebug -m nfs -s all

write to a file:
$ dd if=/dev/zero of=<NFS Mount>/testfile.txt bs=32768 count=1

Without Patch:
[ 2431.032000] NFS:     0 initiated write call (req 0:12/40, 32768 bytes
@ offset 0)                                         ^^^^

With Patch:
[ 2431.032000] NFS:     0 initiated write call (req 0:18/40, 32768 bytes
@ offset 0)                                         ^^^^

We should store NFS "s->s_id" in decimal to avoid confusion between NFS
flush thread name(in ps output) and NFS debug prints.

Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
---
 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3dfa4f1..d64bc3c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2047,7 +2047,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 
 	/* We probably want something more informative here */
 	snprintf(sb->s_id, sizeof(sb->s_id),
-		 "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
+		 "%u:%u", MAJOR(sb->s_dev), MINOR(sb->s_dev));
 
 	if (sb->s_blocksize == 0)
 		sb->s_blocksize = nfs_block_bits(server->wsize,
-- 
1.7.8.4

