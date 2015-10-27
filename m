Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbbJ0KXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2015 06:23:33 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] SUNRPC: drop stale comment in svc_setup_socket()
Date: Tue, 27 Oct 2015 10:23:30 +0000
Message-Id: <1445941410-28270-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since 9660439861aa8dbd5e2b8087f33e20760c2c9afc ("svcrpc: take advantage
of tcp autotuning") the svc_setup_socket() function does set the send
and receive buffer sizes so the comment is out-of-date:

  /* initialise setting must have enough space to
   * receive and respond to one request.
   */
  svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
                                     4 * serv->sv_max_mesg);

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0c81202..c7157eb 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1367,7 +1367,6 @@ EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
 
 /*
  * Initialize socket for RPC use and create svc_sock struct
- * XXX: May want to setsockopt SO_SNDBUF and SO_RCVBUF.
  */
 static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 						struct socket *sock,
-- 
2.4.3

