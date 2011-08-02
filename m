Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57666 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab1HBBGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 21:06:43 -0400
Date: Mon, 1 Aug 2011 21:06:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Greg Banks <gnb@fastmail.fm>, Eric Dumazet <eric.dumazet@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110802010635.GA16305@fieldses.org>
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
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110730093025.716f3f50@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 30, 2011 at 09:30:25AM +1000, NeilBrown wrote:
> On Sat, 30 Jul 2011 06:34:44 +1000 Greg Banks <gnb@fastmail.fm> wrote:
> > The "killall nfsd" semantics in those scripts are awful and lead to  
> > problems shutting down when there are lots of threads. It would  
> > probably be an improvement to provide a better shutdown mechanism and  
> > force distros to use it.
> 
> rpc.nfsd 0
> 
> will stop all nfsd threads.  Follow with
> 
>   exportfs -f
> 
> and you should be done.  I'm not 100% sure about the nfsv4 thread though -
> would need to check.
> 
> And yes - I would love it if distros could standardise on start/stop scripts
> so upstreams could maintain them sensibly.  This is my personal number 1
> reason for liking systemd - it pushes for this standardisation.

I can't remember if this is getting fixed in Fedora--probably not.  We
should fix it.

I'd also be fine with logging a deprecation message when someone signals
an nfsd thread.

> > Or, you could preserve the effective semantics by having a single  
> > "nfsd" thread whose purpose is to notice that it's being signalled and  
> > perform a clean shutdown (perhaps blocking the thread doing the kill()  
> > call until the shutdown has completed).
> 
> That's kinda neat.  It would be an ugly wart to have to keep around, but
> sometimes that the price we pay for "no regressions".

Yep; patch welcomed.

--b.
