Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbaCTUMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Mar 2014 16:12:36 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2KKCZmU029963
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 16:12:36 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-38.rdu.redhat.com [10.13.145.38])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s2KKCZRB030479
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 16:12:35 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id s2KKCZVr064104
	for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 16:12:35 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id s2KKCYZM064102
	for linux-nfs@vger.kernel.org; Thu, 20 Mar 2014 16:12:34 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mount: chk_mountpoint should only check for execute perms for unpriveleged users
Date: Thu, 20 Mar 2014 16:12:34 -0400
Message-Id: <1395346354-64069-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise 'mount -o remount' fails on mounts that have root squashing
enabled and world execute perms disabled.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/mount/utils.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index ede77a8..92662ed 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -130,7 +130,7 @@ int chk_mountpoint(const char *mount_point)
 		mount_error(NULL, mount_point, ENOTDIR);
 		return 1;
 	}
-	if (access(mount_point, X_OK) < 0) {
+	if (getuid() != 0 && geteuid() != 0 && access(mount_point, X_OK) < 0) {
 		mount_error(NULL, mount_point, errno);
 		return 1;
 	}
-- 
1.7.11.7

