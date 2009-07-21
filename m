From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: reset TCP reconnect exponential back-off on
 successful connection.
Date: Tue, 21 Jul 2009 19:07:44 -0400
Message-ID: <1248217664.5034.18.camel@heimdal.trondhjem.org>
References: <19040.11777.346898.322780@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55424 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756354AbZGUXHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 19:07:49 -0400
In-Reply-To: <19040.11777.346898.322780-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-07-17 at 17:53 +1000, Neil Brown wrote:
> Hi.
>  A customer of ours has been testing NFS failover and has been
>  experiencing unexpected delays before the client starts writing
>  again.   It turns out there are a number of issues here, some client
>  and some server.
> 
>  This patch fixes two client issues, one that causes the failover time
>  to double on each migration (or each time the NFS server is stopped
>  and restarted), and one that causes the client to spam the server
>  with SYN requests until it accepts the connection (I have a trace
>  showing over 100 SYN requests, each followed by a RST,ACK reply, in
>  the space for 300 milliseconds).
> 
>  I am able to simulate the first failure and have tested that the
>  patch fixes it.  I have not managed to simulate the second failure,
>  but I think that fix is clearly safe.
> 
>  I'm not sure that the patch fits the original definition for -stable,
>  but it seems to fit the current practice and I would appreciate if
>  (assuming the patch passes review) it could be submitted for -stable.
> 
> Thanks,
> NeilBrown
> 
> 
> 
> The sunrpc/TCP transport has an exponential back-off for reconnection,
> starting at 3 seconds and with a maximum of 300 seconds.  On every
> connection attempt the timeout is doubled.
> It is only reset when the client deliberately closes the connection.
> If the server closes the connection but a subsequent reconnect
> succeeds, the timeout remains elevated.
> 
> This means that if the server resets the connection several times, as
> can happen with server migration in a clustered environment, each
> reconnect takes longer than the previous one - unnecessarily so.
> 
> This patch resets the timeout on a successful connection so that every
> time the server resets the connection we start with a basic 3 second
> timeout.

I seem to remember a situation (was it with NetApp filers?) where the
server would accept the connection, but then immediately abort it
because the services weren't all finished booting.

IMO, the rule should therefore be that if a server aborts the
connection, we should assume it is in some sort of trouble, and be
careful when reconnecting.

Now, that said, if the server has been operating fine for several
minutes before aborting the connection, we could definitely be a bit
more aggressive about the reconnection timeout. Could we rather do that?

> There is also the possibility for the reverse problem.  When the
> client closes the connection it sets the timeout to 0 (so that a
> reconnect - when required - is instant).  When 0 is doubled it remains
> at 0, so if the server refused the reconnect, the client will try
> again instantly and indefinitely.  To avoid this we ensure that after
> doubling the timeout it is at least the minimum.

Is this true? AFAICS, we always ensure xprt->reestablish_timeout is
non-zero when we enter TCP_SYN_SENT.

Cheers
  Trond

