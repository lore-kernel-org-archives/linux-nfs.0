Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:60884 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab3L3L0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Dec 2013 06:26:05 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so9618643pab.23
        for <linux-nfs@vger.kernel.org>; Mon, 30 Dec 2013 03:26:05 -0800 (PST)
Message-ID: <52C15847.9030208@gmail.com>
Date: Mon, 30 Dec 2013 19:25:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J.,Bruce Fields" <bfields@fieldses.org>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: [PATCH 2/2] NFSD: supports nfsv4 service without rpcbind
References: <52B47A12.2070202@garethwilliams.me.uk>	<20131223173956.GA9221@fieldses.org>	<52BD53CA.5050205@gmail.com>	<7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>	<20131227184309.GA9161@fieldses.org>	<01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com>	<6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com>	<CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>	<5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com> <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <52C1577B.9080100@gmail.com>
In-Reply-To: <52C1577B.9080100@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1. set vs_ignore_err for nfsd_version4
2. don't start lockd when only supports nfsv4

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/netns.h    |  1 +
 fs/nfsd/nfs4proc.c |  1 +
 fs/nfsd/nfssvc.c   | 26 +++++++++++++++++++++-----
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 849a7c3..d32b3aa 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -95,6 +95,7 @@ struct nfsd_net {
 	time_t nfsd4_grace;
 
 	bool nfsd_net_up;
+	bool lockd_up;
 
 	/*
 	 * Time of server startup
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..9320986 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1881,6 +1881,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
+		.vs_ignore_err	= 1,
 };
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 760c85a..55b5b57 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -241,6 +241,11 @@ static void nfsd_shutdown_generic(void)
 	nfsd_racache_shutdown();
 }
 
+static bool nfsd_needs_lockd(void)
+{
+	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
+}
+
 static int nfsd_startup_net(int nrservs, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -255,9 +260,14 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 	ret = nfsd_init_socks(net);
 	if (ret)
 		goto out_socks;
-	ret = lockd_up(net);
-	if (ret)
-		goto out_socks;
+
+	if (nfsd_needs_lockd() && !nn->lockd_up) {
+		ret = lockd_up(net);
+		if (ret)
+			goto out_socks;
+		nn->lockd_up = 1;
+	}
+
 	ret = nfs4_state_start_net(net);
 	if (ret)
 		goto out_lockd;
@@ -266,7 +276,10 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 	return 0;
 
 out_lockd:
-	lockd_down(net);
+	if (nn->lockd_up) {
+		lockd_down(net);
+		nn->lockd_up = 0;
+	}
 out_socks:
 	nfsd_shutdown_generic();
 	return ret;
@@ -277,7 +290,10 @@ static void nfsd_shutdown_net(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfs4_state_shutdown_net(net);
-	lockd_down(net);
+	if (nn->lockd_up) {
+		lockd_down(net);
+		nn->lockd_up = 0;
+	}
 	nn->nfsd_net_up = false;
 	nfsd_shutdown_generic();
 }
-- 
1.8.4.2
