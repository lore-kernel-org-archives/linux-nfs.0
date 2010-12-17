Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755892Ab0LQUC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 15:02:26 -0500
Date: Fri, 17 Dec 2010 15:02:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V4 1/9] SUNRPC new transport for the NFSv4.1 shared
 back channel
Message-ID: <20101217200223.GE14510@fieldses.org>
References: <1292610010-19084-1-git-send-email-andros@netapp.com>
 <1292610010-19084-2-git-send-email-andros@netapp.com>
 <20101217184047.GD11515@fieldses.org>
 <AANLkTinb3cZjPJZsGs-eNgU-5qMtvbFZMjY_rc=rZExN@mail.gmail.com>
 <AANLkTi=yKirVoRTEsz9s=8nQHPXR0C52DQHK-nz7Q82j@mail.gmail.com>
 <20101217191037.GA14510@fieldses.org>
 <AANLkTinjxeWAqW7p=nReP7jmqfWZi7CS_p+GVdno7zmQ@mail.gmail.com>
 <20101217193324.GC14510@fieldses.org>
 <AANLkTinHUSkV4LApqmwk+mU7OS5ro0u859PMtQ39qFPC@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTinHUSkV4LApqmwk+mU7OS5ro0u859PMtQ39qFPC@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 17, 2010 at 02:55:11PM -0500, William A. (Andy) Adamson wrote:
> On Fri, Dec 17, 2010 at 2:33 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Dec 17, 2010 at 02:16:35PM -0500, William A. (Andy) Adamson wrote:
> >> On Fri, Dec 17, 2010 at 2:10 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> > On Fri, Dec 17, 2010 at 01:57:50PM -0500, William A. (Andy) Adamson wrote:
> >> >> On Fri, Dec 17, 2010 at 1:54 PM, William A. (Andy) Adamson
> >> >> <androsadamson@gmail.com> wrote:
> >> >> > On Fri, Dec 17, 2010 at 1:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> >> >> On Fri, Dec 17, 2010 at 01:20:02PM -0500, andros@netapp.com wrote:
> >> >> >>> From: Andy Adamson <andros@netapp.com>
> >> >> >>>
> >> >> >>> Create a new transport for the shared back channel.l Move the current sock
> >> >> >>> create and destroy routines into the new transport ops.
> >> >> >>>
> >> >> >>> Reference the back channel transport across message processing (recv/send).
> >> >> >>>
> >> >> >>> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> >> >>> ---
> >> >> >>>  include/linux/sunrpc/svcsock.h |    1 +
> >> >> >>>  net/sunrpc/svc.c               |   18 +++---
> >> >> >>>  net/sunrpc/svcsock.c           |  122 +++++++++++++++++++++++++++++++++-------
> >> >> >>>  3 files changed, 112 insertions(+), 29 deletions(-)
> >> >> >>>
> >> >> >>> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> >> >> >>> index 1b353a7..3a45a80 100644
> >> >> >>> --- a/include/linux/sunrpc/svcsock.h
> >> >> >>> +++ b/include/linux/sunrpc/svcsock.h
> >> >> >>> @@ -45,6 +45,7 @@ int         svc_sock_names(struct svc_serv *serv, char *buf,
> >> >> >>>  int          svc_addsock(struct svc_serv *serv, const int fd,
> >> >> >>>                                       char *name_return, const size_t len);
> >> >> >>>  void         svc_init_xprt_sock(void);
> >> >> >>> +void         svc_init_bc_xprt_sock(void);
> >> >> >>>  void         svc_cleanup_xprt_sock(void);
> >> >> >>>  struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
> >> >> >>>  void         svc_sock_destroy(struct svc_xprt *);
> >> >> >>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> >> >>> index 6359c42..3520cb3 100644
> >> >> >>> --- a/net/sunrpc/svc.c
> >> >> >>> +++ b/net/sunrpc/svc.c
> >> >> >>> @@ -488,10 +488,6 @@ svc_destroy(struct svc_serv *serv)
> >> >> >>>       if (svc_serv_is_pooled(serv))
> >> >> >>>               svc_pool_map_put();
> >> >> >>>
> >> >> >>> -#if defined(CONFIG_NFS_V4_1)
> >> >> >>> -     svc_sock_destroy(serv->bc_xprt);
> >> >> >>> -#endif /* CONFIG_NFS_V4_1 */
> >> >> >>> -
> >> >> >>>       svc_unregister(serv);
> >> >> >>>       kfree(serv->sv_pools);
> >> >> >>>       kfree(serv);
> >> >> >>> @@ -1264,7 +1260,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> >> >> >>>  {
> >> >> >>>       struct kvec     *argv = &rqstp->rq_arg.head[0];
> >> >> >>>       struct kvec     *resv = &rqstp->rq_res.head[0];
> >> >> >>> -     int             error;
> >> >> >>> +     int             ret;
> >> >> >>>
> >> >> >>>       /* Build the svc_rqst used by the common processing routine */
> >> >> >>>       rqstp->rq_xprt = serv->bc_xprt;
> >> >> >>> @@ -1292,12 +1288,16 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> >> >> >>>       svc_getu32(argv);       /* XID */
> >> >> >>>       svc_getnl(argv);        /* CALLDIR */
> >> >> >>>
> >> >> >>> -     error = svc_process_common(rqstp, argv, resv);
> >> >> >>> -     if (error <= 0)
> >> >> >>> -             return error;
> >> >> >>> +     /* Hold a reference to the back channel socket across the call */
> >> >> >>> +     svc_xprt_get(serv->bc_xprt);
> >> >> >>
> >> >> >> Either we already have a reference, in which case this is unnecessary,
> >> >> >> or we don't, in which case this is risky.
> >> >> >
> >> >> > This is done so that when svc_xprt_put is called due to an svc_drop
> >> >> > (svc_xprt_release, svc_xprt_put) it is not freed.  It's not risky
> >> >> > because AFAICS it's the way the rpc server code is intended to work.
> >> >> > Note that svc_recv calls svc_xprt_get, and svc_send calls svc_xprt_put
> >> >> > for the same reason.
> >> >
> >> > The svc_xprt_put()'s in svc_send/svc_drop balance the get in svc_recv().
> >> > They're needed because on a normal server connections can come and go
> >> > (because clients come and go) during the lifetime of the server.
> >> >
> >> > As I understand it, the client is just creating a new server for each
> >> > backchannel.  So the server will never outlive the one connection it
> >> > uses.  So you don't need that stuff.  It's harmless--just leave it
> >> > alone--but definitely don't try to add additional reference counting
> >> > during the processing.
> >>
> >> If I don't add an svc_xprt_get prior to the svc_process_call, the
> >> svc_xprt_put called in the svc_drop case will free the bc_xprt, which
> >> is not what I want.
> >
> > Looking at the code some more....  Oh, right, because the backchannel
> > doesn't call svc_recv, it calls its own bc_send, which doesn't do a put.
> >
> > Oh, yuch, I see: svc_process_common returns "1" to mean send, "0" to
> > mean drop, and leaves it up to the caller to do the put in the send
> > case.  That's confusing.
> >
> > Maybe it would be simpler to have the caller be made responsible for
> > both cases?  So:
> >
> >        if (svc_process_common(rqstp))
> >                send it
> >        else
> >                drop it
> 
> That would work well. I'll send a patch

If you do that you may want your own bc_svc_drop that doesn't bother
with the put?

You'd want to look through svc_xprt_release() to see if any of the rest
of that makes sense in the bc case.

--b.
