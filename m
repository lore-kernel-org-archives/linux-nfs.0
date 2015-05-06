Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:47585 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730AbbEFG4w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 02:56:52 -0400
Date: Wed, 6 May 2015 08:56:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Message-ID: <20150506065651.GA22454@lst.de>
References: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 08:50:24AM +0200, Andreas Gruenbacher wrote:
> The NFSv2 protocol does not have a way to set the atime or mtime of a
> file to the server's current time, only to specific timestamps.  To make
> up for that, when a client sets both atime and mtime to the same
> timestamp and that timestamp is within the last half hour, the server
> sets them to its own current time instead.
> 
> The NFSv3 and later protocols do support setting atime or mtime to the
> server's current time and clients do use that, so skip the NFSv2
> workaround there.
> 
> With this change, clients which have write access but are not the owner
> can still do the equivalent of utimes("file", NULL), for example with
> "touch", but setting atime or mtime to any other value will now
> consistently fail.  This is also the local, non-NFS behavior.

How about moving the workaround into the NFSv2 specific code?

Looks like the call from nfsd_create() should never be used for this
workaround, and the call from nfsd_proc_create isn't ever used for
anything but size updates, leaving nfsd_proc_setattr as the only
caller for which we should apply this hack.
