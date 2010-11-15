Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42906 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756197Ab0KOA2B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Nov 2010 19:28:01 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 15 Nov 2010 11:27:01 +1100
Subject: [PATCH 2/2] sunrpc: svc_sock_names should hold ref to socket being
	closed.
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20101115002701.19121.99158.stgit@notabene.brown>
In-Reply-To: <20101115002634.19121.7027.stgit@notabene.brown>
References: <20101115002634.19121.7027.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently svc_sock_names calls svc_close_xprt on a svc_sock to
which it does not own a reference.
As soon as svc_close_xprt sets XPT_CLOSE, the socket could be
freed by a separate thread (though this is a very unlikely race).

It is safer to hold a reference while calling svc_close_xprt.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/svcsock.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 07919e1..52bd113 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -324,19 +324,21 @@ int svc_sock_names(struct svc_serv *serv, char *buf, const size_t buflen,
 			len = onelen;
 			break;
 		}
-		if (toclose && strcmp(toclose, buf + len) == 0)
+		if (toclose && strcmp(toclose, buf + len) == 0) {
 			closesk = svsk;
-		else
+			svc_xprt_get(&closesk->sk_xprt);
+		} else
 			len += onelen;
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
-	if (closesk)
+	if (closesk) {
 		/* Should unregister with portmap, but you cannot
 		 * unregister just one protocol...
 		 */
 		svc_close_xprt(&closesk->sk_xprt);
-	else if (toclose)
+		svc_xprt_put(&closesk->sk_xprt);
+	} else if (toclose)
 		return -ENOENT;
 	return len;
 }


