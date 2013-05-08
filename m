Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab3EHSk1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 14:40:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: sds@tycho.nsa.gov, james.l.morris@oracle.com, eparis@parisplace.org
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] selinux: make return code consistent with conflicting context= settings on same superblock
Date: Wed,  8 May 2013 14:40:20 -0400
Message-Id: <1368038420-19879-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 094f7b69ea73 adds a new check to ensure that when we clone an
existing superblock that the contexts match properly. We do however have
another place where you can hit similar problems in
selinux_set_mnt_opts. That function returns -EINVAL, whereas
selinux_sb_clone_mnt_opts returns -EBUSY in this situation.

I think -EBUSY is probably more descriptive of the situation here. The
context= option would have worked had the superblock not already been in
use. Fix selinux_set_mnt_opts to return -EBUSY instead of -EINVAL in
this situation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 security/selinux/hooks.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c6f2cd..348f069 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -745,7 +745,7 @@ out:
 	mutex_unlock(&sbsec->lock);
 	return rc;
 out_double_mount:
-	rc = -EINVAL;
+	rc = -EBUSY;
 	printk(KERN_WARNING "SELinux: mount invalid.  Same superblock, different "
 	       "security settings for (dev %s, type %s)\n", sb->s_id, name);
 	goto out;
-- 
1.7.1

