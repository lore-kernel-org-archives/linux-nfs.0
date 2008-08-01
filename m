From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 01 Aug 2008 09:13:38 +0100
Message-ID: <1217578418.3454.316.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: chucklever@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-31 at 21:31 -0400, Chuck Lever wrote:
> It looks like it needs a directory entry's dentry for a couple of
> reasons:
> 
> 1.  To determine whether a directory entry is a mount point
> 
> 2.  If the client has asked for file handles (via a bitmask) for the
> directory entries

Theoretically, neither of those actually need the _inode_. If it's a
mountpoint, won't it be in the dcache already? So a purely dcache-based
lookup would find it, without having to call through to the file
system's ->lookup() method on a dcache miss?

And to generate the file handle, all you need in the common case is
i_generation? You don't need to pull every inode into core.

-- 
dwmw2

