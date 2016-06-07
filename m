Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161331AbcFGSfH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2016 14:35:07 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C6E5D249
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2016 18:35:05 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u57IZ5dA025398
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jun 2016 14:35:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: added usage output when no arguemnts are given
Date: Tue,  7 Jun 2016 14:35:04 -0400
Message-Id: <1465324504-8018-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/mount_libmount.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index fa46d54..1f01f7f 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -208,6 +208,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
 
 	if (!spec || (*spec != '/' && strchr(spec,':') == NULL)) {
 		nfs_error(_("%s: no mount point provided"), progname);
+		umount_usage();
 		return EX_USAGE;
 	}
 
@@ -329,6 +330,7 @@ static int mount_main(struct libmnt_context *cxt, int argc, char **argv)
 
 	if (!mount_point) {
 		nfs_error(_("%s: no mount point provided"), progname);
+		mount_usage();
 		goto err;
 	}
 	if (!spec) {
-- 
2.5.5

