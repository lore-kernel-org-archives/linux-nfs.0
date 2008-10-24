From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Fri, 24 Oct 2008 08:29:28 -0400
Message-ID: <1224851368.22672.20.camel@localhost>
References: <20081023040231.GA13512@zoy.org>
	 <1224776207.7625.7.camel@localhost> <20081023195231.GA2090@zoy.org>
	 <1224803879.7625.79.camel@localhost>  <20081024065759.GA2401@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48845 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbYJXM3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2008 08:29:32 -0400
In-Reply-To: <20081024065759.GA2401-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-23 at 23:57 -0700, Michel Lespinasse wrote:
> On Thu, Oct 23, 2008 at 07:17:59PM -0400, Trond Myklebust wrote:
> > > (I'm still concerned about the 3 second delay here...)
> > Does this patch fix that delay?
> > 
> > SUNRPC: Fix the setting of xprt->reestablish_timeout when reconnecting
> 
> I applied this on top of the previous patch and it worked - but now I'm
> not sure if you wanted to test this as an independant patch ???

It was meant to be applied incrementally on top of the other.

> I'm wondering how the code in xs_tcp_state_change() that sets
> reestablish_timeout back to XS_TCP_INIT_REEST_TO managed to not cause trouble.
> 
> 
> Can I propose a patch too ? mine looks quite similar to your second patch,
> but with the reestablish_timeout logic hopefully simplified...
> 

This would cause a different regression. The current code is there in
order to ensure that we apply that exponential backoff if and only if
the _server_ closes the TCP connection since that would usually indicate
that it is trying to deal with a resource congestion issue. We don't
need to back off if we were the ones closing the socket.

The issue of UDP exponential backoff is moot: the UDP code doesn't use
xs_connect() at all.

Cheers
  Trond

