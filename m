Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:39112 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753294Ab1G0U1I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:27:08 -0400
From: =?iso-8859-1?q?R=FCdiger_Meier?= <sweet_f_a@gmx.de>
To: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Date: Wed, 27 Jul 2011 22:26:55 +0200
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <4E306D09.5030704@netapp.com> <20110727200240.GA16054@infradead.org>
In-Reply-To: <20110727200240.GA16054@infradead.org>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201107272227.03265.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 July 2011, Christoph Hellwig wrote:
> On Wed, Jul 27, 2011 at 03:54:49PM -0400, Bryan Schumaker wrote:
> > It should be printing on the second hit of a cookie.
>
> But looking closer at it it only prints the directory name and not
> that of any of the matching cookies, making it pretty useless to
> debug any problem.  (and it makes my previous question to Justin look
> stupid..).
>
>
> But so far I still stick to my previous theory that this sounds like
> a directory offset getting reused.  How is cache invalidation for
> the array supposed to work?  And maybe more importantly, given that
> he can only reproduce it with a .38 client did any bugs get fixed in
> that code recently that might lead to issues with the cache
> invalidation?

At the time I've started this thread
http://comments.gmane.org/gmane.linux.nfs/40863
I had the feeling that the readdir cache changings in 2.6.37 have 
something to do with these loop problems.

After that thread I've accepted that's a general problem with 
ext4/dirindex and nfs but seeing it again on xfs with just 5000 files 
I'm in doubt again.

cu,
Rudi
