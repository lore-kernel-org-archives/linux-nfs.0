From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/17] text-based mount: support IPv6 addresses in
	get_client_address() function
Date: Mon, 18 Feb 2008 13:36:27 -0500
Message-ID: <20080218183627.19060.18148.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56734 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbYBRSg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:29 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIaRBX019256
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:28 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIaRKs019372
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:27 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 clientaddr= mount option communicates the client's local IP
address to the kernel.  This address is then provided to the server as
the client's callback address.  If the admin doesn't specify a clientaddr=
option, the mount command uses the get_client_address() function to
detect the client's local IP address.

Add support to the get_client_address() function for IPv6 addressing,
and rename the function to identify it as a local API.  Note there's
nothing specific to IPv6 here; we just make the API family-agnostic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   17 ++++++++++-------
 utils/mount/network.h |    2 +-
 utils/mount/stropts.c |    4 +++-
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5e6d17d..6c29e7c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -860,29 +860,32 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 }
 
 /**
- * get_client_address - acquire our local network address
+ * nfs_client_address - acquire our local network address
  * @saddr: server's address
- * @caddr: filled in with our network address
+ * @laddr: filled in with our local network address
+ * @laddr_len: IN: length of buffer to fill in; OUT: length of filled-in address
  *
  * Discover a network address that the server will use to call us back.
  * On multi-homed clients, this address depends on which NIC we use to
  * route requests to the server.
  *
- * Use a connected datagram socket so as not to leave a socket in TIME_WAIT.
+ * A connected datagram socket is used to prevent leaving the socket
+ * in TIME_WAIT, to conserve the ephemeral port number space.  This helps
+ * reduce failed socket binds during mount storms.
  *
  * Returns one if successful, otherwise zero.
  */
-int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
+int nfs_client_address(const struct sockaddr *saddr, struct sockaddr *laddr,
+		       socklen_t *laddr_len)
 {
-	socklen_t len = sizeof(*caddr);
 	int sock, err;
 
-	sock = nfs_getsocket((struct sockaddr *)saddr, IPPROTO_UDP,
+	sock = nfs_getsocket(saddr, IPPROTO_UDP,
 				CONNECT_TIMEOUT, FALSE, TRUE);
 	if (sock == RPC_ANYSOCK)
 		return 0;
 
-	err = getsockname(sock, caddr, &len);
+	err = getsockname(sock, laddr, laddr_len);
 	if (err && verbose)
 		nfs_error(_("%s: error acquiring client's local address: %s"),
 				progname, strerror(errno));
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 99ecc1e..7cabb16 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -48,7 +48,7 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
-int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
+int nfs_client_address(const struct sockaddr *, struct sockaddr *, socklen_t *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cadb1f4..6293766 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -178,12 +178,14 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
 				    struct mount_options *options)
 {
 	struct sockaddr_in my_addr;
+	socklen_t len = sizeof(my_addr);
 	char new_option[32];
 
 	if (po_contains(options, "clientaddr") == PO_SUCCEEDED)
 		return 1;
 
-	if (!get_client_address(saddr, &my_addr))
+	if (!nfs_client_address((struct sockaddr *)saddr,
+				(struct sockaddr *)&my_addr, &len))
 		return 0;
 
 	snprintf(new_option, sizeof(new_option) - 1,

