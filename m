Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:34585 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab3LDFyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 00:54:43 -0500
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <skinsbursky@parallels.com>,
        <linux-nfs@vger.kernel.org>, <lizefan@huawei.com>,
        <h.huangqiang@huawei.com>
Subject: [PATCH 3.4 2/9] nfsd: pass net to nfsd_init_socks()
Date: Wed, 4 Dec 2013 13:53:28 +0800
Message-ID: <1386136415-30976-3-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit db6e182c17cb1a7069f7f8924721ce58ac05d9a3 upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4:
 - adjust context
 - one more parameter(int port) for nfsd_init_socks()]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfssvc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 25d839e..d1ed729 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -182,18 +182,18 @@ int nfsd_nrthreads(void)
 	return rv;
 }
 
-static int nfsd_init_socks(int port)
+static int nfsd_init_socks(int port, struct net *net)
 {
 	int error;
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", &init_net, PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "udp", net, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", &init_net, PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "tcp", net, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
@@ -217,7 +217,7 @@ static int nfsd_startup(unsigned short port, int nrservs)
 	ret = nfsd_racache_init(2*nrservs);
 	if (ret)
 		return ret;
-	ret = nfsd_init_socks(port);
+	ret = nfsd_init_socks(port, net);
 	if (ret)
 		goto out_racache;
 	ret = lockd_up(&init_net);
-- 
1.8.2.2


