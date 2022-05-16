Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F5F6C433F5
	for <linux-nfs@archiver.kernel.org>; Mon, 16 May 2022 19:12:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243793AbiEPTML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 May 2022 15:12:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59312 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231625AbiEPTMK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2022 15:12:10 -0400
X-Greylist: delayed 953 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Mon, 16 May 2022 12:12:09 PDT
Received: from relay.virtuozzo.com (relay.virtuozzo.com [130.117.225.111])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 33EC8DEEF
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2022 12:12:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=virtuozzo.com; s=relay; h=MIME-Version:Message-Id:Date:Subject:From:
        Content-Type; bh=ZRAZ87X3L3JPmycM+t5YYtpINDMnrtSBW0guYw3fx6I=; b=vkp6bD2bncbX
        G1n6I4sf5KLo4KeQ85IVQy6bXssVuM1Ogqoo6xg6UofQYWgM3Gw6eEHrOF38GjnSIXp6ichkSD2YE
        gMzXgx8Tz3g485QrbNjsIq1dRZ/lPevPOKEhpeHVJi0BHODiUdFlYa+twvJ85Lfxesu4ritQhzu6i
        V9A34=;
Received: from [172.29.16.86] (helo=finist-vl9.sw.ru)
        by relay.virtuozzo.com with esmtp (Exim 4.94.2)
        (envelope-from <khorenko@virtuozzo.com>)
        id 1nqfrf-00GLdz-I6; Mon, 16 May 2022 20:55:48 +0200
From:   Konstantin Khorenko <khorenko@virtuozzo.com>
To:     linux-nfs@vger.kernel.org
Cc:     Steve Dickson <steved@redhat.com>,
        Konstantin Khorenko <khorenko@virtuozzo.com>
Subject: [PATCH] mountd: Check 'nfsd/clients' directory presence instead of kernel version
Date:   Mon, 16 May 2022 21:55:55 +0300
Message-Id: <20220516185555.643087-1-khorenko@virtuozzo.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Kernel major version does not always provide 100% certainty about
presence or absence of a feature, for example:
 - some distros backport feature from mainstream kernel to older kernels
 - if NFS server is run inside a system container the reported kernel
   version inside the container may be faked

So let's determine the feature presence by checking
'/proc/fs/nfsd/clients/' directory presence instead of checking the
kernel version.

Signed-off-by: Konstantin Khorenko <khorenko@virtuozzo.com>
---
 support/export/v4clients.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/support/export/v4clients.c b/support/export/v4clients.c
index 5e4f1058..5f15b614 100644
--- a/support/export/v4clients.c
+++ b/support/export/v4clients.c
@@ -8,9 +8,9 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <sys/inotify.h>
+#include <sys/stat.h>
 #include <errno.h>
 #include "export.h"
-#include "version.h"
 
 /* search.h declares 'struct entry' and nfs_prot.h
  * does too.  Easiest fix is to trick search.h into
@@ -24,7 +24,10 @@ static int clients_fd = -1;
 
 void v4clients_init(void)
 {
-	if (linux_version_code() < MAKE_VERSION(5, 3, 0))
+	struct stat sb;
+
+	if (!stat("/proc/fs/nfsd/clients", &sb) == 0 ||
+	    !S_ISDIR(sb.st_mode))
 		return;
 	if (clients_fd >= 0)
 		return;
-- 
2.31.1

