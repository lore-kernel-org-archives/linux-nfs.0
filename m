Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:5742 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241Ab0IQSVh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 14:21:37 -0400
Date: Fri, 17 Sep 2010 20:12:51 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpcbind: don't ignore bind and init_transport errors
Message-ID: <20100917181251.GA21111@sith.mimuw.edu.pl>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
rpcbind currently silently ignores any errors that occur during
init_transport, it also happily continues if bind(2) fails for
UDP socket - it's enough if just one UDP socket is bound.

This patch makes rpcbind fail if there are problems with
setting up any transport, so we don't end up with
semi/non functional running daemon.

Signed-off-by: Jan Rękorajski <baggins@sith.mimuw.edu.pl>

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 63023e1..06e5b08 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -179,11 +179,17 @@ main(int argc, char *argv[])
 	
 	rpc_control(RPC_SVC_CONNMAXREC_SET, &maxrec);
 
-	init_transport(nconf);
+	if (init_transport(nconf)) {
+		syslog(LOG_ERR, "%s: can't init local transport\n", argv[0]);
+		exit(1);
+	}
 
 	while ((nconf = getnetconfig(nc_handle))) {
 		if (nconf->nc_flag & NC_VISIBLE)
-			init_transport(nconf);
+			if (init_transport(nconf)) {
+				syslog(LOG_ERR, "%s: can't init %s transport\n", argv[0], nconf->nc_netid);
+				exit(1);
+			}
 	}
 	endnetconfig(nc_handle);
 
@@ -276,7 +282,6 @@ init_transport(struct netconfig *nconf)
 	int aicode;
 	int addrlen = 0;
 	int nhostsbak;
-	int checkbind;
 	int on = 1;
 	struct sockaddr *sa = NULL;
 	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
@@ -358,7 +363,6 @@ init_transport(struct netconfig *nconf)
 	       /*
 		* Bind to specific IPs if asked to
 		*/
-		checkbind = 0;
 		while (nhostsbak > 0) {
 			--nhostsbak;
 			/*
@@ -425,9 +429,8 @@ init_transport(struct netconfig *nconf)
 					hosts[nhostsbak], nconf->nc_netid);
 				if (res != NULL)
 					freeaddrinfo(res);
-				continue;
-			} else
-				checkbind++;
+				return 1;
+			}
 			(void) umask(oldmask);
 
 			/* Copy the address */
@@ -476,8 +479,6 @@ init_transport(struct netconfig *nconf)
 				goto error;
 			}
 		}
-		if (!checkbind)
-			return 1;
 	} else {	/* NC_TPI_COTS */
 		if ((strcmp(nconf->nc_netid, "local") != 0) &&
 		    (strcmp(nconf->nc_netid, "unix") != 0)) {
