From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
	protocol
Date: Tue, 22 Sep 2009 09:07:32 -0400
Message-ID: <20090922130732.GA19542@infradead.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4AB51538.7060201@schaufler-ca.com> <alpine.LRH.2.00.0909201503390.926@tundra.namei.org> <20090922124755.GA2886@infradead.org> <alpine.LRH.2.00.0909222253470.21052@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33355 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525AbZIVNHb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2009 09:07:31 -0400
In-Reply-To: <alpine.LRH.2.00.0909222253470.21052-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 22, 2009 at 11:03:25PM +1000, James Morris wrote:
> On Tue, 22 Sep 2009, Christoph Hellwig wrote:
> 
> > Note that the mapping should be really simple.  Both the NFS protocol
> > and XFS implement the same IRIX-xattr format that has a numerical
> > namespace instead of the string prefix Linux has.  If you just use the
> > same mapping as XFS it should not have interoperability problems.
> 
> One issue may be that the IRIX protcol for listxattr includes a 
> "attrlist_cursor_kern_t cursor" -- presumably to allow the client to index 
> into large lists of xattrs.  I'm going to guess that this doesn't happen 
> much in practice, although to have interop with IRIX, we'd need to handle 
> this in some useful way.

Yeah, unfortunately XFS experts those semantics via the horrible list
attrs by handle ioctls and carries a lot of cruft around to allow using
the cursor and validating the btree tate stored in it.  It's a real
mess.

Personally I'd just kill it and do a similar indexing scheme that
libattr uses to emulate the IRIX API (libattr/libattr.c:attr_list() in
the libattr repository)

