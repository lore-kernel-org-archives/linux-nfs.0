From: Neil Brown <neilb@suse.de>
Subject: Re: [Fwd: Re: [2/3] 2.6.23-rc2: known regressions v2]
Date: Thu, 9 Aug 2007 09:53:19 +1000
Message-ID: <18106.22383.551248.118418@notabene.brown>
References: <1186594872.6699.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIvLP-00072v-Ed
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 16:53:39 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIvLT-0004iR-44
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 16:53:43 -0700
In-Reply-To: message from Trond Myklebust on Wednesday August 8
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

On Wednesday August 8, Trond.Myklebust@netapp.com wrote:
> Re: the nfsd problem. Shouldn't svc_force_close_socket() be taking the
> serv->sv_lock in order to prevent races with svc_sock_enqueue()?

The theory is that at this time there should be no active server
threads. So the worst svc_sock_enqueue could do would be to queue the
socket to a pool->sp_sockets.  And as the socket and the queue are
both about to be destroyed, that hardly matters.

However the 'theory' doesn't quite match practice.  A new thread can
be started before svc_force_close_socket finishes up.  I think the
race we need to deal with is between the last thread exiting and a new
thread being started.  Whether we provide an interlock to exclude the
possibility, or a fine grained lock so it looks like we never actually
got to zero threads, I'm not sure yet.

> 
> Also, how is the server attempting to prevent races between
> svc_sock_put() and the socket callbacks (->sk_data_ready,
> ->sk_write_space,...)?

Presumably the network code ensure that after sock_release has been
called, no further callbacks will be made (or in process)??
If not, we probably should leverage sk_destruct to delay freeing of
svsk until the network layer is completely done with the socket.

This patch might do that, but I haven't tested it at all.

Would it answer your concerns?

NeilBrown


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    1 +
 ./net/sunrpc/svcsock.c           |   26 ++++++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2007-08-09 09:42:43.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2007-08-09 09:42:58.000000000 +1000
@@ -50,6 +50,7 @@ struct svc_sock {
 	void			(*sk_ostate)(struct sock *);
 	void			(*sk_odata)(struct sock *, int bytes);
 	void			(*sk_owspace)(struct sock *);
+	void			(*sk_odestruct)(struct sock *);
 
 	/* private TCP part */
 	int			sk_reclen;	/* length of record */

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-08-09 09:43:06.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2007-08-09 09:51:32.000000000 +1000
@@ -379,16 +379,24 @@ svc_sock_put(struct svc_sock *svsk)
 		BUG_ON(! test_bit(SK_DEAD, &svsk->sk_flags));
 
 		dprintk("svc: releasing dead socket\n");
+		if (svsk->sk_info_authunix != NULL)
+			svcauth_unix_info_release(svsk->sk_info_authunix);
 		if (svsk->sk_sock->file)
 			sockfd_put(svsk->sk_sock);
 		else
 			sock_release(svsk->sk_sock);
-		if (svsk->sk_info_authunix != NULL)
-			svcauth_unix_info_release(svsk->sk_info_authunix);
-		kfree(svsk);
 	}
 }
 
+static void svsk_destruct(struct sock *sk)
+{
+	struct svc_sock *svsk = sk->sk_user_data;
+	sk->destruct = svsk->sk_odestruct;
+	sk->sk_user_data = NULL;
+	kfree(svsk);
+	sk->destruct(sk);
+}	
+
 static void
 svc_sock_release(struct svc_rqst *rqstp)
 {
@@ -1656,7 +1664,9 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
+	svsk->sk_odestruct = inet->sk_destruct;
 	svsk->sk_server = serv;
+	inet->sk_destruct = svsk_destruct;
 	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
