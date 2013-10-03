Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48165 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab3JCMhK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 08:37:10 -0400
Date: Thu, 3 Oct 2013 05:37:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131003123707.GA16120@infradead.org>
References: <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <20131001203047.GH16245@pad.fieldses.org>
 <524C0556.9070705@primarydata.com>
 <20131002160759.GB27988@infradead.org>
 <524D0873.40602@primarydata.com>
 <20131003095511.GA30147@infradead.org>
 <524D6312.7020709@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524D6312.7020709@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 03:29:06PM +0300, Benny Halevy wrote:
> I picked gfs2 as the initial use case for simplicity and ease of review.
> If there is a rough consensus that it's useless and not worthy of inclusion
> then the one we care about the most is exofs that has a more complete pnfs
> implementation.

This was in reference to file layout implementation details, so exofs
isn't a contender there.

As far as exofs is concerned a pnfs implementation based on it has just
as much toy status as the current gfs2 one.  While the pnfs side of it
might as well be a lot better, a filesystem that lacks all the integrity
and scalability features developed in the last 30 years can't be
considered more than a proof of concept.

