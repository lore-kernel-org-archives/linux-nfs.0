Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757210AbbJVPuR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 11:50:17 -0400
Date: Thu, 22 Oct 2015 11:50:14 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH 08/10] NFS: Move do_vfs_lock to shared inline
In-Reply-To: <20151022083449.GA3919@infradead.org>
Message-ID: <alpine.OSX.2.19.9992.1510221149360.6711@planck.local>
References: <cover.1444846590.git.bcodding@redhat.com> <1ad951a190be5b737d285ae91c3d8acbfb84ff18.1444846590.git.bcodding@redhat.com> <20151014155521.28475a2d@synchrony.poochiereds.net> <CAHQdGtTYxUdJvvALn0o=KVAwyNxCO03JXhexFysbjq6p9wrjUQ@mail.gmail.com>
 <20151022083449.GA3919@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Oct 2015, Christoph Hellwig wrote:

> On Wed, Oct 21, 2015 at 02:48:45PM -0700, Trond Myklebust wrote:
> > > > +static inline int do_vfs_lock(struct inode *inode, struct file_lock *fl)
> > > > +{
> > > > +     int res = 0;
> > > > +     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > > > +             case FL_POSIX:
> > > > +                     res = posix_lock_inode_wait(inode, fl);
> > > > +                     break;
> > > > +             case FL_FLOCK:
> > > > +                     res = flock_lock_inode_wait(inode, fl);
> > > > +                     break;
> > > > +             default:
> > > > +                     BUG();
> > > > +     }
> > > > +     return res;
> > > > +}
>
> This is a) not a good name for a global function, and b) probably
> shouldn't be inline.
>
> Given how similar the functions are I'd rather have a
> file_lock_inode_wait that handles both cases right in fs/locks.c

Makes sense to me.. I'll do it.
