Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44957 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbaGKOba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 10:31:30 -0400
Date: Fri, 11 Jul 2014 10:31:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140711143128.GA7305@fieldses.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
 <20140710201448.GF26561@fieldses.org>
 <20140711074656.GA17661@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140711074656.GA17661@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 11, 2014 at 12:46:56AM -0700, Christoph Hellwig wrote:
> On Thu, Jul 10, 2014 at 04:14:48PM -0400, J. Bruce Fields wrote:
> > On Thu, Jul 10, 2014 at 02:07:24PM -0400, Jeff Layton wrote:
> > > Here is the deny mode handling overhaul broken out into a separate
> > > series, as requested by Christoph. I've tried to address most of
> > > his review comments, but I may have missed some. Let me know if
> > > if I did.
> > 
> > They look fine to me; I'll merge them soon absent any objections from
> > Christoph.
> 
> The whole series looks good, although I've not tested it yet, just the
> original full series.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks!

--b.
