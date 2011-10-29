Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37373 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933608Ab1J2Rzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Oct 2011 13:55:53 -0400
Date: Sat, 29 Oct 2011 13:55:48 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4_is_junction
Message-ID: <20111029175548.GB12122@fieldses.org>
References: <20111029101649.GA12345@infradead.org>
 <929DFFCE-F92B-4EF6-8C9E-E807AB4FFA9C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <929DFFCE-F92B-4EF6-8C9E-E807AB4FFA9C@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2011 at 01:47:55PM -0400, Chuck Lever wrote:
> 
> On Oct 29, 2011, at 6:16 AM, Christoph Hellwig wrote:
> 
> > This function should probably grow a check for S_NOSEC instead of
> > hitting the filesystems with an xattr read for every lookup.
> 
> It doesn't perform the xattr read on _every_ lookup, but only when the object has a special set of permission bits.
> 
> But actually, it probably doesn't need that 'type" attribute check at all.  It should delegate that check to mountd.  I assume many of those upcalls would hit in the export cache anyway?

You're suggesting doing an upcall on every path that passes the mode-bit
checks?

You'd end up populating the export cache with every path that passes
the mode-bit checks.  I don't think that's a good idea.

--b.
