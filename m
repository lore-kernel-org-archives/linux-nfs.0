Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248Ab1IOOgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Sep 2011 10:36:44 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8FEaiWJ030588
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2011 10:36:44 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8FEahi6030179
	for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2011 10:36:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mount.nfs: mounts fail when invalid versions are specified
Date: Thu, 15 Sep 2011 10:36:42 -0400
Message-Id: <1316097402-10528-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When mount options like -o nfsvers=5 or -o v5 call the mount
to silently fail. This patch adds verbosity to those types
of failures.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e7bd522..e125c11 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1235,6 +1235,10 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 	long tmp;
 
 	switch (po_rightmost(options, nfs_version_opttbl)) {
+	case -1: /* invalid value */
+		nfs_error(_("%s: invalid mount option was specified"),
+					progname);
+		return 0;
 	case 0:	/* v2 */
 		*version = 2;
 		return 1;
@@ -1251,6 +1255,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+			nfs_error(_("%s: invalid value for 'vers=' option"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
 			nfs_error(_("%s: parsing error on 'vers=' option\n"),
@@ -1268,6 +1274,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
 			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
-- 
1.7.6

