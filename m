Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47785 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab1H1KCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2011 06:02:34 -0400
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
From: Eric Dumazet <eric.dumazet@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, Greg Banks <gnb@fastmail.fm>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
In-Reply-To: <20110827000219.GF18699@fieldses.org>
References: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
	 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
	 <20110730093025.716f3f50@notabene.brown>
	 <20110729234857.GA30941@fieldses.org>
	 <1311998914.2873.27.camel@edumazet-laptop>
	 <20110730160610.0b751ffd@notabene.brown>
	 <1312006990.2873.75.camel@edumazet-laptop>
	 <1312095534.2873.108.camel@edumazet-laptop>
	 <20110827000219.GF18699@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 28 Aug 2011 12:02:24 +0200
Message-ID: <1314525744.3036.10.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le vendredi 26 août 2011 à 20:02 -0400, J. Bruce Fields a écrit :
> On Sun, Jul 31, 2011 at 08:58:54AM +0200, Eric Dumazet wrote:
> > Le samedi 30 juillet 2011 à 08:23 +0200, Eric Dumazet a écrit :
> > > Le samedi 30 juillet 2011 à 16:06 +1000, NeilBrown a écrit :
> > > > umount /proc/fs/nfsd
> > > > 
> > > > 
> > > 
> > > Thans  a lot, this was the thing I missed !
> > > 
> > > 
> > 
> > Hmm, after this, I left things as the were (nfsd module loaded, but a 0
> > use count )
> > 
> > I got a BUG while updatedb was running,
> > (I tried this on a debian machine/kernel)
> > 
> > Same bug on :
> > 
> > cat /proc/self/mounts 
> 
> Any luck figuring this out?
> 
> I tried reproducing, by stopping everything to get nfsd refcount to
> zero:
> 
> 	# lsmod | grep '^nfsd'
> 	nfsd                  300025  0 
> 
> then running 'cat /proc/self/mounts'.
> 
> But I don't see any crash.
> 
> This is only 3.1.0-rc1 plus some nfsd patches.
> 
> --b.
> 
> > 
> > I'll take a look at this issue later, after my vacations, unless someone
> > wants to take a look before me ;)

Unfortunately, latest linux tree doesnt even boot on my machine, so I
cannot reproduce the problem right now.

Last message displayed being "Switching to clocksource tsc"

Previous kernels were continuing with :

[    4.448417] 00:09: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    4.597727] Real Time Clock Driver v1.12b

Might be a problem with latest tty changes 


