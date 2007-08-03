From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] mount.nfs: Always close the socket at the end
	of	getport()
Date: Fri, 03 Aug 2007 13:23:54 -0400
Message-ID: <20070803172354.3357.95372.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0sW-0001x0-RO
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:56 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sa-0007go-ME
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:00 -0700
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

These days, none of get_socket()'s callers pass an RPC_ANYSOCK on to the
RPC code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 89cb976..132ff1e 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -210,9 +210,9 @@ out:
 }
 
 /*
- * Create a socket that is locally bound to a reserved or non-reserved
- * port. For any failures, RPC_ANYSOCK is returned which will cause 
- * the RPC code to create the socket instead. 
+ * Create a socket that is locally bound to a reserved or non-reserved port.
+ *
+ * The caller should check rpc_createerr to determine the cause of any error.
  */
 static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 			unsigned int timeout, int resvp, int conn)
@@ -360,8 +360,7 @@ static unsigned short getport(struct sockaddr_in *saddr,
 		else if (port == 0)
 			rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
 	}
-	if (socket != 1)
-		close(socket);
+	close(socket);
 
 	return port;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
