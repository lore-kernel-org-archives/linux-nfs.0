Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab3BKA0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2013 19:26:03 -0500
Date: Sun, 10 Feb 2013 19:25:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org,
        devel@openvz.org
Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources
 allocation
Message-ID: <20130211002558.GD10161@fieldses.org>
References: <20130201111046.24066.72836.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130201111046.24066.72836.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2013 at 02:28:21PM +0300, Stanislav Kinsbursky wrote:
> After "NFS" (SUNRPC + NFSd actually) containerization work some basic
> principles of SUNRPC service initialization and deinitialization has been
> changed: now one service can be shared between different network namespaces
> and network "resources" can be attached or detached from the running service.
> This leads to races, described here:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=904870
> 
> and which this small patch set is aimed to solve by using per-cpu rw semphores
> to sync per-net resources processing and shutdown.

Sorry for the slow response.  I think this is probably correct.

But I think we got into this mess because the server shutdown logic is
too complicated.  So I'd prefer to find a way to fix the problem by
simplifying things rather than by adding another lock.

Do you see anything wrong with the following?

--b

commit e8202f39f84b8863337f55159dd18478b9ccb616
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Feb 10 16:08:11 2013 -0500

    svcrpc: fix and simplify server shutdown
    
    Simplify server shutdown, and make it correct whether or not there are
    still threads running (as will happen in the case we're only shutting
    down the service in one network namespace).
    
    Do that by doing what we'd do in normal circumstances: just CLOSE each
    socket, then enqueue it.
    
    Since there may not be threads to handle the resulting queued xprts,
    also run a simplified version of the svc_recv() loop run by a server to
    clean up any closed xprts afterwards.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 024a241..a98e818 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -966,12 +966,12 @@ static void svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, s
 		if (xprt->xpt_net != net)
 			continue;
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		set_bit(XPT_BUSY, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
 	}
 	spin_unlock(&serv->sv_lock);
 }
 
-static void svc_clear_pools(struct svc_serv *serv, struct net *net)
+static struct svc_xprt *svc_dequeue_net(struct svc_serv *serv, struct net *net)
 {
 	struct svc_pool *pool;
 	struct svc_xprt *xprt;
@@ -986,42 +986,31 @@ static void svc_clear_pools(struct svc_serv *serv, struct net *net)
 			if (xprt->xpt_net != net)
 				continue;
 			list_del_init(&xprt->xpt_ready);
+			spin_unlock_bh(&pool->sp_lock);
+			return xprt;
 		}
 		spin_unlock_bh(&pool->sp_lock);
 	}
+	return NULL;
 }
 
-static void svc_clear_list(struct svc_serv *serv, struct list_head *xprt_list, struct net *net)
+static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
 {
 	struct svc_xprt *xprt;
-	struct svc_xprt *tmp;
-	LIST_HEAD(victims);
 
-	spin_lock(&serv->sv_lock);
-	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
-		if (xprt->xpt_net != net)
-			continue;
-		list_move(&xprt->xpt_list, &victims);
-	}
-	spin_unlock(&serv->sv_lock);
-
-	list_for_each_entry_safe(xprt, tmp, &victims, xpt_list)
+	while ((xprt = svc_dequeue_net(serv, net))) {
+		if (!test_bit(XPT_CLOSE, &xprt->xpt_flags))
+			pr_err("found un-closed xprt on service shutdown\n");
 		svc_delete_xprt(xprt);
+	}
 }
 
 void svc_close_net(struct svc_serv *serv, struct net *net)
 {
-	svc_close_list(serv, &serv->sv_tempsocks, net);
 	svc_close_list(serv, &serv->sv_permsocks, net);
-
-	svc_clear_pools(serv, net);
-	/*
-	 * At this point the sp_sockets lists will stay empty, since
-	 * svc_xprt_enqueue will not add new entries without taking the
-	 * sp_lock and checking XPT_BUSY.
-	 */
-	svc_clear_list(serv, &serv->sv_tempsocks, net);
-	svc_clear_list(serv, &serv->sv_permsocks, net);
+	svc_clean_up_xprts(serv, net);
+	svc_close_list(serv, &serv->sv_tempsocks, net);
+	svc_clean_up_xprts(serv, net);
 }
 
 /*
