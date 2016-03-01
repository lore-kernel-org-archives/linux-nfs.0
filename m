Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:32877 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbcCASF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 13:05:29 -0500
Subject: [PATCH v5 01/14] nfsd: Update NFS server comments related to RDMA
 support
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 Mar 2016 13:05:27 -0500
Message-ID: <20160301180527.2492.28091.stgit@klimt.1015granger.net>
In-Reply-To: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
References: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server does indeed now support NFSv4.1 on RDMA transports. It
does not support shifting an RDMA-capable TCP transport (such as
iWARP) to RDMA mode.

Reported-by: Shirley Ma <shirley.ma@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c |    5 ++---
 fs/nfsd/nfs4xdr.c   |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c484a2b..12940cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2710,10 +2710,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_free_conn;
 	}
 	status = nfs_ok;
-	/*
-	 * We do not support RDMA or persistent sessions
-	 */
+	/* Persistent sessions are not supported */
 	cr_ses->flags &= ~SESSION4_PERSIST;
+	/* Upshifting from TCP to RDMA is not supported */
 	cr_ses->flags &= ~SESSION4_RDMA;
 
 	init_session(rqstp, new, conf, cr_ses);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d6ef095..a12a2ea 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3060,7 +3060,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		p = xdr_encode_opaque_fixed(p, bcts->sessionid.data,
 						NFS4_MAX_SESSIONID_LEN);
 		*p++ = cpu_to_be32(bcts->dir);
-		/* Sorry, we do not yet support RDMA over 4.1: */
+		/* Upshifting from TCP to RDMA is not supported */
 		*p++ = cpu_to_be32(0);
 	}
 	return nfserr;

