Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:50186 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbaCERrt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 12:47:49 -0500
Received: by mail-qa0-f48.google.com with SMTP id m5so1311487qaj.7
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 09:47:47 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: James Morris <james.l.morris@oracle.com>,
        Serge Hallyn <serge.hallyn@canonical.com>
Cc: linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH] security: have cap_dentry_init_security return error
Date: Wed,  5 Mar 2014 12:47:37 -0500
Message-Id: <1394041657-7114-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, cap_dentry_init_security returns 0 without actually
initializing the security label. This confuses its only caller
(nfs4_label_init_security) which expects an error in that situation, and
causes it to end up sending out junk onto the wire instead of simply
suppressing the label in the attributes sent.

When CONFIG_SECURITY is disabled, security_dentry_init_security returns
-EOPNOTSUPP. Have cap_dentry_init_security do the same.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 security/capability.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/capability.c b/security/capability.c
index 8b4f24ae4338..9323bbeba296 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -116,7 +116,7 @@ static int cap_dentry_init_security(struct dentry *dentry, int mode,
 					struct qstr *name, void **ctx,
 					u32 *ctxlen)
 {
-	return 0;
+	return -EOPNOTSUPP;
 }
 
 static int cap_inode_alloc_security(struct inode *inode)
-- 
1.8.5.3

