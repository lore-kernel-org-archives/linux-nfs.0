Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:57454 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191AbbAFRkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 12:40:01 -0500
Date: Tue, 6 Jan 2015 18:39:57 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150106173957.GA16200@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-15-git-send-email-hch@lst.de> <20150106171658.GD12067@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106171658.GD12067@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 12:16:58PM -0500, J. Bruce Fields wrote:
> > +file system must sit on shared storage (typically iSCSI) that is accessible
> > +to the clients as well as the server.  The file system needs to either sit
> > +directly on the exported volume, or on a RAID 0 using the MD software RAID
> > +driver with the version 1 superblock format.  If the filesystem uses sits
> > +on a RAID 0 device the clients will automatically stripe their I/O over
> > +multiple LUNs.
> > +
> > +On the server pNFS block volume support is automatically if the file system
> 
> s/automatically/automatically enabled/.
> 
> So there's no server-side configuration required at all?

The only required configuration is the fencing helper script if you
want to be able to fence a non-responding client.  For simple test setups
everything will just work out of the box.
