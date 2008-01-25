From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 072/112] NFS: Change nfs4_set_client() to accept struct
	sockaddr *
Date: Fri, 25 Jan 2008 11:37:48 -0500
Message-ID: <20080125163748.31887.12521.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55343 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755751AbYAYRCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:05 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HA0020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:52 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Adjust the arguments and callers of nfs4_set_client() to pass a "struct
sockaddr *" instead of a "struct sockaddr_in *" to support non-IPv4
addresses in the NFS client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e43072b..1138060 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -927,15 +927,17 @@ error:
  * Set up an NFS4 client
  */
 static int nfs4_set_client(struct nfs_server *server,
-		const char *hostname, const struct sockaddr_in *addr,
+		const char *hostname,
+		const struct sockaddr *addr,
+		const size_t addrlen,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
 		int proto, int timeo, int retrans)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
-		.addr = (const struct sockaddr *)addr,
-		.addrlen = sizeof(*addr),
+		.addr = addr,
+		.addrlen = addrlen,
 		.rpc_ops = &nfs_v4_clientops,
 	};
 	struct nfs_client *clp;
@@ -1015,7 +1017,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
-			&data->nfs_server.address,
+			(struct sockaddr *)&data->nfs_server.address,
+			sizeof(data->nfs_server.address),
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
@@ -1090,12 +1093,14 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname, data->addr,
-			parent_client->cl_ipaddr,
-			data->authflavor,
-			parent_server->client->cl_xprt->prot,
-			parent_client->retrans_timeo,
-			parent_client->retrans_count);
+	error = nfs4_set_client(server, data->hostname,
+				(struct sockaddr *)data->addr,
+				sizeof(*data->addr),
+				parent_client->cl_ipaddr,
+				data->authflavor,
+				parent_server->client->cl_xprt->prot,
+				parent_client->retrans_timeo,
+				parent_client->retrans_count);
 	if (error < 0)
 		goto error;
 
