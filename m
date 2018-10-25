Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70DF7ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:15:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0EA442064C
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:15:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EA442064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=163.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726652AbeJYMqX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 08:46:23 -0400
Received: from mx1.redhat.com ([209.132.183.28]:58530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726308AbeJYMqX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 08:46:23 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BF92EE3E14;
        Thu, 25 Oct 2018 04:15:27 +0000 (UTC)
Received: from dhcp-12-115.nay.redhat.com (dhcp-12-115.nay.redhat.com [10.66.12.115])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 688281054FBA;
        Thu, 25 Oct 2018 04:15:26 +0000 (UTC)
From:   "Jianhong.Yin" <yin-jianhong@163.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] [nfs-utils] fix method to check if mounted already
Date:   Thu, 25 Oct 2018 12:15:18 +0800
Message-Id: <20181025041518.24465-1-yin-jianhong@163.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 25 Oct 2018 04:15:27 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

reproducer:
'''
mkdir /expdir /mnt/nfsmp /mnt/tmpfs
echo "/expdir *(rw,no_root_squash)" >/etc/exports
service nfs restart
mount -t tmpfs tmpfs /mnt/tmpfs
mount -osharecache localhost:/expdir /mnt/nfsmp #success
mount -osharecache localhost:/expdir /mnt/nfsmp #mounted already, return 0(pass)
mount -osharecache localhost:/expdir /mnt/tmpfs #success
mount -osharecache localhost:/expdir /mnt/tmpfs #mounted already, return 0(pass)
umount /mnt/nfsmp
umount /mnt/tmpfs

mount -ocontext=system_u:object_r:xferlog_t:s0,sharecache localhost:/expdir /mnt/nfsmp
mount -ocontext=system_u:object_r:user_home_dir_t:s0,sharecache localhost:/expdir /mnt/tmpfs
[[ $? = 0 ]] && echo "***test fail: hasn't mounted, should return fail ***"
'''

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 support/include/misc.h    |  1 +
 support/misc/mountpoint.c | 26 +++++++++++++++++++++++++-
 utils/mount/stropts.c     |  4 +---
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/support/include/misc.h b/support/include/misc.h
index 06e2a0c..6a146e4 100644
--- a/support/include/misc.h
+++ b/support/include/misc.h
@@ -19,6 +19,7 @@ char *generic_make_pathname(const char *, const char *);
 _Bool generic_setup_basedir(const char *, const char *, char *, const size_t);
 
 extern int is_mountpoint(char *path);
+extern int is_mounted_already(const char *fsname, const char *dir);
 
 /* size of the file pointer buffers for rpc procfs files */
 #define RPC_CHAN_BUF_SIZE 32768
diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
index 9f9ce44..e21d529 100644
--- a/support/misc/mountpoint.c
+++ b/support/misc/mountpoint.c
@@ -4,8 +4,10 @@
  */
 
 #include <string.h>
-#include "xcommon.h"
 #include <sys/stat.h>
+#include <stdio.h>
+#include <mntent.h>
+#include "xcommon.h"
 #include "misc.h"
 
 int
@@ -38,3 +40,25 @@ is_mountpoint(char *path)
 	free(dotdot);
 	return rv;
 }
+
+int
+is_mounted_already(const char *fsname, const char *dir)
+{
+	struct mntent *ent;
+	FILE *fp;
+	int ret = 0;
+
+	fp = setmntent("/proc/mounts", "r");
+	if (fp == NULL) {
+		perror("[unlikely] setmntent(3) fail");
+		exit(1);
+	}
+	while (NULL != (ent = getmntent(fp))) {
+		if (!strcmp(ent->mnt_fsname, fsname) && !strcmp(ent->mnt_dir, dir)) {
+			ret = 1;
+			break;
+		}
+	}
+	endmntent(fp);
+	return ret;
+}
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index eed0356..0ee13bc 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1079,9 +1079,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-#pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
-		if (errno == EBUSY && is_mountpoint(mi->node))
-#pragma GCC diagnostic warning "-Wdiscarded-qualifiers"
+		if (errno == EBUSY && is_mounted_already(mi->spec, mi->node))
 			/*
 			 * EBUSY can happen when mounting a filesystem that
 			 * is already mounted or when the context= are
-- 
2.17.2

