Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:34584 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab3LDFyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 00:54:43 -0500
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <skinsbursky@parallels.com>,
        <linux-nfs@vger.kernel.org>, <lizefan@huawei.com>,
        <h.huangqiang@huawei.com>
Subject: [PATCH 3.4 1/9] nfsd: use "init_net" for portmapper
Date: Wed, 4 Dec 2013 13:53:27 +0800
Message-ID: <1386136415-30976-2-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit f7fb86c6e639360ad9c253cec534819ef928a674 upstream.

There could be a situation, when NFSd was started in one network namespace, but
stopped in another one.
This will trigger kernel panic, because RPCBIND client is stored on per-net
NFSd data, and will be NULL on NFSd shutdown.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfssvc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 53459b0..25d839e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -11,7 +11,6 @@
 #include <linux/module.h>
 #include <linux/fs_struct.h>
 #include <linux/swap.h>
-#include <linux/nsproxy.h>
 
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
@@ -330,7 +329,7 @@ static int nfsd_get_default_max_blksize(void)
 int nfsd_create_serv(void)
 {
 	int error;
-	struct net *net = current->nsproxy->net_ns;
+	struct net *net = &init_net;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
-- 
1.8.2.2


