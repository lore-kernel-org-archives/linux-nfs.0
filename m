From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 7 - Remove irrelevant warning in svc_write_space
Date: Tue, 17 Dec 2002 12:59:27 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18O715-0000p3-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O71O-0003nj-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 17:59:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 12:59:36 +1100
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



tcp recv_msg sometimes activates the socket waitqueue
even though it isn't actually going to wait.
So printing out a warning message when the
waitqueue appears active is not appropriate now that
we support TCP.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2002-12-16 16:29:42.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2002-12-16 16:29:42.000000000 +1100
@@ -461,11 +461,8 @@ svc_write_space(struct sock *sk)
 		svc_sock_enqueue(svsk);
 	}
 
-	if (sk->sleep && waitqueue_active(sk->sleep)) {
-		printk(KERN_WARNING "RPC svc_write_space: some sleeping on %p\n",
-		       svsk);
+	if (sk->sleep && waitqueue_active(sk->sleep))
 		wake_up_interruptible(sk->sleep);
-	}
 }
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
