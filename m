Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43580 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284Ab0LOVzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 16:55:00 -0500
Date: Wed, 15 Dec 2010 16:54:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <andros@netapp.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V3 1/7] NFS dont free shared socket on backchannel put
 xprt
Message-ID: <20101215215459.GD9646@fieldses.org>
References: <1292271585-3038-1-git-send-email-andros@netapp.com>
 <1292271585-3038-2-git-send-email-andros@netapp.com>
 <20101214181909.GA22950@fieldses.org>
 <807D3371-AA86-4CEA-B6D0-BD5285439FB6@netapp.com>
 <20101214215601.GL24828@fieldses.org>
 <EF7B330F-CC15-4B04-9D70-B209166E4F13@netapp.com>
 <20101214223631.GN24828@fieldses.org>
 <EE8BADA8-5D09-47C9-BB09-E906F3EF2728@netapp.com>
 <20101214224714.GO24828@fieldses.org>
 <F2E2B248-C319-4CB3-AA89-C6F5117DF5D8@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F2E2B248-C319-4CB3-AA89-C6F5117DF5D8@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 03:32:23PM -0500, Andy Adamson wrote:
> 
> On Dec 14, 2010, at 5:47 PM, J. Bruce Fields wrote:
> 
> >On Tue, Dec 14, 2010 at 05:40:19PM -0500, Andy Adamson wrote:
> >>
> >>On Dec 14, 2010, at 5:36 PM, J. Bruce Fields wrote:
> >>
> >>>On Tue, Dec 14, 2010 at 05:28:51PM -0500, Andy Adamson wrote:
> >>>>
> >>>>On Dec 14, 2010, at 4:56 PM, J. Bruce Fields wrote:
> >>>>
> >>>>>On Tue, Dec 14, 2010 at 04:44:58PM -0500, Andy Adamson wrote:
> >>>>>>
> >>>>>>On Dec 14, 2010, at 1:19 PM, J. Bruce Fields wrote:
> >>>>>>
> >>>>>>>On Mon, Dec 13, 2010 at 03:19:39PM -0500, Andy Adamson wrote:
> >>>>>>>>Fixes this bug:
> >>>>>>>>fedora-64 kernel: Invoking bc_svc_procass()
> >>>>>>>>fedora-64 kernel: nfs_callback_authenticate SVC_DROP
> >>>>>>>>fedora-64 kernel: BUG: unable to handle kernel NULL pointer
> >>>>>>>>dereference at 0000000000000018 IP: [<ffffffffa0156140>]
> >>>>>>>>svc_sock_free+0x32/0x56 [sunrpc]
> >>>>>>>>
> >>>>>>>>Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>>>>>>---
> >>>>>>>>fs/nfs/callback.c               |    3 +++
> >>>>>>>>include/linux/sunrpc/svc_xprt.h |    1 +
> >>>>>>>>net/sunrpc/svc_xprt.c           |    3 ++-
> >>>>>>>>3 files changed, 6 insertions(+), 1 deletions(-)
> >>>>>>>>
> >>>>>>>>diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> >>>>>>>>index 93a8b3b..023a9eb 100644
> >>>>>>>>--- a/fs/nfs/callback.c
> >>>>>>>>+++ b/fs/nfs/callback.c
> >>>>>>>>@@ -193,6 +193,9 @@ nfs41_callback_up(struct svc_serv *serv,
> >>>>>>>>struct rpc_xprt *xprt)
> >>>>>>>>	serv->bc_xprt = bc_xprt;
> >>>>>>>>	xprt->bc_serv = serv;
> >>>>>>>>
> >>>>>>>>+	/* socket is shared with the fore channel */
> >>>>>>>>+	set_bit(XPT_SHARE_SOCK, &bc_xprt->xpt_flags);
> >>>>>>>>+
> >>>>>>>>	INIT_LIST_HEAD(&serv->sv_cb_list);
> >>>>>>>>	spin_lock_init(&serv->sv_cb_lock);
> >>>>>>>>	init_waitqueue_head(&serv->sv_cb_waitq);
> >>>>>>>>diff --git a/include/linux/sunrpc/svc_xprt.h
> >>>>>>>>b/include/linux/sunrpc/svc_xprt.h
> >>>>>>>>index aea0d43..600c669 100644
> >>>>>>>>--- a/include/linux/sunrpc/svc_xprt.h
> >>>>>>>>+++ b/include/linux/sunrpc/svc_xprt.h
> >>>>>>>>@@ -62,6 +62,7 @@ struct svc_xprt {
> >>>>>>>>#define	XPT_DETACHED	10		/* detached from tempsocks list */
> >>>>>>>>#define XPT_LISTENER	11		/* listening endpoint */
> >>>>>>>>#define XPT_CACHE_AUTH	12		/* cache auth info */
> >>>>>>>>+#define XPT_SHARE_SOCK	13		/* fore and back channel share
> >>>>>>>>socket */
> >>>>>>>>
> >>>>>>>>	struct svc_pool		*xpt_pool;	/* current pool iff queued */
> >>>>>>>>	struct svc_serv		*xpt_server;	/* service for transport */
> >>>>>>>>diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >>>>>>>>index ea2ff78..8c4d9ad 100644
> >>>>>>>>--- a/net/sunrpc/svc_xprt.c
> >>>>>>>>+++ b/net/sunrpc/svc_xprt.c
> >>>>>>>>@@ -128,7 +128,8 @@ static void svc_xprt_free(struct
> >>>>>>>>kref *kref)
> >>>>>>>>	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
> >>>>>>>>		svcauth_unix_info_release(xprt);
> >>>>>>>>	put_net(xprt->xpt_net);
> >>>>>>>>-	xprt->xpt_ops->xpo_free(xprt);
> >>>>>>>>+	if (!test_bit(XPT_SHARE_SOCK, &xprt->xpt_flags))
> >>>>>>>>+		xprt->xpt_ops->xpo_free(xprt);
> >>>>>>>
> >>>>>>>So when does the svc_xprt get freed if not here?
> >>>>>>
> >>>>>>svc_sock_destroy frees the bc_xprt, called by svc_destroy on the
> >>>>>>serv->bc_xprt.
> >>>>>
> >>>>>Can you remove the
> >>>>>
> >>>>>	#if defined(CONFIG_NFS_V4_1)
> >>>>>   	svc_sock_destroy(serv->bc_xprt);
> >>>>>	#endif /* CONFIG_NFS_V4_1 */
> >>>>>
> >>>>>from svc_destroy instead?
> >>>>
> >>>>Instead of what?
> >>>
> >>>Instead of the patch above.
> >>
> >>Sorry, I just don't understand how that will solve the sock_free BUG
> >>above.
> >
> >It may not, sorry, I'd need to look at it more closely.  Maybe you
> >could
> >explain in more detail how the bug happens and why?  (Which pointer is
> >it that's null, and why?)
> 
> I force an SVC_DROP in nfs_callback_authenticate. svc_process_comon
> then calls svc_drop -> svc_xprt_release  -> svc_xprt_put ->
> svc_xprt_free ->  bc_xprt-> xpt_ops->xpt_free -> svc_sock_free where
> the svc_sock->sk_sock pointer is NULL - set that way at creation.
> 
> After more investigation,  the bc_xprt.xpt_ref is not incremented
> across svc processing, so if there is an error such as svc_drop,
> svc_xprt_put call ends up trying to free the bc_xprt.
> 
> What we want is to look at the single bc_xprt as the "pool" of
> svc_xprts for the back channel. It should have a lifetime equal to
> that of the svc_serv. If we take a reference on the bc_xprt across
> processing (e.g. "recv" takes a reference, and upon no error, drop
> the reference after "send" then we will keep the bc_xprt around.

That's starting to make more sense to me now, thanks!

> I'm thinking of doing the following:
> - svc_xprt_get to bc_svc_process, and an svc_xprt_put at the end of
> bc_send.
> - look into creating an svc_xprt_ops for the back channel and
> perhaps adding a module_get on the xpt_class->xcl_owner in
> nfs41_callback_up so that svc_xprt_put works correctly.
> - calling svc_xprt_put instead of svc_sock_destroy in svc_destroy.
> 
> Does this sound like a good plan?

I haven't thought it through, but yes, something like that sounds
better.

> I note that svc_destroy is not even called because for some reason,
> nfs_callback_down gets an nfs_client struct with the cl_mvop-
> >minor_version set to 0, so svc_exit_thread is not even called. I'll
> figure this out as well.

Hm, OK, thanks for looking into this more closely!

--b.
