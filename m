From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: nfs client lockdep warning
Date: Fri, 09 Jan 2009 06:58:17 +0100
Message-ID: <1231480697.11687.522.camel@twins>
References: <20090108203658.GE19312@fieldses.org>
	 <1231447707.7179.10.camel@heimdal.trondhjem.org>
	 <20090108212056.GF19312@fieldses.org>
	 <20090109043315.GA12139@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>,
	Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090109043315.GA12139@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-09 at 15:33 +1100, Herbert Xu wrote:
> On Thu, Jan 08, 2009 at 09:20:56PM +0000, J. Bruce Fields wrote:
> >
> > > > Jan  8 15:29:17 ying3 kernel: =======================================================
> > > > Jan  8 15:29:17 ying3 kernel: [ INFO: possible circular locking dependency detected ]
> > > > Jan  8 15:29:17 ying3 kernel: 2.6.28-07532-g393a64e #71
> > > > Jan  8 15:29:17 ying3 kernel: -------------------------------------------------------
> > > > Jan  8 15:29:17 ying3 kernel: tlocklfs/3527 is trying to acquire lock:
> > > > Jan  8 15:29:17 ying3 kernel:  (sk_lock-AF_INET-RPC){--..}, at: [<c076609c>] tcp_sendmsg+0x1c/0xa80
> > > > Jan  8 15:29:17 ying3 kernel: 
> > > > Jan  8 15:29:17 ying3 kernel: but task is already holding lock:
> > > > Jan  8 15:29:17 ying3 kernel:  (&mm->mmap_sem){----}, at: [<c0835fb7>] do_page_fault+0xc7/0x820
> > > > Jan  8 15:29:17 ying3 kernel: 
> > > > Jan  8 15:29:17 ying3 kernel: which lock already depends on the new lock.
> > > > Jan  8 15:29:17 ying3 kernel: 
> > > > Jan  8 15:29:17 ying3 kernel: 
> > > > Jan  8 15:29:17 ying3 kernel: the existing dependency chain (in reverse order) is:
> > > > Jan  8 15:29:17 ying3 kernel: 
> > > > Jan  8 15:29:17 ying3 kernel: -> #1 (&mm->mmap_sem){----}:
> > > > Jan  8 15:29:17 ying3 kernel:        [<c024900d>] __lock_acquire+0xfcd/0x18e0
> > > > Jan  8 15:29:17 ying3 kernel:        [<c024997c>] lock_acquire+0x5c/0x80
> > > > Jan  8 15:29:17 ying3 kernel:        [<c027dffb>] might_fault+0x7b/0xa0
> 
> This is a false positive introduced by might_fault.  As this is
> a send request from the kernel, it should never fault.
> 
> > > > Jan  8 15:29:17 ying3 kernel:        [<c054bb26>] copy_from_user+0x36/0x90
> > > > Jan  8 15:29:17 ying3 kernel:        [<c0737800>] memcpy_fromiovecend+0x60/0x90
> > > > Jan  8 15:29:17 ying3 kernel:        [<c075ce9f>] ip_generic_getfrag+0x9f/0xb0
> > > > Jan  8 15:29:17 ying3 kernel:        [<c075cb6b>] ip_append_data+0x6bb/0x950
> > > > Jan  8 15:29:17 ying3 kernel:        [<c077cb0d>] udp_sendmsg+0x2bd/0x680
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07835f9>] inet_sendmsg+0x39/0x70
> > > > Jan  8 15:29:17 ying3 kernel:        [<c072f0e6>] sock_sendmsg+0xd6/0x100
> > > > Jan  8 15:29:17 ying3 kernel:        [<c072f485>] kernel_sendmsg+0x35/0x50
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07da698>] xs_send_kvec+0xa8/0xb0
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07da711>] xs_sendpages+0x71/0x210
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07dab30>] xs_udp_send_request+0x40/0x120
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07d91ff>] xprt_transmit+0x6f/0x280
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07d6c1f>] call_transmit+0x17f/0x250
> > > > Jan  8 15:29:17 ying3 kernel:        [<c07dda13>] __rpc_execute+0x73/0x250

Is there anything pinning that user-space page, if not its free to
fault, which would mean its a real warning... 

