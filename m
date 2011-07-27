Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38612
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752863Ab1G0UCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:02:50 -0400
Date: Wed, 27 Jul 2011 16:02:40 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727200240.GA16054@infradead.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
 <20110727160752.GC974@fieldses.org>
 <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
 <20110727181111.GA23009@infradead.org>
 <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
 <20110727193937.GA5354@infradead.org>
 <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>
 <20110727194722.GA9345@infradead.org>
 <4E306D09.5030704@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E306D09.5030704@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 03:54:49PM -0400, Bryan Schumaker wrote:
> > Any chance to figure out if the file you hit the printk with was one
> > that got either recently added or moved when you hit it?  (I can't
> > follow the nfs code enough to check if it prints the first or second hit
> > of the same cookie)
> 
> It should be printing on the second hit of a cookie.

But looking closer at it it only prints the directory name and not that
of any of the matching cookies, making it pretty useless to debug any
problem.  (and it makes my previous question to Justin look stupid..).


But so far I still stick to my previous theory that this sounds like
a directory offset getting reused.  How is cache invalidation for
the array supposed to work?  And maybe more importantly, given that he
can only reproduce it with a .38 client did any bugs get fixed in that
code recently that might lead to issues with the cache invalidation?

