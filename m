Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50612 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758988Ab1FVViG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 17:38:06 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 09/11] nfs:  Propagate src-addr in client code.
Date: Wed, 22 Jun 2011 14:36:49 -0700
Message-Id: <1308778611-9370-10-git-send-email-greearb@candelatech.com>
In-Reply-To: <1308778611-9370-1-git-send-email-greearb@candelatech.com>
References: <1308778611-9370-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This ties the srcaddr supplied by mount to the
rpc code.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 223785f... 8b8766a... M	fs/nfs/client.c
 fs/nfs/client.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 223785f..8b8766a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -161,6 +161,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
 	clp->cl_addrlen = cl_init->addrlen;
+	memcpy(&clp->srcaddr, cl_init->srcaddr, cl_init->srcaddrlen);
+	clp->srcaddrlen = cl_init->srcaddrlen;
 
 	if (cl_init->hostname) {
 		err = -ENOMEM;
@@ -655,6 +657,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.net		= &init_net,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.saddress	= (struct sockaddr *)&clp->srcaddr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= timeparms,
 		.servername	= clp->cl_hostname,
@@ -839,6 +842,8 @@ static int nfs_init_server(struct nfs_server *server,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
+		.srcaddr = (const struct sockaddr *)&data->srcaddr.address,
+		.srcaddrlen = data->srcaddr.addrlen,
 		.rpc_ops = &nfs_v2_clientops,
 		.proto = data->nfs_server.protocol,
 	};
@@ -1419,6 +1424,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const struct sockaddr *addr,
 		const size_t addrlen,
 		const char *ip_addr,
+		const struct sockaddr *srcaddr,
+		const size_t srcaddrlen,
 		rpc_authflavor_t authflavour,
 		int proto, const struct rpc_timeout *timeparms,
 		u32 minorversion)
@@ -1430,6 +1437,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
 		.minorversion = minorversion,
+		.srcaddr = srcaddr,
+		.srcaddrlen = srcaddrlen,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -1604,6 +1613,8 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
+			(const struct sockaddr *)&data->srcaddr.address,
+			data->srcaddr.addrlen,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
 			&timeparms,
@@ -1701,6 +1712,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
+				(const struct sockaddr *)&parent_client->srcaddr,
+				parent_client->srcaddrlen,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
 				parent_server->client->cl_timeout,
-- 
1.7.3.4

