Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38395 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833AbaGYBkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jul 2014 21:40:37 -0400
Date: Thu, 24 Jul 2014 21:40:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com
Subject: Re: [PATCH v2 0/4] nfsd: don't let nfs4_file pin down the inode when
 it has no open state
Message-ID: <20140725014034.GB2216@fieldses.org>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
 <20140723204712.GI9118@fieldses.org>
 <20140724152203.GA14503@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140724152203.GA14503@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 24, 2014 at 08:22:03AM -0700, Christoph Hellwig wrote:
> On Wed, Jul 23, 2014 at 04:47:12PM -0400, J. Bruce Fields wrote:
> > Looks OK to me.  I'll give it a day in case Christoph or someone spots a
> > problem.
> 
> The series looks fine, but I've not done a detailed review.

OK, applied and pushed out.

--b.
