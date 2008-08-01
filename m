From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 01 Aug 2008 17:19:30 +0100
Message-ID: <1217607571.3454.417.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	 <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
	 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, viro@zeniv.linux.org.uk,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: chucklever@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-01 at 12:05 -0400, Chuck Lever wrote:
> Some NFSv3 clients don't support READDIRPLUS at all, while some can
> disable it (like Linux, Mac OS, and FreeBSD), and others use it only
> in certain cases (Linux).  I wouldn't describe any of these as saner
> or more commonly encountered than another.

Readdirplus is easy enough to fix with a lookup_fh() method and some way
to check if a given entry is a mountpoint. I'm not worried about that.

> > Or maybe we could just mask the offending attrs out of ->rd_bmval for
> > readdir calls, and say we don't support them? Would anyone scream if we
> > did that?
> 
> I'm not an NFSv4 expert (hence my initial incorrect assertion about
> NFSv4 not supporting readdirplus at all).  I defer to those who are
> actually working on the standard and Linux implementation (Bruce?)
> But typically masking out these features could potentially cause
> severe interoperability problems for certain client implementations.
> We can only know for sure after a lot of testing at multivendor events
> like Connectathon; it's not something I would disable cavalierly.

It's not readdirplus (FATTR4_WORD0_FILEHANDLE?) I was talking about
masking out -- as I said, we can cope with that. It's things that would
_really_ require the inode, like FATTR4_WORD0_ACL, FATTR4_WORD0_CHANGE,
etc.

But still, if masking them out would be a problem, we could use the
existing trick of doing readdir into a buffer and then going back and
doing the actual lookup later. But _only_ for that relatively rare case,
rather than for _all_ users of readdirplus, as we do at the moment.

> I rather prefer making NFSD do the right thing here -- it seems to
> localize and document the issue and provide a solution that all file
> systems can use with a minimum of real fuss.

Yes, that's definitely my preference too. What I've posted is a good
first step to that, and we can talk about improving it later.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



