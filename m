From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 005 of 5] Code cleanups in calbacks in svcsock.
Date: Mon, 12 Sep 2005 16:25:42 +1000
Message-ID: <1050912062542.4020@cse.unsw.edu.au>
References: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlG-0005MA-It
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:50 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlF-0007m0-WB
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:50 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Change a printk(KERN_WARNING to dprintk, and it is really only interesting
when trying to debug a problem, and can occur normally without error.

Remove various gratuitous gotos in surrounding code, and remove
some type-cast assignments from inside 'if' conditionals,
as that is just obscuring what it going on.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   83 +++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 44 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2005-09-12 16:09:09.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2005-09-12 16:12:29.000000000 +1000
@@ -512,15 +512,14 @@ svc_sock_setbufsize(struct socket *sock,
 static void
 svc_udp_data_ready(struct sock *sk, int count)
 {
-	struct svc_sock	*svsk = (struct svc_sock *)(sk->sk_user_data);
+	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
-	if (!svsk)
-		goto out;
-	dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
-		svsk, sk, count, test_bit(SK_BUSY, &svsk->sk_flags));
-	set_bit(SK_DATA, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
- out:
+	if (svsk) {
+		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
+			svsk, sk, count, test_bit(SK_BUSY, &svsk->sk_flags));
+		set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_enqueue(svsk);
+	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
 }
@@ -540,7 +539,7 @@ svc_write_space(struct sock *sk)
 	}
 
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
-		printk(KERN_WARNING "RPC svc_write_space: some sleeping on %p\n",
+		dprintk("RPC svc_write_space: someone sleeping on %p\n",
 		       svsk);
 		wake_up_interruptible(sk->sk_sleep);
 	}
@@ -689,31 +688,29 @@ svc_udp_init(struct svc_sock *svsk)
 static void
 svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
 {
-	struct svc_sock	*svsk;
+	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
 	dprintk("svc: socket %p TCP (listen) state change %d\n",
-			sk, sk->sk_state);
+		sk, sk->sk_state);
 
-	if  (sk->sk_state != TCP_LISTEN) {
-		/*
-		 * This callback may called twice when a new connection
-		 * is established as a child socket inherits everything
-		 * from a parent LISTEN socket.
-		 * 1) data_ready method of the parent socket will be called
-		 *    when one of child sockets become ESTABLISHED.
-		 * 2) data_ready method of the child socket may be called
-		 *    when it receives data before the socket is accepted.
-		 * In case of 2, we should ignore it silently.
-		 */
-		goto out;
-	}
-	if (!(svsk = (struct svc_sock *) sk->sk_user_data)) {
-		printk("svc: socket %p: no user data\n", sk);
-		goto out;
+	/*
+	 * This callback may called twice when a new connection
+	 * is established as a child socket inherits everything
+	 * from a parent LISTEN socket.
+	 * 1) data_ready method of the parent socket will be called
+	 *    when one of child sockets become ESTABLISHED.
+	 * 2) data_ready method of the child socket may be called
+	 *    when it receives data before the socket is accepted.
+	 * In case of 2, we should ignore it silently.
+	 */
+	if  (sk->sk_state == TCP_LISTEN) {
+		if (svsk) {
+			set_bit(SK_CONN, &svsk->sk_flags);
+			svc_sock_enqueue(svsk);
+		} else
+			printk("svc: socket %p: no user data\n", sk);
 	}
-	set_bit(SK_CONN, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
- out:
+
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_all(sk->sk_sleep);
 }
@@ -724,18 +721,17 @@ svc_tcp_listen_data_ready(struct sock *s
 static void
 svc_tcp_state_change(struct sock *sk)
 {
-	struct svc_sock	*svsk;
+	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 
 	dprintk("svc: socket %p TCP (connected) state change %d (svsk %p)\n",
-			sk, sk->sk_state, sk->sk_user_data);
+		sk, sk->sk_state, sk->sk_user_data);
 
-	if (!(svsk = (struct svc_sock *) sk->sk_user_data)) {
+	if (!svsk)
 		printk("svc: socket %p: no user data\n", sk);
-		goto out;
+	else {
+		set_bit(SK_CLOSE, &svsk->sk_flags);
+		svc_sock_enqueue(svsk);
 	}
-	set_bit(SK_CLOSE, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
- out:
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_all(sk->sk_sleep);
 }
@@ -743,15 +739,14 @@ svc_tcp_state_change(struct sock *sk)
 static void
 svc_tcp_data_ready(struct sock *sk, int count)
 {
-	struct svc_sock *	svsk;
+	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
 
 	dprintk("svc: socket %p TCP data ready (svsk %p)\n",
-			sk, sk->sk_user_data);
-	if (!(svsk = (struct svc_sock *)(sk->sk_user_data)))
-		goto out;
-	set_bit(SK_DATA, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
- out:
+		sk, sk->sk_user_data);
+	if (svsk) {
+		set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_enqueue(svsk);
+	}
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep);
 }


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
