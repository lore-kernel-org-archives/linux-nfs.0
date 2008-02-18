From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [Fwd: Re: Linux 2.6.25-rc2]
Date: Mon, 18 Feb 2008 12:18:02 -0600
Message-ID: <1203358682.24272.31.camel@trinity.ogc.int>
References: <1203282165.2929.7.camel@heimdal.trondhjem.org>
	 <20080218174509.GC32492@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:50139 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750984AbYBRSI5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:08:57 -0500
In-Reply-To: <20080218174509.GC32492@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce:

I'll take a look...

Tom

On Mon, 2008-02-18 at 12:45 -0500, J. Bruce Fields wrote:
> On Sun, Feb 17, 2008 at 04:02:45PM -0500, Trond Myklebust wrote:
> > Hi Bruce,
> > 
> > Here is a question for you.
> > 
> >         Why does svc_close_all() get away with deleting xprt->xpt_ready
> >         without holding the pool->sp_lock?
> 
> >From a quick look--I think the intention is that the code that calls it
> (in svc_destroy()) is only called after all other server threads have
> exited, and that there can't be anyone else monkeying with that service
> any more.  But I haven't verified that really carefully.
> 
> > I ask because the strange Oopses that appear in the attached bugreport
> > often involve the sunrpc server code. They would appear to indicate
> > corruption in the pool->sp_sockets code...
> 
> But obviously this needs a hard look.  OK, thanks.  I could really use
> some help if there's someone that has time to look into this....
> 
> --b.
> 
> > 
> > Cheers
> >   Trond
> 
> Content-Description: Forwarded message - Re: Linux 2.6.25-rc2
> > From: "Rafael J. Wysocki" <rjw@sisk.pl>
> > To: Torsten Kaiser <just.for.lkml@googlemail.com>
> > Subject: Re: Linux 2.6.25-rc2
> > Date: Sun, 17 Feb 2008 21:25:55 +0100
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>,
> > 	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
> > 
> > On Saturday, 16 of February 2008, Torsten Kaiser wrote:
> > > On Feb 15, 2008 10:23 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > > >
> > > > Ok,
> > > >  this kernel is a winner.
> > > 
> > > Sadly not for me:
> > > [ 5282.056415] ------------[ cut here ]------------
> > > [ 5282.059757] kernel BUG at lib/list_debug.c:33!
> > > [ 5282.062055] invalid opcode: 0000 [1] SMP
> > > [ 5282.062055] CPU 3
> > > [ 5282.062055] Modules linked in: radeon drm w83792d ipv6 tuner
> > > tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx tea5761
> > > tvaudio msp3400 bttv videodev v4l1_compat ir_common compat_ioctl32
> > > v4l2_common videobuf_dma_sg videobuf_core btcx_risc tveeprom usbhid
> > > pata_amd i2c_nforce2 hid sg
> > > [ 5282.062055] Pid: 12937, comm: sed Not tainted 2.6.25-rc2 #1
> > > [ 5282.062055] RIP: 0010:[<ffffffff803bffe4>]
> > > -> then the output from the serial console stopped. I was in X, so I
> > > could not see, if there was anything more on the real console.
> > > 
> > > (gdb) list *0xffffffff803bffe4
> > > 0xffffffff803bffe4 is in __list_add (lib/list_debug.c:33).
> > > 28              }
> > > 29              if (unlikely(prev->next != next)) {
> > > 30                      printk(KERN_ERR "list_add corruption.
> > > prev->next should be "
> > > 31                              "next (%p), but was %p. (prev=%p).\n",
> > > 32                              next, prev->next, prev);
> > > 33                      BUG();
> > > 34              }
> > > 35              next->prev = new;
> > > 36              new->next = next;
> > > 37              new->prev = prev;
> > > 
> > > For more on this problem see http://marc.info/?l=linux-kernel&m=120293042005445
> > 
> > There's the Bugzilla entry for it at
> > 


http://bugzilla.kernel.org/show_bug.cgi?id=9973
> > 
> > Please update it with the current information.
> > 
> > Thanks,
> > Rafael
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

