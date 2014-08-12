Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43212 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605AbaHLJwo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 05:52:44 -0400
Date: Tue, 12 Aug 2014 11:52:42 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <openosd@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pnfs: factor GETDEVICEINFO implementations
Message-ID: <20140812095242.GA6842@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de> <53E9DFDD.50405@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53E9DFDD.50405@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2014 at 12:35:25PM +0300, Boaz Harrosh wrote:
> > This is mostly done by moving well tested code from the file and block
> > layout drivers to common code.  I've only tested it using the block
> > layout driver, so testing with the other layouts would be greatly
> > appreciated.  I'm mostly concerned about the object layout driver as
> > it had significant differences and missing bug fixes compared to the
> > others.
> > 
> Hi Christoph
> 
> Please say what BUGs have you seen in object-layout-drive?

I've not seen actual bugs, but it's been missing various minor bug
fixes that were applied to the file layout version.

> Do you have this on a public tree somewhere? I would like to test it?

I didn't bother for just those few patches, but I've created a "getdeviceinfo"
branch at git://git.infradead.org/users/hch/pnfs.git

