Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752908AbdEVPvk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:51:40 -0400
Subject: [PATCH 02/23] VFS: Clean up whitespace in fs/namespace.c [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:51:30 +0100
Message-ID: <149546829059.9289.1136673163269934984.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up line terminal whitespace in fs/namespace.c.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 8bd3e4d448b9..c076787871e7 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1656,7 +1656,7 @@ void __detach_mounts(struct dentry *dentry)
 	namespace_unlock();
 }
 
-/* 
+/*
  * Is the caller allowed to modify his namespace?
  */
 static inline bool may_mount(void)
@@ -2210,7 +2210,7 @@ static int do_loopback(struct path *path, const char *old_name,
 
 	err = -EINVAL;
 	if (mnt_ns_loop(old_path.dentry))
-		goto out; 
+		goto out;
 
 	mp = lock_mount(path);
 	err = PTR_ERR(mp);

