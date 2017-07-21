Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754550AbdGUQiL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:11 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D9550C073D6E
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:10 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8A40260C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:10 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/11] device-discovery.c: removed a warning
Date: Fri, 21 Jul 2017 12:38:02 -0400
Message-Id: <20170721163806.15803-8-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

device-discovery.c:171:13: warning: In the GNU C Library, "major" is defined
 by <sys/sysmacros.h>. For historical compatibility, it is
 currently defined by <sys/types.h> as well, but we plan to
 remove this soon. To use "major", include <sys/sysmacros.h>
 directly. If you did not intend to use a system-defined macro
 "major", you should undefine it after including <sys/types.h>.
  } else if (dm_is_dm_major(major(dev)))
             ^~~~~~~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/blkmapd/device-discovery.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index c66669d..29bafb2 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -26,6 +26,7 @@
  * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <sys/sysmacros.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <sys/ioctl.h>
-- 
2.13.3

