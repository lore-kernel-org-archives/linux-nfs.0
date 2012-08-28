Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29639 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab2H1S0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 14:26:30 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: Fix access on first execute of uncached file
Date: Tue, 28 Aug 2012 14:26:26 -0400
Message-Id: <1346178386-7345-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client currently fails to execute a file that is executable but not
readable -- but only on the first reference of that file.
If the file has been referenced and has a inode linked into the namei cache,
everything works as expected:

simple script:

 $ sudo mount -o v4 zero:/export /mnt
 $ ls -l /mnt/test.sh
 --wx-wx--x 1 dros dros 26 Aug 28  2012 /mnt/test.sh
 $ cat /mnt/test.sh
 #!/bin/sh

 echo "success"
 $ sudo umount /mnt

first access makes execute fail, subsequent accesses succeed:

 $ sudo mount -o v4 zero:/export /mnt
 $ /mnt/test.sh
 -bash: /mnt/test.sh: /bin/sh: bad interpreter: Permission denied
 $ /mnt/test.sh
 success
 $ sudo umount /mnt

On the wire, the first execute calls ACCESS with the mask MAY_EXEC|MAY_READ,
while subsequent calls use just MAY_EXEC.

Any reference to the file inode before the first execute will result in
expected behavior:

 $ sudo mount -o v4 zero:/export /mnt
 $ ls -l /mnt/test.sh
 --wx-wx--x 1 dros dros 26 Aug 28 11:52 /mnt/test.sh
 $ /mnt/test.sh
 success

Only OPENs as the first reference will use nfs_open_permission_mask() to
create the ACCESS mask.  If the file has an inode associated with it, it
will use nfs_permission which is passed the (correct) access bits from VFS
instead of mapping from an openmode.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

This patch is an RFC. I'm not sure if this is the correct way to fix the
issue and I'm open to suggestions!

Thanks!
 -dros

 fs/nfs/dir.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 627f108..3fefdaf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2132,7 +2132,8 @@ static int nfs_open_permission_mask(int openflags)
 {
 	int mask = 0;
 
-	if ((openflags & O_ACCMODE) != O_WRONLY)
+	if (((openflags & O_ACCMODE) != O_WRONLY) &&
+	    !(openflags & __FMODE_EXEC))
 		mask |= MAY_READ;
 	if ((openflags & O_ACCMODE) != O_RDONLY)
 		mask |= MAY_WRITE;
-- 
1.7.9.6 (Apple Git-31.1)

