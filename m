Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754501Ab3EJTd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 May 2013 15:33:28 -0400
Subject: [PATCH 3/8] CacheFiles: name i_mutex lock class explicitly [ver #2]
To: Trond.Myklebust@netapp.com, torvalds@linux-foundation.org
From: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cachefs@redhat.com, "J. Bruce Fields" <bfields@redhat.com>,
        linux-kernel@vger.kernel.org
Date: Fri, 10 May 2013 20:33:23 +0100
Message-ID: <20130510193323.3045.57648.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130510193257.3045.77981.stgit@warthog.procyon.org.uk>
References: <20130510193257.3045.77981.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@redhat.com>

Just some cleanup.

(And note the caller of this function may, for example, call vfs_unlink
on a child, so the "1" (I_MUTEX_PARENT) really was what was intended
here.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/namei.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 8c01c5fc..07cbd44 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -836,7 +836,7 @@ static struct dentry *cachefiles_check_active(struct cachefiles_cache *cache,
 	//       dir->d_name.len, dir->d_name.len, dir->d_name.name, filename);
 
 	/* look up the victim */
-	mutex_lock_nested(&dir->d_inode->i_mutex, 1);
+	mutex_lock_nested(&dir->d_inode->i_mutex, I_MUTEX_PARENT);
 
 	start = jiffies;
 	victim = lookup_one_len(filename, dir, strlen(filename));

