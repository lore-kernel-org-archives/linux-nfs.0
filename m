From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/27] NFS: Adjust nfs_clone_mount structure to store "struct
	sockaddr *"
Date: Mon, 10 Dec 2007 14:59:06 -0500
Message-ID: <20071210195906.2823.66141.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:31679 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbXLJUE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:56 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the addr field in the nfs_clone_mount structure to store a "struct
sockaddr *" to support non-IPv4 addresses in the NFS client.

Note this is mostly a cosmetic change, and does not actually allow
referrals using IPv6 addresses.  The existing referral code assumes that
the server returns a string that represents an IPv4 address.  This code
needs to support hostnames and IPv6 addresses as well as IPv4 addresses,
thus it will need to be reorganized completely (to handle DNS resolution
in user space).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c        |    4 ++--
 fs/nfs/internal.h      |    3 ++-
 fs/nfs/nfs4namespace.c |   12 +++++++-----
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index db703b0..5406410 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1072,8 +1072,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation */
 	error = nfs4_set_client(server, data->hostname,
-				(struct sockaddr *)data->addr,
-				sizeof(*data->addr),
+				data->addr,
+				data->addrlen,
 				parent_client->cl_ipaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b96364..b54ed13 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -21,7 +21,8 @@ struct nfs_clone_mount {
 	struct nfs_fattr *fattr;
 	char *hostname;
 	char *mnt_path;
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
+	size_t addrlen;
 	rpc_authflavor_t authflavor;
 };
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index bd1b161..5f9ba41 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -172,7 +172,10 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 
 		s = 0;
 		while (s < location->nservers) {
-			struct sockaddr_in addr = {};
+			struct sockaddr_in addr = {
+				.sin_family	= AF_INET,
+				.sin_port	= htons(NFS_PORT),
+			};
 
 			if (location->servers[s].len <= 0 ||
 			    valid_ipaddr4(location->servers[s].data) < 0) {
@@ -181,10 +184,9 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 			}
 
 			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname);
-			addr.sin_family = AF_INET;
-			addr.sin_port = htons(NFS_PORT);
-			mountdata.addr = &addr;
+			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
+			mountdata.addr = (struct sockaddr *)&addr;
+			mountdata.addrlen = sizeof(addr);
 
 			snprintf(page, PAGE_SIZE, "%s:%s",
 					mountdata.hostname,

