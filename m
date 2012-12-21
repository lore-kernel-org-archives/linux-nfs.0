Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57373 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab2LUSXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 13:23:33 -0500
Date: Fri, 21 Dec 2012 13:23:32 -0500
To: Rajesh Ghanekar <rajeshsg@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server connection hang in CLOSE_WAIT state
Message-ID: <20121221182332.GA27897@fieldses.org>
References: <CAOn_VZb1Hsv8MpCaZQoixxHpJRfSZdEZ3GgLzdSjawZZuzn33w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOn_VZb1Hsv8MpCaZQoixxHpJRfSZdEZ3GgLzdSjawZZuzn33w@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2012 at 01:37:20PM +0530, Rajesh Ghanekar wrote:
> Hi,
>     I have nfs server hung in CLOSE_WAIT state and the corresponding
> nfs client hang in FIN_WAIT2 state. NFS client is not retrying as NFS
> server isn't calling close() on the socket. The shutdown was initiated
> by NFS client and its now waiting for NFS server to send its FIN.
> 
>    Actually I am using old version here:
> NFS server: 2.6.16 (sles10sp3)
> NFS client: 2.6.27 (sles11)
> 
>    I see sunrpc client code missing xs_tcp_schedule_linger_timeout()  in 2.6.27:
> 
>         case TCP_FIN_WAIT1:
>                 /* The client initiated a shutdown of the socket */
>                 xprt->connect_cookie++;
>                 xprt->reestablish_timeout = 0;
>                 set_bit(XPRT_CLOSING, &xprt->state);
>                 smp_mb__before_clear_bit();
>                 clear_bit(XPRT_CONNECTED, &xprt->state);
>                 clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>                 smp_mb__after_clear_bit();
>                 xs_tcp_schedule_linger_timeout(xprt,
> xs_tcp_fin_timeout);    << This is missing in 2.6.27
>                 break;
> 
> 
>    So its clear that if the above linger timeout had been there
> in 2.6.27 the client would have connected back again. But why
> nfs service (server) sunrpc logic (svc_recv) hasn't called close on its
> part of the socket is yet not clear to me. I would like to know if
> anyone has faced this issue and if there are any fixes which I can
> individually pick.
> 
>    If I do another mount from same NFS client and another
> IP of same NFS server, things starts fine. So to make the
> original IP of same NFS server work fine, restart of nfs server
> will do. But I would like to know why the hang on the transport
> from NFS server side.
> 
>   Sorry in advance for the noise if expectation is to test with
> recent kernels and report accordingly. I can't test with new
> kernels.

Yeah, 2.6.16 is pretty old from the upstream point of view.  If you
can't retry with an upstream kernel then it should be reported to the
SLES folks.

--b.
