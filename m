Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f179.google.com ([209.85.128.179]:55716 "EHLO
	mail-ve0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578AbaGHTBN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 15:01:13 -0400
Received: by mail-ve0-f179.google.com with SMTP id sa20so6061349veb.24
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 12:01:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSgH1tz7cFtLthOvkrvH_RdybA2ezsCq1Y3z_xVoB8k5w@mail.gmail.com>
References: <1403082423-13131-1-git-send-email-hch@lst.de>
	<CAHQdGtSBN4_MPVUWZ1dhOAXyp9w++YGYLP9fmYNq5RPqzrDwPA@mail.gmail.com>
	<20140618130022.GA32043@lst.de>
	<1404833238.7837.5.camel@niobium.home.fifi.org>
	<CAHQdGtSgH1tz7cFtLthOvkrvH_RdybA2ezsCq1Y3z_xVoB8k5w@mail.gmail.com>
Date: Tue, 8 Jul 2014 15:01:12 -0400
Message-ID: <CAHQdGtStu0XT2veR7j0aZQfnvRep0pfpjQVtBEzACw4AVnDHuQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: only show Posix ACLs in listxattr if actually present
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Philippe Troin <phil@fifi.org>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Another gmail vs. vger.kernel.org mailing list battle lost. Resending...

On Tue, Jul 8, 2014 at 2:59 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
>
>
> On Tue, Jul 8, 2014 at 11:27 AM, Philippe Troin <phil@fifi.org> wrote:
>>
>> Hi Chris & Trond,
>>
>> On Wed, 2014-06-18 at 15:00 +0200, Christoph Hellwig wrote:
>> > On Wed, Jun 18, 2014 at 07:35:27AM -0400, Trond Myklebust wrote:
>> > > Hi Christoph,
>> > >
>> > > On Wed, Jun 18, 2014 at 5:07 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > > > The big ACL switched nfs to use generic_listxattr, which calls all
>> > > > existing
>> > > > ->list handlers.  Add a custom .listxattr implementation that only
>> > > > lists
>> > > > the ACLs if they actually are present on the given inode.
>> > > >
>> > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
>> > > > Reported-by: Philippe Troin <phil@fifi.org>
>> > > > Tested-by: Philippe Troin <phil@fifi.org>
>> > > > ---
>> > > >  fs/nfs/nfs3acl.c  |   43
>> > > > +++++++++++++++++++++++++++++++++++++++++++
>> > > >  fs/nfs/nfs3proc.c |    4 ++--
>> > > >  2 files changed, 45 insertions(+), 2 deletions(-)
>> > > >
>> > > > diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
>> > > > index 871d6ed..8f854dd 100644
>> > > > --- a/fs/nfs/nfs3acl.c
>> > > > +++ b/fs/nfs/nfs3acl.c
>> > > > @@ -247,3 +247,46 @@ const struct xattr_handler
>> > > > *nfs3_xattr_handlers[] = {
>> > > >         &posix_acl_default_xattr_handler,
>> > > >         NULL,
>> > > >  };
>> > > > +
>> > > > +static int
>> > > > +nfs3_list_one_acl(struct inode *inode, int type, const char *name,
>> > > > void *data,
>> > > > +               size_t size, ssize_t *result)
>> > >
>> > > Why do you make 'result' a pointer to ssize_t rather than a size_t
>> > > here?
>> >
>> > Because ->listxattr returns a ssize_t, and it points to the variable
>> > used
>> > as return value of nfs3_listxattr.
>>
>> Have these two patches been merged or at least been queued for inclusion
>> into mainline?
>
>
> I believe that the final version of Christoph's patch contained both of his
> former patches, so there should be just one to merge, right?
>
>>
>> I have just checked 3.15.3, and the patches do not seem to be included
>> there.  I haven't tested that specific kernel revision yet though.
>
>
> I've applied the patch to my linux-next branch with a Cc: stable >= 3.14.
> I'll push it to Linus once it has soaked a few days.
>
> Cheers
>   Trond
> --
>
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
