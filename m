Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59306 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759136Ab0LNWgd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 17:36:33 -0500
Date: Tue, 14 Dec 2010 17:36:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <andros@netapp.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V3 1/7] NFS dont free shared socket on backchannel put
 xprt
Message-ID: <20101214223631.GN24828@fieldses.org>
References: <1292271585-3038-1-git-send-email-andros@netapp.com>
 <1292271585-3038-2-git-send-email-andros@netapp.com>
 <20101214181909.GA22950@fieldses.org>
 <807D3371-AA86-4CEA-B6D0-BD5285439FB6@netapp.com>
 <20101214215601.GL24828@fieldses.org>
 <EF7B330F-CC15-4B04-9D70-B209166E4F13@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EF7B330F-CC15-4B04-9D70-B209166E4F13@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 14, 2010 at 05:28:51PM -0500, Andy Adamson wrote:
> 
> On Dec 14, 2010, at 4:56 PM, J. Bruce Fields wrote:
> 
> >On Tue, Dec 14, 2010 at 04:44:58PM -0500, Andy Adamson wrote:
> >>
> >>On Dec 14, 2010, at 1:19 PM, J. Bruce Fields wrote:
> >>
> >>>On Mon, Dec 13, 2010 at 03:19:39PM -0500, Andy Adamson wrote:
> >>>>Fixes this bug:
> >>>>fedora-64 kernel: Invoking bc_svc_procass()
> >>>>fedora-64 kernel: nfs_callback_authenticate SVC_DROP
> >>>>fedora-64 kernel: BUG: unable to handle kernel NULL pointer
> >>>>dereference at 0000000000000018 IP: [<ffffffffa0156140>]
> >>>>svc_sock_free+0x32/0x56 [sunrpc]
> >>>>
> >>>>Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>>---
> >>>>fs/nfs/callback.c               |    3 +++
> >>>>include/linux/sunrpc/svc_xprt.h |    1 +
> >>>>net/sunrpc/svc_xprt.c           |    3 ++-
> >>>>3 files changed, 6 insertions(+), 1 deletions(-)
> >>>>
> >>>>diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> >>>>index 93a8b3b..023a9eb 100644
> >>>>--- a/fs/nfs/callback.c
> >>>>+++ b/fs/nfs/callback.c
> >>>>@@ -193,6 +193,9 @@ nfs41_callback_up(struct svc_serv *serv,
> >>>>struct rpc_xprt *xprt)
> >>>>	serv->bc_xprt = bc_xprt;
> >>>>	xprt->bc_serv = serv;
> >>>>
> >>>>+	/* socket is shared with the fore channel */
> >>>>+	set_bit(XPT_SHARE_SOCK, &bc_xprt->xpt_flags);
> >>>>+
> >>>>	INIT_LIST_HEAD(&serv->sv_cb_list);
> >>>>	spin_lock_init(&serv->sv_cb_lock);
> >>>>	init_waitqueue_head(&serv->sv_cb_waitq);
> >>>>diff --git a/include/linux/sunrpc/svc_xprt.h
> >>>>b/include/linux/sunrpc/svc_xprt.h
> >>>>index aea0d43..600c669 100644
> >>>>--- a/include/linux/sunrpc/svc_xprt.h
> >>>>+++ b/include/linux/sunrpc/svc_xprt.h
> >>>>@@ -62,6 +62,7 @@ struct svc_xprt {
> >>>>#define	XPT_DETACHED	10		/* detached from tempsocks list */
> >>>>#define XPT_LISTENER	11		/* listening endpoint */
> >>>>#define XPT_CACHE_AUTH	12		/* cache auth info */
> >>>>+#define XPT_SHARE_SOCK	13		/* fore and back channel share
> >>>>socket */
> >>>>
> >>>>	struct svc_pool		*xpt_pool;	/* current pool iff queued */
> >>>>	struct svc_serv		*xpt_server;	/* service for transport */
> >>>>diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >>>>index ea2ff78..8c4d9ad 100644
> >>>>--- a/net/sunrpc/svc_xprt.c
> >>>>+++ b/net/sunrpc/svc_xprt.c
> >>>>@@ -128,7 +128,8 @@ static void svc_xprt_free(struct kref *kref)
> >>>>	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
> >>>>		svcauth_unix_info_release(xprt);
> >>>>	put_net(xprt->xpt_net);
> >>>>-	xprt->xpt_ops->xpo_free(xprt);
> >>>>+	if (!test_bit(XPT_SHARE_SOCK, &xprt->xpt_flags))
> >>>>+		xprt->xpt_ops->xpo_free(xprt);
> >>>
> >>>So when does the svc_xprt get freed if not here?
> >>
> >>svc_sock_destroy frees the bc_xprt, called by svc_destroy on the
> >>serv->bc_xprt.
> >
> >Can you remove the
> >
> >	#if defined(CONFIG_NFS_V4_1)
> >       	svc_sock_destroy(serv->bc_xprt);
> >	#endif /* CONFIG_NFS_V4_1 */
> >
> >from svc_destroy instead?
> 
> Instead of what?

Instead of the patch above.

--b.

> Where do you want svc_sock_destroy to be called?

> From svc_xprt_free?
> 
> >
> >>>And why is it OK to do
> >>>the put_net() and module_put() but not the xpo_free()?
> >>
> >>svc_sock_create()  called only by nfs41_callback_up creates the
> >>bc_xprt. It calls svc_xprt_init which calls get_net(), so put_net is
> >>needed.
> >>
> >>Hmmm. It looks like the module_put is also not needed - the matching
> >>module_get is in svc_create_xprt() which is not called for the
> >>NFSv4.1 callback service. (but is called for the NFSv4.0 callback
> >>service ... sheese).
> >>
> >>I'll move the module_put so it is also not called when the
> >>XPT_SHARE_SOCK flag is set.
> >
> >The xpt_net reference counting doesn't look right either.
> 
> I'm not familiar with the xpt_net reference counting.
> 
> >
> >I think we shouldn't need XPT_SHARE_SOCK if we just get the
> >reference counting
> >on the svc_xprt right instead.
> 
> At the end of the day svc_xprt_free will be called on this svc_xprt.
> At that time, xpo_free can not be called because xpo_create was not
> used to create it. svc_sock_destroy needs to be called to free the
> storage kzalloc'ed in svc_sock_create.
> 
> I don't get what you are suggesting.....
> 
> >
> >>
> >>>
> >>>Something feels wrong here....
> >>
> >>Yeah - how about naming the server back channel xprt (bc_xprt) the
> >>same as the client back channel xprt (bc_xprt)!!! How confusing is
> >>THAT! :)
> >
> >Well, and it's also the name of a field in svc_serv.  If nothing
> >else, would
> >you mind renaming that to sv_bc_xprt?
> 
> I can clean up the naming after we figure out the above.
> 
> -->Andy
> 
> >
> >--b.
> >
> >>
> >>Thanks for the review.
> >>
> >>-->Andy
> >>
> >>>
> >>>--b.
> >>>
> >>>>	module_put(owner);
> >>>>}
> >>>>
> >>>>-- 
> >>>>1.6.6
> >>>>
> >>>>--
> >>>>To unsubscribe from this list: send the line "unsubscribe linux-
> >>>>nfs" in
> >>>>the body of a message to majordomo@vger.kernel.org
> >>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>--
> >>>To unsubscribe from this list: send the line "unsubscribe
> >>>linux-nfs" in
> >>>the body of a message to majordomo@vger.kernel.org
> >>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> 
