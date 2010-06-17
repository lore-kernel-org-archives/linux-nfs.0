From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfsd: shut down transport in nfsd_init_socks if no lockd reference
Date: Thu, 17 Jun 2010 10:17:46 -0400
Message-ID: <1276784267-28500-2-git-send-email-jlayton@redhat.com>
References: <1276784267-28500-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chris@cvine.freeserve.co.uk,
	linux-kernel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276784267-28500-1-git-send-email-jlayton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd_last_thread expects that any socket on sv_permsocks will hold a
lockd reference. Fix nfsd_init_socks to close down any transport that
it creates for which it can't get a lockd reference.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a06ea99..f83e6f9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -278,28 +278,41 @@ int nfsd_create_serv(void)
 static int nfsd_init_socks(int port)
 {
 	int error;
+	char *transport;
+	struct svc_xprt *xprt;
+
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
+	transport = "udp";
+	error = svc_create_xprt(nfsd_serv, transport, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
 	error = lockd_up();
 	if (error < 0)
-		return error;
+		goto out_close_xprt;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
+	transport = "tcp";
+	error = svc_create_xprt(nfsd_serv, transport, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
 	error = lockd_up();
 	if (error < 0)
-		return error;
+		goto out_close_xprt;
 
 	return 0;
+out_close_xprt:
+	/* shut down any transport that didn't get a lockd reference */
+	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
+	if (xprt != NULL) {
+		svc_close_xprt(xprt);
+		svc_xprt_put(xprt);
+	}
+	return error;
 }
 
 int nfsd_nrpools(void)
-- 
1.5.5.6
