From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] kernel panic at svc_xprt_release
Date: Mon, 29 Mar 2010 21:07:53 -0400
Message-ID: <20100330010753.GH24251@fieldses.org>
References: <4BA9DDC1.3020202@cn.fujitsu.com> <20100330005748.GG24251@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589Ab0C3BFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 21:05:45 -0400
In-Reply-To: <20100330005748.GG24251@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 29, 2010 at 08:57:48PM -0400, J. Bruce Fields wrote:
> Hm, OK, so it does look like tcp_close() can sleep, so we are wrong to
> be calling svc_xprt_put() while holding sv_lock.
> 
> The commit ab1b18f "sunrpc: remove unnecessary svc_xprt_put" gets rid of
> one svc_xprt_put(), and the remaining final svc_xprt_put() could easily
> be delayed till after we drop the lock.

So, perhaps we want the following.

--b.

commit 788e69e548cc8d127b90f0de1f7b7e983d1d587a
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Mar 29 21:02:31 2010 -0400

    svcrpc: don't hold sv_lock over svc_xprt_put()
    
    svc_xprt_put() can call tcp_close(), which can sleep, so we shouldn't be
    holding this lock.
    
    In fact, only the xpt_list removal and the sv_tmpcnt decrement should
    need the sv_lock here.
    
    Reported-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8f0f1fb..c334f54 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -892,12 +892,12 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	 */
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
+	spin_unlock_bh(&serv->sv_lock);
 
 	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
 		kfree(dr);
 
 	svc_xprt_put(xprt);
-	spin_unlock_bh(&serv->sv_lock);
 }
 
 void svc_close_xprt(struct svc_xprt *xprt)
