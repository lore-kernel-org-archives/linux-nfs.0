Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1605 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbaIOSWk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Sep 2014 14:22:40 -0400
Date: Mon, 15 Sep 2014 14:22:33 -0400 (EDT)
From: Daniel Gryniewicz <dang@linuxbox.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Benny Halevy <bhalevy@primarydata.com>, linux-nfs@vger.kernel.org,
        Boaz Harrosh <boaz@plexistor.com>
Message-ID: <933718474.103.1410805353074.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1538636805.101.1410805338811.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: layoutcommit space reservation for the objlayout driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- "Christoph Hellwig" <hch@lst.de> wrote:

> On Mon, Sep 15, 2014 at 12:05:55PM +0300, Boaz Harrosh wrote:
> > I do not understand. This used to work just fine. Please point me
> to
> > the patch that broke it?
> > (And since when are we allowed to brake old code?)
> 
> I bet it still works the same way it does as commited, which doesn't
> make it right.  The way the NFS XDR buffer allocations work seems to
> be
> that you can actually slightly overun it without things falling
> apart,
> but that doesn't make it right.  E.g. it took a fairly larger overrun
> in the block layout driver to finally find the issues, and most of
> the
> time it was just silent truncations, real corruption happened less
> often.
> 
> But to make sure things work properly in the long run you'd really
> want
> to have the proper allocation.

This is probably the case, then.  The object layout layoutupdate is only 16 bytes long and is fixed size, so it wouldn't take much extra space for it to never hit.

Daniel
