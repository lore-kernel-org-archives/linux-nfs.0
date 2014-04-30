Return-Path: linux-nfs-owner@vger.kernel.org
Received: from [119.145.14.65] ([119.145.14.65]:30417 "EHLO
	szxga02-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbaD3CrQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:47:16 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 2/9] nfsd: pass net to nfsd_startup() and nfsd_shutdown()
Date: Wed, 30 Apr 2014 10:43:37 +0800
Message-ID: <1398825824-6360-3-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit db42d1a76a8dfcaba7a2dc9c591fa4e231db22b3 upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4:
 - adjust context
 - one more parameter(int port) for nfsd_startup()
 - no net ns initialization in nfsd_shutdown()
 - pass @net to lockd_up() in nfsd_startup()
 - pass @net to lockd_down() in nfsd_shutdown()]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfssvc.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 517a883..f8dae75 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -203,10 +203,9 @@ static int nfsd_init_socks(int port, struct net *net)
 
 static bool nfsd_up = false;
 
-static int nfsd_startup(unsigned short port, int nrservs)
+static int nfsd_startup(unsigned short port, int nrservs, struct net *net)
 {
 	int ret;
-	struct net *net = &init_net;
 
 	if (nfsd_up)
 		return 0;
@@ -221,7 +220,7 @@ static int nfsd_startup(unsigned short port, int nrservs)
 	ret = nfsd_init_socks(port, net);
 	if (ret)
 		goto out_racache;
-	ret = lockd_up(&init_net);
+	ret = lockd_up(net);
 	if (ret)
 		goto out_racache;
 	ret = nfs4_state_start();
@@ -230,13 +229,13 @@ static int nfsd_startup(unsigned short port, int nrservs)
 	nfsd_up = true;
 	return 0;
 out_lockd:
-	lockd_down(&init_net);
+	lockd_down(net);
 out_racache:
 	nfsd_racache_shutdown();
 	return ret;
 }
 
-static void nfsd_shutdown(void)
+static void nfsd_shutdown(struct net *net)
 {
 	/*
 	 * write_ports can create the server without actually starting
@@ -247,14 +246,14 @@ static void nfsd_shutdown(void)
 	if (!nfsd_up)
 		return;
 	nfs4_state_shutdown();
-	lockd_down(&init_net);
+	lockd_down(net);
 	nfsd_racache_shutdown();
 	nfsd_up = false;
 }
 
 static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
-	nfsd_shutdown();
+	nfsd_shutdown(net);
 
 	svc_rpcb_cleanup(serv, net);
 
@@ -458,7 +457,7 @@ nfsd_svc(unsigned short port, int nrservs)
 
 	nfsd_up_before = nfsd_up;
 
-	error = nfsd_startup(port, nrservs);
+	error = nfsd_startup(port, nrservs, net);
 	if (error)
 		goto out_destroy;
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
@@ -471,7 +470,7 @@ nfsd_svc(unsigned short port, int nrservs)
 	error = nfsd_serv->sv_nrthreads - 1;
 out_shutdown:
 	if (error < 0 && !nfsd_up_before)
-		nfsd_shutdown();
+		nfsd_shutdown(net);
 out_destroy:
 	nfsd_destroy(net);		/* Release server */
 out:
-- 
1.8.2.2


