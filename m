Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966561AbcCPOWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 10:22:13 -0400
Date: Wed, 16 Mar 2016 10:22:10 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
In-Reply-To: <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1603161016560.11199@planck>
References: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com> <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Mar 2016, Trond Myklebust wrote:

> On Wed, Mar 16, 2016 at 5:17 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> >
> > A zero-length short read without eof should be retried rather than sending
> > an error to the application.
>
>
> In what situation would returning a 0 length read not be a bug? If the
> server intended that we back off and retry, it has the alternative of
> sending a JUKEBOX/DELAY error.

If the server completes a local read but then another writer comes in and
appends to the file before the server checks if it needs to set EOF, then
the response might be 0 length without EOF set.

I'm also using https://tools.ietf.org/html/rfc7530#section-16.23.5 to guide
how I think the client should behave; it says that the client should retry
a short read without eof set.  I think that should include a response with
0 length.


> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/read.c |    5 -----
> >  1 files changed, 0 insertions(+), 5 deletions(-)
> >
> > diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> > index eb31e23..7269d42 100644
> > --- a/fs/nfs/read.c
> > +++ b/fs/nfs/read.c
> > @@ -244,11 +244,6 @@ static void nfs_readpage_retry(struct rpc_task *task,
> >
> >         /* This is a short read! */
> >         nfs_inc_stats(hdr->inode, NFSIOS_SHORTREAD);
> > -       /* Has the server at least made some progress? */
> > -       if (resp->count == 0) {
> > -               nfs_set_pgio_error(hdr, -EIO, argp->offset);
> > -               return;
> > -       }
> >
> >         /* For non rpc-based layout drivers, retry-through-MDS */
> >         if (!task->tk_ops) {
> > --
> > 1.7.1
> >
>
