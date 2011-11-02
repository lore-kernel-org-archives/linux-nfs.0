Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:49566
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063Ab1KBIag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2011 04:30:36 -0400
Date: Wed, 2 Nov 2011 04:30:33 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsd4_is_junction
Message-ID: <20111102083033.GA28246@infradead.org>
References: <20111029101649.GA12345@infradead.org>
 <20111029174533.GA12122@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111029174533.GA12122@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2011 at 01:45:33PM -0400, J. Bruce Fields wrote:
> Note it also takes the convention that junctions should have the sticky
> bit set without being executable, and it does those checks before
> checking for the xattr, so it shouldn't be doing an xattr read for every
> lookup.
> 
> Grepping for S_NOSEC.... "no suid or xattr security attributes".  But
> "junction.type" isn't a "security attribute", is it?  I may not
> understand what that means.

It's basically to avoid doing getxattr calls if not needed.  So far this
was just for security xattrs, but this one falls into a pretty similar
category.

