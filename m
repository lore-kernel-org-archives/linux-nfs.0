Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab2DWP1i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 11:27:38 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3NFRbVk011020
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 11:27:38 -0400
From: Niels de Vos <ndevos@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Niels de Vos <ndevos@redhat.com>
Subject: [PATCH] rpcbind: Only listen on requested hostnames for NC_TPI_COTS connections
Date: Mon, 23 Apr 2012 17:24:52 +0200
Message-Id: <1335194692-6714-1-git-send-email-ndevos@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a check for NC_TPI_CLTS connections which correctly binds only
to the hostnames/addresses given on the commandline (-h option). This
implementation does not take non NC_TPI_CLTS like NC_TPI_COTS and
NC_TPI_COTS_ORD into account. This causes non NC_TPI_CLTS protocols to
listen on the "0.0.0.0" and "::" wildcard addresses.

This patch simplifies the code, and moves the check for NC_TPI_CLTS into
the loop when a bind() for each requested address is done. All
connections, including NC_TPI_COTS and NC_TPI_COTS_ORD can now benefit
from resticted bind()'ing on addresses.

Signed-off-by: Niels de Vos <ndevos@redhat.com>
---
 src/rpcbind.c |  230 ++++++++++++++++++++------------------------------------
 1 files changed, 82 insertions(+), 148 deletions(-)

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 9a0504d..3f6c2a9 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -339,172 +339,103 @@ init_transport(struct netconfig *nconf)
 		hints.ai_socktype = si.si_socktype;
 		hints.ai_protocol = si.si_proto;
 	}
-	if (nconf->nc_semantics == NC_TPI_CLTS) {
+
+	/*
+	 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
+	 * make sure 127.0.0.1 is added to the list.
+	 */
+	nhostsbak = nhosts;
+	nhostsbak++;
+	hosts = realloc(hosts, nhostsbak * sizeof(char *));
+	if (nhostsbak == 1)
+		hosts[0] = "*";
+	else {
+		if (hints.ai_family == AF_INET) {
+			hosts[nhostsbak - 1] = "127.0.0.1";
+		} else if (hints.ai_family == AF_INET6) {
+			hosts[nhostsbak - 1] = "::1";
+		} else
+			return 1;
+	}
+
+       /*
+	* Bind to specific IPs if asked to
+	*/
+	checkbind = 0;
+	while (nhostsbak > 0) {
+		--nhostsbak;
 		/*
-		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
-		 * make sure 127.0.0.1 is added to the list.
+		 * XXX - using RPC library internal functions.
 		 */
-		nhostsbak = nhosts;
-		nhostsbak++;
-		hosts = realloc(hosts, nhostsbak * sizeof(char *));
-		if (nhostsbak == 1)
-			hosts[0] = "*";
-		else {
-			if (hints.ai_family == AF_INET) {
-				hosts[nhostsbak - 1] = "127.0.0.1";
-			} else if (hints.ai_family == AF_INET6) {
-				hosts[nhostsbak - 1] = "::1";
-			} else
-				return 1;
+		if ((fd = __rpc_nconf2fd(nconf)) < 0) {
+			syslog(LOG_ERR, "cannot create socket for %s",
+			    nconf->nc_netid);
+			return (1);
 		}
-
-	       /*
-		* Bind to specific IPs if asked to
-		*/
-		checkbind = 0;
-		while (nhostsbak > 0) {
-			--nhostsbak;
-			/*
-			 * XXX - using RPC library internal functions.
-			 */
-			if ((fd = __rpc_nconf2fd(nconf)) < 0) {
-				syslog(LOG_ERR, "cannot create socket for %s",
-				    nconf->nc_netid);
-				return (1);
+		switch (hints.ai_family) {
+		case AF_INET:
+			if (inet_pton(AF_INET, hosts[nhostsbak],
+			    host_addr) == 1) {
+				hints.ai_flags &= AI_NUMERICHOST;
+			} else {
+				/*
+				 * Skip if we have an AF_INET6 adress.
+				 */
+				if (inet_pton(AF_INET6,
+				    hosts[nhostsbak], host_addr) == 1)
+					continue;
 			}
-			switch (hints.ai_family) {
-			case AF_INET:
+			break;
+		case AF_INET6:
+			if (inet_pton(AF_INET6, hosts[nhostsbak],
+			    host_addr) == 1) {
+				hints.ai_flags &= AI_NUMERICHOST;
+			} else {
+				/*
+				 * Skip if we have an AF_INET adress.
+				 */
 				if (inet_pton(AF_INET, hosts[nhostsbak],
-				    host_addr) == 1) {
-					hints.ai_flags &= AI_NUMERICHOST;
-				} else {
-					/*
-					 * Skip if we have an AF_INET6 adress.
-					 */
-					if (inet_pton(AF_INET6,
-					    hosts[nhostsbak], host_addr) == 1)
-						continue;
-				}
-				break;
-			case AF_INET6:
-				if (inet_pton(AF_INET6, hosts[nhostsbak],
-				    host_addr) == 1) {
-					hints.ai_flags &= AI_NUMERICHOST;
-				} else {
-					/*
-					 * Skip if we have an AF_INET adress.
-					 */
-					if (inet_pton(AF_INET, hosts[nhostsbak],
-					    host_addr) == 1)
-						continue;
-				}
-	        		break;
-			default:
-				break;
+				    host_addr) == 1)
+					continue;
 			}
+			break;
+		default:
+			break;
+		}
 
-			/*
-			 * If no hosts were specified, just bind to INADDR_ANY
-			 */
-			if (strcmp("*", hosts[nhostsbak]) == 0)
-				hosts[nhostsbak] = NULL;
+		/*
+		 * If no hosts were specified, just bind to INADDR_ANY
+		 */
+		if (strcmp("*", hosts[nhostsbak]) == 0)
+			hosts[nhostsbak] = NULL;
 
+		if ((strcmp(nconf->nc_netid, "local") != 0) &&
+		    (strcmp(nconf->nc_netid, "unix") != 0)) {
 			if ((aicode = getaddrinfo(hosts[nhostsbak],
-			    servname, &hints, &res)) != 0) {
+			    servname, &hints, &res))!= 0) {
 			  if ((aicode = getaddrinfo(hosts[nhostsbak],
-						    "portmapper", &hints, &res)) != 0) {
-				syslog(LOG_ERR,
+					    "portmapper", &hints, &res))!= 0) {
+			    syslog(LOG_ERR,
 				    "cannot get local address for %s: %s",
 				    nconf->nc_netid, gai_strerror(aicode));
-				continue;
+			    continue;
 			  }
 			}
 			addrlen = res->ai_addrlen;
 			sa = (struct sockaddr *)res->ai_addr;
-			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
-                        if (bind(fd, sa, addrlen) != 0) {
-				syslog(LOG_ERR, "cannot bind %s on %s: %m",
-					(hosts[nhostsbak] == NULL) ? "*" :
-					hosts[nhostsbak], nconf->nc_netid);
-				if (res != NULL)
-					freeaddrinfo(res);
-				continue;
-			} else
-				checkbind++;
-			(void) umask(oldmask);
-
-			/* Copy the address */
-			taddr.addr.maxlen = taddr.addr.len = addrlen;
-			taddr.addr.buf = malloc(addrlen);
-			if (taddr.addr.buf == NULL) {
-				syslog(LOG_ERR,
-				    "cannot allocate memory for %s address",
-				    nconf->nc_netid);
+		}
+		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
+		if (nconf->nc_semantics != NC_TPI_CLTS) {
+			/* NC_TPI_COTS and NC_TPI_COTS_ORD etc */
+			__rpc_fd2sockinfo(fd, &si);
+			if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
+			    sizeof(on)) != 0) {
+				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
+					nconf->nc_netid);
 				if (res != NULL)
 					freeaddrinfo(res);
 				return 1;
 			}
-			memcpy(taddr.addr.buf, sa, addrlen);
-#ifdef RPCBIND_DEBUG
-			if (debugging) {
-				/*
-				 * for debugging print out our universal
-				 * address
-				 */
-				char *uaddr;
-				struct netbuf nb;
-				int sa_size = 0;
-
-				nb.buf = sa;
-				switch( sa->sa_family){
-				case AF_INET:
-				  sa_size = sizeof (struct sockaddr_in);
-				  break;
-				case AF_INET6:
-				  sa_size = sizeof (struct sockaddr_in6);				 
-				  break;
-				}
-				nb.len = nb.maxlen = sa_size;
-				uaddr = taddr2uaddr(nconf, &nb);
-				(void) fprintf(stderr,
-				    "rpcbind : my address is %s\n", uaddr);
-				(void) free(uaddr);
-			}
-#endif
-			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, 
-                                RPC_MAXDATASIZE, RPC_MAXDATASIZE);
-			if (my_xprt == (SVCXPRT *)NULL) {
-				syslog(LOG_ERR, "%s: could not create service", 
-                                        nconf->nc_netid);
-				goto error;
-			}
-		}
-		if (!checkbind)
-			return 1;
-	} else {	/* NC_TPI_COTS */
-		if ((strcmp(nconf->nc_netid, "local") != 0) &&
-		    (strcmp(nconf->nc_netid, "unix") != 0)) {
-			if ((aicode = getaddrinfo(NULL, servname, &hints, &res))!= 0) {
-			  if ((aicode = getaddrinfo(NULL, "portmapper", &hints, &res))!= 0) {
-			  printf("cannot get local address for %s: %s",  nconf->nc_netid, gai_strerror(aicode));
-			  syslog(LOG_ERR,
-				    "cannot get local address for %s: %s",
-				    nconf->nc_netid, gai_strerror(aicode));
-				return 1;
-			  }
-			}
-			addrlen = res->ai_addrlen;
-			sa = (struct sockaddr *)res->ai_addr;
-		}
-		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
-		__rpc_fd2sockinfo(fd, &si);
-		if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
-				sizeof(on)) != 0) {
-			syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
-				nconf->nc_netid);
-			if (res != NULL)
-				freeaddrinfo(res);
-			return 1;
 		}
 		if (bind(fd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "cannot bind %s: %m", nconf->nc_netid);
@@ -530,7 +461,7 @@ init_transport(struct netconfig *nconf)
 			/* for debugging print out our universal address */
 			char *uaddr;
 			struct netbuf nb;
-		        int sa_size2 = 0;
+			int sa_size2 = 0;
 
 			nb.buf = sa;
 			switch( sa->sa_family){
@@ -551,13 +482,16 @@ init_transport(struct netconfig *nconf)
 
 		listen(fd, SOMAXCONN);
 
-		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, RPC_MAXDATASIZE, RPC_MAXDATASIZE);
+		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr,
+			    RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 		if (my_xprt == (SVCXPRT *)NULL) {
 			syslog(LOG_ERR, "%s: could not create service",
 					nconf->nc_netid);
 			goto error;
 		}
 	}
+	if (!checkbind)
+		return 1;
 
 #ifdef PORTMAP
 	/*
-- 
1.7.7.6

