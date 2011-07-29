Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59749 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752990Ab1G2Xam convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 19:30:42 -0400
Date: Sat, 30 Jul 2011 09:30:25 +1000
From: NeilBrown <neilb@suse.de>
To: Greg Banks <gnb@fastmail.fm>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110730093025.716f3f50@notabene.brown>
In-Reply-To: <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown>
	<4E324DB4.7060600@fastmail.fm>
	<1311921035.7845.10.camel@edumazet-laptop>
	<4E3258E1.6020000@fastmail.fm>
	<20110729103634.GA12050@infradead.org>
	<5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	<1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	<20110729164836.GL23194@fieldses.org>
	<20110729165345.GM23194@fieldses.org>
	<F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 30 Jul 2011 06:34:44 +1000 Greg Banks <gnb@fastmail.fm> wrote:

> 
> 
> Sent from my iPhone
> 
> On 30/07/2011, at 2:53, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Jul 29, 2011 at 12:48:36PM -0400, bfields wrote:
> >> On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
> >>>
> >>>
> >>> Sent from my iPhone
> >>>
> >>> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet@gmail.com>  
> >>> wrote:
> >>>
> >>>> Le vendredi 29 juillet 2011 à 21:58 +1000, Greg Banks a écrit :
> >>>>
> >>>>>
> >>>>> Sure, and a whole lot of the callsites are ("..._%d", cpu),  
> >>>>> hence the
> >>>>> unfortune :(
> >>>>
> >>>> BTW, we could name nfsd threads differently :
> >>>>
> >>>> Currently, they all are named : "nfsd"
> >>>>
> >>>> If SVC_POOL_PERCPU is selected, we could name them :
> >>>> nfsd_c0 -> nfsd_cN
> >>>>
> >>>> If SVC_POOL_PERNODE is selected, we could name them :
> >>>> nfsd_n0  -> nfsd_nN
> >>>>
> >>>> That would help to check with "ps aux" which cpu/nodes are under
> >>>> stress.
> >>>>
> >>>>
> >>>
> >>> I like it!
> >>
> >> Yup, patch welcomed.--b.
> >
> > (Annoying fact: some initscripts stop nfsd using a rough equivalent of
> > "killall nfsd".  So the name of the threads is arguably ABI.  I think
> > those initscripts are nuts and deserve what they get, but that may be
> > because I'm forgetting the reason they do that.)
> >
> 
> We had this discussion in May-June 2008; it's because the nfsds were  
> once  many many years ago userspace threads.

Even when they became kernel threads, 'kill' was the only way to kill them -
at first.

> 
> The "killall nfsd" semantics in those scripts are awful and lead to  
> problems shutting down when there are lots of threads. It would  
> probably be an improvement to provide a better shutdown mechanism and  
> force distros to use it.

rpc.nfsd 0

will stop all nfsd threads.  Follow with

  exportfs -f

and you should be done.  I'm not 100% sure about the nfsv4 thread though -
would need to check.

And yes - I would love it if distros could standardise on start/stop scripts
so upstreams could maintain them sensibly.  This is my personal number 1
reason for liking systemd - it pushes for this standardisation.

> 
> Or, you could preserve the effective semantics by having a single  
> "nfsd" thread whose purpose is to notice that it's being signalled and  
> perform a clean shutdown (perhaps blocking the thread doing the kill()  
> call until the shutdown has completed).

That's kinda neat.  It would be an ugly wart to have to keep around, but
sometimes that the price we pay for "no regressions".

NeilBrown
