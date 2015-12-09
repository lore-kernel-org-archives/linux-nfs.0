Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbbLIP4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Dec 2015 10:56:40 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: init xdr_stream for zero iov_len, page_len
Date: Wed,  9 Dec 2015 10:56:38 -0500
Message-Id: <f5e71b1a1faabbc44c2586aec2dd405a6ade8507.1449675652.git.bcodding@redhat.com>
In-Reply-To: <alpine.OSX.2.19.9992.1512080553340.60717@planck.local>
References: <80ed0167773dfee0807c79233555c7d0c1fae11a.1448031054.git.bcodding@redhat.com> <CAHQdGtQfpNT0nNQ4R=vEcnzi=xtW3291i99nTCNJw3D5Gqq+Fg@mail.gmail.com> <alpine.OSX.2.19.9992.1512080553340.60717@planck.local>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Dec 2015, Benjamin Coddington wrote:

> On Mon, 7 Dec 2015, Trond Myklebust wrote:
> 
> > Hi Ben,
> >
> > I've hit a few problems with this patch after it went upstream.
> >
> > On Fri, Nov 20, 2015 at 6:55 AM, Benjamin Coddington
> > <bcodding@redhat.com> wrote:
> > > A truncated cb_compound request will cause the client to decode null or
> > > data from a previous callback for nfs4.1 backchannel case, or uninitialized
> > > data for the nfs4.0 case. This is because the path through
> > > svc_process_common() advances the request's iov_base and decrements iov_len
> > > without adjusting the overall xdr_buf's len field.  That causes
> > > xdr_init_decode() to set up the xdr_stream with an incorrect length in
> > > nfs4_callback_compound().
> > >
> > > Fixing this for the nfs4.1 backchannel case first requires setting the
> > > correct iov_len and page_len based on the length of received data in the
> > > same manner as the nfs4.0 case.
> > >
> > > Then the request's xdr_buf length can be adjusted for both cases based upon
> > > the remaining iov_len and page_len.
> > >
> > > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > > ---
> > >  fs/nfs/callback_xdr.c         |    7 +++++--
> > >  net/sunrpc/backchannel_rqst.c |    8 ++++++++
> > >  net/sunrpc/svc.c              |    1 +
> > >  3 files changed, 14 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> > > index 6b1697a..1c8213e 100644
> > > --- a/fs/nfs/callback_xdr.c
> > > +++ b/fs/nfs/callback_xdr.c
> > > @@ -76,7 +76,8 @@ static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
> > >
> > >         p = xdr_inline_decode(xdr, nbytes);
> > >         if (unlikely(p == NULL))
> > > -               printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed!\n");
> > > +               printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed "
> > > +                                                       "or truncated request.\n");
> > >         return p;
> > >  }
> > >
> > > @@ -892,6 +893,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> > >         struct cb_compound_hdr_arg hdr_arg = { 0 };
> > >         struct cb_compound_hdr_res hdr_res = { NULL };
> > >         struct xdr_stream xdr_in, xdr_out;
> > > +       struct xdr_buf *rq_arg = &rqstp->rq_arg;
> > >         __be32 *p, status;
> > >         struct cb_process_state cps = {
> > >                 .drc_status = 0,
> > > @@ -903,7 +905,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> > >
> > >         dprintk("%s: start\n", __func__);
> > >
> > > -       xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
> > > +       rq_arg->len = rq_arg->head[0].iov_len + rq_arg->page_len;
> >
> > This is redundant.
> 
> The decoding routines in svc_process_common() and svc_authenticate() are
> advancing the xdr_buf's iov_base and decremening iov_len without adjusting
> the overall xdr_buf.len field, so I believed this adjustment was necessary
> after they had moved things around.
> 
> I'm simulating this problem by sending CB_COMPOUND instead of CB_NULL when
> setting up the callback channel (since that is easy to do in pynfs).  In
> that scenario, just before xdr_init_decode() my xdr_buf.len is 80 (the size
> of the RPC headers), but the xdr_buf.kvec iov_len is 0 (all the headers have
> been decoded).  Then xdr_init_decode() then skips xdr_set_iov() so xdr->end
> is never initialized, and xdr->nwords ends up at 20.
> 
> Then, as we start decoding, we end up in __xdr_inline_decode(), which
> expects xdr->end to have a valid value if we haven't run out of nwords, or
> we start decoding a previous request or uninitialized data.  Usually, this
> is harmless, as the string decode overflows those 20 words, and NULL is
> returned in my test; however I believe it is possible to decode part of a
> previous request here..
> 
> With this adjustment, nwords ends up at 0, so __xdr_inline_decode() returns
> before using xdr->end.
> 
> Maybe the right fix is to adjust xdr_init_decode() to make sure xdr->end is
> always initialized based on iov_len.

8<----------------------------------------------------------------------------- 

An xdr_buf with head[0].iov_len = 0 and page_len = 0 will cause
xdr_init_decode() to incorrectly setup the xdr_stream.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 net/sunrpc/xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4..4f29e30 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -797,6 +797,8 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 		xdr_set_iov(xdr, buf->head, buf->len);
 	else if (buf->page_len != 0)
 		xdr_set_page_base(xdr, 0, buf->len);
+	else
+		xdr_set_iov(xdr, buf->head, buf->len);
 	if (p != NULL && p > xdr->p && xdr->end >= p) {
 		xdr->nwords -= p - xdr->p;
 		xdr->p = p;
-- 
1.7.1

