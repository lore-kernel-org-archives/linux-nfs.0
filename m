Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47182 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752908AbdEVPv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:51:57 -0400
Subject: [PATCH 03/23] VFS: Make get_mnt_ns() return the namespace [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:51:45 +0100
Message-ID: <149546830481.9289.4135112774863721416.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make get_mnt_ns() return the namespace it got a ref on for consistency with
other namespace ref getting functions.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/mount.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/mount.h b/fs/mount.h
index bf1fda6eed8f..02ef292a77d7 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -108,9 +108,10 @@ static inline void detach_mounts(struct dentry *dentry)
 	__detach_mounts(dentry);
 }
 
-static inline void get_mnt_ns(struct mnt_namespace *ns)
+static inline struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns)
 {
 	atomic_inc(&ns->count);
+	return ns;
 }
 
 extern seqlock_t mount_lock;

