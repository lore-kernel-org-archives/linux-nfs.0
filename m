From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/23] mount.nfs: fix hang when getport() uses TCP
	against	unavailable servers
Date: Sat, 28 Jul 2007 17:50:19 -0400
Message-ID: <20070728215019.21871.74142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOl-0003dx-Nj
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:33:59 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOp-0003me-GV
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:03 -0700
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

If get_socket() can't get us an open TCP socket, we know the server is
down, so make  getport() exit early instead of hanging.  This logic is
copied from clnt_ping().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 21cf4ef..5653302 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -135,8 +135,23 @@ unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
 	struct pmap parms;
 	enum clnt_stat stat;
 
-	saddr->sin_port = htons (PMAPPORT);
-	socket = get_socket(saddr, prot, FALSE, FALSE);
+	saddr->sin_port = htons(PMAPPORT);
+
+	/*
+	 * Try to get a socket with a non-privileged port.
+	 * clnt*create() will create one anyway if this
+	 * fails.
+	 */
+	socket = get_socket(saddr, proto, FALSE, FALSE);
+	if (socket == RPC_ANYSOCK) {
+		if (proto == IPPROTO_TCP && errno == ETIMEDOUT) {
+			/*
+			 * TCP SYN timed out, so exit now.
+			 */
+			rpc_createerr.cf_stat = RPC_TIMEDOUT;
+		}
+		return 0;
+	}
 
 	switch (prot) {
 	case IPPROTO_UDP:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
