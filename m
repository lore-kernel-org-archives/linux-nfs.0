Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756102Ab2BGNCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 08:02:16 -0500
From: Steve Dickson <steved@redhat.com>
To: James Morris <jmorris@namei.org>
Cc: Linux Keyring Mailing list <keyrings@linux-nfs.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Make keys writable on the idmap keyring.
Date: Tue,  7 Feb 2012 08:02:13 -0500
Message-Id: <1328619733-30859-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To take advantage of the "Allow special keyrings to be
cleared" keyring patch the NFS keyring has to be writeable.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/idmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index a1bbf77..1d88cdb 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -269,7 +269,7 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
 	}
 
 	rcu_read_lock();
-	rkey->perm |= KEY_USR_VIEW;
+	rkey->perm |= KEY_USR_VIEW|KEY_USR_WRITE;
 
 	ret = key_validate(rkey);
 	if (ret < 0)
-- 
1.7.7.5

