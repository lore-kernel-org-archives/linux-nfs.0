Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:47691 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbJXBTz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2015 21:19:55 -0400
From: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Neil Brown <nfbrown@novell.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier
 in sunrpc
Date: Sat, 24 Oct 2015 01:19:00 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A0287AD15@BPXM09GP.gisp.nec.co.jp>
In-Reply-To: <20151023204945.GD16137@fieldses.org>
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Oct 23, 2015 at 04:14:10AM +0000, Kosuke Tatsukawa wrote:
>> J. Bruce Fields wrote:
>> > On Fri, Oct 16, 2015 at 02:28:10AM +0000, Kosuke Tatsukawa wrote:
>> >> Tatsukawa Kosuke wrote:
>> >> > J. Bruce Fields wrote:
>> >> >> On Thu, Oct 15, 2015 at 11:44:20AM +0000, Kosuke Tatsukawa wrote:
>> >> >>> Tatsukawa Kosuke wrote:
>> >> >>> > J. Bruce Fields wrote:
>> >> >>> >> Thanks for the detailed investigation.
>> >> >>> >> 
>> >> >>> >> I think it would be worth adding a comment if that might help someone
>> >> >>> >> having to reinvestigate this again some day.
>> >> >>> > 
>> >> >>> > It would be nice, but I find it difficult to write a comment in the
>> >> >>> > sunrpc layer why a memory barrier isn't necessary, using the knowledge
>> >> >>> > of how nfsd uses it, and the current implementation of the network code.
>> >> >>> > 
>> >> >>> > Personally, I would prefer removing the call to waitqueue_active() which
>> >> >>> > would make the memory barrier totally unnecessary at the cost of a
>> >> >>> > spin_lock + spin_unlock by unconditionally calling
>> >> >>> > wake_up_interruptible.
>> >> >>> 
>> >> >>> On second thought, the callbacks will be called frequently from the tcp
>> >> >>> code, so it wouldn't be a good idea.
>> >> >> 
>> >> >> So, I was even considering documenting it like this, if it's not
>> >> >> overkill.
>> >> >> 
>> >> >> Hmm... but if this is right, then we may as well ask why we're doing the
>> >> >> wakeups at all.  Might be educational to test the code with them
>> >> >> removed.
>> >> > 
>> >> > sk_write_space will be called in sock_wfree() with UDP/IP each time
>> >> > kfree_skb() is called.  With TCP/IP, sk_write_space is only called if
>> >> > SOCK_NOSPACE has been set.
>> >> > 
>> >> > sk_data_ready will be called in both tcp_rcv_established() for TCP/IP
>> >> > and in sock_queue_rcv_skb() for UDP/IP.  The latter lacks a memory
>> >> > barrier with sk_data_ready called right after __skb_queue_tail().
>> >> > I think this hasn't caused any problems because sk_data_ready wasn't
>> >> > used.
>> >> 
>> >> Actually, svc_udp_data_ready() calls set_bit() which is an atomic
>> >> operation.  So there won't be a problem unless svsk is NULL.
>> > 
>> > So is it true that every caller of these socket callbacks has adequate
>> > memory barriers between the time the change is made visible and the time
>> > the callback is called?
>> > 
>> > If so, then there's nothing really specific about nfsd here.
>> > 
>> > In that case maybe it's the networking code that use some documentation,
>> > if it doesn't already?  (Or maybe common helper functions for this
>> > 
>> > 	if (waitqueue_active(wq))
>> > 		wake_up(wq)
>> > 
>> > pattern?)
>> 
>> Some of the other places defining these callback functions are using
>>   static inline bool wq_has_sleeper(struct socket_wq *wq)
>> defined in include/net/sock.h
>> 
>> The comment above the function explains that it was introduced for
>> exactly this purpose.
>> 
>> Even thought the argument variable uses the same name "wq", it has a
>> different type from the wq used in svcsock.c (struct socket_wq *
>> vs. wait_queue_head_t *).
> 
> OK, thanks.  So, I guess it still sounds like the code is OK as is, but
> maybe my comment wasn't.  Here's another attempt.

Thank you.  By now the patch looks completely different from my original
patch, so I don't think I deserve to be mentioned in the Author line.


> --b.
> 
> commit b805ca58a81a
> Author: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
> Date:   Fri Oct 9 01:44:07 2015 +0000
> 
>     svcrpc: document lack of some memory barriers
>     
>     We're missing memory barriers in net/sunrpc/svcsock.c in some spots we'd
>     expect them.  But it doesn't appear they're necessary in our case, and
>     this is likely a hot path--for now just document the odd behavior.
>     
>     I found this issue when I was looking through the linux source code
>     for places calling waitqueue_active() before wake_up*(), but without
>     preceding memory barriers, after sending a patch to fix a similar
>     issue in drivers/tty/n_tty.c  (Details about the original issue can be
>     found here: https://lkml.org/lkml/2015/9/28/849).

I should have used the stable link format to refer to the disucssion in
LKML instead of the lkml.org URL.  The stable link is

http://lkml.kernel.org/r/17EC94B0A072C34B8DCF0D30AD16044A02871D53@BPXM09GP.gisp.nec.co.jp


>     
>     Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
>     [bfields@redhat.com,nfbrown@novell.com: document instead of adding barriers]
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 48923730722d..1f71eece04d3 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -399,6 +399,31 @@ static int svc_sock_secure_port(struct svc_rqst *rqstp)
>  	return svc_port_is_privileged(svc_addr(rqstp));
>  }
>  
> +static bool sunrpc_waitqueue_active(wait_queue_head_t *wq)
> +{
> +	if (!wq)
> +		return false;
> +	/*
> +	 * Kosuke Tatsukawa points out there should normally be a memory
> +	 * barrier here--see wq_has_sleeper().

Having my name in the comment itself looks a little odd, since I don't
see other places in the kernel source code that mentions the reporter's
name.


> +	 *
> +	 * It appears that isn't currently necessary, though, basically
> +	 * because callers all appear to have sufficient memory barriers
> +	 * between the time the relevant change is made and the
> +	 * time they call these callbacks.
> +	 *
> +	 * The nfsd code itself doesn't actually explicitly wait on
> +	 * these waitqueues, but it may wait on them for example in
> +	 * sendpage() or sendmsg() calls.  (And those may be the only
> +	 * places, since it it uses nonblocking reads.)

The above line contains an extra "it".


> +	 *
> +	 * Maybe we should add the memory barriers anyway, but these are
> +	 * hot paths so we'd need to be convinced there's no sigificant
> +	 * penalty.
> +	 */
> +	return waitqueue_active(wq);
> +}
> +
>  /*
>   * INET callback when data has been received on the socket.
>   */
> @@ -414,7 +439,7 @@ static void svc_udp_data_ready(struct sock *sk)
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	if (wq && waitqueue_active(wq))
> +	if (sunrpc_waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }
>  
> @@ -432,7 +457,7 @@ static void svc_write_space(struct sock *sk)
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
>  
> -	if (wq && waitqueue_active(wq)) {
> +	if (sunrpc_waitqueue_active(wq)) {
>  		dprintk("RPC svc_write_space: someone sleeping on %p\n",
>  		       svsk);
>  		wake_up_interruptible(wq);
> @@ -787,7 +812,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
>  	}
>  
>  	wq = sk_sleep(sk);
> -	if (wq && waitqueue_active(wq))
> +	if (sunrpc_waitqueue_active(wq))
>  		wake_up_interruptible_all(wq);
>  }
>  
> @@ -808,7 +833,7 @@ static void svc_tcp_state_change(struct sock *sk)
>  		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	if (wq && waitqueue_active(wq))
> +	if (sunrpc_waitqueue_active(wq))
>  		wake_up_interruptible_all(wq);
>  }
>  
> @@ -823,7 +848,7 @@ static void svc_tcp_data_ready(struct sock *sk)
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	if (wq && waitqueue_active(wq))
> +	if (sunrpc_waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }
>  
> @@ -1594,7 +1619,7 @@ static void svc_sock_detach(struct svc_xprt *xprt)
>  	sk->sk_write_space = svsk->sk_owspace;
>  
>  	wq = sk_sleep(sk);
> -	if (wq && waitqueue_active(wq))
> +	if (sunrpc_waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }

Best regards.
---
Kosuke TATSUKAWA  | 3rd IT Platform Department
                  | IT Platform Division, NEC Corporation
                  | tatsu@ab.jp.nec.com
