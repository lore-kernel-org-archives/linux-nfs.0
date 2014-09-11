Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37716 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744AbaIKTDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 15:03:49 -0400
Date: Thu, 11 Sep 2014 15:03:45 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv2/3 vs v4 error codes?
Message-ID: <20140911190345.GA20501@fieldses.org>
References: <20140910221650.GD29452@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910221650.GD29452@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 03:16:50PM -0700, Christoph Hellwig wrote:
> As a followup to the fallocate discussion I checked what we map ENODEV
> to in nfsd.  Turns out we map it to NFSERR_NODEV, which doesn't exist
> in eiter NFSv4.0 nor NFSv4.1 despite the comment in
> include/uapi/linux/nfs.h claiming otherwise.

That's interesting.  Is there a reasonable alternative, or is this a
protocol bug?

> I also just ran into another issue where nfserrno translates a large
> lits of errors into NFSERR_JUKEBOX, but for v4 we'd really want
> NFSERR_DELAY instead for most of them.

The distinction is academic as they're both 10008.

> Is it time for a version specific errno mapping?

I'm certainly not opposed if it turns out to be necessary.

--b.
