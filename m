From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] sock_writeable not appropriate for TCP sockets, for 2.4.20
Date: Fri, 30 Aug 2002 16:51:57 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208301648230.1645-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kskR-0005gq-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 13:52:07 -0700
To: marcelo@plucky.distro.conectiva
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi marcelo-

sock_writeable determines whether there is space in a socket's output
buffer.  socket write_space callbacks use it to determine whether to wake
up those that are waiting for more output buffer space.

however, sock_writeable is not appropriate for TCP sockets.  because the
RPC layer's write_space callback uses it for TCP sockets, the RPC layer
hammers on sock_sendmsg with dozens of write requests that are only a few
hundred bytes long when it is trying to send a large write RPC request.
this patch adds logic to the RPC layer's write_space callback that 
properly handles TCP sockets.

patch reviewed by Trond and Alexey.  patch already sent to linus for 2.5.


--- 2.4.20-pre5/net/sunrpc/xprt.c.orig	Fri Aug 30 15:49:28 2002
+++ 2.4.20-pre5/net/sunrpc/xprt.c	Fri Aug 30 15:52:55 2002
@@ -950,6 +950,8 @@
 
 /*
- * The following 2 routines allow a task to sleep while socket memory is
- * low.
+ * Called when more output buffer space is available for this socket.
+ * We try not to wake our writers until they can make "significant"
+ * progress, otherwise we'll waste resources thrashing sock_sendmsg
+ * with a bunch of small requests.
  */
 static void
@@ -965,6 +967,13 @@
 
 	/* Wait until we have enough socket memory */
-	if (!sock_writeable(sk))
-		return;
+	if (xprt->stream) {
+		/* from net/ipv4/tcp.c:tcp_write_space */
+		if (tcp_wspace(sk) < tcp_min_write_space(sk))
+			return;
+	} else {
+		/* from net/core/sock.c:sock_def_write_space */
+		if (!sock_writeable(sk))
+			return;
+	}
 
 	if (!test_and_clear_bit(SOCK_NOSPACE, &sock->flags))

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
