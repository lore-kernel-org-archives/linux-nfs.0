From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/14] text-based mount command: Remove unused IPv4-only
	functions
Date: Wed, 09 Jul 2008 20:38:05 -0400
Message-ID: <20080710003804.6137.34360.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12566 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbYGJEIQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:16 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove unused IPv4-only functions used by the text-based mount
command.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   33 ---------------------------------
 utils/mount/network.h |    1 -
 utils/mount/stropts.c |   20 --------------------
 3 files changed, 0 insertions(+), 54 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 128d7f7..0c2bb23 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -886,39 +886,6 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 		return 0;
 }
 
-/**
- * get_client_address - acquire our local network address
- * @saddr: server's address
- * @caddr: filled in with our network address
- *
- * Discover a network address that the server will use to call us back.
- * On multi-homed clients, this address depends on which NIC we use to
- * route requests to the server.
- *
- * Use a connected datagram socket so as not to leave a socket in TIME_WAIT.
- *
- * Returns one if successful, otherwise zero.
- */
-int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
-{
-	socklen_t len = sizeof(*caddr);
-	int socket, err;
-
-	socket = get_socket(saddr, IPPROTO_UDP, CONNECT_TIMEOUT, FALSE, TRUE);
-	if (socket == RPC_ANYSOCK)
-		return 0;
-
-	err = getsockname(socket, caddr, &len);
-	close(socket);
-
-	if (err && verbose) {
-		nfs_error(_("%s: getsockname failed: %s"),
-				progname, strerror(errno));
-		return 0;
-	}
-	return 1;
-}
-
 /*
  * Try a getsockname() on a connected datagram socket.
  *
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 2f4ff3a..544ac93 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -57,7 +57,6 @@ int nfs_string_to_sockaddr(const char *, const size_t,
 			   struct sockaddr *, socklen_t *);
 int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);
-int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
 int nfs_callback_address(const struct sockaddr *, const socklen_t,
 		struct sockaddr *, socklen_t *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c4f2326..a51cf0b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -99,26 +99,6 @@ struct nfsmount_info {
 	sa_family_t		family;		/* supported address family */
 };
 
-static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
-{
-	struct hostent *hp;
-	addr->sin_family = AF_INET;
-
-	if (inet_aton(hostname, &addr->sin_addr))
-		return 1;
-	if ((hp = gethostbyname(hostname)) == NULL) {
-		nfs_error(_("%s: can't get address for %s\n"),
-				progname, hostname);
-		return 0;
-	}
-	if (hp->h_length > sizeof(struct in_addr)) {
-		nfs_error(_("%s: got bad hp->h_length"), progname);
-		hp->h_length = sizeof(struct in_addr);
-	}
-	memcpy(&addr->sin_addr, hp->h_addr, hp->h_length);
-	return 1;
-}
-
 /*
  * Obtain a retry timeout value based on the value of the "retry=" option.
  *

