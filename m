From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 069/112] NFS: Change cb_recallargs to pass "struct sockaddr
	*" instead of sockaddr_in
Date: Fri, 25 Jan 2008 11:37:47 -0500
Message-ID: <20080125163746.31887.72867.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbYAYRCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:06 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HA4020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:55 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Change the addr field in the cb_recallargs struct to a "struct sockaddr *"
to support non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/callback.h      |    2 +-
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index ec0ffd9..bb25d21 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -53,7 +53,7 @@ struct cb_getattrres {
 };
 
 struct cb_recallargs {
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 32f0df0..fa9586d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 3eda1bc..c63eb72 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -188,7 +188,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 *p;
 	__be32 status;
 
-	args->addr = svc_addr_in(rqstp);
+	args->addr = svc_addr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
