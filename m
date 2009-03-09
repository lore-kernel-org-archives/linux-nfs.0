From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] [RESEND] NFS: Handle -ESTALE error in access()
Date: Mon, 09 Mar 2009 18:15:50 +0530
Message-ID: <49B50F7E.9080500@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:41902 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbZCIMqL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 08:46:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I sent this patch a while ago and I guess it's got lost admist busy
cthon'09 and FAST '09 schedules. So, resending for consideration and
inclusion.

There have been multiple bug reports on temporarily failure of
applications while trying to launch them from a KDE session on a NFS
mounted home.

http://bugzilla.kernel.org/show_bug.cgi?id=12557
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/269954
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508866.html

This issue can be reproducible consistently by doing this on a NFS
mounted KDE home:
 1. Open 2 xterm sessions
 2. From one of the xterm session, do "ssh -X <remote host>"
 3. "stat ~/.Xauthority" on the remote SSH session
 4. Close the two xterm sessions
 5. On the server do a "stat ~/.Xauthority"
 6. Now on the client, try to open xterm
This will fail.

Even if the filehandle had become stale, the NFS client should
invalidate the cache/inode and should repeat LOOKUP. Looking at the
packet capture during the failure shows that there were two subsequent
ACCESS() calls with the same filehandle and both failed with -ESTALE
error. This patch attempts to fix this. I have tested this fix
and with this fix the client retries LOOKUP as expected.
---

If the server returns an -ESTALE error due to stale filehandle in
response to an ACCESS() call, we need to invalidate the cache and inode
so that LOOKUP() can be retried. Without this change, the nfs client
retries ACCESS() with the same filehandle, fails again and could lead to
temporary failure of applications running on nfs mounted home.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---

 fs/nfs/dir.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e35c819..672368f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1892,8 +1892,14 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	cache.cred = cred;
 	cache.jiffies = jiffies;
 	status = NFS_PROTO(inode)->access(inode, &cache);
-	if (status != 0)
+	if (status != 0) {
+		if (status == -ESTALE) {
+			nfs_zap_caches(inode);
+			if (!S_ISDIR(inode->i_mode))
+				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+		}
 		return status;
+	}
 	nfs_access_add_cache(inode, &cache);
 out:
 	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)

