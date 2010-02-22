From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 1/2] knfsd: nfsd_max_connections module parameter
Date: Mon, 22 Feb 2010 15:54:42 -0600
Message-ID: <20100222215442.8481.92759.stgit@case>
References: <20100222215349.8481.80700.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:60439 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753769Ab0BVVyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 16:54:43 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay2.corp.sgi.com (Postfix) with ESMTP id 3037C304048
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 13:54:43 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id A7C5349F2093
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 15:54:42 -0600 (CST)
In-Reply-To: <20100222215349.8481.80700.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Decouple the maximum number of nfs client connections from the number of server
threads by adding the nfsd_max_connections module parameter.  Note that the
default remains the current formula: (nr_threads+3) * 20.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 fs/nfsd/nfsctl.c |    6 ++++++
 fs/nfsd/nfssvc.c |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0f0e77f..981366d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -16,6 +16,9 @@
 #include "nfsd.h"
 #include "cache.h"
 
+/* Default to use existing settings in svc_check_conn_limits */
+unsigned int nfsd_max_connections = 0;
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
@@ -1447,5 +1450,8 @@ static void __exit exit_nfsd(void)
 
 MODULE_AUTHOR("Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>");
 MODULE_LICENSE("GPL");
+
+module_param(nfsd_max_connections, uint, 0644);
+
 module_init(init_nfsd)
 module_exit(exit_nfsd)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 171699e..a21fd4e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -275,11 +275,14 @@ int nfsd_create_serv(void)
 	return err;
 }
 
+extern unsigned int nfsd_max_connections;
 static int nfsd_init_socks(int port)
 {
 	int error;
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
+	
+	nfsd_serv->sv_maxconn = nfsd_max_connections;
 
 	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
 					SVC_SOCK_DEFAULTS);

