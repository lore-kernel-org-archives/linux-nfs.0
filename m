Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:53965 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3AWXzL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 18:55:11 -0500
Message-ID: <5100785D.8040101@candelatech.com>
Date: Wed, 23 Jan 2013 15:55:09 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop> <1358875607.3464.4020.camel@edumazet-glaptop> <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
In-Reply-To: <50FF4BC9.1060206@candelatech.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2013 06:32 PM, Ben Greear wrote:

So, I'm slowly making some progress.  I've verified that the skb
has bogus dst (0xdeadbeef) at the top of the ip_rcv_finish
method.  I'm trying to track it backwards and figure out which
device it belongs to, etc....takes a while to reproduce though.

One thing about this stack trace below...the dev_seq_stop() does
a rcu read-unlock.  Now, I can't figure out exactly how ip_rcv()
can cause dev_seq_stop() to run, but if this stack is legit,
then maybe by the time we enter the ip_rcv_finish() code we are
running without rcu_readlock() held?

If so, that would probably explain the bug.

> Call Trace:
>   [<ffffffff814a8b02>] ? ip_rcv_finish+0x2f0/0x308
>   [<ffffffff814a8812>] ? skb_dst+0x5a/0x5a
>   [<ffffffff814a8eb5>] NF_HOOK.clone.1+0x4c/0x54
>   [<ffffffff81472e61>] ? dev_seq_stop+0xb/0xb
>   [<ffffffff814a9142>] ip_rcv+0x237/0x269
>   [<ffffffff81473def>] __netif_receive_skb+0x487/0x530
>   [<ffffffff81473f91>] process_backlog+0xf9/0x1da
>   [<ffffffff8147639a>] net_rx_action+0xad/0x218
>   [<ffffffff8108d50a>] __do_softirq+0x9c/0x161
>   [<ffffffff8108d5f2>] run_ksoftirqd+0x23/0x42
>   [<ffffffff810a7ebe>] smpboot_thread_fn+0x253/0x259
>   [<ffffffff810a7c6b>] ? test_ti_thread_flag.clone.0+0x11/0x11
>   [<ffffffff810a0a6d>] kthread+0xc2/0xca
>   [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
>   [<ffffffff81537b7c>] ret_from_fork+0x7c/0xb0
>   [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56


## This is from a slightly different kernel image...but probably this part is legit.

0xffffffff814a92b3 is in ip_rcv (/home/greearb/git/linux-3.7.dev.y/net/ipv4/ip_input.c:466).
461		/* Our transport medium may have padded the buffer out. Now we know it
462		 * is IP we can trim to the true length of the frame.
463		 * Note this now means skb->len holds ntohs(iph->tot_len).
464		 */
465		if (pskb_trim_rcsum(skb, len)) {
466			IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
467			goto drop;
468		}
469	
470		/* Remove any debris in the socket control block */


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

