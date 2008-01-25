From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 073/112] NFS: Adjust nfs_clone_mount structure to store
	"struct sockaddr *"
Date: Fri, 25 Jan 2008 11:37:49 -0500
Message-ID: <20080125163748.31887.7250.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754930AbYAYQ7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:47 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxk1m010174
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:47 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c        |    4 ++--
 fs/nfs/internal.h      |    3 ++-
 fs/nfs/nfs4namespace.c |   12 +++++++-----
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1138060..ba114fa 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1094,8 +1094,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
 	error = nfs4_set_client(server, data->hostname,
-				(struct sockaddr *)data->addr,
-				sizeof(*data->addr),
+				data->addr,
+				data->addrlen,
 				parent_client->cl_ipaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c8458b1..75dd4e2 100644
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
