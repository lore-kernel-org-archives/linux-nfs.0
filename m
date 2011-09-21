Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab1IUO62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] leases: break read leases on unlink
Date: Wed, 21 Sep 2011 10:58:14 -0400
Message-Id: <1316617097-21384-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A read lease is used by NFSv4 as a guarantee that a client can perform
local read opens without informing the server.

The open operation takes the last component of the pathname as an
argument, thus is also a lookup operation, and giving the client the
above guarantee means informing the client before we allow anything that
would change the set of names pointing to the inode.

Samba, from what I can tell, has similar requirements, so this is really
a bug in the lease code, I think, not just a strange requirement from
NFS.

Therefore, we need to break leases on rename, link, and unlink.

Start with unlink.

The simplest thing to do is just to use the fact that unlink always
takes the i_mutex to prevent new leases from being acquired while the
unlink is in progress.

The lease is generally just an optimization--it's always OK not to give
one out.  So we can just do a mutex_trylock() in setlease() and fail the
setlease if we don't get the lock.

It's annoying that the lease break--which will require acknowledgement
from an nfs client or an application--happens while holding the i_mutex.
But the time for that is limited by lease_break_time, so at least
there's no (permanent) deadlock there.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |    7 +++++--
 fs/namei.c |    3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index b342902..61130c1 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1361,6 +1361,9 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 
 	lease = *flp;
 
+	if (!mutex_trylock(&inode->i_mutex))
+		return -EAGAIN;
+
 	error = -EAGAIN;
 	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 		goto out;
@@ -1411,9 +1414,9 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 		goto out;
 
 	locks_insert_lock(before, lease);
-	return 0;
-
+	error = 0;
 out:
+	mutex_unlock(&inode->i_mutex);
 	return error;
 }
 
diff --git a/fs/namei.c b/fs/namei.c
index 6ff59e5..5c78f72 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2772,6 +2772,9 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 		error = security_path_unlink(&nd.path, dentry);
 		if (error)
 			goto exit3;
+		error = break_lease(inode, O_WRONLY);
+		if (error)
+			goto exit3;
 		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
 exit3:
 		mnt_drop_write(nd.path.mnt);
-- 
1.7.4.1

