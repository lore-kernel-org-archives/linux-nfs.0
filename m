Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:49804 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816Ab1G3J6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Jul 2011 05:58:14 -0400
Date: Sat, 30 Jul 2011 05:58:13 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Bryan Schumaker <bjschuma@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <alpine.DEB.2.02.1107291820560.25432@p34.internal.lan>
Message-ID: <alpine.DEB.2.02.1107300553300.10141@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>    <20110727160752.GC974@fieldses.org>    <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>    <20110727181111.GA23009@infradead.org>    <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
  <20110727193937.GA5354@infradead.org>    <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>    <20110727194722.GA9345@infradead.org>    <1311799021.25645.41.camel@lade.trondhjem.org>    <1311800051.25645.43.camel@lade.trondhjem.org>  
 <1311800195.25645.45.camel@lade.trondhjem.org>   <alpine.DEB.2.02.1107271723500.25432@p34.internal.lan>   <alpine.DEB.2.02.1107271844100.25432@p34.internal.lan>  <1311886137.27285.2.camel@lade.trondhjem.org> <4E331D86.7060801@netapp.com>
 <alpine.DEB.2.02.1107291656340.25432@p34.internal.lan> <1311977016.16078.10.camel@lade.trondhjem.org> <alpine.DEB.2.02.1107291820560.25432@p34.internal.lan>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Fri, 29 Jul 2011, Justin Piszcz wrote:

> 
> 
> On Fri, 29 Jul 2011, Trond Myklebust wrote:
> 
> > On Fri, 2011-07-29 at 16:59 -0400, Justin Piszcz wrote:
> >> On Fri, 29 Jul 2011, Bryan Schumaker wrote:
> >>
> >>> How does this look for printing out more information when a cookie loop is detected?  Is there anything else that should be printed out?  My patch applies on top of Trond's from yesterday.
> >>
> >>
> >> Hi,
> >>
> >> This fails against 2.6.38:
> >>
> >> patching file fs/nfs/dir.c
> >> Hunk #1 FAILED at 134.
> >> Hunk #2 FAILED at 173.
> >> Hunk #3 FAILED at 323.
> >> Hunk #4 FAILED at 336.
> >> Hunk #5 FAILED at 349.
> >> Hunk #6 succeeded at 320 (offset -48 lines).
> >> Hunk #7 FAILED at 741.
> >> Hunk #8 succeeded at 716 (offset -59 lines).
> >> Hunk #9 succeeded at 749 (offset -59 lines).
> >> Hunk #10 succeeded at 763 (offset -59 lines).
> >> 6 out of 10 hunks FAILED -- saving rejects to file fs/nfs/dir.c.rej
> >> patching file include/linux/nfs_fs.h
> >> Hunk #1 FAILED at 99.
> >> 1 out of 1 hunk FAILED -- saving rejects to file include/linux/nfs_fs.h.rej
> >> atom:/usr/src/linux#
> >>
> >> And the 3.0 kernel is broken for my wireless adapter:
> >> http://www.gossamer-threads.com/lists/linux/kernel/1411576
> >>
> >> If you can make a combined patch for 2.6.38 I can try it, 2.6.39+ have a
> >> horrible driver (rt2800usb) and 1 person emailed me as well stating the
> >> same thing off-list (they stick with the manufacturer's driver or the *sta
> >> one).
> >
> > I don't understand. The readdir loop detection code was first merged
> > upstream in 2.6.39. 2.6.38 doesn't report any loops...
> 
> Hi,
> 
> Sorry--(my error) this is meant for the client, patched & will e-mail when 
> it happens again.
> 
> # patch -p1 < /home/jpiszcz/patch1
> patching file fs/nfs/dir.c
> patching file include/linux/nfs_fs.h
> 
> # patch -p1 < /home/jpiszcz/patch2
> patching file fs/nfs/dir.c
> 
> (recompile->reboot->waiting for next error)
> 
> Justin.

So I have been running Linux 2.6.37-(.. 3.0 recently) since Jan of this year on these new hosts and I have never had so much as a kernel OOPS, with these 
patches, there were several kernel lockups/problems but the nfs/loop did 
not show up.

I've went back to the previous (non-patched) kernel, is there a less invasive
patch?

http://home.comcast.net/~jpiszcz/20110730/kernel-error.txt

Justin.


