Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59740 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbeEKVNl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2018 17:13:41 -0400
Date: Fri, 11 May 2018 22:13:39 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Subject: [RFC][PATCH] nfsd: vfs_mkdir() might succeed leaving dentry negative
 unhashed
Message-ID: <20180511211339.GG30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[-stable fodder; as it is, one can e.g. add
/mnt/cgroup     localhost(rw,no_root_squash,fsid=4242)
to /etc/exports,
mount -t cgroup none /mnt/cgroup
mkdir /tmp/a
mount -t nfs localhost://mnt/cgroup /tmp/a
mkdir /tmp/a/foo

and have knfsd oops; the patch below deals with that.

Questions:
	1) is fh_update() use below legitimate, or should we
do fh_put/fh_compose instead?
	2) is nfserr_serverfail valid for situation when
directory created by such vfs_mkdir() manages to disappear
under us immediately afterwards?  Or should we return nfserr_stale
instead?

It's in vfs.git#for-linus, if you prefer to use git for review...
]

That can (and does, on some filesystems) happen - ->mkdir() (and thus
vfs_mkdir()) can legitimately leave its argument negative and just
unhash it, counting upon the lookup to pick the object we'd created
next time we try to look at that name.

Some vfs_mkdir() callers forget about that possibility...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2410b093a2e6..b0555d7d8200 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1201,6 +1201,28 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case S_IFDIR:
 		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
+		if (!host_err && unlikely(d_unhashed(dchild))) {
+			struct dentry *d;
+			d = lookup_one_len(dchild->d_name.name,
+					   dchild->d_parent,
+					   dchild->d_name.len);
+			if (IS_ERR(d)) {
+				host_err = PTR_ERR(d);
+				break;
+			}
+			if (unlikely(d_is_negative(d))) {
+				dput(d);
+				err = nfserr_serverfault;
+				goto out;
+			}
+			dput(resfhp->fh_dentry);
+			resfhp->fh_dentry = dget(d);
+			err = fh_update(resfhp);
+			dput(dchild);
+			dchild = d;
+			if (err)
+				goto out;
+		}
 		break;
 	case S_IFCHR:
 	case S_IFBLK:
