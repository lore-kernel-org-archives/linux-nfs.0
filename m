Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:33709 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab1G0ToV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 15:44:21 -0400
Date: Wed, 27 Jul 2011 15:44:20 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <20110727193937.GA5354@infradead.org>
Message-ID: <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <20110727181111.GA23009@infradead.org> <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
 <20110727193937.GA5354@infradead.org>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Wed, 27 Jul 2011, Christoph Hellwig wrote:

> On Wed, Jul 27, 2011 at 03:35:01PM -0400, Justin Piszcz wrote:
>> Currently I do not see any dupes, however I have a script that moves
>> images out of the directory once an hour:
>> 0 * * * * /usr/local/bin/move_to_old2.sh > /dev/null 2>&1
>
> Do you keep adding files to the directory while you move files out?
Yes, otherwise there are too many files in the directory and viewers, e.g.,
each geeqie (picture viewer) will use > 4-6GB of memory, so I try to keep
it around 5,000 pictures or less.

> What's the rate of additions/removals to the directory?
Additions it depends, around 5,000 over a 12hr period, 416/hr, current:

atom:/d1/motion# find cam1|wc
    5215    5215  166853
atom:/d1/motion# find cam2|wc
    5069    5069  162181
atom:/d1/motion# find cam3|wc
    5594    5594  178981
atom:/d1/motion#

>
> If we add files to the directory while removing others we could easily
> re-use the same offset for a different file.
>

Justin.

