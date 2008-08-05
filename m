From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Tue, 05 Aug 2008 09:59:48 +0100
Message-ID: <1217926788.3454.685.camel@pmac.infradead.org>
References: <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
	 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
	 <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
	 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
	 <18582.21855.2092.903688@notabene.brown>
	 <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com>
	 <20080805085157.GG21635@disturbed>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, viro@zeniv.linux.org.uk,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Dave Chinner <david@fromorbit.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080805085157.GG21635@disturbed>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-08-05 at 18:51 +1000, Dave Chinner wrote:
> On Mon, Aug 04, 2008 at 02:19:12AM -0400, Chuck Lever wrote:
> > So, the JFFS2 locking problem is a garbage-collection issue.  I'm not
> > sure this is the case with other file systems like XFS and OCFS2.  My
> > impression was that XFS had a transaction logging deadlock,
> 
> Just to clarify - XFS has a directory buffer lock deadlock. That is,
> while reading the contents of the directory buffer it is locked to
> prevent modifications from occurring while extracting the contents.
> Looking up an entry in the directory also requires the directory
> buffer lock (for the same reason), so calling the lookup while
> already holding the directory buffer lock (i.e from the filldir
> callback) will deadlock.

But if we had a ->lookup_locked() or ->lookup_fh() method which is
_guaranteed_ to be called from within your ->readdir(), you could manage
to bypass that locking and avoid the deadlock?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



