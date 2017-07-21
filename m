Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752091AbdGUQiJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:09 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7D381C06C9E3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:09 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 305AA1824C
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:09 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/11] cache.c: removed a couple warning
Date: Fri, 21 Jul 2017 12:37:59 -0400
Message-Id: <20170721163806.15803-5-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cache.c:623:13: warning: In the GNU C Library, "major" is defined
 by <sys/sysmacros.h>. For historical compatibility, it is
 currently defined by <sys/types.h> as well, but we plan to
 remove this soon. To use "major", include <sys/sysmacros.h>
 directly. If you did not intend to use a system-defined macro
 "major", you should undefine it after including <sys/types.h>.
   if (parsed->major != major(stb.st_dev) ||
             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cache.c:624:13: warning: In the GNU C Library, "minor" is defined
 by <sys/sysmacros.h>. For historical compatibility, it is
 currently defined by <sys/types.h> as well, but we plan to
 remove this soon. To use "minor", include <sys/sysmacros.h>
 directly. If you did not intend to use a system-defined macro
 "minor", you should undefine it after including <sys/types.h>.
       parsed->minor != minor(stb.st_dev))
             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca6c84f..e49300d 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -11,6 +11,7 @@
 #include <config.h>
 #endif
 
+#include <sys/sysmacros.h>
 #include <sys/types.h>
 #include <sys/select.h>
 #include <sys/stat.h>
-- 
2.13.3

