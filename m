Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34348
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752681Ab1G0Tr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 15:47:27 -0400
Date: Wed, 27 Jul 2011 15:47:22 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727194722.GA9345@infradead.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
 <20110727160752.GC974@fieldses.org>
 <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
 <20110727181111.GA23009@infradead.org>
 <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
 <20110727193937.GA5354@infradead.org>
 <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 03:44:20PM -0400, Justin Piszcz wrote:
> 
> 
> On Wed, 27 Jul 2011, Christoph Hellwig wrote:
> 
> >On Wed, Jul 27, 2011 at 03:35:01PM -0400, Justin Piszcz wrote:
> >>Currently I do not see any dupes, however I have a script that moves
> >>images out of the directory once an hour:
> >>0 * * * * /usr/local/bin/move_to_old2.sh > /dev/null 2>&1
> >
> >Do you keep adding files to the directory while you move files out?
> Yes, otherwise there are too many files in the directory and viewers, e.g.,
> each geeqie (picture viewer) will use > 4-6GB of memory, so I try to keep
> it around 5,000 pictures or less.
> 
> >What's the rate of additions/removals to the directory?
> Additions it depends, around 5,000 over a 12hr period, 416/hr, current:
> 
> atom:/d1/motion# find cam1|wc
>    5215    5215  166853
> atom:/d1/motion# find cam2|wc
>    5069    5069  162181
> atom:/d1/motion# find cam3|wc
>    5594    5594  178981
> atom:/d1/motion#

This sounds a lot like xfs simply filling up the directory index slots
of files that you just moved out with new files, and nfs falsely
claiming that this is a problem.

Any chance to figure out if the file you hit the printk with was one
that got either recently added or moved when you hit it?  (I can't
follow the nfs code enough to check if it prints the first or second hit
of the same cookie)
