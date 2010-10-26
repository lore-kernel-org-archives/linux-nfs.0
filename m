Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47795 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab0JZA3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 20:29:03 -0400
Date: Mon, 25 Oct 2010 20:28:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101026002858.GH13523@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-1-git-send-email-bfields@redhat.com>
 <20101025124357.63b966bb@notabene>
 <20101025202155.GD13523@fieldses.org>
 <20101026095836.61bf6a38@notabene>
 <20101025230331.GF13523@fieldses.org>
 <20101026105447.264b690e@notabene>
 <20101026001145.GG13523@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026001145.GG13523@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 25, 2010 at 08:11:45PM -0400, J. Bruce Fields wrote:
> On Tue, Oct 26, 2010 at 10:54:47AM +1100, Neil Brown wrote:
> > Note that once we always set XPT_BUSY and it stays set.  So we call
> > svc_delete_xprt instread of svc_close_xprt.
> > 
> > Maybe we don't actually need to list_del_init - both the pool and the xprt
> > will soon be freed and if there is linkage between them, who cares??
> > In that case we wouldn't need to for_each_pool after all ???

So, untested:

commit 5e0bffc6376d8d3316771e12af698631a4ca2634
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 25 18:11:21 2010 -0400

    svcrpc: simplify svc_close_all
    
    There's no need to be fooling with XPT_BUSY now that all the threads
    are gone.
    
    The list_del_init() here could execute at the same time as the
    svc_xprt_enqueue()'s list_add_tail(), with undefined results.  We don't
    really care at this point, but it might result in a spurious
    list-corruption warning or something.
    
    And svc_close() isn't adding any value; just call svc_delete_xprt()
    directly.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index dd61cd0..8c018df 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -941,16 +941,16 @@ void svc_close_all(struct list_head *xprt_list)
 	struct svc_xprt *xprt;
 	struct svc_xprt *tmp;
 
+	/*
+	 * The server is shutting down, and no more threads are running.
+	 * svc_xprt_enqueue() might still be running, but at worst it
+	 * will re-add the xprt to sp_sockets, which will soon get
+	 * freed.  So we don't bother with any more locking, and don't
+	 * leave the close to the (nonexistent) server threads:
+	 */
 	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		if (test_bit(XPT_BUSY, &xprt->xpt_flags)) {
-			/* Waiting to be processed, but no threads left,
-			 * So just remove it from the waiting list
-			 */
-			list_del_init(&xprt->xpt_ready);
-			clear_bit(XPT_BUSY, &xprt->xpt_flags);
-		}
-		svc_close_xprt(xprt);
+		svc_delete_xprt(xprt);
 	}
 }
 
