From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] mount.nfs: getport() should avoid modifying
	passed-in	arguments
Date: Tue, 21 Aug 2007 12:19:13 -0400
Message-ID: <20070821161913.4373.3231.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INWRn-0003T5-AZ
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:15 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INWRr-0000bs-H0
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:19 -0700
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

Defensive coding: getport() shouldn't alter the passed-in server address,
but should treat it as read only.  Have it operate on a copy.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index eb59c1f..9f803a4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -303,14 +303,16 @@ static unsigned short getport(struct sockaddr_in *saddr,
 				unsigned long version,
 				unsigned int proto)
 {
+	struct sockaddr_in bind_saddr;
 	unsigned short port = 0;
 	int socket;
 	CLIENT *clnt = NULL;
 	enum clnt_stat stat;
+ 
+	bind_saddr = *saddr;
+	bind_saddr.sin_port = htons(PMAPPORT);
 
-	saddr->sin_port = htons(PMAPPORT);
-
-	socket = get_socket(saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
+	socket = get_socket(&bind_saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
 	if (socket == RPC_ANYSOCK) {
 		if (proto == IPPROTO_TCP &&
 		    rpc_createerr.cf_error.re_errno == ETIMEDOUT)
@@ -320,14 +322,16 @@ static unsigned short getport(struct sockaddr_in *saddr,
 
 	switch (proto) {
 	case IPPROTO_UDP:
-		clnt = clntudp_bufcreate(saddr,
+		clnt = clntudp_bufcreate(&bind_saddr,
 					 PMAPPROG, PMAPVERS,
 					 RETRY_TIMEOUT, &socket,
 					 RPCSMALLMSGSIZE,
 					 RPCSMALLMSGSIZE);
 		break;
 	case IPPROTO_TCP:
-		clnt = clnttcp_create(saddr, PMAPPROG, PMAPVERS, &socket,
+		clnt = clnttcp_create(&bind_saddr,
+				      PMAPPROG, PMAPVERS,
+				      &socket,
 				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
 		break;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
