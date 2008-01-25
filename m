From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 066/112] NFS: Add support for AF_INET6 addresses in
	__nfs_find_client()
Date: Fri, 25 Jan 2008 11:37:46 -0500
Message-ID: <20080125163745.31887.7292.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757076AbYAYRCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:07 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HA6020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:57 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce AF_INET6-specific address checking to __nfs_find_client().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   41 +++++++++++++++++++++++++++++++++++++++--
 1 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 701cd19..876162c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -34,6 +34,8 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 
 #include <asm/system.h>
@@ -208,16 +210,44 @@ void nfs_put_client(struct nfs_client *clp)
 	}
 }
 
+static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
+				 const struct sockaddr_in *sa2)
+{
+	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
+}
+
+static int nfs_sockaddr_match_ipaddr6(const struct sockaddr_in6 *sa1,
+				 const struct sockaddr_in6 *sa2)
+{
+	return ipv6_addr_equal(&sa1->sin6_addr, &sa2->sin6_addr);
+}
+
+static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+				 const struct sockaddr *sa2)
+{
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
+				(const struct sockaddr_in *)sa2);
+	case AF_INET6:
+		return nfs_sockaddr_match_ipaddr6((const struct sockaddr_in6 *)sa1,
+				(const struct sockaddr_in6 *)sa2);
+	}
+	BUG();
+}
+
 /*
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
+struct nfs_client *_nfs_find_client(const struct sockaddr *addr, int nfsversion)
 {
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state != NFS_CS_READY)
 			continue;
@@ -226,8 +256,10 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversio
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
+		if (addr->sa_family != clap->sa_family)
+			continue;
 		/* Match only the IP address, not the port number */
-		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
+		if (!nfs_sockaddr_match_ipaddr(addr, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);
@@ -238,6 +270,11 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversio
 	return NULL;
 }
 
+struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
+{
+	return _nfs_find_client((const struct sockaddr *)addr, nfsversion);
+}
+
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
