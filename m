Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386Ab2CHOhh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 09:37:37 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q28EbbpZ030176
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 8 Mar 2012 09:37:37 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q28EbbLA026703
	for <linux-nfs@vger.kernel.org>; Thu, 8 Mar 2012 09:37:37 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] rpcbind: drop supplemental groups
Date: Thu,  8 Mar 2012 09:37:30 -0500
Message-Id: <1331217450-20798-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop out of the 'root' group to ensure the process does
not have any access to writable or readable files
to that group.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcbind.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 24e069b..9a0504d 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -236,6 +236,10 @@ main(int argc, char *argv[])
                         syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
                         exit(1);
                 }
+		if (setgroups(0, NULL) == -1) {
+			syslog(LOG_ERR, "dropping supplemental groups failed: %m");
+			exit(1);
+		}
 		if (setuid(p->pw_uid) == -1) {
 			syslog(LOG_ERR, "setuid to '%s' (%d) failed: %m", id, p->pw_uid);
 			exit(1);
-- 
1.7.7.6

