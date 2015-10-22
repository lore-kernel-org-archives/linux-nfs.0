Return-Path: <BATV+005935976f176913d2ff+4442+infradead.org+hch@bombadil.srs.infradead.org>
Date: Thu, 22 Oct 2015 01:34:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH 08/10] NFS: Move do_vfs_lock to shared inline
Message-ID: <20151022083449.GA3919@infradead.org>
References: <cover.1444846590.git.bcodding@redhat.com>
 <1ad951a190be5b737d285ae91c3d8acbfb84ff18.1444846590.git.bcodding@redhat.com>
 <20151014155521.28475a2d@synchrony.poochiereds.net>
 <CAHQdGtTYxUdJvvALn0o=KVAwyNxCO03JXhexFysbjq6p9wrjUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTYxUdJvvALn0o=KVAwyNxCO03JXhexFysbjq6p9wrjUQ@mail.gmail.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 21, 2015 at 02:48:45PM -0700, Trond Myklebust wrote:
> > > +static inline int do_vfs_lock(struct inode *inode, struct file_lock *fl)
> > > +{
> > > +     int res = 0;
> > > +     switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
> > > +             case FL_POSIX:
> > > +                     res = posix_lock_inode_wait(inode, fl);
> > > +                     break;
> > > +             case FL_FLOCK:
> > > +                     res = flock_lock_inode_wait(inode, fl);
> > > +                     break;
> > > +             default:
> > > +                     BUG();
> > > +     }
> > > +     return res;
> > > +}

This is a) not a good name for a global function, and b) probably
shouldn't be inline.

Given how similar the functions are I'd rather have a
file_lock_inode_wait that handles both cases right in fs/locks.c
