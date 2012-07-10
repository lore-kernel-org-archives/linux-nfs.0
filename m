Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41040 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab2GJTVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 15:21:43 -0400
Date: Tue, 10 Jul 2012 15:21:40 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        stable@kernel.org
Subject: Re: [PATCH 4/7] nfsd4: our filesystems are normally case sensitive
Message-ID: <20120710192140.GA5128@fieldses.org>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
 <1341936466-3821-5-git-send-email-bfields@redhat.com>
 <20120710173432.GA18485@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120710173432.GA18485@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 01:34:32PM -0400, Christoph Hellwig wrote:
> On Tue, Jul 10, 2012 at 12:07:43PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Actually, xfs can optionally be case insensitive; we'll handle that case
> > in later patches.
> 
> The same is true for jfs, btw.

Oops, I missed that.

I need to resend the patches to test for that soon.

--b.
