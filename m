Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59776 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751927AbdF3NYh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:37 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 11/14] nfsd: support vsock xprt creation
Date: Fri, 30 Jun 2017 14:23:49 +0100
Message-Id: <20170630132352.32133-12-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs-utils will write the vsock address details to /proc/fs/nfsd/portlist
to start listening for NFS client connections.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 fs/nfsd/nfsctl.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6493df6..1b71c28 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -768,15 +768,22 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net)
 	if (err != 0)
 		return err;
 
-	err = svc_create_xprt(nn->nfsd_serv, transport, net,
-				PF_INET, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0)
-		goto out_err;
+	if (!strcmp(transport, "vsock")) {
+		err = svc_create_xprt(nn->nfsd_serv, transport, net,
+					AF_VSOCK, port, SVC_SOCK_ANONYMOUS);
+		if (err < 0)
+			goto out_err;
+	} else {
+		err = svc_create_xprt(nn->nfsd_serv, transport, net,
+					PF_INET, port, SVC_SOCK_ANONYMOUS);
+		if (err < 0)
+			goto out_err;
 
-	err = svc_create_xprt(nn->nfsd_serv, transport, net,
-				PF_INET6, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0 && err != -EAFNOSUPPORT)
-		goto out_close;
+		err = svc_create_xprt(nn->nfsd_serv, transport, net,
+					PF_INET6, port, SVC_SOCK_ANONYMOUS);
+		if (err < 0 && err != -EAFNOSUPPORT)
+			goto out_close;
+	}
 
 	/* Decrease the count, but don't shut down the service */
 	nn->nfsd_serv->sv_nrthreads--;
-- 
2.9.4

