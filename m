From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] libnfs.a: Provide shared helpers for managing netids
Date: Tue, 08 Dec 2009 12:59:18 -0500
Message-ID: <20091208175918.2544.27657.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:54462 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965733AbZLHSAu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:50 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a couple of shared functions that can convert netids to
protocol numbers and families, and back.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |   12 ++++++
 support/nfs/getport.c    |   92 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 97 insertions(+), 7 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index dff6af7..d6d4a1c 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -90,6 +90,18 @@ extern CLIENT		*nfs_get_priv_rpcclient( const struct sockaddr *,
 				struct timeval *);
 
 /*
+ * Convert a netid to a protocol number and protocol family
+ */
+extern int		nfs_get_proto(const char *netid, sa_family_t *family,
+				unsigned long *protocol);
+
+/*
+ * Convert a protocol family and protocol name to a netid
+ */
+extern char		*nfs_get_netid(const sa_family_t family,
+				const unsigned long protocol);
+
+/*
  * Convert a socket address to a universal address
  */
 extern char		*nfs_sockaddr2universal(const struct sockaddr *);
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 4bdf556..7e0f798 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -199,7 +199,63 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 	return clnt;
 }
 
-/*
+/**
+ * nfs_get_proto - Convert a netid to an address family and protocol number
+ * @netid: C string containing a netid
+ * @family: OUT: address family
+ * @protocol: OUT: protocol number
+ *
+ * Returns 1 and fills in @protocol if the netid was recognized;
+ * otherwise zero is returned.
+ */
+#ifdef HAVE_LIBTIRPC
+int
+nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
+{
+	struct netconfig *nconf;
+	struct protoent *proto;
+
+	nconf = getnetconfigent(netid);
+	if (nconf == NULL)
+		return 0;
+
+	proto = getprotobyname(nconf->nc_proto);
+	if (proto == NULL) {
+		freenetconfigent(nconf);
+		return 0;
+	}
+
+	*family = AF_UNSPEC;
+	if (strcmp(nconf->nc_protofmly, NC_INET) == 0)
+		*family = AF_INET;
+	if (strcmp(nconf->nc_protofmly, NC_INET6) == 0)
+		*family = AF_INET6;
+	freenetconfigent(nconf);
+
+	*protocol = (unsigned long)proto->p_proto;
+	return 1;
+}
+#else	/* !HAVE_LIBTIRPC */
+int
+nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
+{
+	struct protoent *proto;
+
+	proto = getprotobyname(netid);
+	if (proto == NULL)
+		return 0;
+
+	*family = AF_INET;
+	*protocol = (unsigned long)proto->p_proto;
+	return 1;
+}
+#endif /* !HAVE_LIBTIRPC */
+
+/**
+ * nfs_get_netid - Convert a protocol family and protocol name to a netid
+ * @family: protocol family
+ * @protocol: protocol number
+ *
  * One of the arguments passed when querying remote rpcbind services
  * via rpcbind v3 or v4 is a netid string.  This replaces the pm_prot
  * field used in legacy PMAP_GETPORT calls.
@@ -213,13 +269,12 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
  * first entry that matches @family and @protocol and whose netid string
  * fits in the provided buffer.
  *
- * Returns a '\0'-terminated string if successful; otherwise NULL.
+ * Returns a '\0'-terminated string if successful.  Caller must
+ * free the returned string.  Otherwise NULL is returned, and
  * rpc_createerr.cf_stat is set to reflect the error.
  */
 #ifdef HAVE_LIBTIRPC
-
-static char *nfs_gp_get_netid(const sa_family_t family,
-			      const unsigned short protocol)
+char *nfs_get_netid(const sa_family_t family, const unsigned long protocol)
 {
 	char *nc_protofmly, *nc_proto, *nc_netid;
 	struct netconfig *nconf;
@@ -255,6 +310,9 @@ static char *nfs_gp_get_netid(const sa_family_t family,
 
 		nc_netid = strdup(nconf->nc_netid);
 		endnetconfig(handle);
+
+		if (nc_netid == NULL)
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		return nc_netid;
 	}
 	endnetconfig(handle);
@@ -263,8 +321,28 @@ out:
 	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
 	return NULL;
 }
+#else	/* !HAVE_LIBTIRPC */
+char *nfs_get_netid(const sa_family_t family, const unsigned long protocol)
+{
+	struct protoent *proto;
+	char *netid;
 
-#endif	/* HAVE_LIBTIRPC */
+	if (family != AF_INET)
+		goto out;
+	proto = getprotobynumber((int)protocol);
+	if (proto == NULL)
+		goto out;
+
+	netid = strdup(proto->p_name);
+	if (netid == NULL)
+		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	return netid;
+
+out:
+	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
+	return NULL;
+}
+#endif	/* !HAVE_LIBTIRPC */
 
 /*
  * Extract a port number from a universal address, and terminate the
@@ -421,7 +499,7 @@ static int nfs_gp_init_rpcb_parms(const struct sockaddr *sap,
 {
 	char *netid, *addr;
 
-	netid = nfs_gp_get_netid(sap->sa_family, protocol);
+	netid = nfs_get_netid(sap->sa_family, protocol);
 	if (netid == NULL)
 		return 0;
 

