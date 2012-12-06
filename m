Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45967 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423202Ab2LFLXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:23:06 -0500
Subject: [PATCH 7/8] nfsd: replace boolean nfsd_up flag by users counter
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:39 +0300
Message-ID: <20121206112339.29559.46130.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we have generic NFSd resurces, we have to introduce some way how to
allocate and destroy those resources on first per-net NFSd start and on
last per-net NFSd stop respectively.
This patch replaces global boolean nfsd_up flag (which is unused now) by users
counter and use it to determine either we need to allocate generic resources
or destroy them.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfssvc.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 0c87b4e..5bb4a33 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -204,13 +204,13 @@ static int nfsd_init_socks(struct net *net)
 	return 0;
 }
 
-static bool nfsd_up = false;
+static int nfsd_users = 0;
 
 static int nfsd_startup_generic(int nrservs)
 {
 	int ret;
 
-	if (nfsd_up)
+	if (nfsd_users++)
 		return 0;
 
 	/*
@@ -233,9 +233,11 @@ out_racache:
 
 static void nfsd_shutdown_generic(void)
 {
+	if (--nfsd_users)
+		return;
+
 	nfs4_state_shutdown();
 	nfsd_racache_shutdown();
-	nfsd_up = false;
 }
 
 static int nfsd_startup_net(int nrservs, struct net *net)
@@ -260,7 +262,6 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 		goto out_lockd;
 
 	nn->nfsd_net_up = true;
-	nfsd_up = true;
 	return 0;
 
 out_lockd:

