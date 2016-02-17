Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422745AbcBQPlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 10:41:42 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4: Fix a dentry leak on alias use
Date: Wed, 17 Feb 2016 10:41:41 -0500
Message-Id: <0a2b2b20ebb7f170c0176dbe9a285429b07875b8.1455723010.git.bcodding@redhat.com>
In-Reply-To: <a65c14e6e3e051fd2367732ba4b237d3605920a6.1455718518.git.bcodding@redhat.com>
References: <a65c14e6e3e051fd2367732ba4b237d3605920a6.1455718518.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've had some users hitting what used to be a BUG() in
shink_dcache_for_umount() but is now a printk:

BUG: Dentry ffff880066676000{i=20007,n=foobar} still in use (1) [unmount of nfs4 0:39]
VFS: Busy inodes after unmount of 0:39. Self-destruct in 5 seconds.  Have a nice day...

The users don't like that very much.

I've spotted a dentry leak in the rare case where d_add_unique() finds an
alias on open and we swap the open context's dentry.  I'm pretty sure we
shouldn't be doing another dget() there.  I can reliably reproduce it with
this bit of bash:

mkdir -p /exports/dir{1,2}
exportfs -o rw localhost:/exports
mount -t nfs -ov4.1 localhost:/ /mnt/localhost

(sleep 2) > /mnt/localhost/dir1/foobar &
waitpid="$!"
sleep 1
mv /exports/dir{1,2}/foobar
echo A > /mnt/localhost/dir2/foobar
stat /mnt/localhost/dir1/foobar 2> /dev/null
mv /exports/dir{2,1}/foobar
echo A > /mnt/localhost/dir1/foobar

wait $waitpid
umount /mnt/localhost

Ben

Version 2:

This version corrects for the case where the dentry returned is the same as
the ctx->dentry, even though that is quite impossible.  There's no need to
check if the returned dentry differs from ctx->dentry, so get rid of the
check.

8<---------------------------------------------------------------------
In the case where d_add_unique() finds an appropriate alias to use it will
have already incremented the reference count.  An additional dget() to swap
the open context's dentry is unnecessary and will leak a reference.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4bfc33a..1488159 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2466,9 +2466,9 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		dentry = d_add_unique(dentry, igrab(state->inode));
 		if (dentry == NULL) {
 			dentry = opendata->dentry;
-		} else if (dentry != ctx->dentry) {
+		} else {
 			dput(ctx->dentry);
-			ctx->dentry = dget(dentry);
+			ctx->dentry = dentry;
 		}
 		nfs_set_verifier(dentry,
 				nfs_save_change_attribute(d_inode(opendata->dir)));
-- 
1.7.1

