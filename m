From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] disable Nagle's algorithm for RPC over TCP sockets
Date: Wed, 2 Oct 2002 15:55:21 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0210021552540.2050-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>

hi Linus-

please apply this patch to 2.5.40.  it disables Nagle's algorithm for TCP 
sockets used by the RPC client.  other RPC implementations on TCP also 
disable Nagle.  this reduces average RPC request latency on TCP, and makes 
network trace tools work a little nicer.

trond, alexey, and davem are all OK with this patch.

diff -drN -U2 01-iip/net/sunrpc/xprt.c 02-nagle/net/sunrpc/xprt.c
--- 01-iip/net/sunrpc/xprt.c	Fri Sep 27 17:50:23 2002
+++ 02-nagle/net/sunrpc/xprt.c	Tue Oct  1 10:59:06 2002
@@ -1447,4 +1447,6 @@
 		xprt_set_connected(xprt);
 	} else {
+		struct tcp_opt *tp = tcp_sk(sk);
+		tp->nonagle = 1;	/* disable Nagle's algorithm */
 		sk->data_ready = tcp_data_ready;
 		sk->state_change = tcp_state_change;

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>
