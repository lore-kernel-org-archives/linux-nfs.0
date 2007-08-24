From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/9] mount.nfs: Create a new API to find out client's
	address
Date: Fri, 24 Aug 2007 13:11:38 -0400
Message-ID: <20070824171137.10418.38097.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOch9-0003wC-Pp
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:40 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOchE-000246-0c
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:44 -0700
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

Provide a version of clnt_ping() that discovers the client's address, but
doesn't do an RPC ping.  The in-kernel text-based mount code already does
a ping, so all we need here is address discovery.

As well, add a block comment in front of clnt_ping() that hopefully
elucidates the differences.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    1 +
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 9f803a4..16b802d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -642,10 +642,23 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
 }
 
 /*
+ * clnt_ping - send an RPC ping to the remote RPC service endpoint
+ * @saddr: server's address
+ * @prog: target RPC program number
+ * @vers: target RPC version number
+ * @prot: target RPC protocol
+ * @caddr: filled in with our network address
+ *
  * Sigh... getport() doesn't actually check the version number.
  * In order to make sure that the server actually supports the service
  * we're requesting, we open and RPC client, and fire off a NULL
  * RPC call.
+ *
+ * caddr is the network address that the server will use to call us back.
+ * On multi-homed clients, this address depends on which NIC we use to
+ * route requests to the server.
+ *
+ * Returns one if successful, otherwise zero.
  */
 int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 		const unsigned long vers, const unsigned int prot,
@@ -715,3 +728,36 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	else
 		return 0;
 }
+
+/*
+ * get_client_address - acquire our local network address
+ * @saddr: server's address
+ * @caddr: filled in with our network address
+ *
+ * Discover a network address that the server will use to call us back.
+ * On multi-homed clients, this address depends on which NIC we use to
+ * route requests to the server.
+ *
+ * Use a connected datagram socket so as not to leave a socket in TIME_WAIT.
+ *
+ * Returns one if successful, otherwise zero.
+ */
+int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
+{
+	socklen_t len = sizeof(*caddr);
+	int socket, err;
+
+	socket = get_socket(saddr, IPPROTO_UDP, CONNECT_TIMEOUT, FALSE, TRUE);
+	if (socket == RPC_ANYSOCK)
+		return 0;
+
+	err = getsockname(socket, caddr, &len);
+	close(socket);
+
+	if (err && verbose) {
+		nfs_error(_("%s: getsockname failed: %s"),
+				progname, strerror(errno));
+		return 0;
+	}
+	return 1;
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 2e4dbbc..99ecc1e 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -48,6 +48,7 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
