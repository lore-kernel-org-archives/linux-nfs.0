Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbcCATYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 14:24:10 -0500
Date: Tue, 1 Mar 2016 14:24:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: pNFS SCSI layout support
Message-ID: <20160301192408.GC23792@fieldses.org>
References: <1456752247-6549-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456752247-6549-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 02:24:04PM +0100, Christoph Hellwig wrote:
> This series adds support the pNFS SCSI layout to both the NFS server
> and client.  It's a fairly simple extension to the existing block
> layout drivers, which relies on the Persistent Reservation API in
> the block layer merged a while ago.

Thanks, Christoph!

> On the server side we will now always export SCSI devices a SCSI
> layout.

If I understand correctly, you still require NFSEXP_PNFS (the "pnfs"
export option).  So, setting exporting with the "pnfs" option means
clients will see only one of block or SCSI layout support (or neither)
depending on what's possible, with preference for the SCSI layout.

> I though about allowing exports of multiple layour types
> for the same file system, but both the not really production ready
> nature of block layout fencing, and the horrors of passing options
> to NFS exports made me go with the simple way for now.

I agree that we should keep things simple, and agree that we should not
worry too much about block layout support.

I still wonder whether this is the best behavior.  How about also adding
the ability to configure out the block layout?  I think we'd want to be
sure it's completely off in production.

Also todo?:
	- wireshark support
	- testing, including of fencing and reboot recovery.  (And:
	  currently I just share a file between two vm's to use as my
	  shared block device, I guess I'll need to set up a real SCSI
	  target instead.)

I think there's not any additional documentation required--this is just
like block layout but without the need to configure fencing.  (Or do
people need to do some additional configuration of the SCSI devices?  Or
check the specs on their hardware to make sure it has support for the
right features?)

--b.
