Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41464 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbBKOQT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 09:16:19 -0500
Date: Wed, 11 Feb 2015 06:16:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211141619.GA24299@infradead.org>
References: <20150202161557.GF22301@fieldses.org>
 <20150211123757.GA10532@infradead.org>
 <20150211141257.GA25696@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211141257.GA25696@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 09:12:57AM -0500, J. Bruce Fields wrote:
> I think so.  That's all optional--e.g. for READ_PLUS clients can
> determine server support using ERR_OP_NOTSUPP (or whatever it's called),
> and for attributes they can query the supported_attributes attribute.
> It's possible we'll never support everything in 4.2.

The questions is if we need a useful subset of 4.2 to bother.  I doubt
we'll ever bother with ADBs for example, and the copy offload might
take a while to get everyting sorted.  But exposting most attributes
and supporting READ_PLUS sounds like important enought to implement
before considering 4.2 ready.

