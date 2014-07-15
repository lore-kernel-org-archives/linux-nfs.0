Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336AbaGOPJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:51 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/15] rpcb_clnt: Convert fprintf calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:32 -0400
Message-Id: <1405436974-4161-14-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcb_clnt.c | 65 +++++++++++++++++++--------------------------------------
 1 file changed, 21 insertions(+), 44 deletions(-)

diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index e9b7b5d..a796593 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -54,6 +54,7 @@
 #include <assert.h>
 
 #include "rpc_com.h"
+#include "debug.h"
 
 static struct timeval tottimeout = { 60, 0 };
 static const struct timeval rmttimeout = { 3, 0 };
@@ -152,10 +153,8 @@ check_cache(host, netid)
 	for (cptr = front; cptr != NULL; cptr = cptr->ac_next) {
 		if (!strcmp(cptr->ac_host, host) &&
 		    !strcmp(cptr->ac_netid, netid)) {
-#ifdef ND_DEBUG
-			fprintf(stderr, "Found cache entry for %s: %s\n",
-				host, netid);
-#endif
+			LIBTIRPC_DEBUG(3, ("check_cache: Found cache entry for %s: %s\n", 
+				host, netid));
 			return (cptr);
 		}
 	}
@@ -214,9 +213,7 @@ add_cache(host, netid, taddr, uaddr)
 	if (ad_cache->ac_taddr->buf == NULL)
 		goto out_free;
 	memcpy(ad_cache->ac_taddr->buf, taddr->buf, taddr->len);
-#ifdef ND_DEBUG
-	fprintf(stderr, "Added to cache: %s : %s\n", host, netid);
-#endif
+	LIBTIRPC_DEBUG(3, ("add_cache: Added to cache: %s : %s\n", host, netid));
 
 /* VARIABLES PROTECTED BY rpcbaddr_cache_lock:  cptr */
 
@@ -234,10 +231,8 @@ add_cache(host, netid, taddr, uaddr)
 			cptr = cptr->ac_next;
 		}
 
-#ifdef ND_DEBUG
-		fprintf(stderr, "Deleted from cache: %s : %s\n",
-			cptr->ac_host, cptr->ac_netid);
-#endif
+		LIBTIRPC_DEBUG(3, ("add_cache: Deleted from cache: %s : %s\n",
+			cptr->ac_host, cptr->ac_netid));
 		free(cptr->ac_host);
 		free(cptr->ac_netid);
 		free(cptr->ac_taddr->buf);
@@ -338,17 +333,14 @@ getclnthandle(host, nconf, targaddr)
 	hints.ai_socktype = si.si_socktype;
 	hints.ai_protocol = si.si_proto;
 
-#ifdef CLNT_DEBUG
-	printf("trying netid %s family %d proto %d socktype %d\n",
-	    nconf->nc_netid, si.si_af, si.si_proto, si.si_socktype);
-#endif
+	LIBTIRPC_DEBUG(3, ("getclnthandle: trying netid %s family %d proto %d socktype %d\n",
+	    nconf->nc_netid, si.si_af, si.si_proto, si.si_socktype));
 
 	if (nconf->nc_protofmly != NULL && strcmp(nconf->nc_protofmly, NC_LOOPBACK) == 0) {
 		client = local_rpcb();
 		if (! client) {
-#ifdef ND_DEBUG
-			clnt_pcreateerror("rpcbind clnt interface");
-#endif
+			LIBTIRPC_DEBUG(1, ("getclnthandle: %s", 
+				clnt_spcreateerror("local_rpcb failed")));
 			goto out_err;
 		} else {
 			struct sockaddr_un sun;
@@ -370,19 +362,13 @@ getclnthandle(host, nconf, targaddr)
 		taddr.buf = tres->ai_addr;
 		taddr.len = taddr.maxlen = tres->ai_addrlen;
 
-#ifdef ND_DEBUG
-		{
+		if (libtirpc_debug_level > 3 && log_stderr) {
 			char *ua;
+			int i;
 
 			ua = taddr2uaddr(nconf, &taddr);
-			fprintf(stderr, "Got it [%s]\n", ua);
+			fprintf(stderr, "Got it [%s]\n", ua); 
 			free(ua);
-		}
-#endif
-
-#ifdef ND_DEBUG
-		{
-			int i;
 
 			fprintf(stderr, "\tnetbuf len = %d, maxlen = %d\n",
 				taddr.len, taddr.maxlen);
@@ -391,14 +377,13 @@ getclnthandle(host, nconf, targaddr)
 				fprintf(stderr, "%u.", ((char *)(taddr.buf))[i]);
 			fprintf(stderr, "\n");
 		}
-#endif
+
 		client = clnt_tli_create(RPC_ANYFD, nconf, &taddr,
 		    (rpcprog_t)RPCBPROG, (rpcvers_t)RPCBVERS4, 0, 0);
-#ifdef ND_DEBUG
 		if (! client) {
-			clnt_pcreateerror("rpcbind clnt interface");
+			LIBTIRPC_DEBUG(1, ("getclnthandle: %s", 
+				clnt_spcreateerror("clnt_tli_create failed")));
 		}
-#endif
 
 		if (client) {
 			tmpaddr = targaddr ? taddr2uaddr(nconf, &taddr) : NULL;
@@ -641,13 +626,8 @@ got_entry(relp, nconf)
 		    (nconf->nc_semantics == rmap->r_nc_semantics) &&
 		    (rmap->r_maddr != NULL) && (rmap->r_maddr[0] != 0)) {
 			na = uaddr2taddr(nconf, rmap->r_maddr);
-#ifdef ND_DEBUG
-			fprintf(stderr, "\tRemote address is [%s].\n",
-				rmap->r_maddr);
-			if (!na)
-				fprintf(stderr,
-				    "\tCouldn't resolve remote address!\n");
-#endif
+			LIBTIRPC_DEBUG(3, ("got_entry: Remote address is [%s] %s", 
+				rmap->r_maddr, (na ? "Resolvable" : "Not Resolvable")));
 			break;
 		}
 	}
@@ -875,12 +855,9 @@ try_rpcbind:
 				goto error;
 			}
 			address = uaddr2taddr(nconf, ua);
-#ifdef ND_DEBUG
-			fprintf(stderr, "\tRemote address is [%s]\n", ua);
-			if (!address)
-				fprintf(stderr,
-					"\tCouldn't resolve remote address!\n");
-#endif
+			LIBTIRPC_DEBUG(3, ("__rpcb_findaddr_timed: Remote address is [%s] %s", 
+				ua, (address ? "Resolvable" : "Not Resolvable")));
+
 			xdr_free((xdrproc_t)xdr_wrapstring,
 			    (char *)(void *)&ua);
 
-- 
1.9.3

