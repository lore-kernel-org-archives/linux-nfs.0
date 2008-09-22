From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 1/2] nfs: BUG_ON in nfs_follow_mountpoint
Date: Mon, 22 Sep 2008 14:10:53 -0700
Message-ID: <200809222110.m8MLAsCo029914@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, den@openvz.org,
	Trond.Myklebust@netapp.com
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50176 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753154AbYIVVLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 17:11:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>

Unfortunately, BUG_ON(IS_ROOT(dentry)) can happen inside
nfs_follow_mountpoint with NFS running Fedora 8 using a specific setup.

See https://bugzilla.redhat.com/show_bug.cgi?id=458622

So the situation should be handled on NFS client gracefully.

(Trond: 

  I'm not convinced that ESTALE is the correct error to return to the
  user.  ESTALE has a very precise meaning in the NFS protocol: it tells
  you that access to the object has been revoked.

  That again means either that either the object has been deleted, or it
  is no longer exported by the server to this client.

  In the case referred to by Denis, the source of the bug is a broken
  server, and so I'd expect that EIO is probably more appropriate.)

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/namespace.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN fs/nfs/namespace.c~nfs-bug_on-in-nfs_follow_mountpoint fs/nfs/namespace.c
--- a/fs/nfs/namespace.c~nfs-bug_on-in-nfs_follow_mountpoint
+++ a/fs/nfs/namespace.c
@@ -105,7 +105,10 @@ static void * nfs_follow_mountpoint(stru
 
 	dprintk("--> nfs_follow_mountpoint()\n");
 
-	BUG_ON(IS_ROOT(dentry));
+	err = -ESTALE;
+	if (IS_ROOT(dentry))
+		goto out_err;
+
 	dprintk("%s: enter\n", __func__);
 	dput(nd->path.dentry);
 	nd->path.dentry = dget(dentry);
_
