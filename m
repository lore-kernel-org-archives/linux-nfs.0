From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] race in deleting sockets.
Date: Wed, 20 Nov 2002 21:09:26 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021120.210926.52171897.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ETp9-0002E9-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Nov 2002 04:19:19 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Hello Neil,

I just realized another race problem.

svc_delete_socket() may break some queues.
Two or more threads are allowed to access the same socket at the
same time. Each of the them may call svc_delete_socket() so that
some of linked lists will be unlinked several times and might
cause oops.

And it's too bad that some of them might call svc_sock_enqueue()
to enqueue SK_DEAD sockets. It's bad to try to shuffle SK_TEMP
and SK_DEAD sockets either.

Thank you,
Hirokazu Takahashi.


--- net/sunrpc/svcsock.c.DELE	Wed Nov 20 18:16:25 2030
+++ net/sunrpc/svcsock.c	Wed Nov 20 20:09:48 2030
@@ -144,6 +144,12 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		goto out_unlock;
 	}
 
+	if (test_bit(SK_DEAD, &svsk->sk_flags)) {
+		/* Don't enqueue dead sockets */
+		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
+		goto out_unlock;
+	}
+
 	if (((svsk->sk_reserved + serv->sv_bufsz)*2
 	     > sock_wspace(svsk->sk_sk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
@@ -1179,8 +1185,10 @@ svc_recv(struct svc_serv *serv, struct s
 	if (test_bit(SK_TEMP, &svsk->sk_flags)) {
 		/* push active sockets to end of list */
 		spin_lock_bh(&serv->sv_lock);
-		list_del(&svsk->sk_list);
-		list_add_tail(&svsk->sk_list, &serv->sv_tempsocks);
+		if (test_bit(SK_TEMP, &svsk->sk_flags)) {
+			list_del(&svsk->sk_list);
+			list_add_tail(&svsk->sk_list, &serv->sv_tempsocks);
+		}
 		spin_unlock_bh(&serv->sv_lock);
 	}
 
@@ -1371,14 +1379,19 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	spin_lock_bh(&serv->sv_lock);
 
-	list_del(&svsk->sk_list);
-	if (test_bit(SK_TEMP, &svsk->sk_flags))
-		serv->sv_tmpcnt--;
-	if (test_bit(SK_QUED, &svsk->sk_flags))
-		list_del(&svsk->sk_ready);
-
+	if (!test_bit(SK_DEAD, &svsk->sk_flags)) {
+		list_del(&svsk->sk_list);
+		if (test_bit(SK_TEMP, &svsk->sk_flags)) {
+			serv->sv_tmpcnt--;
+			clear_bit(SK_TEMP, &svsk->sk_flags);
+		}
+		if (test_bit(SK_QUED, &svsk->sk_flags)) {
+			list_del(&svsk->sk_ready);
+			clear_bit(SK_QUED, &svsk->sk_flags);
+		}
 
-	set_bit(SK_DEAD, &svsk->sk_flags);
+		set_bit(SK_DEAD, &svsk->sk_flags);
+	}
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
