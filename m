From: Christoph Hellwig <hch@lst.de>
Subject: Re: nfsd stuckage
Date: Wed, 7 Jan 2009 00:03:56 +0100
Message-ID: <20090106230356.GA31520@lst.de>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <20090106230244.GB13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>, Eric Sesterhenn <snakebyte@gmx.de>,
	hch@lst.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:58580 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbZAFXEi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:04:38 -0500
In-Reply-To: <20090106230244.GB13785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 06:02:44PM -0500, J. Bruce Fields wrote:
> On Tue, Jan 06, 2009 at 02:56:12PM -0800, Andrew Morton wrote:
> > 
> > I just built current mainline plus the just-sent 266 -mm patches.
> > 
> > The machine failed to power off when hit with `halt -pfn'.  dmesg output:
> 
> Christoph, can you live with this for now?

nfsd part is well, livable.  But the fs/sync.c is buggy as stackable
filesystems can call vfs_fsync with a NULL pointer due to nfs calling it
that way, so please drop that hunk.
