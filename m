Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35592 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbbDHQVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 12:21:06 -0400
Date: Wed, 8 Apr 2015 18:21:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, xfs@oss.sgi.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] xfs: unlock i_mutex in xfs_break_layouts
Message-ID: <20150408162104.GC16052@lst.de>
References: <1428420944-20965-1-git-send-email-hch@lst.de> <20150407210747.GD3363@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150407210747.GD3363@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2015 at 05:07:47PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 07, 2015 at 05:35:44PM +0200, Christoph Hellwig wrote:
> > We want to drop all I/O path locks when recalling layouts, and that includes
> > i_mutex for the write path.  Without this we get stuck processe when recalls
> > take too long.
> 
> Also if the writer is an nfsd thread than we'd rather just error out
> than wait.

We have no way to know we are called by nfsd here unfortunately.
