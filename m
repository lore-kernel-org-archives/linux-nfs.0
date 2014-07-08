Return-Path: linux-nfs-owner@vger.kernel.org
Received: from granite.fifsource.com ([173.255.216.206]:52678 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbaGHP1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 11:27:19 -0400
Message-ID: <1404833238.7837.5.camel@niobium.home.fifi.org>
Subject: Re: [PATCH] nfs: only show Posix ACLs in listxattr if actually
 present
From: Philippe Troin <phil@fifi.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 08 Jul 2014 08:27:18 -0700
In-Reply-To: <20140618130022.GA32043@lst.de>
References: <1403082423-13131-1-git-send-email-hch@lst.de>
	 <CAHQdGtSBN4_MPVUWZ1dhOAXyp9w++YGYLP9fmYNq5RPqzrDwPA@mail.gmail.com>
	 <20140618130022.GA32043@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chris & Trond,

On Wed, 2014-06-18 at 15:00 +0200, Christoph Hellwig wrote:
> On Wed, Jun 18, 2014 at 07:35:27AM -0400, Trond Myklebust wrote:
> > Hi Christoph,
> > 
> > On Wed, Jun 18, 2014 at 5:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> > > The big ACL switched nfs to use generic_listxattr, which calls all existing
> > > ->list handlers.  Add a custom .listxattr implementation that only lists
> > > the ACLs if they actually are present on the given inode.
> > >
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > Reported-by: Philippe Troin <phil@fifi.org>
> > > Tested-by: Philippe Troin <phil@fifi.org>
> > > ---
> > >  fs/nfs/nfs3acl.c  |   43 +++++++++++++++++++++++++++++++++++++++++++
> > >  fs/nfs/nfs3proc.c |    4 ++--
> > >  2 files changed, 45 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> > > index 871d6ed..8f854dd 100644
> > > --- a/fs/nfs/nfs3acl.c
> > > +++ b/fs/nfs/nfs3acl.c
> > > @@ -247,3 +247,46 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
> > >         &posix_acl_default_xattr_handler,
> > >         NULL,
> > >  };
> > > +
> > > +static int
> > > +nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
> > > +               size_t size, ssize_t *result)
> > 
> > Why do you make 'result' a pointer to ssize_t rather than a size_t here?
> 
> Because ->listxattr returns a ssize_t, and it points to the variable used
> as return value of nfs3_listxattr.

Have these two patches been merged or at least been queued for inclusion
into mainline?
I have just checked 3.15.3, and the patches do not seem to be included
there.  I haven't tested that specific kernel revision yet though.

Phil.


