Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48328 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab1IVPpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 11:45:10 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1R6lSW-00020C-Qb
	for linux-nfs@vger.kernel.org; Thu, 22 Sep 2011 17:45:09 +0200
Received: from DHCP075238.FHCRC.ORG ([140.107.75.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 17:45:08 +0200
Received: from mrg by DHCP075238.FHCRC.ORG with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 17:45:08 +0200
To: linux-nfs@vger.kernel.org
From: Michael Gutteridge <mrg@fhcrc.org>
Subject: Re: processes hanging in state D when reading from nfs
Date: Thu, 22 Sep 2011 15:39:52 +0000 (UTC)
Message-ID: <loom.20110922T173217-948@post.gmane.org>
References: <201108272122.53243.sweet_f_a@gmx.de> <20110920135252.GB12422@fieldses.org> <201109220140.01082.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Rüdiger Meier <sweet_f_a@...> writes:

> 
> On Tuesday 20 September 2011, J. Bruce Fields wrote:
> > On Sat, Aug 27, 2011 at 09:22:53PM +0200, Rüdiger Meier wrote:
> > > I've got an annoying problem with my nfs4 clients.
> > > Lately I see many processes hanging in state D when reading from
> > > nfs mount. Sometimes they can be killed sometimes not.
> >
> > Is this still happening?
> 
> Yes, allthough we've managed to avoid the "dangerous" things.
> Sometimes we have also probs like the other current thread
> "Writing / Locking problem with NFSv4".
> 

For what it's worth:  we have been seeing very similar behavior on our OpenSuSE
11.3 (x86_64, 2.6.34.10-0.2) systems, though one other difference is that we are
using NFSv3 for these mounts.

I was able to get some traces via sysrq, though no ethernet dumps (these
problems would happen occasionally, impossible to determine when/where).  These
are heavily loaded systems, doing lots of compute and IO.

  1  [3754730.533669] R             D ffffffff810dc3e0     0 22621      1
0x00000004     
  2  [3754730.533671]  ffff88165f993cb8 0000000000000086 ffff881037174600
ffffffffa0332bbd 
  3  [3754730.533673]  0000000000013e80 0000000000013e80 ffff88165f993fd8
0000000000013e80 
  4  [3754730.533675]  ffff88165f993fd8 ffff881e5cd521c0 0000000000013e80
0000000000013e80 
  5  [3754730.533676] Call Trace:
  6  [3754730.533678]  [<ffffffff8145004e>] io_schedule+0x6e/0xb0
  7  [3754730.533681]  [<ffffffff810dc418>] sync_page+0x38/0x50
  8  [3754730.533683]  [<ffffffff814505da>] __wait_on_bit_lock+0x4a/0xb0
  9  [3754730.533685]  [<ffffffff810dc3be>] __lock_page+0x5e/0x70
 10  [3754730.533687]  [<ffffffff810dd2f8>] filemap_fault+0x2f8/0x410
 11  [3754730.533690]  [<ffffffff810f7c12>] __do_fault+0x52/0x4f0
 12  [3754730.533692]  [<ffffffff810fbf82>] handle_mm_fault+0x1b2/0xbd0
 13  [3754730.533694]  [<ffffffff81455799>] do_page_fault+0x169/0x3a0
 14  [3754730.533697]  [<ffffffff8145271f>] page_fault+0x1f/0x30
 15  [3754730.533699]  [<00007f79e2486ce0>] 0x7f79e2486ce0

This is pretty representative of the processses in D.  Does this help, or are
there too many differences from the original?

Thanks

Michael



