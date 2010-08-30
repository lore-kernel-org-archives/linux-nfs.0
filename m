Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45867 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772Ab0H3NFH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 09:05:07 -0400
From: Olaf Kirch <okir@suse.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] Introduce new helper function getpmaphandle
Date: Mon, 30 Aug 2010 15:04:20 +0200
Cc: nfsv4@linux-nfs.org, Steve Dickson <SteveD@redhat.com>
References: <201008301503.19783.okir@suse.de>
In-Reply-To: <201008301503.19783.okir@suse.de>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201008301504.20634.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


From: Olaf Kirch <okir@suse.de>
Date: Mon, 23 Aug 2010 12:58:41 +0200
Subject: [PATCH] Introduce new helper function getpmaphandle

This moves some code for creation of PMAP handles out of the getaddr
code and into a function of its own.

Signed-off-by: Olaf Kirch <okir@suse.de>
---
 src/rpcb_clnt.c |   62 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 43 insertions(+), 19 deletions(-)

diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index a800128..531c619 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -434,6 +434,44 @@ out_err:
 	return (client);
 }
 
+/*
+ * Create a PMAP client handle.
+ */
+static CLIENT *
+getpmaphandle(nconf, hostname, tgtaddr)
+	const struct netconfig *nconf;
+	const char *hostname;
+	char **tgtaddr;
+{
+	CLIENT *client = NULL;
+	rpcvers_t pmapvers = 2;
+
+	/*
+	 * Try UDP only - there are some portmappers out
+	 * there that use UDP only.
+	 */
+	if (nconf == NULL || strcmp(nconf->nc_proto, NC_TCP) == 0) {
+		struct netconfig *newnconf;
+
+		if ((newnconf = getnetconfigent("udp")) == NULL) {
+			rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
+			return NULL;
+		}
+		client = getclnthandle(hostname, newnconf, tgtaddr);
+		freenetconfigent(newnconf);
+	} else if (strcmp(nconf->nc_proto, NC_UDP) == 0) {
+		if (strcmp(nconf->nc_protofmly, NC_INET) != 0)
+			return NULL;
+		client = getclnthandle(hostname, nconf, tgtaddr);
+	}
+
+	/* Set version */
+	if (client != NULL)
+		CLNT_CONTROL(client, CLSET_VERS, (char *)&pmapvers);
+
+	return client;
+}
+
 /* XXX */
 #define IN4_LOCALHOST_STRING	"127.0.0.1"
 #define IN6_LOCALHOST_STRING	"::1"
@@ -770,34 +808,20 @@ __rpcb_findaddr_timed(program, version, nconf, host, 
clpp, tp)
 	if (strcmp(nconf->nc_protofmly, NC_INET) == 0) {
 		u_short port = 0;
 		struct netbuf remote;
-		rpcvers_t pmapvers = 2;
 		struct pmap pmapparms;
 
-		/*
-		 * Try UDP only - there are some portmappers out
-		 * there that use UDP only.
-		 */
-		if (strcmp(nconf->nc_proto, NC_TCP) == 0) {
-			struct netconfig *newnconf;
-
-			if ((newnconf = getnetconfigent("udp")) == NULL) {
-				rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
-				return (NULL);
-			}
-			client = getclnthandle(host, newnconf, &parms.r_addr);
-			freenetconfigent(newnconf);
-		} else if (strcmp(nconf->nc_proto, NC_UDP) == 0)
-			client = getclnthandle(host, nconf, &parms.r_addr);
-		else
+		if (strcmp(nconf->nc_proto, NC_UDP) != 0
+		 && strcmp(nconf->nc_proto, NC_TCP) != 0)
 			goto try_rpcbind;
+
+		client = getpmaphandle(nconf, IN4_LOCALHOST_STRING, &parms.r_addr);
 		if (client == NULL)
 			return (NULL);
 
 		/*
-		 * Set version and retry timeout.
+		 * Set retry timeout.
 		 */
 		CLNT_CONTROL(client, CLSET_RETRY_TIMEOUT, (char *)&rpcbrmttime);
-		CLNT_CONTROL(client, CLSET_VERS, (char *)&pmapvers);
 
 		pmapparms.pm_prog = program;
 		pmapparms.pm_vers = version;
-- 
1.6.0.2


-- 
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)
