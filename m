From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Tue, 5 Aug 2008 19:47:05 +1000
Message-ID: <20080805094705.GH21635@disturbed>
References: <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com> <1217607571.3454.417.camel@pmac.infradead.org> <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com> <20080802182644.GE30454@fieldses.org> <18581.40178.976747.769343@notabene.brown> <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com> <18582.21855.2092.903688@notabene.brown> <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com> <20080805085157.GG21635@disturbed> <1217926788.3454.685.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, viro@zeniv.linux.org.uk,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1217926788.3454.685.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 05, 2008 at 09:59:48AM +0100, David Woodhouse wrote:
> On Tue, 2008-08-05 at 18:51 +1000, Dave Chinner wrote:
> > On Mon, Aug 04, 2008 at 02:19:12AM -0400, Chuck Lever wrote:
> > > So, the JFFS2 locking problem is a garbage-collection issue.  I'm not
> > > sure this is the case with other file systems like XFS and OCFS2.  My
> > > impression was that XFS had a transaction logging deadlock,
> > 
> > Just to clarify - XFS has a directory buffer lock deadlock. That is,
> > while reading the contents of the directory buffer it is locked to
> > prevent modifications from occurring while extracting the contents.
> > Looking up an entry in the directory also requires the directory
> > buffer lock (for the same reason), so calling the lookup while
> > already holding the directory buffer lock (i.e from the filldir
> > callback) will deadlock.
> 
> But if we had a ->lookup_locked() or ->lookup_fh() method which is
> _guaranteed_ to be called from within your ->readdir(), you could manage
> to bypass that locking and avoid the deadlock?

I *think* it's possible. It's definitely in the realm of difficult
because the buffer locks are a couple of layers removed from the
directory code and both readdir and lookup assume exclusive access to
the directory block.

We'd probably have to introduce a directory buffer (dabuf) cache
layer with it's own locking to allow multiple accessors to the
buffer at the same time. Christoph might have some other ideas for
this, but I think it's going to take significant surgery
to implement a 'recursive lockless lookup' like this.

The main problem you are going to have is finding someone who has
the time to do the XFS work. If you only implement this lookup
interface, then I'd say it's going to be some time before XFS would
actually use it....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
