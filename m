Return-Path: bfields@fieldses.org
Date: Fri, 7 Nov 2014 10:53:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141107155307.GG22638@fieldses.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
 <20141106201341.GD22638@fieldses.org>
 <20141107072637.GA25215@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141107072637.GA25215@infradead.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 06, 2014 at 11:26:37PM -0800, Christoph Hellwig wrote:
> [adding Tom to Cc for a little spec clarification]
> 
> On Thu, Nov 06, 2014 at 03:13:41PM -0500, J. Bruce Fields wrote:
> > > Makes sense to me.--b.
> > 
> > Applying for 3.19.--b.
> 
> Looking at the specs again I have a little doubt about DATA_SYNC vs
> NFSv4.
> 
> RFC3530, 14.2.36. sais:
> 
> "If stable is DATA_SYNC4,
>  then the server must commit all of the data to stable storage and
>  enough of the metadata to retrieve the data before returning."
> 
> So far so good, and exactly matches our fdatasync semantics, which
> force out the inode itself, and any indirect blocks or extent tree
> information, ignoring only time stamp updates.
> 
> But for NFSv4 there is a consideration that we don't have for local 
> access: the change attribute.  For most exportable filesystems we
> use the ctime timestamp for that, which does not get persisted by
> fdatasync.  Unfortunately the whole language about DATA_SYNC is
> so vague that I'm tempted to withraw my patch due to this issue.
> 
> Note that for filesystems natively implementing the change attribute
> (btrfs, XFSv5 and ext4 with a mount option)

By the way, the nfsd code is only using i_version when
IS_I_VERSION(inode), otherwise it falls back on ctime.  Do we have some
easy way to check for change attribute support now?  Otherwise we're
ignoring it on xfs and btrfs.

> there is no difference anyway,
> as they update the change attribute on every write,

You mean by that that the change attribute on these filesystems will
reach the disk at the same time as the write, regardless of whether
someone does sync or datasync?

> which doesn't
> fall under the fdatasync umbrella, although I think it generally should,
> as it would render fdatasync useless on thee otherwise.
> 
> Summary:  a patch like mine above probably doesn't make sense, and
> as far as I can tell we should deprecate use of DATA_SYNC4 for NFSv4,
> because it cannot be different from FILE_SYNC4 due to the specification
> for the change attribute.

I'm not completely following.  So if the spec had a definite statement
one way or the other, would that be good enough to make the distinction
used to?  If we could specify the behavior from scratch, what do you
think would be the right choice?

I find it had to figure out the consequences of the change attribute not
being written at the same time as the write, and whether there's some
reasonable second-best behavior the server can provide in the case it
doesn't write them to disk together atomically.  It doesn't currently
seem like there's much a client can really count on after boot.

--b.
