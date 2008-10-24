From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Fri, 24 Oct 2008 14:02:16 -0700
Message-ID: <20081024210216.GA20386@zoy.org>
References: <20081023040231.GA13512@zoy.org> <1224776207.7625.7.camel@localhost> <20081023195231.GA2090@zoy.org> <1224803879.7625.79.camel@localhost> <20081024065759.GA2401@zoy.org> <1224851368.22672.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:54639 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbYJXVCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 17:02:17 -0400
In-Reply-To: <1224851368.22672.20.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2008 at 08:29:28AM -0400, Trond Myklebust wrote:
> On Thu, 2008-10-23 at 23:57 -0700, Michel Lespinasse wrote:
> > I applied this on top of the previous patch and it worked - but now I'm
> > not sure if you wanted to test this as an independant patch ???
> It was meant to be applied incrementally on top of the other.

OK. Worked fine, then. Thanks again !

> > Can I propose a patch too ? mine looks quite similar to your second patch,
> > but with the reestablish_timeout logic hopefully simplified...
> 
> This would cause a different regression. The current code is there in
> order to ensure that we apply that exponential backoff if and only if
> the _server_ closes the TCP connection since that would usually indicate
> that it is trying to deal with a resource congestion issue. We don't
> need to back off if we were the ones closing the socket.

So the idea is to backoff if the connection is closed by a server FIN but
retry right away if it's closed by a RST ?
I did not realize that, but this makes sense too...

> The issue of UDP exponential backoff is moot: the UDP code doesn't use
> xs_connect() at all.

Hrmmm ? I see the following down the file:
static struct rpc_xprt_ops xs_udp_ops = {
...
        .connect                = xs_connect,
...
}

I'm not sure if/when the callback is actually called in the UDP case,
but it's definitely being set up that way.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
