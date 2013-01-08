Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523Ab3AHPSl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 10:18:41 -0500
Date: Tue, 8 Jan 2013 10:18:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yanchuan Nian <ycnian@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Remove write permission from file content
Message-ID: <20130108151840.GC16343@fieldses.org>
References: <1357299935-9321-1-git-send-email-ycnian@gmail.com>
 <20130104211204.GA14712@fieldses.org>
 <CAC5OsZPR88SktqjTKsqJVaxKZ1LkPnvPcT2gPSFq_oPDZ1FZpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAC5OsZPR88SktqjTKsqJVaxKZ1LkPnvPcT2gPSFq_oPDZ1FZpw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 05, 2013 at 12:29:05PM +0800, Yanchuan Nian wrote:
> 2013/1/5 J. Bruce Fields <bfields@fieldses.org>
> 
> > On Fri, Jan 04, 2013 at 07:45:35PM +0800, ycnian@gmail.com wrote:
> > > From: Yanchuan Nian <ycnian@gmail.com>
> > >
> > > The write function doesn't be implemented in file content, and it's
> > meaningless
> > > to write data into this file directly. Remove write permission from it.
> >
> > So does it really matter either way?
> >
> No, it doesn't matter. I saw that nfs-utils communicates with nfsd through
> proc fs, so I tried to update the cache by writing data to proc fs
> directly. I found the format of "channel" and "flush" in nfs-utils, but I
> couldn't find the format of "content", so I read the sunrpc source code,
> and found that the write function doesn't be implemented, but the write
> permission is set when registering into proc fs. I also found that
> "content" in pipe fs doesn't have write permission.

OK, so if it had been read-only it might have saved you a little
confusion.  Fair enough.

--b.

> 
> >
> > OK, applying, but I wonder.
> >
> > --b.
> >
> > >
> > > Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> > > ---
> > >  net/sunrpc/cache.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >
> > > diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> > > index 9afa439..9f84703 100644
> > > --- a/net/sunrpc/cache.c
> > > +++ b/net/sunrpc/cache.c
> > > @@ -1614,7 +1614,7 @@ static int create_cache_proc_entries(struct
> > cache_detail *cd, struct net *net)
> > >                       goto out_nomem;
> > >       }
> > >       if (cd->cache_show) {
> > > -             p = proc_create_data("content", S_IFREG|S_IRUSR|S_IWUSR,
> > > +             p = proc_create_data("content", S_IFREG|S_IRUSR,
> > >                               cd->u.procfs.proc_ent,
> > >                               &content_file_operations_procfs, cd);
> > >               cd->u.procfs.content_ent = p;
> > > --
> > > 1.7.4.4
> > >
> >
