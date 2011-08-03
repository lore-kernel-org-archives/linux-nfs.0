Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754936Ab1HCMgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 08:36:23 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p73CaNDH004815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 08:36:23 -0400
From: Karel Zak <kzak@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Karel Zak <kzak@redhat.com>
Subject: [PATCH] mount: fix for libmount from util-linux >= 2.20
Date: Wed,  3 Aug 2011 14:36:09 +0200
Message-Id: <1312374969-15726-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The function mnt_fs_set_fs_options() has been removed from the final
version of the libmount API.

Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mount/mount_libmount.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index 6dd6484..cf6e58c 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -61,10 +61,19 @@ int nomtab;
  * managed by libmount at all. We have to use "mount attributes" that are
  * private for mount.<type> helpers.
  */
-static void store_mount_options(struct libmnt_fs *fs, const char *opts)
+static void store_mount_options(struct libmnt_fs *fs, const char *nfs_opts)
 {
-	mnt_fs_set_fs_options(fs, opts);	/* for mtab */
-	mnt_fs_set_attributes(fs, opts);	/* for non-mtab systems */
+	char *o = NULL;
+
+	mnt_fs_set_attributes(fs, nfs_opts);	/* for non-mtab systems */
+
+	/* for mtab create a new options list */
+	mnt_optstr_append_option(&o, mnt_fs_get_vfs_options(fs), NULL);
+	mnt_optstr_append_option(&o, nfs_opts, NULL);
+	mnt_optstr_append_option(&o, mnt_fs_get_user_options(fs), NULL);
+
+	mnt_fs_set_options(fs, o);
+	free(o);
 }
 
 /*
-- 
1.7.6

