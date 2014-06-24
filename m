Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976AbaFXUoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2014 16:44:16 -0400
Date: Tue, 24 Jun 2014 16:44:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] nfsd: fix rare symlink decoding bug
Message-ID: <20140624204413.GE2343@pad.redhat.com>
References: <1403559272-11019-1-git-send-email-bfields@redhat.com>
 <CAHQdGtQXjvyaXx9PkYW=96F+wvPEj8-=eGFV2NDpfFZEB77E5w@mail.gmail.com>
 <20140623221016.GA9429@pad.redhat.com>
 <CAHQdGtR54dy4DJLbx9jBEFbOM7dxihkZBqFgLpafSXdYuqei9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtR54dy4DJLbx9jBEFbOM7dxihkZBqFgLpafSXdYuqei9A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 07:28:16PM -0400, Trond Myklebust wrote:
> On Mon, Jun 23, 2014 at 6:10 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 2d305a1..56bdf4a 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -600,7 +600,18 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
> >                 READ_BUF(4);
> >                 create->cr_linklen = be32_to_cpup(p++);
> >                 READ_BUF(create->cr_linklen);
> > -               SAVEMEM(create->cr_linkname, create->cr_linklen);
> > +               /*
> > +                * The VFS will want a null-terminated string, and
> > +                * null-terminating in place isn't safe since this might
> > +                * end on a page boundary:
> > +                */
> > +               create->cr_linkname =
> > +                               kmalloc(create->cr_linklen + 1, GFP_KERNEL);
> > +               if (!create->cr_linkname)
> > +                       return nfserr_jukebox;
> > +               memcpy(create->cr_linkname, p, create->cr_linklen);
> > +               create->cr_linkname[create->cr_linklen] = '\0';
> > +               defer_free(argp, kfree, create->cr_linkname);
> >                 break;
> >         case NF4BLK:
> >         case NF4CHR:
> 
> Note that "defer_free()" does yet another allocation here in order to
> make space for a small 'struct tmpbuf' structure. Unlike the first
> allocation, there is no check for whether or not that second
> allocation is successful above, so you can easily end up with a silent
> memory leakage (ditto for a number of other callers of defer_free()).
> 
> Looking around at all the other users, wouldn't it perhaps make sense
> to replace defer_free() with a helper that does just a single
> allocation for both the memory buffer and the struct tmpbuf?

Yeah, thanks, working on it....

--b.
