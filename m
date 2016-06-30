Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0193.hostedemail.com ([216.40.44.193]:54938 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752000AbcF3PXt convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 11:23:49 -0400
Date: Thu, 30 Jun 2016 11:23:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "Linux Network Devel Mailing List" <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port
 (left over from xs_bind() ))
Message-ID: <20160630112341.5ab5a821@gandalf.local.home>
In-Reply-To: <C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
References: <20160630085950.61e5c7e0@gandalf.local.home>
 <C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 Jun 2016 13:17:47 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> > On Jun 30, 2016, at 08:59, Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > [ resending as a new email, as I'm assuming people do not sort their
> >  INBOX via last email on thread, thus my last email is sitting in the
> >  bottom of everyone's INBOX ]
> > 
> > I've hit this again. Not sure when it started, but I applied my old
> > debug trace_printk() patch (attached) and rebooted (4.5.7). I just
> > tested the latest kernel from Linus's tree (from last nights pull), and
> > it still gives me the problem.
> > 
> > Here's the trace I have:
> > 
> >    kworker/3:1H-134   [003] ..s.    61.036129: inet_csk_get_port: snum 805

Here's were the port is taken

> >    kworker/3:1H-134   [003] ..s.    61.036135: <stack trace>  
> > => sched_clock
> > => inet_addr_type_table
> > => security_capable
> > => inet_bind
> > => xs_bind
> > => release_sock
> > => sock_setsockopt
> > => __sock_create
> > => xs_create_sock.isra.19
> > => xs_tcp_setup_socket
> > => process_one_work
> > => worker_thread
> > => worker_thread
> > => kthread
> > => ret_from_fork
> > => kthread    
> >    kworker/3:1H-134   [003] ..s.    61.036136: inet_bind_hash: add 805
> >    kworker/3:1H-134   [003] ..s.    61.036138: <stack trace>  
> > => inet_csk_get_port
> > => sched_clock
> > => inet_addr_type_table
> > => security_capable
> > => inet_bind
> > => xs_bind
> > => release_sock
> > => sock_setsockopt
> > => __sock_create
> > => xs_create_sock.isra.19
> > => xs_tcp_setup_socket
> > => process_one_work
> > => worker_thread
> > => worker_thread
> > => kthread
> > => ret_from_fork
> > => kthread    
> >    kworker/3:1H-134   [003] ....    61.036139: xs_bind: RPC:       xs_bind 4.136.255.255:805: ok (0)

Here's where it is bounded.

> >    kworker/3:1H-134   [003] ....    61.036140: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff880407eca800 via tcp to 192.168.23.22 (port 43651)
> >    kworker/3:1H-134   [003] ....    61.036162: xs_tcp_setup_socket: RPC:       ffff880407eca800 connect status 115 connected 0 sock state 2
> >          <idle>-0     [001] ..s.    61.036450: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff880407eca800...
> >          <idle>-0     [001] ..s.    61.036452: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
> >    kworker/1:1H-136   [001] ....    61.036476: xprt_connect_status: RPC:    43 xprt_connect_status: retrying
> >    kworker/1:1H-136   [001] ....    61.036478: xprt_prepare_transmit: RPC:    43 xprt_prepare_transmit
> >    kworker/1:1H-136   [001] ....    61.036479: xprt_transmit: RPC:    43 xprt_transmit(72)
> >    kworker/1:1H-136   [001] ....    61.036486: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
> >    kworker/1:1H-136   [001] ....    61.036487: xprt_transmit: RPC:    43 xmit complete
> >          <idle>-0     [001] ..s.    61.036789: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
> >    kworker/1:1H-136   [001] ....    61.036798: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
> >    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
> >    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
> >    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:       reading request with XID 2f4c3f88
> >    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
> >    kworker/1:1H-136   [001] ....    61.036801: xs_tcp_data_recv: RPC:       read reply XID 2f4c3f88
> >    kworker/1:1H-136   [001] ..s.    61.036801: xs_tcp_data_recv: RPC:       XID 2f4c3f88 read 16 bytes
> >    kworker/1:1H-136   [001] ..s.    61.036802: xs_tcp_data_recv: RPC:       xprt = ffff880407eca800, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
> >    kworker/1:1H-136   [001] ..s.    61.036802: xprt_complete_rqst: RPC:    43 xid 2f4c3f88 complete (24 bytes received)
> >    kworker/1:1H-136   [001] ....    61.036803: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
> >    kworker/1:1H-136   [001] ....    61.036812: xprt_release: RPC:    43 release request ffff88040b270800
> > 
> > 
> > # unhide-tcp 
> > Unhide-tcp 20130526
> > Copyright © 2013 Yago Jesus & Patrick Gouin
> > License GPLv3+ : GNU GPL version 3 or later
> > http://www.unhide-forensics.info
> > Used options: 
> > [*]Starting TCP checking
> > 
> > Found Hidden port that not appears in ss: 805
> >   
> 
> What is a “Hidden port that not appears in ss: 805”, and what does this report mean? Are we failing to close a socket?

I believe hidden ports are ports that are bound to no socket.
Basically, a "port leak". Where they are in limbo and can never be
reused.

I looked at my past report, and everthing is exactly like the issue
before. When I first boot my box, the port is there, I have the above
trace. I run netstat -tapn and grep for the port. And it shows that it
is an established socket between my box and my wife's box (I have a nfs
mounted file system for her to copy her pictures to my server). After a
couple of minutes, the port turns from ESTABLISHED to TIME_WAIT, and
after another minute it disappears. At that moment, the unhide-tcp
shows the port as hidden.

When the socket goes away (without releasing the port) I see this in my
trace:

    kworker/1:1H-131   [001] ..s.   364.762537: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040ad68800...
    kworker/1:1H-131   [001] ..s.   364.762539: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [001] ..s.   364.762715: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040ad68800...
          <idle>-0     [001] ..s.   364.762716: xs_tcp_state_change: RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [001] ..s.   364.762728: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040ad68800...
          <idle>-0     [001] ..s.   364.762728: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [001] ..s.   364.762729: xprt_disconnect_done: RPC:       disconnected transport ffff88040ad68800
          <idle>-0     [001] ..s.   364.762730: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040ad68800...
          <idle>-0     [001] ..s.   364.762730: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [001] ..s.   364.762730: xprt_disconnect_done: RPC:       disconnected transport ffff88040ad68800

I can add more trace_printk()s if it would help.

-- Steve
