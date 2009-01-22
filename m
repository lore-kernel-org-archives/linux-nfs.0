From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  Support binding to a local IPv4 address when mounting a server.
Date: Wed, 21 Jan 2009 17:01:52 -0800
Message-ID: <4977C580.4040805@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050103020507060700000602"
To: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38819 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbZAVBB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 20:01:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050103020507060700000602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


The attached patch allows one to mount NFSv3 (should work with v4 as well,
but not tested as of today) servers and specify the local IP address.

This facilitates mounting on a particular interface if you have a
multi-homed box.

I have a matching patch to the kernel that I will be porting forward to
the latest 2.6.29-rcX branch next.

Please note that Patrick gets a lot of credit for helping me with
this patch in the past, though I have somewhat butchered his previous
work so blame can fall directly to me :)

Please let me know if this patch or something like it would be welcome
in the nfs-utils tree.  Suggestions for improvement are welcome.

Signed-Off-By: Ben Greear<greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------050103020507060700000602
Content-Type: text/x-patch;
 name="nfs_local_ip_14.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs_local_ip_14.patch"

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index fc26f4e..03dea21 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -71,7 +71,7 @@ struct nfsctl_client {
  */
 #include <linux/version.h>
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,70)
-# define __nfsd_dev_t  __kernel_old_dev_t
+# define __nfsd_dev_t  unsigned short /*__kernel_old_dev_t -BEN*/
 #else
 # define __nfsd_dev_t  __kernel_dev_t
 #endif
diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 1529d44..265bbbe 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -62,7 +62,8 @@ extern unsigned short	nfs_getportbynumber(const rpcprog_t program,
 /*
  * Acquire an RPC CLIENT *
  */
-extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
+extern CLIENT *nfs_get_rpcclient(struct sockaddr* caddr, const socklen_t clen,
+				 const struct sockaddr *,
 				const socklen_t, const unsigned short,
 				const rpcprog_t, const rpcvers_t,
 				struct timeval *);
@@ -83,7 +84,8 @@ extern int		nfs_universal2port(const char *);
  * number of the service on a remote post, and sends a NULL
  * request to determine if the service is responding to requests
  */
-extern int		nfs_getport_ping(struct sockaddr *sap,
+extern int		nfs_getport_ping(struct sockaddr* caddr, const socklen_t clen,
+				struct sockaddr *sap,
 				const socklen_t salen,
 				const rpcprog_t program,
 				const rpcvers_t version,
@@ -93,7 +95,8 @@ extern int		nfs_getport_ping(struct sockaddr *sap,
  * Generic function that maps an RPC service tuple to an IP port
  * number of the service on a remote host
  */
-extern unsigned short	nfs_getport(const struct sockaddr *,
+extern unsigned short	nfs_getport(struct sockaddr* caddr, const socklen_t clen,
+				const struct sockaddr *,
 				const socklen_t, const rpcprog_t,
 				const rpcvers_t, const unsigned short);
 
@@ -120,7 +123,8 @@ extern unsigned short	nfs_rpcb_getaddr(const struct sockaddr *,
 /*
  * Function to invoke a portmap GETPORT request
  */
-extern unsigned long	nfs_pmap_getport(const struct sockaddr_in *,
+extern unsigned long	nfs_pmap_getport(struct sockaddr* caddr, const socklen_t clen,
+				const struct sockaddr_in *,
 				const unsigned short,
 				const unsigned long,
 				const unsigned long,
@@ -131,7 +135,8 @@ extern unsigned long	nfs_pmap_getport(const struct sockaddr_in *,
  * Contact a remote RPC service to discover whether it is responding
  * to requests.
  */
-extern int		nfs_rpc_ping(const struct sockaddr *sap,
+extern int		nfs_rpc_ping(struct sockaddr* caddr, const socklen_t clen,
+				const struct sockaddr *sap,
 				const socklen_t salen,
 				const rpcprog_t program,
 				const rpcvers_t version,
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 47824a2..ec099ba 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -190,7 +190,9 @@ static void nfs_gp_set_port(struct sockaddr *sap, const in_port_t port)
  * client.  Otherwise returns NULL, and rpc_createerr.cf_stat is set to
  * reflect the error.
  */
-static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
+static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr* caddr,
+				     const socklen_t clen,
+				     const struct sockaddr *sap,
 				     const socklen_t salen,
 				     const unsigned short transport,
 				     const rpcvers_t version,
@@ -203,7 +205,7 @@ static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
 	memcpy(saddr, sap, (size_t)salen);
 	nfs_gp_set_port(saddr, nfs_gp_get_rpcb_port(transport));
 
-	return nfs_get_rpcclient(saddr, salen, transport, rpcb_prog,
+	return nfs_get_rpcclient(caddr, clen, saddr, salen, transport, rpcb_prog,
 					version, timeout);
 }
 
@@ -660,7 +662,8 @@ static unsigned short nfs_gp_getport(CLIENT *client,
  * Returns 1 if the remote service responded without an error; otherwise
  * zero.
  */
-int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
+int nfs_rpc_ping(struct sockaddr* caddr, const socklen_t clen,
+		 const struct sockaddr *sap, const socklen_t salen,
 		 const rpcprog_t program, const rpcvers_t version,
 		 const unsigned short protocol, const struct timeval *timeout)
 {
@@ -671,7 +674,7 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 	if (timeout != NULL)
 		tout = *timeout;
 
-	client = nfs_get_rpcclient(sap, salen, protocol, program, version, &tout);
+	client = nfs_get_rpcclient(caddr, clen, sap, salen, protocol, program, version, &tout);
 	if (client != NULL) {
 		result = nfs_gp_ping(client, tout);
 		CLNT_DESTROY(client);
@@ -720,7 +723,8 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
  * AF_INET6 at all.  The rpcbind socket is re-used in an attempt to keep the
  * overall number of consumed ephemeral ports low.
  */
-unsigned short nfs_getport(const struct sockaddr *sap,
+unsigned short nfs_getport(struct sockaddr* caddr, const socklen_t clen,
+			   const struct sockaddr *sap,
 			   const socklen_t salen,
 			   const rpcprog_t program,
 			   const rpcvers_t version,
@@ -730,7 +734,7 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 	unsigned short port = 0;
 	CLIENT *client;
 
-	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
+	client = nfs_gp_get_rpcbclient(caddr, clen, sap, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
 		port = nfs_gp_getport(client, sap, salen, program,
@@ -759,7 +763,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
  * if both the query and the ping were successful; otherwise zero.
  * rpccreateerr is set to reflect the underlying cause of the error.
  */
-int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
+int nfs_getport_ping(struct sockaddr* caddr, const socklen_t clen,
+		     struct sockaddr *sap, const socklen_t salen,
 		     const rpcprog_t program, const rpcvers_t version,
 		     const unsigned short protocol)
 {
@@ -768,7 +773,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	CLIENT *client;
 	int result = 0;
 	
-	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
+	client = nfs_gp_get_rpcbclient(caddr, clen, sap, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
 		port = nfs_gp_getport(client, sap, salen, program,
@@ -784,7 +789,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 		memcpy(saddr, sap, (size_t)salen);
 		nfs_gp_set_port(saddr, htons(port));
 
-		client = nfs_get_rpcclient(saddr, salen, protocol,
+		client = nfs_get_rpcclient(caddr, clen, saddr, salen, protocol,
 						program, version, &timeout);
 		if (client != NULL) {
 			result = nfs_gp_ping(client, timeout);
@@ -836,7 +841,7 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 {
 	struct sockaddr_storage address;
 	struct sockaddr *lb_addr = (struct sockaddr *)&address;
-	socklen_t lb_len = sizeof(lb_addr);
+	socklen_t lb_len = sizeof(*lb_addr);
 	unsigned short port = 0;
 
 #ifdef NFS_GP_LOCAL
@@ -864,7 +869,23 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 
 	if (port == 0) {
 		if (nfs_gp_loopback_address(lb_addr, &lb_len)) {
-			port = nfs_getport(lb_addr, lb_len,
+			struct sockaddr_in sin = {
+				.sin_family		= AF_INET,
+				.sin_addr.s_addr	= htonl(INADDR_ANY),
+			};
+			struct sockaddr_in6 sin6 = {
+				.sin6_family		= AF_INET6,
+				.sin6_addr		= IN6ADDR_ANY_INIT,
+			};
+			struct sockaddr* caddr = (struct sockaddr*)(&sin);
+			int ln = sizeof(sin);
+
+			if (lb_addr->sa_family == AF_INET6) {
+				caddr = (struct sockaddr*)(&sin6);
+				ln = sizeof(sin6);
+			}
+
+			port = nfs_getport(caddr, ln, lb_addr, lb_len,
 						program, version, protocol);
 		} else
 			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
@@ -983,7 +1004,8 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
  *  3.	This version shares code with the rpcbindv3 and rpcbindv4 query
  *	functions.  It can use a TI-RPC generated CLIENT.
  */
-unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
+unsigned long nfs_pmap_getport(struct sockaddr* caddr, const socklen_t clen,
+			       const struct sockaddr_in *sin,
 			       const unsigned short transport,
 			       const unsigned long program,
 			       const unsigned long version,
@@ -1002,7 +1024,7 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 	if (timeout != NULL)
 		tout = *timeout;
 
-	client = nfs_gp_get_rpcbclient((struct sockaddr *)sin,
+	client = nfs_gp_get_rpcbclient(caddr, clen, (struct sockaddr *)sin,
 					(socklen_t)sizeof(*sin),
 					transport, PMAPVERS, &tout);
 	if (client != NULL) {
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 82ba818..57c96c8 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -149,28 +149,10 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bind(const int sock, const sa_family_t family)
+static int nfs_bind(struct sockaddr* caddr, const socklen_t clen,
+		    const int sock, const sa_family_t family)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= htonl(INADDR_ANY),
-	};
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-		.sin6_addr		= IN6ADDR_ANY_INIT,
-	};
-
-	switch (family) {
-	case AF_INET:
-		return bind(sock, (struct sockaddr *)&sin,
-					(socklen_t)sizeof(sin));
-	case AF_INET6:
-		return bind(sock, (struct sockaddr *)&sin6,
-					(socklen_t)sizeof(sin6));
-	}
-
-	errno = EAFNOSUPPORT;
-	return -1;
+	return bind(sock, caddr, clen);
 }
 
 /*
@@ -255,7 +237,8 @@ done:
  * must destroy a non-NULL returned RPC client.  Otherwise NULL, and
  * rpc_createerr.cf_stat is set to reflect the error.
  */
-static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
+static CLIENT *nfs_get_udpclient(struct sockaddr* caddr, const socklen_t clen,
+				 const struct sockaddr *sap,
 				 const socklen_t salen,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
@@ -286,7 +269,7 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	ret = nfs_bind(sock, sap->sa_family);
+	ret = nfs_bind(caddr, clen, sock, sap->sa_family);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -331,7 +314,8 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
  * Otherwise NULL, and rpc_createerr.cf_stat is set to reflect the
  * error.
  */
-static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
+static CLIENT *nfs_get_tcpclient(struct sockaddr* caddr, const socklen_t clen,
+				 const struct sockaddr *sap,
 				 const socklen_t salen,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
@@ -362,7 +346,7 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	ret = nfs_bind(sock, sap->sa_family);
+	ret = nfs_bind(caddr, clen, sock, sap->sa_family);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -413,7 +397,9 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
  * client.  Otherwise returns NULL, and rpc_createerr.cf_stat is set to
  * reflect the error.
  */
-CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
+CLIENT *nfs_get_rpcclient(struct sockaddr *caddr,
+			  const socklen_t clen,
+			  const struct sockaddr *sap,
 			  const socklen_t salen,
 			  const unsigned short transport,
 			  const rpcprog_t program,
@@ -446,10 +432,10 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 
 	switch (transport) {
 	case IPPROTO_TCP:
-		return nfs_get_tcpclient(sap, salen, program, version, timeout);
+		return nfs_get_tcpclient(caddr, clen, sap, salen, program, version, timeout);
 	case 0:
 	case IPPROTO_UDP:
-		return nfs_get_udpclient(sap, salen, program, version, timeout);
+		return nfs_get_udpclient(caddr, clen, sap, salen, program, version, timeout);
 	}
 
 	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
diff --git a/utils/mount/network.c b/utils/mount/network.c
index d262e94..5fb52f6 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -428,30 +428,27 @@ out:
  *
  * The caller should check rpc_createerr to determine the cause of any error.
  */
-static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
-			unsigned int timeout, int resvp, int conn)
+static int get_socket(struct sockaddr *caddr, const socklen_t clen,
+		      struct sockaddr_in *saddr,
+		      unsigned int p_prot, unsigned int timeout, int resvp,
+		      int conn)
 {
 	int so, cc, type;
-	struct sockaddr_in laddr;
-	socklen_t namelen = sizeof(laddr);
 
 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
 	if ((so = socket (AF_INET, type, p_prot)) < 0)
 		goto err_socket;
 
-	laddr.sin_family = AF_INET;
-	laddr.sin_port = 0;
-	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
-		if (bindresvport(so, &laddr) < 0)
+		if (bindresvport(so, (struct sockaddr_in*)caddr) < 0)
 			goto err_bindresvport;
 	} else {
-		cc = bind(so, (struct sockaddr *)&laddr, namelen);
+		cc = bind(so, caddr, clen);
 		if (cc < 0)
 			goto err_bind;
 	}
 	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect_to(so, (struct sockaddr *)saddr, namelen,
+		cc = connect_to(so, (struct sockaddr *)saddr, sizeof(*saddr),
 				timeout);
 		if (cc < 0)
 			goto err_connect;
@@ -473,9 +470,9 @@ err_bindresvport:
 	rpc_createerr.cf_error.re_errno = errno;
 	if (verbose) {
 		nfs_error(_("%s: Unable to bindresvport %s socket: errno %d"
-				" (%s)\n"),
+				" (%s)  caddr->family: %i\n"),
 			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
-			errno, strerror(errno));
+			  errno, strerror(errno), (int)(caddr->sa_family));
 	}
 	close(so);
 	return RPC_ANYSOCK;
@@ -519,11 +516,12 @@ static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
 	}
 
 	fprintf(stderr, _("%s: trying %s prog %ld vers %ld prot %s port %d\n"),
-			progname, buf, program, version,
-			(protocol == IPPROTO_UDP ? _("UDP") : _("TCP")),
-			port);
+		progname, buf, program, version,
+		(protocol == IPPROTO_UDP ? _("UDP") : _("TCP")),
+		port);
 }
 
+
 /*
  * Use the portmapper to discover whether or not the service we want is
  * available. The lists 'versions' and 'protos' define ordered sequences
@@ -538,7 +536,8 @@ static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
  * If an error occurs or the requested service isn't available, zero is
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
-static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
+static int nfs_probe_port(struct sockaddr *caddr, const socklen_t clen,
+			  const struct sockaddr *sap, const socklen_t salen,
 			  struct pmap *pmap, const unsigned long *versions,
 			  const unsigned int *protos)
 {
@@ -556,13 +555,12 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 	rpc_createerr.cf_stat = 0;
 
 	for (;;) {
-		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
+		p_port = nfs_getport(caddr, clen, saddr, salen, prog, *p_vers, *p_prot);
 		if (p_port) {
 			if (!port || port == p_port) {
 				nfs_set_port(saddr, p_port);
-				nfs_pp_debug(saddr, salen, prog, *p_vers,
-						*p_prot, p_port);
-				if (nfs_rpc_ping(saddr, salen, prog,
+				nfs_pp_debug(saddr, salen, prog, *p_vers, *p_prot, p_port);
+				if (nfs_rpc_ping(caddr, clen, saddr, salen, prog,
 							*p_vers, *p_prot, NULL))
 					goto out_ok;
 			}
@@ -613,17 +611,18 @@ out_ok:
  * If an error occurs or the requested service isn't available, zero is
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
-static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
-				struct pmap *pmap)
+static int nfs_probe_nfsport(struct sockaddr *caddr, const socklen_t clen,
+                             const struct sockaddr *sap, const socklen_t salen,
+                             struct pmap *pmap)
 {
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return nfs_probe_port(sap, salen, pmap,
+		return nfs_probe_port(caddr, clen, sap, salen, pmap,
 					probe_nfs3_first, probe_tcp_first);
 	else
-		return nfs_probe_port(sap, salen, pmap,
+		return nfs_probe_port(caddr, clen, sap, salen, pmap,
 					probe_nfs2_only, probe_udp_only);
 }
 
@@ -640,17 +639,18 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
  * If an error occurs or the requested service isn't available, zero is
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
-static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
+static int nfs_probe_mntport(struct sockaddr *caddr, const socklen_t clen,
+                             const struct sockaddr *sap, const socklen_t salen,
 				struct pmap *pmap)
 {
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return nfs_probe_port(sap, salen, pmap,
+		return nfs_probe_port(caddr, clen, sap, salen, pmap,
 					probe_mnt3_first, probe_udp_first);
 	else
-		return nfs_probe_port(sap, salen, pmap,
+		return nfs_probe_port(caddr, clen, sap, salen, pmap,
 					probe_mnt1_first, probe_udp_only);
 }
 
@@ -666,13 +666,15 @@ static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
 static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
 			const socklen_t mnt_salen,
 			struct pmap *mnt_pmap,
+			struct sockaddr *nfs_caddr,
+			const socklen_t nfs_clen,
 			const struct sockaddr *nfs_saddr,
 			const socklen_t nfs_salen,
 			struct pmap *nfs_pmap)
 {
-	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
+	if (!nfs_probe_nfsport(nfs_caddr, nfs_clen, nfs_saddr, nfs_salen, nfs_pmap))
 		return 0;
-	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
+	return nfs_probe_mntport(nfs_caddr, nfs_clen, mnt_saddr, mnt_salen, mnt_pmap);
 }
 
 /**
@@ -693,6 +695,8 @@ static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
 int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 			const socklen_t mnt_salen,
 			struct pmap *mnt_pmap,
+                        struct sockaddr *nfs_caddr,
+			const socklen_t nfs_clen,
 			const struct sockaddr *nfs_saddr,
 			const socklen_t nfs_salen,
 			struct pmap *nfs_pmap)
@@ -707,6 +711,7 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
 	if (nfs_pmap->pm_vers)
 		return nfs_probe_version_fixed(mnt_saddr, mnt_salen, mnt_pmap,
+					       nfs_caddr, nfs_clen,
 					       nfs_saddr, nfs_salen, nfs_pmap);
 
 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
@@ -716,9 +721,9 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
 	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
-		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap) != 0) {
+		if (nfs_probe_nfsport(nfs_caddr, nfs_clen, nfs_saddr, nfs_salen, nfs_pmap) != 0) {
 			mnt_pmap->pm_vers = *probe_vers;
-			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap) != 0)
+			if (nfs_probe_mntport(nfs_caddr, nfs_clen, mnt_saddr, mnt_salen, mnt_pmap) != 0)
 				return 1;
 			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
 		}
@@ -748,11 +753,12 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
  * Otherwise zero is returned; rpccreateerr.cf_stat is set to reflect
  * the nature of the error.
  */
-int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+int probe_bothports(struct sockaddr* caddr, const socklen_t clen, clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 {
 	return nfs_probe_bothports((struct sockaddr *)&mnt_server->saddr,
 					sizeof(mnt_server->saddr),
 					&mnt_server->pmap,
+				 	caddr, clen,
 					(struct sockaddr *)&nfs_server->saddr,
 					sizeof(nfs_server->saddr),
 					&nfs_server->pmap);
@@ -764,9 +770,14 @@ static int nfs_probe_statd(void)
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
 	};
+	struct sockaddr_in laddr = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+	};
 	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
 
-	return nfs_getport_ping((struct sockaddr *)&addr, sizeof(addr),
+	return nfs_getport_ping((struct sockaddr*)&laddr, sizeof(laddr),
+				(struct sockaddr *)&addr, sizeof(addr),
 				program, (rpcvers_t)1, IPPROTO_UDP);
 }
 
@@ -820,7 +831,7 @@ int start_statd(void)
  * Note that a side effect of calling this function is that rpccreateerr
  * is set.
  */
-int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
+int nfs_call_umount(struct sockaddr *caddr, const socklen_t clen, clnt_addr_t *mnt_server, dirpath *argp)
 {
 	struct sockaddr *sap = (struct sockaddr *)&mnt_server->saddr;
 	socklen_t salen = sizeof(mnt_server->saddr);
@@ -829,9 +840,9 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	enum clnt_stat res = 0;
 	int msock;
 
-	if (!nfs_probe_mntport(sap, salen, pmap))
+	if (!nfs_probe_mntport(caddr, clen, sap, salen, pmap))
 		return 0;
-	clnt = mnt_openclnt(mnt_server, &msock);
+	clnt = mnt_openclnt(caddr, clen, mnt_server, &msock);
 	if (!clnt)
 		return 0;
 	res = clnt_call(clnt, MOUNTPROC_UMNT,
@@ -852,14 +863,14 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
  *
  * Returns an active handle for the remote's mountd service
  */
-CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
+CLIENT *mnt_openclnt(struct sockaddr *caddr, const socklen_t clen, clnt_addr_t *mnt_server, int *msock)
 {
 	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	CLIENT *clnt = NULL;
 
 	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
-	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
+	*msock = get_socket(caddr, clen, mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
 				TRUE, FALSE);
 	if (*msock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
@@ -925,9 +936,9 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
  *
  * Returns one if successful, otherwise zero.
  */
-int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
-		const unsigned long vers, const unsigned int prot,
-		struct sockaddr_in *caddr)
+int clnt_ping(struct sockaddr* caddr, socklen_t clen,
+	      struct sockaddr_in *saddr, const unsigned long prog,
+	      const unsigned long vers, const unsigned int prot)
 {
 	CLIENT *clnt = NULL;
 	int sock, stat;
@@ -935,7 +946,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	struct sockaddr dissolve;
 
 	rpc_createerr.cf_stat = stat = 0;
-	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
+	sock = get_socket(caddr, clen, saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
 	if (sock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == ETIMEDOUT) {
 			/*
@@ -949,9 +960,8 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 
 	if (caddr) {
 		/* Get the address of our end of this connection */
-		socklen_t len = sizeof(*caddr);
-		if (getsockname(sock, caddr, &len) != 0)
-			caddr->sin_family = 0;
+		if (getsockname(sock, caddr, &clen) != 0)
+			((struct sockaddr_in*)(caddr))->sin_family = 0;
 	}
 
 	switch(prot) {
@@ -1003,40 +1013,20 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
  * This conserves the ephemeral port number space, helping reduce failed
  * socket binds during mount storms.
  */
-static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
+static int nfs_ca_sockname(const struct sockaddr* caddr, const socklen_t clen,
+                           const struct sockaddr *sap, const socklen_t salen,
 			   struct sockaddr *buf, socklen_t *buflen)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= htonl(INADDR_ANY),
-	};
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-		.sin6_addr		= IN6ADDR_ANY_INIT,
-	};
 	int sock;
 
 	sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (sock < 0)
 		return 0;
 
-	switch (sap->sa_family) {
-	case AF_INET:
-		if (bind(sock, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
-			close(sock);
-			return 0;
-		}
-		break;
-	case AF_INET6:
-		if (bind(sock, (struct sockaddr *)&sin6, sizeof(sin6)) < 0) {
-			close(sock);
-			return 0;
-		}
-		break;
-	default:
-		errno = EAFNOSUPPORT;
-		return 0;
-	}
+        if (bind(sock, (struct sockaddr *)&caddr, clen) < 0) {
+                close(sock);
+                return 0;
+        }
 
 	if (connect(sock, sap, salen) < 0) {
 		close(sock);
@@ -1086,12 +1076,13 @@ static int nfs_ca_gai(const struct sockaddr *sap, const socklen_t salen,
  * available; returns 1 and fills in an appropriate ANYADDR address
  * if a local address isn't available; otherwise, returns zero.
  */
-int nfs_callback_address(const struct sockaddr *sap, const socklen_t salen,
+int nfs_callback_address(struct sockaddr* caddr, const socklen_t clen,
+			 const struct sockaddr *sap, const socklen_t salen,
 			 struct sockaddr *buf, socklen_t *buflen)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)buf;
 
-	if (nfs_ca_sockname(sap, salen, buf, buflen) == 0)
+	if (nfs_ca_sockname(caddr, clen, sap, salen, buf, buflen) == 0)
 		if (nfs_ca_gai(sap, salen, buf, buflen) == 0)
 			goto out_failed;
 
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 075093d..5413686 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -39,29 +39,32 @@ typedef struct {
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
-int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+int probe_bothports(struct sockaddr* caddr, const socklen_t clen, clnt_addr_t *, clnt_addr_t *);
 int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
-			struct pmap *, const struct sockaddr *,
+			struct pmap *,
+                        struct sockaddr *nfs_caddr,
+			const socklen_t nfs_clen, const struct sockaddr *,
 			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int nfs_call_umount(struct sockaddr *caddr, const socklen_t clen, clnt_addr_t *, dirpath *);
 int nfs_name_to_address(const char *, const sa_family_t,
 		struct sockaddr *, socklen_t *);
 int nfs_string_to_sockaddr(const char *, const size_t,
 			   struct sockaddr *, socklen_t *);
 int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);
-int nfs_callback_address(const struct sockaddr *, const socklen_t,
+int nfs_callback_address(struct sockaddr* caddr, const socklen_t clen,
+		const struct sockaddr *, const socklen_t,
 		struct sockaddr *, socklen_t *);
-int nfs_call_umount(clnt_addr_t *, dirpath *);
-int clnt_ping(struct sockaddr_in *, const unsigned long,
-		const unsigned long, const unsigned int,
-		struct sockaddr_in *);
+int clnt_ping(struct sockaddr* caddr, socklen_t clen,
+		struct sockaddr_in *, const unsigned long,
+		const unsigned long, const unsigned int);
 
 int start_statd(void);
 
 unsigned long nfsvers_to_mnt(const unsigned long);
 
-CLIENT *mnt_openclnt(clnt_addr_t *, int *);
+CLIENT *mnt_openclnt(struct sockaddr *caddr, const socklen_t clen, clnt_addr_t *, int *);
 void mnt_closeclnt(CLIENT *, int);
 
 #endif	/* _NFS_UTILS_MOUNT_NETWORK_H */
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index a2f318f..e06025d 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -420,9 +420,12 @@ int nfs4mount(const char *spec, const char *node, int flags,
 				data.proto == IPPROTO_UDP ? "udp" : "tcp",
 				ntohs(server_addr.sin_port));
 		}
-		client_addr.sin_family = 0;
-		client_addr.sin_addr.s_addr = 0;
-		clnt_ping(&server_addr, NFS_PROGRAM, 4, data.proto, &client_addr);
+		memset(&client_addr, 0, sizeof(client_addr));
+		if (ip_addr_in_opts) {
+			client_addr.sin_family = AF_INET;
+			client_addr.sin_addr.s_addr = inet_addr(ip_addr);
+		}
+		clnt_ping((struct sockaddr*)&client_addr, sizeof(client_addr), &server_addr, NFS_PROGRAM, 4, data.proto);
 		if (rpc_createerr.cf_stat == RPC_SUCCESS) {
 			if (!ip_addr_in_opts &&
 			    client_addr.sin_family != 0 &&
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 2becfb1..9fe1251 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -14,7 +14,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 
-#define NFS_MOUNT_VERSION	6
+#define NFS_MOUNT_VERSION	7
 #define NFS_MAX_CONTEXT_LEN	256
 
 struct nfs2_fh {
@@ -45,6 +45,7 @@ struct nfs_mount_data {
 	struct nfs3_fh	root;			/* 4 */
 	int		pseudoflavor;		/* 5 */
 	char    context[NFS_MAX_CONTEXT_LEN + 1]; /* 6 */
+	struct sockaddr_storage clientaddr;		/* 7 */
 
 };
 
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6355681..8c01d58 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -122,17 +122,17 @@ nfs2_mount(CLIENT *clnt, mnt2arg_t *mnt2arg, mnt2res_t *mnt2res)
 }
 
 static int
-nfs_call_mount(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
-	       mntarg_t *mntarg, mntres_t *mntres)
+nfs_call_mount(clnt_addr_t *mnt_server, struct sockaddr *clientaddr, socklen_t clen,
+	       clnt_addr_t *nfs_server, mntarg_t *mntarg, mntres_t *mntres)
 {
 	CLIENT *clnt;
 	enum clnt_stat stat;
 	int msock;
 
-	if (!probe_bothports(mnt_server, nfs_server))
+	if (!probe_bothports(clientaddr, clen, mnt_server, nfs_server))
 		goto out_bad;
 
-	clnt = mnt_openclnt(mnt_server, &msock);
+	clnt = mnt_openclnt(clientaddr, clen, mnt_server, &msock);
 	if (!clnt)
 		goto out_bad;
 	/* make pointers in xdr_mountres3 NULL so
@@ -167,6 +167,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	      clnt_addr_t *nfs_server, char *new_opts, const int opt_size)
 {
 	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
+	struct sockaddr_in *clientaddr;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap *nfs_pmap = &nfs_server->pmap;
 	int len;
@@ -178,6 +179,10 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	data->flags = 0;
 	*bg = 0;
 
+	/* TODO:  Support IPv6 binding */
+	clientaddr = (struct sockaddr_in *)&data->clientaddr;
+	clientaddr->sin_family = AF_INET;
+
 	len = strlen(new_opts);
 	for (p=old_opts, opt_b=NULL; p && *p; p++) {
 		if (!opt_b)
@@ -252,6 +257,19 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "addr")) {
 				/* ignore */;
 				continue;
+#if NFS_MOUNT_VERSION >= 7
+			} else if (!strcmp(opt, "clientaddr")) {
+				char ip_addr[sizeof("255.255.255.255")];
+				if (strlen(opteq+1) >= sizeof(ip_addr)) {
+					printf(_("Invalid client address %s"),
+						 opteq+1);
+					goto bad_parameter;
+				}
+				strncpy(ip_addr,opteq+1, sizeof(ip_addr));
+				ip_addr[sizeof(ip_addr)-1] = '\0';
+
+				clientaddr->sin_addr.s_addr = inet_addr(ip_addr);
+#endif
  			} else if (sloppy)
 				continue;
 			else
@@ -673,8 +691,10 @@ nfsmount(const char *spec, const char *node, int flags,
 			if (t - prevt < 30)
 				sleep(30);
 
-			stat = nfs_call_mount(&mnt_server, &nfs_server,
-					      &dirname, &mntres);
+			stat = nfs_call_mount(&mnt_server,
+					      (struct sockaddr *)&data.clientaddr,
+					      sizeof(data.clientaddr),
+					      &nfs_server, &dirname, &mntres);
 			if (stat)
 				break;
 			memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
@@ -772,7 +792,8 @@ nfsmount(const char *spec, const char *node, int flags,
 					"not supported"),
 					progname, hostname, dirname);
 			/* server has registered us in rmtab, send umount */
-			nfs_call_umount(&mnt_server, &dirname);
+			nfs_call_umount((struct sockaddr *)&data.clientaddr, sizeof(data.clientaddr),
+					&mnt_server, &dirname);
 			goto fail;
 		}
 noauth_flavors:
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index b2327e0..cb9edfd 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -25,6 +25,9 @@
 #include <sys/mount.h>
 #include <ctype.h>
 #include <pwd.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
 
 #include "xcommon.h"
 #include "fstab.h"
@@ -147,6 +150,7 @@ static int do_nfs_umount23(const char *spec, char *opts)
 {
 	char *hostname;
 	char *dirname;
+	struct sockaddr_in caddr;
 	clnt_addr_t mnt_server = { &hostname, };
 	struct mntent mnt = { .mnt_opts = opts };
 	struct pmap *pmap = &mnt_server.pmap;
@@ -160,14 +164,37 @@ static int do_nfs_umount23(const char *spec, char *opts)
 	printf(_("host: %s, directory: %s\n"), hostname, dirname);
 #endif
 
-	if (opts && (p = strstr(opts, "addr="))) {
+	for (p = opts; (p = strstr(p, "addr=")); ) {
 		char *q;
 
+		/* This is a bit of a hack, but necessary to avoid using the
+		 * client address as server address. */
+		if (p >= opts + strlen("client") &&
+		    strncmp(p - strlen("client"), "client",
+		    	    strlen("client")) == 0) {
+			p += strlen("addr=");
+			continue;
+		}
+
 		free(hostname);
 		p += 5;
 		q = p;
 		while (*q && *q != ',') q++;
 		hostname = xstrndup(p,q-p);
+		break;
+	}
+
+	memset(&caddr, 0, sizeof(caddr));
+	if (opts && (p = strstr(opts, "clientaddr="))) {
+		char *q, *tmp;
+
+		p += 11;
+		q = p;
+		while (*q && *q != ',') q++;
+		tmp = xstrndup(p,q-p);
+		caddr.sin_family = AF_INET;
+		caddr.sin_addr.s_addr = inet_addr(tmp);
+		free(tmp);
 	}
 
 	if (opts && (p = strstr(opts, "mounthost="))) {
@@ -211,7 +238,7 @@ static int do_nfs_umount23(const char *spec, char *opts)
 		goto out;
 	}
 
-	if (!nfs_call_umount(&mnt_server, &dirname)) {
+	if (!nfs_call_umount((struct sockaddr*)&caddr, sizeof(caddr), &mnt_server, &dirname)) {
 		nfs_error(_("%s: Server failed to unmount '%s'"),
 				progname, spec);
 		result = EX_FAIL;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 43791e6..54b5c94 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -184,11 +184,17 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 	struct sockaddr_storage dummy;
 	struct sockaddr *my_addr = (struct sockaddr *)&dummy;
 	socklen_t my_len = sizeof(dummy);
+	struct sockaddr_storage dclient;
+	struct sockaddr *my_cl = (struct sockaddr *)&dclient;
+	socklen_t my_lenc = sizeof(dclient);
 
 	if (po_contains(options, "clientaddr") == PO_FOUND)
 		return 1;
 
-	nfs_callback_address(sap, salen, my_addr, &my_len);
+	memset(&dclient, 0, sizeof(dclient));
+	my_cl->sa_family = sap->sa_family;
+	
+	nfs_callback_address(my_cl, my_lenc, sap, salen, my_addr, &my_len);
 
 	return nfs_append_generic_address_option(my_addr, my_len,
 							"clientaddr", options);
@@ -322,8 +328,11 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	char *option, new_option[64];
 	clnt_addr_t mnt_server = { };
 	clnt_addr_t nfs_server = { };
+        struct sockaddr_in clientaddr;
 	int p;
 
+        memset(&clientaddr, 0, sizeof(clientaddr));
+        
 	options = po_split(str);
 	if (!options) {
 		errno = EFAULT;
@@ -339,6 +348,12 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	} else
 		goto err;
 
+        option = po_get(options, "clientaddr");
+        if (option) {
+           clientaddr.sin_family = AF_INET;
+           clientaddr.sin_addr.s_addr = inet_addr(option);
+        }
+        
 	option = po_get(options, "mountaddr");
 	if (option) {
 		mnt_server.saddr.sin_family = AF_INET;
@@ -407,7 +422,7 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 	po_remove_all(options, "tcp");
 	po_remove_all(options, "udp");
 
-	if (!probe_bothports(&mnt_server, &nfs_server)) {
+	if (!probe_bothports((struct sockaddr*)&clientaddr, sizeof(clientaddr), &mnt_server, &nfs_server)) {
 		errno = ESPIPE;
 		goto err;
 	}
diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 2695c51..2545ed6 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -55,6 +55,7 @@ static struct option longopts[] =
 	{ "all", 0, 0, 'a' },
 	{ "directories", 0, 0, 'd' },
 	{ "exports", 0, 0, 'e' },
+	{ "local_ip", 1, 0, 'i' },
 	{ "no-headers", 0, &headers, 0 },
 	{ "version", 0, 0, 'v' },
 	{ "help", 0, 0, 'h' },
@@ -74,7 +75,7 @@ static void usage(FILE *fp, int n)
 {
 	fprintf(fp, "Usage: %s [-adehv]\n", program_name);
 	fprintf(fp, "       [--all] [--directories] [--exports]\n");
-	fprintf(fp, "       [--no-headers] [--help] [--version] [host]\n");
+	fprintf(fp, "       [--no-headers] [--help] [--version] [--local_ip a.b.c.d] [host]\n");
 	exit(n);
 }
 
@@ -190,14 +191,35 @@ done:
  *
  * Supports only AF_INET server addresses.
  */
-static CLIENT *nfs_get_mount_client(const char *hostname)
+static CLIENT *nfs_get_mount_client(const char *hostname, const char* local_ip)
 {
 	struct hostent *hp;
 	struct sockaddr_in server_addr;
+	struct sockaddr_in local_addr;
 	struct timeval pertry_timeout;
 	CLIENT *mclient = NULL;
 	int ret, msock;
 
+	if (local_ip) {
+		if (inet_aton(local_ip, &local_addr.sin_addr)) {
+			server_addr.sin_family = AF_INET;
+		}
+		else {
+			if ((hp = gethostbyname(hostname)) == NULL) {
+				fprintf(stderr, "%s: can't get address for %s\n",
+					program_name, hostname);
+				exit(1);
+			}
+			server_addr.sin_family = AF_INET;
+			memcpy(&server_addr.sin_addr, hp->h_addr, hp->h_length);
+		}
+	}
+	else {
+		local_addr.sin_addr.s_addr = htonl(INADDR_ANY);
+		local_addr.sin_port = 0;
+		local_addr.sin_family = AF_INET;
+	}
+	
 	if (inet_aton(hostname, &server_addr.sin_addr)) {
 		server_addr.sin_family = AF_INET;
 	}
@@ -213,7 +235,8 @@ static CLIENT *nfs_get_mount_client(const char *hostname)
 
 	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
 	if (msock != -1) {
-		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+		if (nfs_getport_ping((struct sockaddr*)(&local_addr), sizeof(local_addr),
+				     (struct sockaddr *)&server_addr,
 					sizeof(server_addr), MOUNTPROG,
 					MOUNTVERS, IPPROTO_TCP)) {
 			ret = connect_nb(msock, &server_addr, 0);
@@ -228,7 +251,8 @@ static CLIENT *nfs_get_mount_client(const char *hostname)
 	}
 
 	if (!mclient) {
-		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+		if (nfs_getport_ping((struct sockaddr*)&local_addr, sizeof(local_addr),
+				     (struct sockaddr *)&server_addr,
 					sizeof(server_addr), MOUNTPROG,
 					MOUNTVERS, IPPROTO_UDP)) {
 			clnt_pcreateerror("showmount");
@@ -253,6 +277,7 @@ int main(int argc, char **argv)
 {
 	char hostname_buf[MAXHOSTLEN];
 	char *hostname;
+	char* local_ip = NULL;
 	enum clnt_stat clnt_stat;
 	struct timeval total_timeout;
 	int c;
@@ -267,7 +292,7 @@ int main(int argc, char **argv)
 	char **dumpv;
 
 	program_name = argv[0];
-	while ((c = getopt_long(argc, argv, "adehv", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "adehvi:", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			aflag = 1;
@@ -281,6 +306,9 @@ int main(int argc, char **argv)
 		case 'h':
 			usage(stdout, 0);
 			break;
+		case 'i':
+			local_ip = strdup(optarg);
+			break;
 		case 'v':
 			printf("%s\n", version);
 			exit(0);
@@ -326,7 +354,7 @@ int main(int argc, char **argv)
 		break;
 	}
 
-	mclient = nfs_get_mount_client(hostname);
+	mclient = nfs_get_mount_client(hostname, local_ip);
 	mclient->cl_auth = authunix_create_default();
 	total_timeout.tv_sec = TOTAL_TIMEOUT;
 	total_timeout.tv_usec = 0;

--------------050103020507060700000602--
