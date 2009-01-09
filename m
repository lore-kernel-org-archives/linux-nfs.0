From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: nfs client lockdep warning
Date: Fri, 9 Jan 2009 17:23:33 +1100
Message-ID: <20090109062333.GB13304@gondor.apana.org.au>
References: <20090108203658.GE19312@fieldses.org> <1231447707.7179.10.camel@heimdal.trondhjem.org> <20090108212056.GF19312@fieldses.org> <20090109043315.GA12139@gondor.apana.org.au> <1231480697.11687.522.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>,
	Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47268 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752158AbZAIGXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2009 01:23:43 -0500
In-Reply-To: <1231480697.11687.522.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2009 at 06:58:17AM +0100, Peter Zijlstra wrote:
>
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c054bb26>] copy_from_user+0x36/0x90
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c0737800>] memcpy_fromiovecend+0x60/0x90
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c075ce9f>] ip_generic_getfrag+0x9f/0xb0
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c075cb6b>] ip_append_data+0x6bb/0x950
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c077cb0d>] udp_sendmsg+0x2bd/0x680
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07835f9>] inet_sendmsg+0x39/0x70
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c072f0e6>] sock_sendmsg+0xd6/0x100
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c072f485>] kernel_sendmsg+0x35/0x50
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07da698>] xs_send_kvec+0xa8/0xb0
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07da711>] xs_sendpages+0x71/0x210
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07dab30>] xs_udp_send_request+0x40/0x120
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07d91ff>] xprt_transmit+0x6f/0x280
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07d6c1f>] call_transmit+0x17f/0x250
> > > > > Jan  8 15:29:17 ying3 kernel:        [<c07dda13>] __rpc_execute+0x73/0x250
> 
> Is there anything pinning that user-space page, if not its free to
> fault, which would mean its a real warning... 

It's kernel memory, not user memory.  See xs_udp_send_request in
net/sunrpc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
