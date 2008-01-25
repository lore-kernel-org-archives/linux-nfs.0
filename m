From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 071/112] NFS: Change nfs_get_client() to take sockaddr *
Date: Fri, 25 Jan 2008 11:37:48 -0500
Message-ID: <20080125163747.31887.18731.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756779AbYAYRAa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:30 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmm010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:28 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Adjust arguments and callers of nfs_get_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support
non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 73bf4ec..e43072b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -97,7 +97,7 @@ struct rpc_program		nfsacl_program = {
 
 struct nfs_client_initdata {
 	const char *hostname;
-	const struct sockaddr_in *addr;
+	const struct sockaddr *addr;
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 };
@@ -308,9 +308,8 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
-		cl_init->hostname ?: "", NIPQUAD(cl_init->addr->sin_addr),
-		cl_init->addr->sin_port, cl_init->rpc_ops->version);
+	dprintk("--> nfs_get_client(%s,v%u)\n",
+		cl_init->hostname ?: "", cl_init->rpc_ops->version);
 
 	/* see if the client already exists */
 	do {
@@ -581,7 +580,7 @@ static int nfs_init_server(struct nfs_server *server,
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = data->nfs_server.hostname,
-		.addr = &data->nfs_server.address,
+		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = sizeof(data->nfs_server.address),
 		.rpc_ops = &nfs_v2_clientops,
 	};
@@ -935,7 +934,7 @@ static int nfs4_set_client(struct nfs_server *server,
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
-		.addr = addr,
+		.addr = (const struct sockaddr *)addr,
 		.addrlen = sizeof(*addr),
 		.rpc_ops = &nfs_v4_clientops,
 	};
