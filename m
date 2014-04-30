Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:45488 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbaD3Cqs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:46:48 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 1/9] nfsd: pass net to nfsd_init_socks()
Date: Wed, 30 Apr 2014 10:43:36 +0800
Message-ID: <1398825824-6360-2-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
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
 - one more parameter(int port) for nfsd_init_socks()
 - net initialization in nfsd_startup()]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfssvc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 25d839e..517a883 100644
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
@@ -206,6 +206,7 @@ static bool nfsd_up = false;
 static int nfsd_startup(unsigned short port, int nrservs)
 {
 	int ret;
+	struct net *net = &init_net;
 
 	if (nfsd_up)
 		return 0;
@@ -217,7 +218,7 @@ static int nfsd_startup(unsigned short port, int nrservs)
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


