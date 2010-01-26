From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] NFSD: Create PF_INET6 listener in write_ports
Date: Tue, 26 Jan 2010 14:04:22 -0500
Message-ID: <20100126190422.3368.3981.stgit@localhost.localdomain>
References: <20100126190214.3368.89388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:46042 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934Ab0AZTEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 14:04:34 -0500
In-Reply-To: <20100126190214.3368.89388.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to create a PF_INET6 listener for NFSD, if IPv6 is enabled in the
kernel.

Make sure nfsd_serv's reference count is decreased if
__write_ports_addxprt() failed to create a listener.  See
__write_ports_addfd().

Our current plan is to rely on rpc.nfsd to create appropriate IPv6
listeners when server-side NFS/IPv6 support is desired.  Legacy
behavior, via the write_threads or write_svc kernel APIs, will remain
the same -- only IPv4 listeners are created.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f43ecd6..f0a614e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1003,8 +1003,26 @@ static ssize_t __write_ports_addxprt(char *buf)
 	err = svc_create_xprt(nfsd_serv, transport,
 				PF_INET, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0)
-		return err;
+		goto out_err;
+
+	err = svc_create_xprt(nfsd_serv, transport,
+				PF_INET6, port, SVC_SOCK_ANONYMOUS);
+	if (err < 0 && err != -EAFNOSUPPORT) {
+		struct svc_xprt *xprt;
+		xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
+		if (xprt != NULL) {
+			svc_close_xprt(xprt);
+			svc_xprt_put(xprt);
+		}
+		goto out_err;
+	}
+
 	return 0;
+
+out_err:
+	/* Decrease the count, but don't shut down the service */
+	nfsd_serv->sv_nrthreads--;
+	return err;
 }
 
 /*

