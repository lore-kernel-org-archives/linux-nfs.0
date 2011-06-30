Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39452 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1F3SZO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 14:25:14 -0400
Date: Thu, 30 Jun 2011 14:25:13 -0400
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: NFS crash in un-modified 3.0.0-rc3+, list corruption.
Message-ID: <20110630182513.GC18713@fieldses.org>
References: <4DFFCCDC.2070106@candelatech.com>
 <4DFFD738.2080608@candelatech.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DFFD738.2080608@candelatech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 20, 2011 at 04:26:48PM -0700, Ben Greear wrote:
> On 06/20/2011 03:42 PM, Ben Greear wrote:
> >This machine is acting as a server.  It is from linux-2.6, pulled
> >today:
> >
> >commit de505e709ffb09a7382ca8e0d8c7dbb171ba5830
> >
> >We are hitting it with 200 clients reading and writing, mounting and
> >un-mounting.
> >This bug is fairly reproducible (twice today).
> >
> >Large amounts of debugging options are enabled.
> 
> We were also starting/stopping NFS on the server machine.
> It appears that this crash happens during the
> /etc/init.d/nfs stop
> command.

I'll be submitting the below.

The bug's been there for a really long time and we're getting late into
the release cycle so I'll probably just save it for 3.1 (but it'll go to
stable as well then).

--b.

commit 0f4bb2521a0e300443e9d80b10778f5a93cc0dbc
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 29 16:49:04 2011 -0400

    svcrpc: fix list-corrupting race on nfsd shutdown
    
    After commit 3262c816a3d7fb1eaabce633caa317887ed549ae "[PATCH] knfsd:
    split svc_serv into pools", svc_delete_xprt (then svc_delete_socket) no
    longer removed its xpt_ready (then sk_ready) field from whatever list it
    was on, noting that there was no point since the whole list was about to
    be destroyed anyway.
    
    That was mostly true, but forgot that a few svc_xprt_enqueue()'s might
    still be hanging around playing with the about-to-be-destroyed list, and
    could get themselves into trouble writing to freed memory if we left
    this xprt on the list after freeing it.
    
    (This is actually functionally identical to a patch made first by Ben
    Greear, but with more comments.)
    
    Cc: stable@kernel.org
    Cc: gnb@fmeh.org
    Reported-by: Ben Greear <greearb@candelatech.com>
    Tested-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ab86b79..bd31208 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -902,12 +902,13 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
 		list_del_init(&xprt->xpt_list);
 	/*
-	 * We used to delete the transport from whichever list
-	 * it's sk_xprt.xpt_ready node was on, but we don't actually
-	 * need to.  This is because the only time we're called
-	 * while still attached to a queue, the queue itself
-	 * is about to be destroyed (in svc_destroy).
+	 * The only time we're called while xpt_ready is still on a list
+	 * is while the list itself is about to be destroyed (in
+	 * svc_destroy).  BUT svc_xprt_enqueue could still be attempting
+	 * to add new entries to the sp_sockets list, so we can't leave
+	 * a freed xprt on it.
 	 */
+	list_del_init(&xprt->xpt_ready);
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
 	spin_unlock_bh(&serv->sv_lock);
