From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/23] mount.nfs: clean up getport() function
Date: Sat, 28 Jul 2007 17:50:24 -0400
Message-ID: <20070728215024.21871.54208.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOn-0003ea-DJ
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:01 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOr-0005cB-3z
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:05 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Mostly comment clarification.  Also replace some naked undocumented
integers with macros, and make getport() static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   47 ++++++++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5653302..c997c4c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -121,18 +121,22 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 }
 
 /*
- * getport() is very similar to pmap_getport() with
- * the exception this version uses a non-reserve ports
- * instead of reserve ports since reserve ports
- * are not needed for pmap requests.
+ * getport() is very similar to pmap_getport() with the exception that
+ * this version tries to use an ephemeral port, since reserved ports are
+ * not needed for GETPORT queries.  This conserves the very limited
+ * reserved port space, which helps reduce failed socket binds
+ * during mount storms.
+ *
+ * A side effect of calling this function is that rpccreateerr is set.
  */
-unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
-			unsigned long vers, unsigned int prot)
+static unsigned short getport(struct sockaddr_in *saddr,
+				unsigned long program,
+				unsigned long version,
+				unsigned int proto)
 {
 	unsigned short port = 0;
 	int socket;
 	CLIENT *clnt = NULL;
-	struct pmap parms;
 	enum clnt_stat stat;
 
 	saddr->sin_port = htons(PMAPPORT);
@@ -153,25 +157,30 @@ unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
 		return 0;
 	}
 
-	switch (prot) {
+	switch (proto) {
 	case IPPROTO_UDP:
 		clnt = clntudp_bufcreate(saddr,
-					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
-					 UDPMSGSIZE, UDPMSGSIZE);
+					 PMAPPROG, PMAPVERS,
+					 RETRY_TIMEOUT, &socket,
+					 RPCSMALLMSGSIZE,
+					 RPCSMALLMSGSIZE);
 		break;
 	case IPPROTO_TCP:
-		clnt = clnttcp_create(saddr,
-			PMAPPROG, PMAPVERS, &socket, 50, 500);
+		clnt = clnttcp_create(saddr, PMAPPROG, PMAPVERS, &socket,
+				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
 		break;
 	}
 	if (clnt != NULL) {
-		parms.pm_prog = prog;
-		parms.pm_vers = vers;
-		parms.pm_prot = prot;
-		parms.pm_port = 0;    /* not needed or used */
-
-		stat = clnt_call(clnt, PMAPPROC_GETPORT, (xdrproc_t)xdr_pmap,
-			(caddr_t)&parms, (xdrproc_t)xdr_u_short, (caddr_t)&port, TIMEOUT);
+		struct pmap parms = {
+			.pm_prog	= program,
+			.pm_vers	= version,
+			.pm_prot	= proto,
+		};
+
+		stat = clnt_call(clnt, PMAPPROC_GETPORT,
+				 (xdrproc_t)xdr_pmap, (caddr_t)&parms,
+				 (xdrproc_t)xdr_u_short, (caddr_t)&port,
+				 TIMEOUT);
 		if (stat) {
 			clnt_geterr(clnt, &rpc_createerr.cf_error);
 			rpc_createerr.cf_stat = stat;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
