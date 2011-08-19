From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH] nfs:include <linux/prefetch.h> to fix compiling error
Date: Sat, 20 Aug 2011 05:19:22 +0800
Message-ID: <1313788762-2562-1-git-send-email-wanlong.gao@gmail.com>
Cc: linux-nfs@vger.kernel.org, Wanlong Gao <gaowanlong@cn.fujitsu.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:39595 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab1HSVV5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 17:21:57 -0400
Received: by pzk37 with SMTP id 37so5463352pzk.1
        for <linux-nfs@vger.kernel.org>; Fri, 19 Aug 2011 14:21:56 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wanlong Gao <gaowanlong@cn.fujitsu.com>

fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_read':
fs/nfs/blocklayout/blocklayout.c:201:4: error: implicit
declaration of function 'prefetchw'
make[4]: *** [fs/nfs/blocklayout/blocklayout.o] Error 1
make[3]: *** [fs/nfs/blocklayout] Error 2
make[2]: *** [fs/nfs] Error 2
make[1]: *** [fs] Error 2

Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e56564d..9561c8f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -36,6 +36,7 @@
 #include <linux/namei.h>
 #include <linux/bio.h>		/* struct bio */
 #include <linux/buffer_head.h>	/* various write calls */
+#include <linux/prefetch.h>
 
 #include "blocklayout.h"
 
-- 
1.7.4.1

