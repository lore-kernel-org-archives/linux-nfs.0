Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:57840 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966162AbaFRNAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2014 09:00:25 -0400
Date: Wed, 18 Jun 2014 15:00:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, Philippe Troin <phil@fifi.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: only show Posix ACLs in listxattr if actually
	present
Message-ID: <20140618130022.GA32043@lst.de>
References: <1403082423-13131-1-git-send-email-hch@lst.de> <CAHQdGtSBN4_MPVUWZ1dhOAXyp9w++YGYLP9fmYNq5RPqzrDwPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSBN4_MPVUWZ1dhOAXyp9w++YGYLP9fmYNq5RPqzrDwPA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 18, 2014 at 07:35:27AM -0400, Trond Myklebust wrote:
> Hi Christoph,
> 
> On Wed, Jun 18, 2014 at 5:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> > The big ACL switched nfs to use generic_listxattr, which calls all existing
> > ->list handlers.  Add a custom .listxattr implementation that only lists
> > the ACLs if they actually are present on the given inode.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reported-by: Philippe Troin <phil@fifi.org>
> > Tested-by: Philippe Troin <phil@fifi.org>
> > ---
> >  fs/nfs/nfs3acl.c  |   43 +++++++++++++++++++++++++++++++++++++++++++
> >  fs/nfs/nfs3proc.c |    4 ++--
> >  2 files changed, 45 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> > index 871d6ed..8f854dd 100644
> > --- a/fs/nfs/nfs3acl.c
> > +++ b/fs/nfs/nfs3acl.c
> > @@ -247,3 +247,46 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
> >         &posix_acl_default_xattr_handler,
> >         NULL,
> >  };
> > +
> > +static int
> > +nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
> > +               size_t size, ssize_t *result)
> 
> Why do you make 'result' a pointer to ssize_t rather than a size_t here?

Because ->listxattr returns a ssize_t, and it points to the variable used
as return value of nfs3_listxattr.

