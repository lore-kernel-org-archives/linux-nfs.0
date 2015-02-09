Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:36846 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933560AbbBISYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 13:24:36 -0500
Date: Mon, 9 Feb 2015 19:24:33 +0100
From: Christoph Hellwig <hch@lst.de>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 13/19] pnfs/blocklayout: correctly decrement extent
	length
Message-ID: <20150209182433.GA22147@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-14-git-send-email-hch@lst.de> <20150209170140.18f4d004@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150209170140.18f4d004@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 09, 2015 at 05:01:40PM +1100, NeilBrown wrote:
> Hi Christoph,
>  I was reviewing this patch for possible backport.
> As 'extent_length' is sector_t, it is unsigned (either u64 or unsigned long).
> 
> So comparing "<= 0" has the same effect as comparing "== 0".
> So the new checks are not "defensive".
> 
> That doesn't mean they are wrong, but they could be misleading...
> 
> There may be nothing that needs to be done here, but I thought I should let
> you know.

I think this is just an artefact of my earlier unsuccessful attempts at
solving the problem. The real fix is the part that calculates
the "extent_length" variable correctly.
