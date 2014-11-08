Return-Path: BATV+22e315319b93109fe431+4094+infradead.org+hch@bombadil.srs.infradead.org
Date: Fri, 7 Nov 2014 23:06:48 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141108070648.GA18993@infradead.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
 <20141106201341.GD22638@fieldses.org>
 <20141107072637.GA25215@infradead.org>
 <20141107155307.GG22638@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141107155307.GG22638@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 07, 2014 at 10:53:08AM -0500, J. Bruce Fields wrote:
> By the way, the nfsd code is only using i_version when
> IS_I_VERSION(inode), otherwise it falls back on ctime.  Do we have some
> easy way to check for change attribute support now?  Otherwise we're
> ignoring it on xfs and btrfs.

Both btrfs and xfs set MS_I_VERSION.  Btw, could you resend your patches
to move this out of s_flags?

> > there is no difference anyway,
> > as they update the change attribute on every write,
> 
> You mean by that that the change attribute on these filesystems will
> reach the disk at the same time as the write, regardless of whether
> someone does sync or datasync?

Not nessecarily exactly the same time, but vfs_fsync_range will ensure
that we flush both all data for the range, and then flush all metadata.
With the datasync flag set to 1 we will skip inodes where only the
timestamps are dirty.  Interestingly ext4 consideres the change
attribute a skippable timestamp update, XFS doesn't and btrfs doesn't
even try to optimize fdatasync, so we have three different behaviors
for three different filesystems here - my previous post was just based
on the XFS behavior.

> I'm not completely following.  So if the spec had a definite statement
> one way or the other, would that be good enough to make the distinction
> used to?  If we could specify the behavior from scratch, what do you
> think would be the right choice?
> 
> I find it had to figure out the consequences of the change attribute not
> being written at the same time as the write, and whether there's some
> reasonable second-best behavior the server can provide in the case it
> doesn't write them to disk together atomically.  It doesn't currently
> seem like there's much a client can really count on after boot.

Tom, do you think it's reasonable to propose an errata for 4.0/4.1 that
explicitly allows the behavior of updating the change attribute in memory
on a DATA_SYNC4 write, but not nessecarily persisting it?  What about
COMMIT?  Using datasync there would provide even more benefits in
practice there.

I guess I just need to take this to the ietf list.
