From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/23] mount.nfs: use nfs_error instead of fprintf
	in	get_socket()
Date: Sat, 28 Jul 2007 17:50:50 -0400
Message-ID: <20070728215050.21871.64557.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOp-0003gF-5v
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:03 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOs-0003sP-VG
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:07 -0700
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

Use nfs_error() where appropriate.  I used "goto" here to reduce string
splitting and indenting past the point of readability.  Gee, it would be
nice if C had proper exception handling...

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |  100 ++++++++++++++++++++++++++-----------------------
 1 files changed, 53 insertions(+), 47 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 4831990..af37ef6 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -171,64 +171,70 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 	socklen_t namelen = sizeof(laddr);
 
 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket (AF_INET, type, p_prot)) < 0) {
-		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-		rpc_createerr.cf_error.re_errno = errno;
-		if (verbose) {
-			fprintf(stderr, 
-				"mount: Unable to create %s socket: errno %d (%s)\n",
-				p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-				errno, strerror(errno));
-		}
-		return RPC_ANYSOCK;
-	}
+	if ((so = socket (AF_INET, type, p_prot)) < 0)
+		goto err_socket;
+
 	laddr.sin_family = AF_INET;
 	laddr.sin_port = 0;
 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
-		if (bindresvport(so, &laddr) < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to bindresvport %s socket: errno %d (%s)\n",
-					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
+		if (bindresvport(so, &laddr) < 0)
+			goto err_bindresvport;
 	} else {
 		cc = bind(so, (struct sockaddr *)&laddr, namelen);
-		if (cc < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to bind to %s socket: errno %d (%s)\n",
-					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
+		if (cc < 0)
+			goto err_bind;
 	}
 	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
 		cc = connect(so, (struct sockaddr *)saddr, namelen);
-		if (cc < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to connect to %s:%d, errno %d (%s)\n",
-					inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port),
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
+		if (cc < 0)
+			goto err_connect;
 	}
 	return so;
+
+err_socket:
+	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	rpc_createerr.cf_error.re_errno = errno;
+	if (verbose) {
+		nfs_error(_("%s: Unable to create %s socket: errno %d (%s)\n"),
+			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
+			errno, strerror(errno));
+	}
+	return RPC_ANYSOCK;
+
+err_bindresvport:
+	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	rpc_createerr.cf_error.re_errno = errno;
+	if (verbose) {
+		nfs_error(_("%s: Unable to bindresvport %s socket: errno %d"
+				" (%s)\n"),
+			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
+			errno, strerror(errno));
+	}
+	close(so);
+	return RPC_ANYSOCK;
+
+err_bind:
+	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	rpc_createerr.cf_error.re_errno = errno;
+	if (verbose) {
+		nfs_error(_("%s: Unable to bind to %s socket: errno %d (%s)\n"),
+			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
+			errno, strerror(errno));
+	}
+	close(so);
+	return RPC_ANYSOCK;
+
+err_connect:
+	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	rpc_createerr.cf_error.re_errno = errno;
+	if (verbose) {
+		nfs_error(_("%s: Unable to connect to %s:%d, errno %d (%s)\n"),
+			progname, inet_ntoa(saddr->sin_addr),
+			ntohs(saddr->sin_port), errno, strerror(errno));
+	}
+	close(so);
+	return RPC_ANYSOCK;
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
