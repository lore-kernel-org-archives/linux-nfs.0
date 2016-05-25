Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59928 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbcEYSVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 14:21:44 -0400
Date: Wed, 25 May 2016 14:21:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <loghyr@primarydata.com>
Cc: hch <hch@lst.de>, Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] nfsd: Provide a config option for flex file layouts
Message-ID: <20160525182144.GC12306@fieldses.org>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-5-git-send-email-loghyr@primarydata.com>
 <20160525150917.GC27535@lst.de>
 <5F7AEB38-6AFE-4BB5-B52A-3EF358FF5B46@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5F7AEB38-6AFE-4BB5-B52A-3EF358FF5B46@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 06:19:20PM +0000, Thomas Haynes wrote:
> 
> > On May 25, 2016, at 8:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> > 
> >> +config NFSD_FLEXFILELAYOUT
> >> +	bool "NFSv4.1 server support for pNFS Flex File layouts"
> >> +	depends on NFSD_V4
> >> +	select NFSD_PNFS
> >> +	help
> >> +	  This option enables support for the exporting pNFS Flex File
> >> +	  layouts in the kernel's NFS server. The pNFS Flex File  layout
> >> +	  enables NFS clients to directly perform I/O to NFSv3 devices
> >> +	  accesible to both the server and the clients.  See
> >> +	  draft-ietf-nfsv4-flex-files for more details.
> > 
> > How about a bit more of a warning that this is just a toy demo server?
> > 
> 
> Add:
> 
>           Warning, this server implements the bare minimum functionality for
>           to be a flex file server - it is more for testing the client
>           than for a production server.

I'd leave out the "more", and just say "it is for testing the client,
not for use in production".

Which makes me wonder whether it's even worth merging.

But it's very small and self-contained, so I'm inclined to go ahead,
pending other review.

--b.
