Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34960 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab2DRLwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2012 07:52:12 -0400
Received: by yenl12 with SMTP id l12so3574038yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Apr 2012 04:52:12 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, malahal@us.ibm.com,
        bfields@fieldses.org, trond.myklebust@fys.uio.no, rees@umich.edu
Subject: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call
Date: Wed, 18 Apr 2012 07:52:07 -0400
Message-Id: <1334749927-26138-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ESTALE errors are a source of pain for many users of NFS. Usually they
occur when a file is removed from the server after a successful lookup
against it.

Luckily, the remedy in these cases is usually simple. We should just
redo the lookup, forcing revalidations all the way in and then retry the
call. We of course cannot do this for syscalls that do not involve a
path, but for path-based syscalls we can and should attempt to recover
from an ESTALE.

This patch implements this by having the VFS reattempt the lookup (with
LOOKUP_REVAL set) and call exactly once when it would ordinarily return
ESTALE. This should catch the bulk of these cases under normal usage,
without unduly inconveniencing other filesystems that return ESTALE on
path-based syscalls.

Note that it's possible to hit this race more than once, but a single
retry should catch the bulk of these cases under normal circumstances.

This patch is just an example. We'll alter most path-based syscalls in a
similar fashion to fix this correctly. At this point, I'm just trying to
ensure that the retry semantics are acceptable before I being that work.

Does anyone have strong objections to this patch? I'm aware that the
retry mechanism is not as robust as many (e.g. Peter) would like, but it
should at least improve the current situation.

If no one has a strong objection, then I'll start going through and
adding similar code to the other syscalls. And we can hopefully we can
get at least some of them in for 3.5.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/stat.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index c733dc5..0ee9cb4 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	bool retried = false;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -84,12 +85,18 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
+retry:
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
 		goto out;
 
 	error = vfs_getattr(path.mnt, path.dentry, stat);
 	path_put(&path);
+	if (error == -ESTALE && !retried) {
+		retried = true;
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
 out:
 	return error;
 }
-- 
1.7.7.6

