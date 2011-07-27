Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:34028 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab1G0TfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 15:35:03 -0400
Date: Wed, 27 Jul 2011 15:35:01 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <20110727181111.GA23009@infradead.org>
Message-ID: <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <20110727181111.GA23009@infradead.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Wed, 27 Jul 2011, Christoph Hellwig wrote:

> Justin,
>
> can you please run the attached test program on the affected directory
> on the server, and see if you see duplicates in the d_off colum.  Unless
> you have privacy concerns I would also love to see the full output.
>
>

Hi,

Done:

atom:/d1/motion/cam1# /root/getdents  > /tmp/cam1-out.txt
atom:/d1/motion/cam1# cd ../cam2
atom:/d1/motion/cam2# /root/getdents  > /tmp/cam2-out.txt
atom:/d1/motion/cam2# cd ../cam3
atom:/d1/motion/cam3# /root/getdents  > /tmp/cam3-out.txt
atom:/d1/motion/cam3#

Files:
http://home.comcast.net/~jpiszcz/20110727/cam1-out.txt
http://home.comcast.net/~jpiszcz/20110727/cam2-out.txt
http://home.comcast.net/~jpiszcz/20110727/cam3-out.txt

Currently I do not see any dupes, however I have a script that moves 
images out of the directory once an hour:
0 * * * * /usr/local/bin/move_to_old2.sh > /dev/null 2>&1

I'll disable that for now and see if this recurs, if it does, I'll gather 
additional output and send it out, thanks.

Justin.

