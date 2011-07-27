Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38196
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838Ab1G0Ura (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:47:30 -0400
Date: Wed, 27 Jul 2011 16:47:24 -0400
From: Christoph Hellwig <hch@infradead.org>
To: R?diger Meier <sweet_f_a@gmx.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727204724.GA21314@infradead.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
 <4E306D09.5030704@netapp.com>
 <20110727200240.GA16054@infradead.org>
 <201107272227.03265.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201107272227.03265.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 10:26:55PM +0200, R?diger Meier wrote:
> At the time I've started this thread
> http://comments.gmane.org/gmane.linux.nfs/40863
> I had the feeling that the readdir cache changings in 2.6.37 have 
> something to do with these loop problems.
> 
> After that thread I've accepted that's a general problem with 
> ext4/dirindex and nfs but seeing it again on xfs with just 5000 files 
> I'm in doubt again.

Two separate issues.  For one thing the nfs code simply doesn't seem
to handle changing directories very well, and one and a half the Linux
NFS server might even send incoherent readdir output in a single
protocol reply.

Issue two is that the ext3/4 hashed directory format is too simply (not
to say dumb) to provide a proper 32-bit linear value for the dirent
d_off field.  It's not a complex task, and the first relatively simple
generation of xfs btree directories couldn't handle it either.  The
v2 directory format handles it fine, but at the cost of a much more
complex codebase.

