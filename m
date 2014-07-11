Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55205 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbaGKHq6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 03:46:58 -0400
Date: Fri, 11 Jul 2014 00:46:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140711074656.GA17661@infradead.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
 <20140710201448.GF26561@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710201448.GF26561@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 04:14:48PM -0400, J. Bruce Fields wrote:
> On Thu, Jul 10, 2014 at 02:07:24PM -0400, Jeff Layton wrote:
> > Here is the deny mode handling overhaul broken out into a separate
> > series, as requested by Christoph. I've tried to address most of
> > his review comments, but I may have missed some. Let me know if
> > if I did.
> 
> They look fine to me; I'll merge them soon absent any objections from
> Christoph.

The whole series looks good, although I've not tested it yet, just the
original full series.

Reviewed-by: Christoph Hellwig <hch@lst.de>
