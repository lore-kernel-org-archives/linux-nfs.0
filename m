Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42314 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbcCAUaO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 15:30:14 -0500
Date: Tue, 1 Mar 2016 21:30:12 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: pNFS SCSI layout support
Message-ID: <20160301203012.GA6033@lst.de>
References: <1456752247-6549-1-git-send-email-hch@lst.de> <20160301192408.GC23792@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160301192408.GC23792@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 01, 2016 at 02:24:08PM -0500, J. Bruce Fields wrote:
> If I understand correctly, you still require NFSEXP_PNFS (the "pnfs"
> export option).  So, setting exporting with the "pnfs" option means
> clients will see only one of block or SCSI layout support (or neither)
> depending on what's possible, with preference for the SCSI layout.

pnfs is supposed to enable any pnfs layout.  Currently only block
is implemented, and with this patch the scsi layout as well.

The scsi layout will be exported if the device supports reservations
and the file system supports block layout exports (SCSI layout is the
same to the file system).  Otherwise the block layout is enabled if
we're on a block device, and the file system supports block layout
exports.

> I still wonder whether this is the best behavior.  How about also adding
> the ability to configure out the block layout?  I think we'd want to be
> sure it's completely off in production.

Being able to configure block layout eventually might be useful.  Do
you simply want separate compile time options?  It's not like a whole
lot of code will go away, it's mostly just entry points.

> Also todo?:
> 	- wireshark support

I've mostly stayed clear of wiresharė.

> 	- testing, including of fencing and reboot recovery.

I've done a fair amount of testing, and the interesting part is
indeed fencing.  The normal path is not very different from the block
layout driver.

> 	(And:
> 	  currently I just share a file between two vm's to use as my
> 	  shared block device, I guess I'll need to set up a real SCSI
> 	  target instead.)

The in-kernel lio target will work just fine.  You can actually export
that directly to VMs using the vhost_scsi driver, but I've not tried
that option myself yet.

> I think there's not any additional documentation required--this is just
> like block layout but without the need to configure fencing.

Exactly.

> (Or do
> people need to do some additional configuration of the SCSI devices?  Or
> check the specs on their hardware to make sure it has support for the
> right features?)

Yes, the device needs to support persistent reservations.

I can write up a little blurb on that.
