Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40352 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932861AbdEKOAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 10:00:16 -0400
Subject: [PATCH 02/14] Clean up whitespace in fs/namespace.c [ver #2]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 11 May 2017 15:00:01 +0100
Message-ID: <149451120169.4599.16753519675983745973.stgit@warthog.procyon.org.uk>
In-Reply-To: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
References: <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
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
index cc1375eff88c..db034b6afd43 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1659,7 +1659,7 @@ void __detach_mounts(struct dentry *dentry)
 	namespace_unlock();
 }
 
-/* 
+/*
  * Is the caller allowed to modify his namespace?
  */
 static inline bool may_mount(void)
@@ -2213,7 +2213,7 @@ static int do_loopback(struct path *path, const char *old_name,
 
 	err = -EINVAL;
 	if (mnt_ns_loop(old_path.dentry))
-		goto out; 
+		goto out;
 
 	mp = lock_mount(path);
 	err = PTR_ERR(mp);

