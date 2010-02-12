From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Fri, 12 Feb 2010 15:37:01 -0500
Message-ID: <20100212203701.GB28731@infradead.org>
References: <20100211220454.26466.37578.stgit@case> <20100211220505.26466.99037.stgit@case> <1265986006.3201.112.camel@doink1> <20100212174706.GB22633@infradead.org> <20100212195647.GQ23654@sgi.com> <20100212200359.GA23361@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bpm@sgi.com, Christoph Hellwig <hch@infradead.org>,
	Alex Elder <aelder@sgi.com>, linux-nfs@vger.kernel.org,
	xfs@oss.sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37072 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757621Ab0BLUhC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2010 15:37:02 -0500
In-Reply-To: <20100212200359.GA23361@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 12, 2010 at 03:03:59PM -0500, J. Bruce Fields wrote:
> Assuming the xfs tree's something stable, I could also just go ahead and
> pull it into the nfsd tree.
> 
> (Or we could do it the other way around--as long as when the merge
> window opens we try to send the pull requests in the same order.)

The xfs tree is supposed to be stable and we only had very few incidents
where a patch had to be pulled again.  But it's also a quite large set
of changes. 

