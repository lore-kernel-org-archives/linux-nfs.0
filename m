From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] mount.nfs: get_socket() may clobber errno,
	but preserves .re_errno
Date: Fri, 03 Aug 2007 13:24:00 -0400
Message-ID: <20070803172359.3357.77791.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0sb-0001xR-RT
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:03 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0se-0000Zw-3J
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:04 -0700
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

get_socket() guarantees that rpc_createerr.cf_error.re_errno is set
correctly after an error, but it can wipe errno if it has to print an error
message.  Make sure that clnt_ping() checks the correct error code when
get_socket() returns.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 132ff1e..5a56c23 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -310,19 +310,11 @@ static unsigned short getport(struct sockaddr_in *saddr,
 
 	saddr->sin_port = htons(PMAPPORT);
 
-	/*
-	 * Try to get a socket with a non-privileged port.
-	 * clnt*create() will create one anyway if this
-	 * fails.
-	 */
 	socket = get_socket(saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
 	if (socket == RPC_ANYSOCK) {
-		if (proto == IPPROTO_TCP && errno == ETIMEDOUT) {
-			/*
-			 * TCP SYN timed out, so exit now.
-			 */
+		if (proto == IPPROTO_TCP &&
+		    rpc_createerr.cf_error.re_errno == ETIMEDOUT)
 			rpc_createerr.cf_stat = RPC_TIMEDOUT;
-		}
 		return 0;
 	}
 
@@ -660,10 +652,10 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	static char clnt_res;
 	struct sockaddr dissolve;
 
-	rpc_createerr.cf_stat = stat = errno = 0;
+	rpc_createerr.cf_stat = stat = 0;
 	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
 	if (sock == RPC_ANYSOCK) {
-		if (errno == ETIMEDOUT) {
+		if (rpc_createerr.cf_error.re_errno == ETIMEDOUT) {
 			/*
 			 * TCP timeout. Bubble up the error to see 
 			 * how it should be handled.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
