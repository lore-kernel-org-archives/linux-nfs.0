Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbaAGTXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 14:23:32 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s07JNWnb028544
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jan 2014 14:23:32 -0500
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s07JNVQh032390
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jan 2014 14:23:32 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Don't silently ignore invalid protocol versions.
Date: Tue,  7 Jan 2014 14:25:17 -0500
Message-Id: <1389122717-14269-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 2853d00..2fdd2c0 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1245,6 +1245,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+			nfs_error(_("%s: parsing error on 'vers=' option\n"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
 			nfs_error(_("%s: parsing error on 'vers=' option\n"),
@@ -1262,6 +1264,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
 			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
-- 
1.8.3.1

