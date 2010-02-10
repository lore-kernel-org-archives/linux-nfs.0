From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 2/2] xfs_export_operations.commit_metadata
Date: Wed, 10 Feb 2010 16:57:44 -0500
Message-ID: <20100210215744.GB25004@infradead.org>
References: <20100210003220.6021.74943.stgit@case> <20100210003337.6021.10942.stgit@case> <20100210090750.GB21875@infradead.org> <20100210201527.GJ23654@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: bpm@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44853 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab0BJV5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 16:57:45 -0500
In-Reply-To: <20100210201527.GJ23654@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 10, 2010 at 02:15:27PM -0600, bpm@sgi.com wrote:
> > Note that _xfs_log_force_lsn is new in the XFS tree, mainline still
> > has _xfs_log_force with an lsn argument.
> 
> I've been working with Bruce's tree.  Not sure how best to handle that.

Keep working against it for now, the merge fixup will be easy enough.

