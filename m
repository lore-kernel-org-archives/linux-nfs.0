Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbaGKSxL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 14:53:11 -0400
Date: Fri, 11 Jul 2014 14:53:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Check acl returned from get_acl/posix_acl_from_mode
Message-ID: <20140711185308.GD9775@fieldses.org>
References: <53BD4988.6020302@gmail.com>
 <20140710074324.GB32584@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710074324.GB32584@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 12:43:24AM -0700, Christoph Hellwig wrote:
> On Wed, Jul 09, 2014 at 09:54:16PM +0800, Kinglong Mee wrote:
> > Commit 4ac7249ea5 (nfsd: use get_acl and ->set_acl)
> > don't check the acl returned from get_acl()/posix_acl_from_mode().
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 3.17.

--b.
