Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60414 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbbHJPXN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2015 11:23:13 -0400
Date: Mon, 10 Aug 2015 11:23:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: jhopper@Safe-mail.net
Cc: linux-nfs@vger.kernel.org
Subject: Re: extremely slow v4 performance on gigabit link
Message-ID: <20150810152313.GE9066@fieldses.org>
References: <N1B-bi9fdBdoAp@Safe-mail.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <N1B-bi9fdBdoAp@Safe-mail.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 06, 2015 at 10:48:21AM -0400, jhopper@Safe-mail.net wrote:
> the problem is also present when vers=3 and vers=2
> I think I found the problem, vers=2,udp transfers at 50 MB/s and vers=3,udp transfers at 90 MB/s (when exported async, but when exported sync - the udp mode rates are <5MB/s)
> all vers in tcp mode are limited to <1MB/s
> I am afraid running in udp mode, the docs say udp can cause silent data corruption on gigabit links :x
> but I did take care of the possible problems - reduced the fragmentation time to 2 seconds and enable 9000 mtu with rsize/wsize=8192

Neither udp nor the async export option are generally recommended.

Again, we need more information about what exactly you're measuring:

> I see the data transfer speed in the file manager (worker)

Sorry, that's not enough detail to understand what you're doing and
where you're getting these numbers from.

--b.

> 
> -------- Original Message --------
> From: bfields@fieldses.org (J. Bruce Fields)
> To: jhopper@Safe-mail.net
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: extremely slow v4 performance on gigabit link
> Date: Wed, 5 Aug 2015 14:24:00 -0400
> 
> > On Wed, Aug 05, 2015 at 07:13:58AM -0400, jhopper@Safe-mail.net wrote:
> > > I have a very slow (less than 1MB/s) performance with nfsv4 TCP,
> > 
> > How are you measuring this?
> > 
> > > rsize/wsize have no effect, server is a kernel 3.19 x86 100hz no
> > > preempt exporting async nfsv4 TCP on nfs-utils 1.2.7,
> > 
> > The "async" export option isn't normally recommended, though it's
> > unlikely to have anything to do with this problem.
> > 
> > > client is a
> > > kernel 4.1.3 x64 1000hz full preempt with nfs-utils 1.3.2 , physical
> > > link is 1 gigabit full duplex, I mounted a few cifs shares to check,
> > > the cifs shares are working at 30 MB/s and higher
> > > 
> > > is it possible that preempt has an effect on NFS performance ? does
> > > timeslice have effect on performance ?
> > 
> > I think those are unlikely to be relevant.
> > 
> > --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
