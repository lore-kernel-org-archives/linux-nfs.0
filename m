From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 22 Sep 2009 23:03:25 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0909222253470.21052@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4AB51538.7060201@schaufler-ca.com> <alpine.LRH.2.00.0909201503390.926@tundra.namei.org> <20090922124755.GA2886@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090922124755.GA2886@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 22 Sep 2009, Christoph Hellwig wrote:

> Note that the mapping should be really simple.  Both the NFS protocol
> and XFS implement the same IRIX-xattr format that has a numerical
> namespace instead of the string prefix Linux has.  If you just use the
> same mapping as XFS it should not have interoperability problems.

One issue may be that the IRIX protcol for listxattr includes a 
"attrlist_cursor_kern_t cursor" -- presumably to allow the client to index 
into large lists of xattrs.  I'm going to guess that this doesn't happen 
much in practice, although to have interop with IRIX, we'd need to handle 
this in some useful way.

Otherwise, yes, mapping to the IRIX protocol should be straightforward.
We can use the side-protocol number+version to detect that we're talking 
to an IRIX box.


- James
-- 
James Morris
<jmorris@namei.org>
