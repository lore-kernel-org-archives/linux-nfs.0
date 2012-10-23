Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:46448 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933317Ab2JWUJA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 16:09:00 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so4694648vcb.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2012 13:08:59 -0700 (PDT)
Date: Tue, 23 Oct 2012 16:08:55 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121023200855.GC27191@nyc-qws-132.nyc.delacy.com>
References: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
 <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 23, 2012 at 04:02:27PM +0000, Myklebust, Trond wrote:
> call_transmit() should normally just cause the rpc_task to detect that
> the connection is down, and should cause it to go to call_connect in
> order to fix everything.
> 
> If it is causing a race, then I'm thinking that is probably due to the
> call to xs_tcp_shutdown() when we get an EPIPE error in
> xs_tcp_send_request(). That shutdown seems to be needed only in the case
> when we're in TCP_CLOSE_WAIT, in which case what we really want is to
> force the rpc_task to go to xprt_connect, which means clearing
> xprt_connected().
> 
> Hmm.... Can you try applying the attached 2 patches?

I rebuilt with those two patches as well as the first one that removed
the `xs_error_report' callback.

Good news, it works!

However, looking at the interactions, it still seems a little bit racy.
Clearly you know more about this than I do, so I'll defer to your better
judgement, but let me lay out what I believe is happening:

            Stat Thread                                rpciod
           -------------                              --------
  - woken up with tk_status set to
    EAGAIN via xs_tcp_state_change

  - tries call_transmit again, which
    calls xs_tcp_send_request which
    comes back with ECONNRESET (b/c this
    is what sk_err is)

  - call_status sees this and goes to
    sleep for 3 seconds and then sets
    tk_action to call_bind

  - call_bind

  - call_connect, queues execution of
    xs_tcp_setup_socket with rpciod and
    goes to sleep
    			
					   - starts doing its thing, but wakes
					     up our other thread before its done
					     trying to connect the socket (or
					     failing to do so) via the call
					     stack mentioned before (via
					     xprt_disconnect_done)
					     
  - tk_status is set to EAGAIN, so
    call_connect_status moves on to
    call_transmit

  - call_transmit calls
    xs_tcp_send_request again which
    finds the socket with sk_shutdown !=
    0 and so returns EPIPE

  - call_status sees the EPIPE and sets
    tk_action back to call_bind

					   - continues on and updates the state
					     of the socket to TCP_SYN_SENT

					   - When the connection is established,
					     xs_tcp_state_change takes care of
					     marking the xprt connected

  - call_bind

  - call_connect, however this time it
    schedules no work because it finds
    that the transport is already
    connected

  - call_transmit, succeeds, we recover

This is how the recovery went when I was testing, but I could imagine a
situation where different timing comes into play and we wind up asking
rpciod to execute xs_tcp_setup_socket twice (because the first connect
hasn't been established yet).  I haven't thought too hard about what
that would mean, but I imagine it probably wouldn't be good.

Like I said, you know way more about this than I do, I just wanted to point this
out.  Its entirely possible that I'm missing or misunderstanding something.

Thanks!

Chris
