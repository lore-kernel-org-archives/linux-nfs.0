From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous locks for cluster exports
Date: Sat, 3 Feb 2007 20:44:58 -0500
Message-ID: <20070204014458.GF7588@fieldses.org>
References: <20070203083929.GA18828@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203083929.GA18828@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 08:39:29AM +0000, Christoph Hellwig wrote:
> On Sat, Feb 03, 2007 at 12:30:55AM -0500, J. Bruce Fields wrote:
> > The gfs2 implementation in the last patch is (unfortunately) still just
> > a rough draft that needs some more thought and some testing.
> 
> So what exactly in this patch is tested?

Marc's testing this stuff against gpfs.  Yeah, I know, I know.  I'm not
asking this be merged until it makes sense purely from the point of view
of in-tree users.

Right now all we know is that it doesn't appear to break local or NFS
locking, that it works for one out-of-tree filesystem, and that it looks
like it should be right for gfs--but the gfs implementation is just a
sketch, totally untested.  I'm here at connectathon working with one of
the gfs developers, so hopefully that should change soon.

We'd like to work with ocfs too at some point, but last I heard they
hadn't yet tried to implement cluster-coherent posix locking.

--b.
