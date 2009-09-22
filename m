From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
	protocol
Date: Tue, 22 Sep 2009 08:47:55 -0400
Message-ID: <20090922124755.GA2886@infradead.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4AB51538.7060201@schaufler-ca.com> <alpine.LRH.2.00.0909201503390.926@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0909201503390.926@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 20, 2009 at 03:13:28PM +1000, James Morris wrote:
> As a first step, it keeps the semantics simple, and provides a direct 
> mapping between the userland API and the NFS protocol.  System level 
> xattrs may have semantics which extend beyond the simple NFS xattr 
> protocol (e.g. full security labeling as we've previously discussed & 
> documented needs to convey more than just object labels).
> 
> Some xattr uses are internal local interfaces, such as with Linux ACLs, 
> where xattrs are used internally for storing the ACL data, but the exposed 
> API is quite different (as is the NFS protocol).
> 
> We can go beyond user.*, but I think each system-level xattr exposed via 
> NFS will need to be considered on a case-by-case basis.

Note that the mapping should be really simple.  Both the NFS protocol
and XFS implement the same IRIX-xattr format that has a numerical
namespace instead of the string prefix Linux has.  If you just use the
same mapping as XFS it should not have interoperability problems.

