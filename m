Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbaATRsK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 12:48:10 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0KHm9q1029471
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 12:48:09 -0500
Received: from smallhat.boston.devel.redhat.com.org (vpn-58-78.rdu2.redhat.com [10.10.58.78])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0KHm8ev017628
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 12:48:09 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Removed supported flag from usage string
Date: Mon, 20 Jan 2014 12:49:57 -0500
Message-Id: <1390240197-24908-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/utils.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index 2778ed7..ede77a8 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -93,7 +93,7 @@ void print_one(char *spec, char *node, char *type, char *opts)
 
 void mount_usage(void)
 {
-	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
+	printf(_("usage: %s remotetarget dir [-rvVwfnsh] [-o nfsoptions]\n"),
 		progname);
 	printf(_("options:\n"));
 	printf(_("\t-r\t\tMount file system readonly\n"));
-- 
1.8.3.1

