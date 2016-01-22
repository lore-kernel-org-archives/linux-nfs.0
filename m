Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34723 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbcAVQFD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2016 11:05:03 -0500
Received: by mail-oi0-f42.google.com with SMTP id k206so50553592oia.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2016 08:05:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56A23EF7.6000107@Netapp.com>
References: <1453409713-15878-1-git-send-email-trond.myklebust@primarydata.com>
	<1453409713-15878-2-git-send-email-trond.myklebust@primarydata.com>
	<56A23EF7.6000107@Netapp.com>
Date: Fri, 22 Jan 2016 11:05:02 -0500
Message-ID: <CAHQdGtQYicNb_QUOWZaHPbCaxOV8ds8Lu06_W59dJKaoJo7rGQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] pNFS/flexfiles: Fix an XDR encoding bug in layoutreturn
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 22, 2016 at 9:38 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
>
> Hi Trond,
>
> On 01/21/2016 03:55 PM, Trond Myklebust wrote:
> > We must not skip encoding the statistics, or the server will see an
> > XDR encoding error.
> >
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Cc: stable@vger.kernel.org # 4.0+
> > ---
> >  fs/nfs/flexfilelayout/flexfilelayout.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> > index 405f46ba490e..82959409b9a6 100644
> > --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> > +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> > @@ -1859,9 +1859,7 @@ ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
> >       start = xdr_reserve_space(xdr, 4);
> >       BUG_ON(!start);
> >
> > -     if (ff_layout_encode_ioerr(flo, xdr, args))
> > -             goto out;
>
> Can you remove the label "out", too?  GCC tells me:
>
> fs/nfs/flexfilelayout/flexfilelayout.c:1953:1: error: label 'out' defined but not used [-Werror=unused-label]
>

I intended to do this, but it slipped my mind. Done now...

Apologies
  Trond
