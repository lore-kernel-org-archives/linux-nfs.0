Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:43873 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbbJOLpC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 07:45:02 -0400
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
Date: Thu, 15 Oct 2015 11:44:20 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A02878443@BPXM09GP.gisp.nec.co.jp>
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A02877D53@BPXM09GP.gisp.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tatsukawa Kosuke wrote:
> J. Bruce Fields wrote:
>> On Wed, Oct 14, 2015 at 03:57:13AM +0000, Kosuke Tatsukawa wrote:
>>> J. Bruce Fields wrote:
>>> > On Mon, Oct 12, 2015 at 10:41:06AM +0000, Kosuke Tatsukawa wrote:
>>> >> J. Bruce Fields wrote:
>>> >> > On Fri, Oct 09, 2015 at 06:29:44AM +0000, Kosuke Tatsukawa wrote:
>>> >> >> Neil Brown wrote:
>>> >> >> > Kosuke Tatsukawa <tatsu@ab.jp.nec.com> writes:
>>> >> >> > 
>>> >> >> >> There are several places in net/sunrpc/svcsock.c which calls
>>> >> >> >> waitqueue_active() without calling a memory barrier.  Add a memory
>>> >> >> >> barrier just as in wq_has_sleeper().
>>> >> >> >>
>>> >> >> >> I found this issue when I was looking through the linux source code
>>> >> >> >> for places calling waitqueue_active() before wake_up*(), but without
>>> >> >> >> preceding memory barriers, after sending a patch to fix a similar
>>> >> >> >> issue in drivers/tty/n_tty.c  (Details about the original issue can be
>>> >> >> >> found here: https://lkml.org/lkml/2015/9/28/849).
>>> >> >> > 
>>> >> >> > hi,
>>> >> >> > this feels like the wrong approach to the problem.  It requires extra
>>> >> >> > 'smb_mb's to be spread around which are hard to understand as easy to
>>> >> >> > forget.
>>> >> >> > 
>>> >> >> > A quick look seems to suggest that (nearly) every waitqueue_active()
>>> >> >> > will need an smb_mb.  Could we just put the smb_mb() inside
>>> >> >> > waitqueue_active()??
>>> >> >> <snip>
>>> >> >> 
>>> >> >> There are around 200 occurrences of waitqueue_active() in the kernel
>>> >> >> source, and most of the places which use it before wake_up are either
>>> >> >> protected by some spin lock, or already has a memory barrier or some
>>> >> >> kind of atomic operation before it.
>>> >> >> 
>>> >> >> Simply adding smp_mb() to waitqueue_active() would incur extra cost in
>>> >> >> many cases and won't be a good idea.
>>> >> >> 
>>> >> >> Another way to solve this problem is to remove the waitqueue_active(),
>>> >> >> making the code look like this;
>>> >> >> 	if (wq)
>>> >> >> 		wake_up_interruptible(wq);
>>> >> >> This also fixes the problem because the spinlock in the wake_up*() acts
>>> >> >> as a memory barrier and prevents the code from being reordered by the
>>> >> >> CPU (and it also makes the resulting code is much simpler).
>>> >> > 
>>> >> > I might not care which we did, except I don't have the means to test
>>> >> > this quickly, and I guess this is some of our most frequently called
>>> >> > code.
>>> >> > 
>>> >> > I suppose your patch is the most conservative approach, as the
>>> >> > alternative is a spinlock/unlock in wake_up_interruptible, which I
>>> >> > assume is necessarily more expensive than an smp_mb().
>>> >> > 
>>> >> > As far as I can tell it's been this way since forever.  (Well, since a
>>> >> > 2002 patch "NFSD: TCP: rationalise locking in RPC server routines" which
>>> >> > removed some spinlocks from the data_ready routines.)
>>> >> > 
>>> >> > I don't understand what the actual race is yet (which code exactly is
>>> >> > missing the wakeup in this case?  nfsd threads seem to instead get
>>> >> > woken up by the wake_up_process() in svc_xprt_do_enqueue().)
>>> >> 
>>> >> Thank you for the reply.  I tried looking into this.
>>> >> 
>>> >> The callbacks in net/sunrpc/svcsock.c are set up in svc_tcp_init() and
>>> >> svc_udp_init(), which are both called from svc_setup_socket().
>>> >> svc_setup_socket() is called (indirectly) from lockd, nfsd, and nfsv4
>>> >> callback port related code.
>>> >> 
>>> >> Maybe I'm wrong, but there might not be any kernel code that is using
>>> >> the socket's wait queue in this case.
>>> > 
>>> > As Trond points out there are probably waiters internal to the
>>> > networking code.
>>> 
>>> Trond and Bruce, thank you for the comment.  I was able to find the call
>>> to the wait function that was called from nfsd.
>>> 
>>> sk_stream_wait_connect() and sk_stream_wait_memory() were called from
>>> either do_tcp_sendpages() or tcp_sendmsg() called from within
>>> svc_send().  sk_stream_wait_connect() shouldn't be called at this point,
>>> because the socket has already been used to receive the rpc request.
>>> 
>>> On the wake_up side, sk_write_space() is called from the following
>>> locations.  The relevant ones seems to be preceded by atomic_sub or a
>>> memory barrier.
>>> + ksocknal_write_space [drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c:633]
>>> + atm_pop_raw [net/atm/raw.c:40]
>>> + sock_setsockopt [net/core/sock.c:740]
>>> + sock_wfree [net/core/sock.c:1630]
>>>   Preceded by atomic_sub in sock_wfree()
>>> + ccid3_hc_tx_packet_recv [net/dccp/ccids/ccid3.c:442]
>>> + do_tcp_sendpages [net/ipv4/tcp.c:1008]
>>> + tcp_sendmsg [net/ipv4/tcp.c:1300]
>>> + do_tcp_setsockopt [net/ipv4/tcp.c:2597]
>>> + tcp_new_space [net/ipv4/tcp_input.c:4885]
>>>   Preceded by smp_mb__after_atomic in tcp_check_space()
>>> + llc_conn_state_process [net/llc/llc_conn.c:148]
>>> + pipe_rcv_status [net/phonet/pep.c:312]
>>> + pipe_do_rcv [net/phonet/pep.c:440]
>>> + pipe_start_flow_control [net/phonet/pep.c:554]
>>> + svc_sock_setbufsize [net/sunrpc/svcsock.c:45]
>>> 
>>> sk_state_change() calls related to TCP/IP were called from the following
>>> places.
>>> + inet_shutdown [net/ipv4/af_inet.c:825]
>>>   This shouldn't be called when waiting
>>> + tcp_done [net/ipv4/tcp.c:3078]
>>>   spin_lock*/spin_unlock* is called in lock_timer_base
>>> + tcp_fin [net/ipv4/tcp_input.c:4031]
>>>   atomic_long_sub is called from sk_memory_allocated_sub called within
>>>   sk_mem_reclaim
>>> + tcp_finish_connect [net/ipv4/tcp_input.c:5415]
>>>   This shoudn't be called when waiting
>>> + tcp_rcv_state_process [net/ipv4/tcp_input.c:5807,5880]
>>>   The socket shouldn't be in TCP_SYN_RECV nor TCP_FIN_WAIT1 states when
>>>   waiting
>>> 
>>> I think the wait queue won't be used for being woken up by
>>> svc_{tcp,udp}_data_ready, because nfsd doesn't read from a socket.
>> 
>> Looking, well, I guess kernel_recvmsg() does read from a socket, but I
>> assume calling with MSG_DONTWAIT means that it doesn't block.
>> 
>>> So with the current implementation, it seems there shouldn't be any
>>> problems even if the memory barrier is missing.
>> 
>> Thanks for the detailed investigation.
>> 
>> I think it would be worth adding a comment if that might help someone
>> having to reinvestigate this again some day.
> 
> It would be nice, but I find it difficult to write a comment in the
> sunrpc layer why a memory barrier isn't necessary, using the knowledge
> of how nfsd uses it, and the current implementation of the network code.
> 
> Personally, I would prefer removing the call to waitqueue_active() which
> would make the memory barrier totally unnecessary at the cost of a
> spin_lock + spin_unlock by unconditionally calling
> wake_up_interruptible.

On second thought, the callbacks will be called frequently from the tcp
code, so it wouldn't be a good idea.
---
Kosuke TATSUKAWA  | 3rd IT Platform Department
                  | IT Platform Division, NEC Corporation
                  | tatsu@ab.jp.nec.com
