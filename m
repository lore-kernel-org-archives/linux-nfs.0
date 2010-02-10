From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 2/2] xfs_export_operations.commit_metadata
Date: Wed, 10 Feb 2010 05:11:30 -0500
Message-ID: <20100210101130.GA7993@infradead.org>
References: <20100210003220.6021.74943.stgit@case> <20100210003337.6021.10942.stgit@case> <20100210090750.GB21875@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42955 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab0BJKLb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 05:11:31 -0500
In-Reply-To: <20100210090750.GB21875@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 10, 2010 at 04:07:50AM -0500, Christoph Hellwig wrote:
> > +			/*
> > +			 * AFAICS the child is always modified after the parent
> > +			 * in nfsd so should always have a larger lsn.
> > +			 */
> > +			if (c_xip->i_itemp->ili_last_lsn > force_lsn) {
> > +				force_lsn = c_xip->i_itemp->ili_last_lsn;
> > +			} else {
> > +				force_lsn = 0; /* whole thing */
> > +			}
> 
> I wouldn't rely on that and always take the larger one.

Or we could use that fact for making the prototype saner:

 - the commit_metadata only takes a single inode to force out
 - we make sure to always call in on the child first.  For any
   log based filesystem that will force the parent update, too.
 - we then call it on the parent, which will be a no-op and thus
   fast for a log based filesystem, but still provide a fallback
   if that is not the case.

