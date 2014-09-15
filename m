Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:34142 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535AbaIOVLR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Sep 2014 17:11:17 -0400
Date: Mon, 15 Sep 2014 23:11:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Daniel Gryniewicz <dang@linuxbox.com>
Cc: Benny Halevy <bhalevy@primarydata.com>, linux-nfs@vger.kernel.org,
        Boaz Harrosh <boaz@plexistor.com>
Subject: Re: layoutcommit space reservation for the objlayout driver
Message-ID: <20140915211113.GA30397@lst.de>
References: <1538636805.101.1410805338811.JavaMail.root@thunderbeast.private.linuxbox.com> <933718474.103.1410805353074.JavaMail.root@thunderbeast.private.linuxbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <933718474.103.1410805353074.JavaMail.root@thunderbeast.private.linuxbox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2014 at 02:22:33PM -0400, Daniel Gryniewicz wrote:
> This is probably the case, then.  The object layout layoutupdate is only 16 bytes long and is fixed size, so it wouldn't take much extra space for it to never hit.

Yes, I suspect at the moment we just overallocate the XDR buffer due
to slab or nfs implementation details, which are bound to chance as some
point without notice.
