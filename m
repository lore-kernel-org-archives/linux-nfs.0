From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Wed, 6 Aug 2008 10:08:05 +1000
Message-ID: <20080806000805.GJ21635@disturbed>
References: <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com> <1217607571.3454.417.camel@pmac.infradead.org> <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com> <20080802182644.GE30454@fieldses.org> <18581.40178.976747.769343@notabene.brown> <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com> <18582.21855.2092.903688@notabene.brown> <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com> <20080805085157.GG21635@disturbed> <18584.56584.98868.881298@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: chucklever@gmail.com, "J. Bruce Fields" <bfields@fieldses.org>,
	David Woodhouse <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <18584.56584.98868.881298@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 06, 2008 at 09:06:48AM +1000, Neil Brown wrote:
> On Tuesday August 5, david@fromorbit.com wrote:
> > On Mon, Aug 04, 2008 at 02:19:12AM -0400, Chuck Lever wrote:
> > > So, the JFFS2 locking problem is a garbage-collection issue.  I'm=
 not
> > > sure this is the case with other file systems like XFS and OCFS2.=
  My
> > > impression was that XFS had a transaction logging deadlock,
> >=20
> > Just to clarify - XFS has a directory buffer lock deadlock. That is=
,
> > while reading the contents of the directory buffer it is locked to
> > prevent modifications from occurring while extracting the contents.
> > Looking up an entry in the directory also requires the directory
> > buffer lock (for the same reason), so calling the lookup while
> > already holding the directory buffer lock (i.e from the filldir
> > callback) will deadlock.
>=20
> How much cost would it be, do you think, to drop the lock across the
> call to filldir?  Then reclaim the lock, validate pointers etc agains=
t
> a 'version' counter, and restart based on the current telldir cookie
> if needed?

The problem is that the dabuf is a temporary structure only valid
for the length of a block read or transaction - it is built from
buffers that are cached and provide persistence. Remember, XFS
supports large, non-contiguous, directory blocks and so the
directory code extremely complex in places. To do the above we need
to pretty much tear down the dabuf to unlock everything before the
filldir call, then build it in the lookup during the filldir call,
then tear it down for the readdir to build it again, validate,
etc....

Basically, what you suggest above still needs the same
infrastructure as a proper shared locking scheme on the dabuf to
work efficiently. Using a shared locking scheme gives much more
benefit, because it will alow parallel directory traversals and
lookups in *all cases*, not just NFS.

Basically, I don't want to replace an _easily validated_ hack with
some other nasty, non-trivial, disaster-waiting-to-happen hack that
doesn't provide any benefit over the current hack....

> To me, that is the generic solution to allowing filldir to call
> ->lookup.  I'm just not sure what it costs to be constantly dropping
> and reclaiming the lock in the normal case where ->lookup isn't being
> called.

Allowing filldir to call lookup require=D1=95 shared read lock semantic=
s
between readdir and lookup. I don't think any filesystem has that
implemented, it can't be implemented with i_mutex involved, and it
will be non-trivial to implement in the filesystems that need it.

Normally the generic solution is the lowest common denominator
solution - move the double buffering into the NFSD so everything
works with the current exclusive locking semantics, and then provide
another filldir+lookup for filesystem that are able to do something
special to avoid the slower generic path.

Cheers,

Dave.
--=20
Dave Chinner
david@fromorbit.com
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
