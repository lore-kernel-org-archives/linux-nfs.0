From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Thu, 26 Nov 2009 10:20:59 -0500
Message-ID: <1259248859.6715.50.camel@localhost>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56722 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050AbZKZPU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Nov 2009 10:20:59 -0500
In-Reply-To: <64b4daae0911260707i4064f608w4f7169441640567-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-11-26 at 16:07 +0100, Stephen R. van den Berg wrote: 
> On Thu, Nov 26, 2009 at 16:01, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2009-11-26 at 00:11 +0100, Stephen R. van den Berg wrote:
> >> 1.2.3.167 is the Linux client kernel which locks up, 1.2.3.151 is the
> >> unfs server.
> >> It looks like the client terminates the TCP connection.  The server
> >> confirms it, the client then sends a final acknowledge.  At that point
> >> the client kernel locks up in the infinite loop.
> 
> > OK. Have you tried running with RPCDBG_TRANS debugging enabled? I
> > suspect you might see a flood of 'sendmsg returned unrecognized error'
> > or 'connect returned unhandled error' messages if you do.
> 
> The pcap trace is not conclusive (enough)?
> I can run with RPCDBG_TRANS enabled, if it is needed to further
> pinpoint the problem.

The pcap trace shows what is happening: the socket is getting closed
correctly, and so the RPC client needs to initiate a reconnection before
it can transmit again. What I don't understand is why it is failing to
do so...

   Trond

