From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 070/112] NFS: Change nfs_find_client() to take "struct
	sockaddr *"
Date: Fri, 25 Jan 2008 11:37:47 -0500
Message-ID: <20080125163747.31887.12743.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495AbYAYRAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:34 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Ln0010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:31 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Adjust arguments and callers of nfs_find_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support non-IPv4
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>

Trond: Also fix up protocol version number argument in nfs_find_client() to
use the correct u32 type.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/callback.c      |    3 +--
 fs/nfs/callback_proc.c |    4 ++--
 fs/nfs/client.c        |    7 +------
 fs/nfs/internal.h      |    2 +-
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bbf67f1..9b6bbf1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -164,12 +164,11 @@ void nfs_callback_down(void)
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *addr = svc_addr_in(rqstp);
 	struct nfs_client *clp;
 	char buf[RPC_MAX_ADDRBUFLEN];
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client(svc_addr(rqstp), 4);
 	if (clp == NULL)
 		return SVC_DROP;
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa9586d..e89a900 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -25,7 +25,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 44fe7fd..73bf4ec 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -242,7 +242,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *_nfs_find_client(const struct sockaddr *addr, int nfsversion)
+struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 {
 	struct nfs_client *clp;
 
@@ -272,11 +272,6 @@ struct nfs_client *_nfs_find_client(const struct sockaddr *addr, int nfsversion)
 	return NULL;
 }
 
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
-{
-	return _nfs_find_client((const struct sockaddr *)addr, nfsversion);
-}
-
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 058d503..c8458b1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -60,7 +60,7 @@ struct nfs_parsed_mount_data {
 extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs_find_client(const struct sockaddr_in *, int);
+extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
