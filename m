Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46479 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752948AbdFNPP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:15:56 -0400
Subject: [PATCH 03/27] VFS: Make get_mnt_ns() return the namespace [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:15:42 +0100
Message-ID: <149745334260.10897.8377331388521502715.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
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

