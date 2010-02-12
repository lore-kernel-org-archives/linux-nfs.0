From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Fri, 12 Feb 2010 15:03:59 -0500
Message-ID: <20100212200359.GA23361@fieldses.org>
References: <20100211220454.26466.37578.stgit@case> <20100211220505.26466.99037.stgit@case> <1265986006.3201.112.camel@doink1> <20100212174706.GB22633@infradead.org> <20100212195647.GQ23654@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Alex Elder <aelder@sgi.com>,
	linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: bpm@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971Ab0BLUD3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 15:03:29 -0500
In-Reply-To: <20100212195647.GQ23654@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 12, 2010 at 01:56:47PM -0600, bpm@sgi.com wrote:
> On Fri, Feb 12, 2010 at 12:47:07PM -0500, Christoph Hellwig wrote:
> > if we care enough about the returned error.  But Ben is working against
> > the NFS tree which doesn't have that change yet.
> > 
> > We can deal with that by either commiting the old variant to the nfs
> > tree and then leaving sending Stephen a patch to fix it up in -next,
> > or just not apply the xfs commit_metadata implementation yet, and wait
> > for it until both the xfs and nfs trees have hit mainline.

Assuming the xfs tree's something stable, I could also just go ahead and
pull it into the nfsd tree.

(Or we could do it the other way around--as long as when the merge
window opens we try to send the pull requests in the same order.)

--b.
