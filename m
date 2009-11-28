From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Sat, 28 Nov 2009 10:30:15 -0500
Message-ID: <1259422215.3486.77.camel@localhost>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
	 <1259248859.6715.50.camel@localhost>
	 <64b4daae0911261607m10d1ba3al8c067f85249c198f@mail.gmail.com>
	 <64b4daae0911261614l471fb74fx79db2988f0c65738@mail.gmail.com>
	 <1259357036.3486.38.camel@localhost>
	 <64b4daae0911271620k46a99666td81528fc863e69f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57034 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbZK1PaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Nov 2009 10:30:17 -0500
In-Reply-To: <64b4daae0911271620k46a99666td81528fc863e69f0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-11-28 at 01:20 +0100, Stephen R. van den Berg wrote: 
> On Fri, Nov 27, 2009 at 22:23, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2009-11-27 at 01:14 +0100, Stephen R. van den Berg wrote:
> >> On Fri, Nov 27, 2009 at 01:07, Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org> wrote:
> > Does the following patch fix matters?
> 
> >        if (!xprt_lock_write(xprt, task))
> >                return;
> > +
> > +       if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state))
> > +               xprt->ops->close(xprt);
> > +
> >        if (xprt_connected(xprt))
> 
> Sorry.  No go.  I got the following trace, I'm not sure if this is
> relevant, because it is difficult to determine if the logging
> corresponds to the experienced problem.
> 
> RPC: 14194 xprt_connect_status: retrying
> RPC: 14194 xprt_prepare_transmit
> RPC: 14194 xprt_transmit(112)
> RPC:       disconnected transport cfa82400
> RPC: 14194 xprt_connect xprt cfa82400 is not connected
> RPC: 14194 xprt_connect_status: retrying
> RPC: 14194 xprt_prepare_transmit
> RPC: 14194 xprt_transmit(112)
> RPC:       disconnected transport cfa82400
> RPC: 14194 xprt_connect xprt cfa82400 is not connected
> RPC: 14194 xprt_connect_status: retrying
> RPC: 14194 xprt_prepare_transmit
> RPC: 14194 xprt_transmit(112)
> RPC:       disconnected transport cfa82400
> RPC: 14194 xprt_connect xprt cfa82400 is not connected
> RPC: 14194 xprt_connect_status: retrying
> RPC: 14194 xprt_prepare_transmit
> RPC: 14194 xprt_transmit(112)
> RPC:       disconnected transport cfa82400
> RPC: 14194 xprt_connect xprt cfa82400 is not connected
> RPC: 14194 xprt_connect_status: retrying
> RPC: 14194 xprt_prepare_transmit
> RPC: 14194 xprt_transmit(112)

Did anything change w.r.t. the RPCDBG_TRANS (or better still - the
RPCDBG_XPRT|RPCDBG_TRANS) trace?

Trond

