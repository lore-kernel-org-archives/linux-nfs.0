Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:43633 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab3AUUsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:48:03 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 08/13] nfs: Propagate src-addr in client code.
Date: Mon, 21 Jan 2013 12:45:54 -0800
Message-Id: <1358801159-18829-9-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This ties the srcaddr supplied by mount to the
rpc code.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/client.c     |    5 +++++
 fs/nfs/nfs4client.c |    8 ++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e5230fe..bb0a8ce 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -167,6 +167,8 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
 	clp->cl_addrlen = cl_init->addrlen;
+	memcpy(&clp->srcaddr, cl_init->srcaddr, cl_init->srcaddrlen);
+	clp->srcaddrlen = cl_init->srcaddrlen;
 
 	if (cl_init->hostname) {
 		err = -ENOMEM;
@@ -594,6 +596,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.net		= clp->cl_net,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.saddress	= (struct sockaddr *)&clp->srcaddr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= timeparms,
 		.servername	= clp->cl_hostname,
@@ -751,6 +754,8 @@ static int nfs_init_server(struct nfs_server *server,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
 		.nfs_mod = nfs_mod,
+		.srcaddr = (const struct sockaddr *)&data->srcaddr.address,
+		.srcaddrlen = data->srcaddr.addrlen,
 		.proto = data->nfs_server.protocol,
 		.net = data->net,
 	};
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 7c4dc21..bdd5f3b 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -610,6 +610,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const struct sockaddr *addr,
 		const size_t addrlen,
 		const char *ip_addr,
+		const struct sockaddr *srcaddr,
+		const size_t srcaddrlen,
 		rpc_authflavor_t authflavour,
 		int proto, const struct rpc_timeout *timeparms,
 		u32 minorversion, struct net *net)
@@ -622,6 +624,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		.proto = proto,
 		.minorversion = minorversion,
 		.net = net,
+		.srcaddr = srcaddr,
+		.srcaddrlen = srcaddrlen,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -796,6 +800,8 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
+			(const struct sockaddr *)&data->srcaddr.address,
+			data->srcaddr.addrlen,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
 			&timeparms,
@@ -896,6 +902,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
+				(const struct sockaddr *)&parent_client->srcaddr,
+				parent_client->srcaddrlen,
 				data->authflavor,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
-- 
1.7.3.4

