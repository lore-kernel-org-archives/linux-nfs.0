From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] sock_writeable not appropriate for TCP sockets, for 2.5.32
Date: Fri, 30 Aug 2002 14:20:42 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208301413500.7274-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17kqNz-0005Y2-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 11:20:47 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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

hi linus-

sock_writeable determines whether there is space in a socket's output
buffer.  socket write_space callbacks use it to determine whether to wake
up those that are waiting for more output buffer space.

however, sock_writeable is not appropriate for TCP sockets.  because the
RPC layer's write_space callback uses it for TCP sockets, the RPC layer
hammers on sock_sendmsg with dozens of write requests that are only a few
hundred bytes long when it is trying to send a large write RPC request.
this patch adds logic to the RPC layer's write_space callback that 
properly handles TCP sockets.

patch reviewed by Trond and Alexey.  patch forthcoming for 2.4.20-pre.

diff -drN -U2 01-lock_write/net/sunrpc/xprt.c 02-write_space/net/sunrpc/xprt.c
--- 01-lock_write/net/sunrpc/xprt.c	Wed Aug 28 17:09:08 2002
+++ 02-write_space/net/sunrpc/xprt.c	Wed Aug 28 17:18:14 2002
@@ -957,6 +957,8 @@
 
 /*
- * The following 2 routines allow a task to sleep while socket memory is
- * low.
+ * Called when more output buffer space is available for this socket.
+ * We try not to wake our writers until they can make "significant"
+ * progress, otherwise we'll waste resources thrashing sock_sendmsg
+ * with a bunch of small requests.
  */
 static void
@@ -972,6 +974,13 @@
 
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
