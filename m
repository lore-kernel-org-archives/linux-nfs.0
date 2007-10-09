From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 3/7] svc: Move setting of XPT_LISTENER bit to svc_tcp_init
Date: Tue, 09 Oct 2007 10:37:13 -0500
Message-ID: <20071009153713.18846.17462.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH90-0005ez-9F
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:15 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH95-00088U-BJ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:19 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
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


Move the setting of the XPT_LISTENER bit to svc_tcp_init where 
the remaining TCP transport initializiation is done.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f967c23..07a6f42 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1128,6 +1128,7 @@ svc_tcp_init(struct svc_sock *svsk, stru
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
+		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
 		set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 	} else {
@@ -1253,8 +1254,6 @@ int svc_addsock(struct svc_serv *serv,
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
-		if (so->sk->sk_protocol == IPPROTO_TCP)
-			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
 		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
 		spin_lock_bh(&serv->sv_lock);
 		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
@@ -1311,8 +1310,6 @@ svc_create_socket(struct svc_serv *serv,
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
-		if (protocol == IPPROTO_TCP)
-			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
