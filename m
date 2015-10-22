Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35224 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbbJVQbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 12:31:35 -0400
Date: Thu, 22 Oct 2015 12:31:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Neil Brown <nfbrown@novell.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier
 in sunrpc
Message-ID: <20151022163133.GB5205@fieldses.org>
References: <17EC94B0A072C34B8DCF0D30AD16044A0287864B@BPXM09GP.gisp.nec.co.jp>
 <17EC94B0A072C34B8DCF0D30AD16044A028786CB@BPXM09GP.gisp.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A028786CB@BPXM09GP.gisp.nec.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 02:28:10AM +0000, Kosuke Tatsukawa wrote:
> Tatsukawa Kosuke wrote:
> > J. Bruce Fields wrote:
> >> On Thu, Oct 15, 2015 at 11:44:20AM +0000, Kosuke Tatsukawa wrote:
> >>> Tatsukawa Kosuke wrote:
> >>> > J. Bruce Fields wrote:
> >>> >> Thanks for the detailed investigation.
> >>> >> 
> >>> >> I think it would be worth adding a comment if that might help someone
> >>> >> having to reinvestigate this again some day.
> >>> > 
> >>> > It would be nice, but I find it difficult to write a comment in the
> >>> > sunrpc layer why a memory barrier isn't necessary, using the knowledge
> >>> > of how nfsd uses it, and the current implementation of the network code.
> >>> > 
> >>> > Personally, I would prefer removing the call to waitqueue_active() which
> >>> > would make the memory barrier totally unnecessary at the cost of a
> >>> > spin_lock + spin_unlock by unconditionally calling
> >>> > wake_up_interruptible.
> >>> 
> >>> On second thought, the callbacks will be called frequently from the tcp
> >>> code, so it wouldn't be a good idea.
> >> 
> >> So, I was even considering documenting it like this, if it's not
> >> overkill.
> >> 
> >> Hmm... but if this is right, then we may as well ask why we're doing the
> >> wakeups at all.  Might be educational to test the code with them
> >> removed.
> > 
> > sk_write_space will be called in sock_wfree() with UDP/IP each time
> > kfree_skb() is called.  With TCP/IP, sk_write_space is only called if
> > SOCK_NOSPACE has been set.
> > 
> > sk_data_ready will be called in both tcp_rcv_established() for TCP/IP
> > and in sock_queue_rcv_skb() for UDP/IP.  The latter lacks a memory
> > barrier with sk_data_ready called right after __skb_queue_tail().
> > I think this hasn't caused any problems because sk_data_ready wasn't
> > used.
> 
> Actually, svc_udp_data_ready() calls set_bit() which is an atomic
> operation.  So there won't be a problem unless svsk is NULL.

So is it true that every caller of these socket callbacks has adequate
memory barriers between the time the change is made visible and the time
the callback is called?

If so, then there's nothing really specific about nfsd here.

In that case maybe it's the networking code that use some documentation,
if it doesn't already?  (Or maybe common helper functions for this

	if (waitqueue_active(wq))
		wake_up(wq)

pattern?)

--b.

> 
> 
> >> --b.
> >> 
> >> commit 0882cfeb39e0
> >> Author: J. Bruce Fields <bfields@redhat.com>
> >> Date:   Thu Oct 15 16:53:41 2015 -0400
> >> 
> >>     svcrpc: document lack of some memory barriers.
> >>     
> >>     Kosuke Tatsukawa points out an odd lack of memory barriers in some sites
> >>     here.  I think the code's correct, but it's probably worth documenting.
> >>     
> >>     Reported-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
> >> 
> >> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> >> index 856407fa085e..90480993ec4a 100644
> >> --- a/net/sunrpc/svcsock.c
> >> +++ b/net/sunrpc/svcsock.c
> >> @@ -399,6 +399,25 @@ static int svc_sock_secure_port(struct svc_rqst *rqstp)
> >>  	return svc_port_is_privileged(svc_addr(rqstp));
> >>  }
> >>  
> >> +static void svc_no_smp_mb(void)
> >> +{
> >> +	/*
> >> +	 * Kosuke Tatsukawa points out there should normally be an
> >> +	 * smp_mb() at the callsites of this function.  (Either that or
> >> +	 * we could just drop the waitqueue_active() checks.)
> >> +	 *
> >> +	 * It appears they aren't currently necessary, though, basically
> >> +	 * because nfsd does non-blocking reads from these sockets, so
> >> +	 * the only places we wait on this waitqueue is in sendpage and
> >> +	 * sendmsg, which won't be waiting for wakeups on newly arrived
> >> +	 * data.
> >> +	 *
> >> +	 * Maybe we should add the memory barriers anyway, but these are
> >> +	 * hot paths so we'd need to be convinced there's no sigificant
> >> +	 * penalty.
> >> +	 */
> >> +}
> >> +
> >>  /*
> >>   * INET callback when data has been received on the socket.
> >>   */
> >> @@ -414,7 +433,7 @@ static void svc_udp_data_ready(struct sock *sk)
> >>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
> >>  		svc_xprt_enqueue(&svsk->sk_xprt);
> >>  	}
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq))
> >>  		wake_up_interruptible(wq);
> >>  }
> >> @@ -433,7 +452,7 @@ static void svc_write_space(struct sock *sk)
> >>  		svc_xprt_enqueue(&svsk->sk_xprt);
> >>  	}
> >>  
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq)) {
> >>  		dprintk("RPC svc_write_space: someone sleeping on %p\n",
> >>  		       svsk);
> >> @@ -789,7 +808,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
> >>  	}
> >>  
> >>  	wq = sk_sleep(sk);
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq))
> >>  		wake_up_interruptible_all(wq);
> >>  }
> >> @@ -811,7 +830,7 @@ static void svc_tcp_state_change(struct sock *sk)
> >>  		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
> >>  		svc_xprt_enqueue(&svsk->sk_xprt);
> >>  	}
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq))
> >>  		wake_up_interruptible_all(wq);
> >>  }
> >> @@ -827,7 +846,7 @@ static void svc_tcp_data_ready(struct sock *sk)
> >>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
> >>  		svc_xprt_enqueue(&svsk->sk_xprt);
> >>  	}
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq))
> >>  		wake_up_interruptible(wq);
> >>  }
> >> @@ -1599,7 +1618,7 @@ static void svc_sock_detach(struct svc_xprt *xprt)
> >>  	sk->sk_write_space = svsk->sk_owspace;
> >>  
> >>  	wq = sk_sleep(sk);
> >> -	smp_mb();
> >> +	svc_no_smp_mb();
> >>  	if (wq && waitqueue_active(wq))
> >>  		wake_up_interruptible(wq);
> >>  }
> ---
> Kosuke TATSUKAWA  | 3rd IT Platform Department
>                   | IT Platform Division, NEC Corporation
>                   | tatsu@ab.jp.nec.com
