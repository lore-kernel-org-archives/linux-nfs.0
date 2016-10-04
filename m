Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52142 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbcJDNiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Oct 2016 09:38:00 -0400
From: Artem Savkov <asavkov@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, linux-kernel@vger.kernel.org,
        Artem Savkov <asavkov@redhat.com>
Subject: [PATCH] Fix suspicious RCU usage in nfs_idmap_get_key.
Date: Tue,  4 Oct 2016 15:37:40 +0200
Message-Id: <1475588260-10838-1-git-send-email-asavkov@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_idmap_get_key doesn't hold rkey->sem when calling user_key_payload
resulting in a "suspicious RCU usage" lockdep splat. It does, however hold
rcu_read_lock, so it either needs to use unprotected rcu_dereference, or take
rkey->sem instead of rcu_read_lock.

Signed-off-by: Artem Savkov <asavkov@redhat.com>
---
 fs/nfs/nfs4idmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index c444285..a67d1c0 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -309,7 +309,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		goto out;
 	}
 
-	rcu_read_lock();
+	down_read(&rkey->sem);
 	rkey->perm |= KEY_USR_VIEW;
 
 	ret = key_validate(rkey);
@@ -329,7 +329,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		ret = -EINVAL;
 
 out_up:
-	rcu_read_unlock();
+	up_read(&rkey->sem);
 	key_put(rkey);
 out:
 	return ret;
-- 
2.7.4

