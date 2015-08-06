Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tamar.safe-mail.net ([212.29.227.229]:55708 "EHLO
	tamar.safe-mail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbbHFOtV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2015 10:49:21 -0400
Subject: Re: extremely slow v4 performance on gigabit link
Date: Thu, 6 Aug 2015 10:48:21 -0400
From: jhopper@Safe-mail.net
To: bfields@fieldses.org
CC: linux-nfs@vger.kernel.org
Message-Id: <N1B-bi9fdBdoAp@Safe-mail.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the problem is also present when vers=3 and vers=2
I think I found the problem, vers=2,udp transfers at 50 MB/s and vers=3,udp transfers at 90 MB/s (when exported async, but when exported sync - the udp mode rates are <5MB/s)
all vers in tcp mode are limited to <1MB/s
I am afraid running in udp mode, the docs say udp can cause silent data corruption on gigabit links :x
but I did take care of the possible problems - reduced the fragmentation time to 2 seconds and enable 9000 mtu with rsize/wsize=8192

I see the data transfer speed in the file manager (worker)

-------- Original Message --------
From: bfields@fieldses.org (J. Bruce Fields)
To: jhopper@Safe-mail.net
Cc: linux-nfs@vger.kernel.org
Subject: Re: extremely slow v4 performance on gigabit link
Date: Wed, 5 Aug 2015 14:24:00 -0400

> On Wed, Aug 05, 2015 at 07:13:58AM -0400, jhopper@Safe-mail.net wrote:
> > I have a very slow (less than 1MB/s) performance with nfsv4 TCP,
> 
> How are you measuring this?
> 
> > rsize/wsize have no effect, server is a kernel 3.19 x86 100hz no
> > preempt exporting async nfsv4 TCP on nfs-utils 1.2.7,
> 
> The "async" export option isn't normally recommended, though it's
> unlikely to have anything to do with this problem.
> 
> > client is a
> > kernel 4.1.3 x64 1000hz full preempt with nfs-utils 1.3.2 , physical
> > link is 1 gigabit full duplex, I mounted a few cifs shares to check,
> > the cifs shares are working at 30 MB/s and higher
> > 
> > is it possible that preempt has an effect on NFS performance ? does
> > timeslice have effect on performance ?
> 
> I think those are unlikely to be relevant.
> 
> --b.
