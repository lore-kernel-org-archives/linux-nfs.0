From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/27] NFS: Change nfs4_set_client() to accept struct sockaddr
	*
Date: Mon, 10 Dec 2007 14:58:59 -0500
Message-ID: <20071210195859.2823.42043.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:35301 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbXLJUDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:10 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust the arguments and callers of nfs4_set_client() to pass a "struct
sockaddr *" instead of a "struct sockaddr_in *" to support non-IPv4
addresses in the NFS client.

Clean-up: remove a comment that suggests NFSv4 always uses TCP, since
that's not true.  On Linux, it can use UDP.  And RFC 3530, section 3.1
mandates only that the transport support congestion control.

Quote:
Where an NFS version 4 implementation supports operation over the IP
network protocol, the supported transports between NFS and IP MUST be
among the IETF-approved congestion control transport protocols, which
include TCP and SCTP.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6a49ae7..db703b0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -912,7 +912,9 @@ error:
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
@@ -923,8 +925,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, (struct sockaddr *)addr,
-			     sizeof(*addr), 4);
+	clp = nfs_get_client(hostname, addr, addrlen, 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
@@ -995,7 +996,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
-			&data->nfs_server.address,
+			(struct sockaddr *)&data->nfs_server.address,
+			sizeof(data->nfs_server.address),
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
@@ -1068,14 +1070,15 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	parent_server = NFS_SB(data->sb);
 	parent_client = parent_server->nfs_client;
 
-	/* Get a client representation.
-	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname, data->addr,
-			parent_client->cl_ipaddr,
-			data->authflavor,
-			parent_server->client->cl_xprt->prot,
-			parent_client->retrans_timeo,
-			parent_client->retrans_count);
+	/* Get a client representation */
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
 

