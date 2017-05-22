Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757277AbdEVQXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:25 -0400
Subject: [PATCH 6/9] Allow fs syscall dfd arguments to take a container fd
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:23:17 +0100
Message-ID: <149547019721.10599.1876770305181115673.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some filesystem system calls, such as mkdirat(), take a 'directory fd' to
specify the pathwalk origin.  This takes either AT_FDCWD or a file
descriptor that refers to an open directory.

Make it possible to supply a container fd, as obtained from
container_create(), instead thereby specifying the container's root as the
origin.  This performs the filesystem operation into the container's mount
namespace.  For example:

	int cfd = container_create("fred", CONTAINER_NEW_MNT_NS, 0);
	mkdirat(cfd, "/fred", 0755);

A better way to do this might be to temporarily override current->fs and
current->nsproxy, but this requires splitting those fields so that procfs
doesn't see the override.

A sequence number and lock are available to protect the root pointer in
case container_chroot() and/or container_pivot_root() are implemented.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c |   52 ++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0d35760fee00..2f0310a39e60 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2208,23 +2208,47 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 		if (!f.file)
 			return ERR_PTR(-EBADF);
 
-		dentry = f.file->f_path.dentry;
+		if (is_container_file(f.file)) {
+			struct container *c = f.file->private_data;
+			unsigned seq;
 
-		if (*s) {
-			if (!d_can_lookup(dentry)) {
-				fdput(f);
-				return ERR_PTR(-ENOTDIR);
+			if (!*s)
+				return ERR_PTR(-EINVAL);
+
+			if (flags & LOOKUP_RCU) {
+				rcu_read_lock();
+				do {
+					seq = read_seqcount_begin(&c->seq);
+					nd->path = c->root;
+					nd->inode = nd->path.dentry->d_inode;
+					nd->seq = __read_seqcount_begin(&nd->path.dentry->d_seq);
+				} while (read_seqcount_retry(&c->seq, seq));
+			} else {
+				spin_lock(&c->lock);
+				nd->path = c->root;
+				path_get(&nd->path);
+				spin_unlock(&c->lock);
+				nd->inode = nd->path.dentry->d_inode;
 			}
-		}
-
-		nd->path = f.file->f_path;
-		if (flags & LOOKUP_RCU) {
-			rcu_read_lock();
-			nd->inode = nd->path.dentry->d_inode;
-			nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
 		} else {
-			path_get(&nd->path);
-			nd->inode = nd->path.dentry->d_inode;
+			dentry = f.file->f_path.dentry;
+
+			if (*s) {
+				if (!d_can_lookup(dentry)) {
+					fdput(f);
+					return ERR_PTR(-ENOTDIR);
+				}
+			}
+
+			nd->path = f.file->f_path;
+			if (flags & LOOKUP_RCU) {
+				rcu_read_lock();
+				nd->inode = nd->path.dentry->d_inode;
+				nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
+			} else {
+				path_get(&nd->path);
+				nd->inode = nd->path.dentry->d_inode;
+			}
 		}
 		fdput(f);
 		return s;

