From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with TCP and 2.4.20-pre4
Date: 28 Aug 2002 20:58:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65xuzu7m.fsf@charged.uio.no>
References: <200208281638.g7SGc7V19149@roma.math.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17k81N-0006V8-00
	for <nfs@lists.sourceforge.net>; Wed, 28 Aug 2002 11:58:29 -0700
To: Andrew Schretter <schrett@math.duke.edu>
In-Reply-To: <200208281638.g7SGc7V19149@roma.math.duke.edu>
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

>>>>> " " == Andrew Schretter <schrett@math.duke.edu> writes:

     > Perhaps I'm just a bit confused with what patches are still
     > applicable and what are applied now that there has been a big
     > merge into the 2.4.20 pre series, but I'm having a big problem
     > with TCP mounting when the server is running 2.4.20-pre4.

Do you perhaps see the message

  svc: socket blah no space, 65536, not enqueued

in the server's syslog?

If so, Neil should have a fix that was merged into 2.5.x
recently. I've appended it below...

Cheers,
  Trond

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.485.7.14 -> 1.485.7.15
#	net/sunrpc/svcsock.c	1.22    -> 1.23   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/23	neilb@cse.unsw.edu.au	1.485.7.15
# [PATCH] call svc_sock_setbufsize when socket created.
# 
# bufsiz is re-evaluated on recv if SK_CHNGBUF is set,
# but recv will never be reached if the buffers are too small.
# So we have to set to to something vaguely reasonable
# at init time.
# --------------------------------------------
#
diff -Nru a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
--- a/net/sunrpc/svcsock.c	Wed Aug 28 20:56:54 2002
+++ b/net/sunrpc/svcsock.c	Wed Aug 28 20:56:54 2002
@@ -574,6 +574,14 @@
 	svsk->sk_recvfrom = svc_udp_recvfrom;
 	svsk->sk_sendto = svc_udp_sendto;
 
+	/* initialise setting must have enough space to
+	 * receive and respond to one request.  
+	 * svc_udp_recvfrom will re-adjust if necessary
+	 */
+	svc_sock_setbufsize(svsk->sk_sock,
+			    3 * svsk->sk_server->sv_bufsz,
+			    3 * svsk->sk_server->sv_bufsz);
+
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
 
 	return 0;
@@ -945,6 +953,14 @@
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
+
+		/* initialise setting must have enough space to
+		 * receive and respond to one request.  
+		 * svc_tcp_recvfrom will re-adjust if necessary
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    3 * svsk->sk_server->sv_bufsz,
+				    3 * svsk->sk_server->sv_bufsz);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 	}


-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
