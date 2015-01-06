Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:54474 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403AbbAFTmQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 14:42:16 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so31105926pdb.38
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 11:42:16 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 6 Jan 2015 11:42:05 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150106114205.4151269c@synchrony.poochiereds.net>
In-Reply-To: <20150106193949.GD28003@fieldses.org>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
	<1420561721-9150-15-git-send-email-hch@lst.de>
	<20150106171658.GD12067@fieldses.org>
	<20150106173957.GA16200@lst.de>
	<20150106193949.GD28003@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Jan 2015 14:39:49 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jan 06, 2015 at 06:39:57PM +0100, Christoph Hellwig wrote:
> > On Tue, Jan 06, 2015 at 12:16:58PM -0500, J. Bruce Fields wrote:
> > > > +file system must sit on shared storage (typically iSCSI) that is accessible
> > > > +to the clients as well as the server.  The file system needs to either sit
> > > > +directly on the exported volume, or on a RAID 0 using the MD software RAID
> > > > +driver with the version 1 superblock format.  If the filesystem uses sits
> > > > +on a RAID 0 device the clients will automatically stripe their I/O over
> > > > +multiple LUNs.
> > > > +
> > > > +On the server pNFS block volume support is automatically if the file system
> > > 
> > > s/automatically/automatically enabled/.
> > > 
> > > So there's no server-side configuration required at all?
> > 
> > The only required configuration is the fencing helper script if you
> > want to be able to fence a non-responding client.  For simple test setups
> > everything will just work out of the box.
> 
> I think we want at a minimum some kind of server-side "off" switch.
> 
> If nothing else it'd be handy for troubleshooting.  ("Server crashing?
> Could you turn off pnfs blocks and try again?")
> 
> --b.

Or maybe an "on" switch?

We have some patches (not posted currently) that add a "pnfs" export
option. Maybe we should add that and only enable pnfs on exports that
have that option present?

-- 
Jeff Layton <jlayton@primarydata.com>
