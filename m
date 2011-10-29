Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49716 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933496Ab1J2Rpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Oct 2011 13:45:36 -0400
Date: Sat, 29 Oct 2011 13:45:33 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsd4_is_junction
Message-ID: <20111029174533.GA12122@fieldses.org>
References: <20111029101649.GA12345@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111029101649.GA12345@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2011 at 06:16:49AM -0400, Christoph Hellwig wrote:
> This function should probably grow a check for S_NOSEC instead of
> hitting the filesystems with an xattr read for every lookup.

Note it also takes the convention that junctions should have the sticky
bit set without being executable, and it does those checks before
checking for the xattr, so it shouldn't be doing an xattr read for every
lookup.

Grepping for S_NOSEC.... "no suid or xattr security attributes".  But
"junction.type" isn't a "security attribute", is it?  I may not
understand what that means.

--b.
