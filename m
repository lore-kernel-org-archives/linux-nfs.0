Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40865 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923Ab1G3GGa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 02:06:30 -0400
Date: Sat, 30 Jul 2011 16:06:10 +1000
From: NeilBrown <neilb@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Greg Banks <gnb@fastmail.fm>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110730160610.0b751ffd@notabene.brown>
In-Reply-To: <1311998914.2873.27.camel@edumazet-laptop>
References: <1311921035.7845.10.camel@edumazet-laptop>
	<4E3258E1.6020000@fastmail.fm>
	<20110729103634.GA12050@infradead.org>
	<5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	<1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	<20110729164836.GL23194@fieldses.org>
	<20110729165345.GM23194@fieldses.org>
	<F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
	<20110730093025.716f3f50@notabene.brown>
	<20110729234857.GA30941@fieldses.org>
	<1311998914.2873.27.camel@edumazet-laptop>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 30 Jul 2011 06:08:34 +0200 Eric Dumazet <eric.dumazet@gmail.com>
wrote:

> Le vendredi 29 juillet 2011 à 19:48 -0400, J. Bruce Fields a écrit :
> > On Sat, Jul 30, 2011 at 09:30:25AM +1000, NeilBrown wrote:
> > > 
> > > rpc.nfsd 0
> > > 
> > > will stop all nfsd threads.  Follow with
> > > 
> > >   exportfs -f
> > > 
> > > and you should be done.  I'm not 100% sure about the nfsv4 thread though -
> > > would need to check.
> > 
> > Should be fine.
> > 
> 
> What are the needed steps to be able to unload nfsd module ?
> 
> So far, I am unable to perform this without using -f option.
> 
> 
> 
> 

Kill all nfsd threads.
   This can be done with 'kill' or 'rpc.nfsd 0' or
     echo 0 > /proc/fs/nfsd/threads

kill mountd
   killall rpc.mountd

kill idmapd

unexport everything.
   This can be done with 'exportfs -f' and checked by
    grep . /proc/net/rpc/*/content
   this should only contain comments

unmount the 'nfsd' filesystem
   umount /proc/fs/nfsd

rmmod nfsd


(it look me ages to remember idmapd - but 
   lsof /proc/net/rpc/*/*
 gave it away)

NeilBrown
