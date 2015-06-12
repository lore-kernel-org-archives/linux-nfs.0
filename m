Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0049.hostedemail.com ([216.40.44.49]:50226 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750803AbbFLPeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 11:34:25 -0400
Date: Fri, 12 Jun 2015 11:34:20 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150612113420.5c114183@gandalf.local.home>
In-Reply-To: <1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Jun 2015 07:40:35 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Strange, because the usual way to not have time-wait is to use SO_LINGER
> with linger=0
> 
> And apparently xs_tcp_finish_connecting() has this :
> 
>                 sock_reset_flag(sk, SOCK_LINGER);
>                 tcp_sk(sk)->linger2 = 0;
> 
> Are you sure SO_REUSEADDR was not the thing you wanted ?
> 
> Steven, have you tried kmemleak ?

Nope, and again, I'm hesitant on adding too much debug. This is my main
server (build server, ssh server, web server, mail server, proxy
server, irc server, etc).

Although, I made dprintk() into trace_printk() in xprtsock.c and
xprt.c, and reran it. Here's the output:

(port 684 was the bad one this time)

# tracer: nop
#
# entries-in-buffer/entries-written: 396/396   #P:4
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
        rpc.nfsd-4710  [002] ....    48.615382: xs_local_setup_socket: RPC:       worker connecting xprt ffff8800d9018000 via AF_LOCAL to /var/run/rpcbind.sock
        rpc.nfsd-4710  [002] ....    48.615393: xs_local_setup_socket: RPC:       xprt ffff8800d9018000 connected to /var/run/rpcbind.sock
        rpc.nfsd-4710  [002] ....    48.615394: xs_setup_local: RPC:       set up xprt to /var/run/rpcbind.sock via AF_LOCAL
        rpc.nfsd-4710  [002] ....    48.615399: xprt_create_transport: RPC:       created transport ffff8800d9018000 with 65536 slots
        rpc.nfsd-4710  [002] ....    48.615416: xprt_alloc_slot: RPC:     1 reserved req ffff8800db829600 xid cb06d5e8
        rpc.nfsd-4710  [002] ....    48.615419: xprt_prepare_transmit: RPC:     1 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.615420: xprt_transmit: RPC:     1 xprt_transmit(44)
        rpc.nfsd-4710  [002] ....    48.615424: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-4710  [002] ....    48.615425: xprt_transmit: RPC:     1 xmit complete
         rpcbind-1829  [003] ..s.    48.615503: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.615506: xprt_complete_rqst: RPC:     1 xid cb06d5e8 complete (24 bytes received)
        rpc.nfsd-4710  [002] ....    48.615556: xprt_release: RPC:     1 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.615568: xprt_alloc_slot: RPC:     2 reserved req ffff8800db829600 xid cc06d5e8
        rpc.nfsd-4710  [002] ....    48.615569: xprt_prepare_transmit: RPC:     2 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.615569: xprt_transmit: RPC:     2 xprt_transmit(44)
        rpc.nfsd-4710  [002] ....    48.615578: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-4710  [002] ....    48.615578: xprt_transmit: RPC:     2 xmit complete
         rpcbind-1829  [003] ..s.    48.615643: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.615645: xprt_complete_rqst: RPC:     2 xid cc06d5e8 complete (24 bytes received)
        rpc.nfsd-4710  [002] ....    48.615695: xprt_release: RPC:     2 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.615698: xprt_alloc_slot: RPC:     3 reserved req ffff8800db829600 xid cd06d5e8
        rpc.nfsd-4710  [002] ....    48.615699: xprt_prepare_transmit: RPC:     3 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.615700: xprt_transmit: RPC:     3 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.615706: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.615707: xprt_transmit: RPC:     3 xmit complete
         rpcbind-1829  [003] ..s.    48.615784: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.615785: xprt_complete_rqst: RPC:     3 xid cd06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.615830: xprt_release: RPC:     3 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.615833: xprt_alloc_slot: RPC:     4 reserved req ffff8800db829600 xid ce06d5e8
        rpc.nfsd-4710  [002] ....    48.615834: xprt_prepare_transmit: RPC:     4 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.615835: xprt_transmit: RPC:     4 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.615841: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.615841: xprt_transmit: RPC:     4 xmit complete
         rpcbind-1829  [003] ..s.    48.615892: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.615894: xprt_complete_rqst: RPC:     4 xid ce06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.615958: xprt_release: RPC:     4 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.615961: xprt_alloc_slot: RPC:     5 reserved req ffff8800db829600 xid cf06d5e8
        rpc.nfsd-4710  [002] ....    48.615962: xprt_prepare_transmit: RPC:     5 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.615966: xprt_transmit: RPC:     5 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.615971: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.615972: xprt_transmit: RPC:     5 xmit complete
         rpcbind-1829  [003] ..s.    48.616011: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.616012: xprt_complete_rqst: RPC:     5 xid cf06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616057: xprt_release: RPC:     5 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616059: xprt_alloc_slot: RPC:     6 reserved req ffff8800db829600 xid d006d5e8
        rpc.nfsd-4710  [002] ....    48.616060: xprt_prepare_transmit: RPC:     6 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616061: xprt_transmit: RPC:     6 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.616065: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.616066: xprt_transmit: RPC:     6 xmit complete
         rpcbind-1829  [003] ..s.    48.616117: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [003] ..s.    48.616119: xprt_complete_rqst: RPC:     6 xid d006d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616163: xprt_release: RPC:     6 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616165: xprt_alloc_slot: RPC:     7 reserved req ffff8800db829600 xid d106d5e8
        rpc.nfsd-4710  [002] ....    48.616166: xprt_prepare_transmit: RPC:     7 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616167: xprt_transmit: RPC:     7 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.616172: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.616172: xprt_transmit: RPC:     7 xmit complete
         rpcbind-1829  [000] ..s.    48.616247: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616249: xprt_complete_rqst: RPC:     7 xid d106d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616289: xprt_release: RPC:     7 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616296: xprt_alloc_slot: RPC:     8 reserved req ffff8800db829600 xid d206d5e8
        rpc.nfsd-4710  [002] ....    48.616297: xprt_prepare_transmit: RPC:     8 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616298: xprt_transmit: RPC:     8 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616302: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616302: xprt_transmit: RPC:     8 xmit complete
         rpcbind-1829  [000] ..s.    48.616324: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616326: xprt_complete_rqst: RPC:     8 xid d206d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616340: xprt_release: RPC:     8 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616346: xprt_alloc_slot: RPC:     9 reserved req ffff8800db829600 xid d306d5e8
        rpc.nfsd-4710  [002] ....    48.616347: xprt_prepare_transmit: RPC:     9 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616348: xprt_transmit: RPC:     9 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616355: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616355: xprt_transmit: RPC:     9 xmit complete
         rpcbind-1829  [000] ..s.    48.616380: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616381: xprt_complete_rqst: RPC:     9 xid d306d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616392: xprt_release: RPC:     9 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616396: xprt_alloc_slot: RPC:    10 reserved req ffff8800db829600 xid d406d5e8
        rpc.nfsd-4710  [002] ....    48.616396: xprt_prepare_transmit: RPC:    10 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616397: xprt_transmit: RPC:    10 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616401: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616402: xprt_transmit: RPC:    10 xmit complete
         rpcbind-1829  [000] ..s.    48.616421: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616422: xprt_complete_rqst: RPC:    10 xid d406d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616433: xprt_release: RPC:    10 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616436: xprt_alloc_slot: RPC:    11 reserved req ffff8800db829600 xid d506d5e8
        rpc.nfsd-4710  [002] ....    48.616437: xprt_prepare_transmit: RPC:    11 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616438: xprt_transmit: RPC:    11 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616442: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616442: xprt_transmit: RPC:    11 xmit complete
         rpcbind-1829  [000] ..s.    48.616461: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616462: xprt_complete_rqst: RPC:    11 xid d506d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616473: xprt_release: RPC:    11 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616476: xprt_alloc_slot: RPC:    12 reserved req ffff8800db829600 xid d606d5e8
        rpc.nfsd-4710  [002] ....    48.616477: xprt_prepare_transmit: RPC:    12 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616478: xprt_transmit: RPC:    12 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616482: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616482: xprt_transmit: RPC:    12 xmit complete
         rpcbind-1829  [000] ..s.    48.616501: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616502: xprt_complete_rqst: RPC:    12 xid d606d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616511: xprt_release: RPC:    12 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616535: xprt_alloc_slot: RPC:    13 reserved req ffff8800db829600 xid d706d5e8
        rpc.nfsd-4710  [002] ....    48.616536: xprt_prepare_transmit: RPC:    13 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616537: xprt_transmit: RPC:    13 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616541: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616541: xprt_transmit: RPC:    13 xmit complete
         rpcbind-1829  [000] ..s.    48.616580: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616581: xprt_complete_rqst: RPC:    13 xid d706d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616589: xprt_release: RPC:    13 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616591: xprt_alloc_slot: RPC:    14 reserved req ffff8800db829600 xid d806d5e8
        rpc.nfsd-4710  [002] ....    48.616591: xprt_prepare_transmit: RPC:    14 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616592: xprt_transmit: RPC:    14 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616594: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616595: xprt_transmit: RPC:    14 xmit complete
         rpcbind-1829  [000] ..s.    48.616610: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616611: xprt_complete_rqst: RPC:    14 xid d806d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616618: xprt_release: RPC:    14 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616619: xprt_alloc_slot: RPC:    15 reserved req ffff8800db829600 xid d906d5e8
        rpc.nfsd-4710  [002] ....    48.616620: xprt_prepare_transmit: RPC:    15 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616620: xprt_transmit: RPC:    15 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616623: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616623: xprt_transmit: RPC:    15 xmit complete
         rpcbind-1829  [000] ..s.    48.616635: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616637: xprt_complete_rqst: RPC:    15 xid d906d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616643: xprt_release: RPC:    15 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616644: xprt_alloc_slot: RPC:    16 reserved req ffff8800db829600 xid da06d5e8
        rpc.nfsd-4710  [002] ....    48.616645: xprt_prepare_transmit: RPC:    16 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616645: xprt_transmit: RPC:    16 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616648: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616648: xprt_transmit: RPC:    16 xmit complete
         rpcbind-1829  [000] ..s.    48.616658: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616659: xprt_complete_rqst: RPC:    16 xid da06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616665: xprt_release: RPC:    16 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.616666: xprt_alloc_slot: RPC:    17 reserved req ffff8800db829600 xid db06d5e8
        rpc.nfsd-4710  [002] ....    48.616667: xprt_prepare_transmit: RPC:    17 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.616667: xprt_transmit: RPC:    17 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.616670: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.616670: xprt_transmit: RPC:    17 xmit complete
         rpcbind-1829  [000] ..s.    48.616680: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.616681: xprt_complete_rqst: RPC:    17 xid db06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.616687: xprt_release: RPC:    17 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617251: xprt_alloc_slot: RPC:    18 reserved req ffff8800db829600 xid dc06d5e8
        rpc.nfsd-4710  [002] ....    48.617252: xprt_prepare_transmit: RPC:    18 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617252: xprt_transmit: RPC:    18 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617256: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617257: xprt_transmit: RPC:    18 xmit complete
         rpcbind-1829  [000] ..s.    48.617265: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617265: xprt_complete_rqst: RPC:    18 xid dc06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617272: xprt_release: RPC:    18 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617274: xprt_alloc_slot: RPC:    19 reserved req ffff8800db829600 xid dd06d5e8
        rpc.nfsd-4710  [002] ....    48.617274: xprt_prepare_transmit: RPC:    19 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617275: xprt_transmit: RPC:    19 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617277: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617277: xprt_transmit: RPC:    19 xmit complete
         rpcbind-1829  [000] ..s.    48.617287: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617288: xprt_complete_rqst: RPC:    19 xid dd06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617293: xprt_release: RPC:    19 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617295: xprt_alloc_slot: RPC:    20 reserved req ffff8800db829600 xid de06d5e8
        rpc.nfsd-4710  [002] ....    48.617295: xprt_prepare_transmit: RPC:    20 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617296: xprt_transmit: RPC:    20 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617298: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617298: xprt_transmit: RPC:    20 xmit complete
         rpcbind-1829  [000] ..s.    48.617307: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617308: xprt_complete_rqst: RPC:    20 xid de06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617314: xprt_release: RPC:    20 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617315: xprt_alloc_slot: RPC:    21 reserved req ffff8800db829600 xid df06d5e8
        rpc.nfsd-4710  [002] ....    48.617316: xprt_prepare_transmit: RPC:    21 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617316: xprt_transmit: RPC:    21 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617318: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617319: xprt_transmit: RPC:    21 xmit complete
         rpcbind-1829  [000] ..s.    48.617328: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617329: xprt_complete_rqst: RPC:    21 xid df06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617334: xprt_release: RPC:    21 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617336: xprt_alloc_slot: RPC:    22 reserved req ffff8800db829600 xid e006d5e8
        rpc.nfsd-4710  [002] ....    48.617336: xprt_prepare_transmit: RPC:    22 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617336: xprt_transmit: RPC:    22 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617339: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617339: xprt_transmit: RPC:    22 xmit complete
         rpcbind-1829  [000] ..s.    48.617348: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617349: xprt_complete_rqst: RPC:    22 xid e006d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617354: xprt_release: RPC:    22 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617370: xprt_alloc_slot: RPC:    23 reserved req ffff8800db829600 xid e106d5e8
        rpc.nfsd-4710  [002] ....    48.617371: xprt_prepare_transmit: RPC:    23 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617371: xprt_transmit: RPC:    23 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617374: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617374: xprt_transmit: RPC:    23 xmit complete
         rpcbind-1829  [000] ..s.    48.617382: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617383: xprt_complete_rqst: RPC:    23 xid e106d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617389: xprt_release: RPC:    23 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617390: xprt_alloc_slot: RPC:    24 reserved req ffff8800db829600 xid e206d5e8
        rpc.nfsd-4710  [002] ....    48.617391: xprt_prepare_transmit: RPC:    24 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617391: xprt_transmit: RPC:    24 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617394: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617394: xprt_transmit: RPC:    24 xmit complete
         rpcbind-1829  [000] ..s.    48.617403: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617404: xprt_complete_rqst: RPC:    24 xid e206d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617410: xprt_release: RPC:    24 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617411: xprt_alloc_slot: RPC:    25 reserved req ffff8800db829600 xid e306d5e8
        rpc.nfsd-4710  [002] ....    48.617412: xprt_prepare_transmit: RPC:    25 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617412: xprt_transmit: RPC:    25 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617414: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617414: xprt_transmit: RPC:    25 xmit complete
         rpcbind-1829  [000] ..s.    48.617424: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617424: xprt_complete_rqst: RPC:    25 xid e306d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617430: xprt_release: RPC:    25 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617431: xprt_alloc_slot: RPC:    26 reserved req ffff8800db829600 xid e406d5e8
        rpc.nfsd-4710  [002] ....    48.617432: xprt_prepare_transmit: RPC:    26 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617432: xprt_transmit: RPC:    26 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617434: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617434: xprt_transmit: RPC:    26 xmit complete
         rpcbind-1829  [000] ..s.    48.617444: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617444: xprt_complete_rqst: RPC:    26 xid e406d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617450: xprt_release: RPC:    26 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617451: xprt_alloc_slot: RPC:    27 reserved req ffff8800db829600 xid e506d5e8
        rpc.nfsd-4710  [002] ....    48.617452: xprt_prepare_transmit: RPC:    27 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617452: xprt_transmit: RPC:    27 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617454: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617455: xprt_transmit: RPC:    27 xmit complete
         rpcbind-1829  [000] ..s.    48.617464: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617464: xprt_complete_rqst: RPC:    27 xid e506d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617470: xprt_release: RPC:    27 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617575: xprt_alloc_slot: RPC:    28 reserved req ffff8800db829600 xid e606d5e8
        rpc.nfsd-4710  [002] ....    48.617576: xprt_prepare_transmit: RPC:    28 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617577: xprt_transmit: RPC:    28 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.617580: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.617580: xprt_transmit: RPC:    28 xmit complete
         rpcbind-1829  [000] ..s.    48.617590: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617591: xprt_complete_rqst: RPC:    28 xid e606d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617598: xprt_release: RPC:    28 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617599: xprt_alloc_slot: RPC:    29 reserved req ffff8800db829600 xid e706d5e8
        rpc.nfsd-4710  [002] ....    48.617599: xprt_prepare_transmit: RPC:    29 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617600: xprt_transmit: RPC:    29 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.617602: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.617602: xprt_transmit: RPC:    29 xmit complete
         rpcbind-1829  [000] ..s.    48.617614: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617615: xprt_complete_rqst: RPC:    29 xid e706d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617621: xprt_release: RPC:    29 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617622: xprt_alloc_slot: RPC:    30 reserved req ffff8800db829600 xid e806d5e8
        rpc.nfsd-4710  [002] ....    48.617622: xprt_prepare_transmit: RPC:    30 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617623: xprt_transmit: RPC:    30 xprt_transmit(68)
        rpc.nfsd-4710  [002] ....    48.617625: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4710  [002] ....    48.617625: xprt_transmit: RPC:    30 xmit complete
         rpcbind-1829  [000] ..s.    48.617634: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617635: xprt_complete_rqst: RPC:    30 xid e806d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617640: xprt_release: RPC:    30 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617647: xprt_alloc_slot: RPC:    31 reserved req ffff8800db829600 xid e906d5e8
        rpc.nfsd-4710  [002] ....    48.617647: xprt_prepare_transmit: RPC:    31 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617648: xprt_transmit: RPC:    31 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617650: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617650: xprt_transmit: RPC:    31 xmit complete
         rpcbind-1829  [000] ..s.    48.617659: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617660: xprt_complete_rqst: RPC:    31 xid e906d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617666: xprt_release: RPC:    31 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617668: xprt_alloc_slot: RPC:    32 reserved req ffff8800db829600 xid ea06d5e8
        rpc.nfsd-4710  [002] ....    48.617668: xprt_prepare_transmit: RPC:    32 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617669: xprt_transmit: RPC:    32 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617671: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617671: xprt_transmit: RPC:    32 xmit complete
         rpcbind-1829  [000] ..s.    48.617681: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617681: xprt_complete_rqst: RPC:    32 xid ea06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617687: xprt_release: RPC:    32 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617688: xprt_alloc_slot: RPC:    33 reserved req ffff8800db829600 xid eb06d5e8
        rpc.nfsd-4710  [002] ....    48.617689: xprt_prepare_transmit: RPC:    33 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617689: xprt_transmit: RPC:    33 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617692: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617692: xprt_transmit: RPC:    33 xmit complete
         rpcbind-1829  [000] ..s.    48.617701: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617702: xprt_complete_rqst: RPC:    33 xid eb06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617707: xprt_release: RPC:    33 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617716: xprt_alloc_slot: RPC:    34 reserved req ffff8800db829600 xid ec06d5e8
        rpc.nfsd-4710  [002] ....    48.617716: xprt_prepare_transmit: RPC:    34 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617717: xprt_transmit: RPC:    34 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617719: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617719: xprt_transmit: RPC:    34 xmit complete
         rpcbind-1829  [000] ..s.    48.617728: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617729: xprt_complete_rqst: RPC:    34 xid ec06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617735: xprt_release: RPC:    34 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617737: xprt_alloc_slot: RPC:    35 reserved req ffff8800db829600 xid ed06d5e8
        rpc.nfsd-4710  [002] ....    48.617737: xprt_prepare_transmit: RPC:    35 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617738: xprt_transmit: RPC:    35 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617740: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617740: xprt_transmit: RPC:    35 xmit complete
         rpcbind-1829  [000] ..s.    48.617749: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617750: xprt_complete_rqst: RPC:    35 xid ed06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617756: xprt_release: RPC:    35 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617757: xprt_alloc_slot: RPC:    36 reserved req ffff8800db829600 xid ee06d5e8
        rpc.nfsd-4710  [002] ....    48.617758: xprt_prepare_transmit: RPC:    36 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617758: xprt_transmit: RPC:    36 xprt_transmit(88)
        rpc.nfsd-4710  [002] ....    48.617760: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4710  [002] ....    48.617760: xprt_transmit: RPC:    36 xmit complete
         rpcbind-1829  [000] ..s.    48.617770: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617770: xprt_complete_rqst: RPC:    36 xid ee06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617776: xprt_release: RPC:    36 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617782: xprt_alloc_slot: RPC:    37 reserved req ffff8800db829600 xid ef06d5e8
        rpc.nfsd-4710  [002] ....    48.617782: xprt_prepare_transmit: RPC:    37 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617783: xprt_transmit: RPC:    37 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.617785: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.617785: xprt_transmit: RPC:    37 xmit complete
         rpcbind-1829  [000] ..s.    48.617794: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617795: xprt_complete_rqst: RPC:    37 xid ef06d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617800: xprt_release: RPC:    37 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617802: xprt_alloc_slot: RPC:    38 reserved req ffff8800db829600 xid f006d5e8
        rpc.nfsd-4710  [002] ....    48.617802: xprt_prepare_transmit: RPC:    38 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617803: xprt_transmit: RPC:    38 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.617805: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.617805: xprt_transmit: RPC:    38 xmit complete
         rpcbind-1829  [000] ..s.    48.617814: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617815: xprt_complete_rqst: RPC:    38 xid f006d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617821: xprt_release: RPC:    38 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617822: xprt_alloc_slot: RPC:    39 reserved req ffff8800db829600 xid f106d5e8
        rpc.nfsd-4710  [002] ....    48.617822: xprt_prepare_transmit: RPC:    39 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617823: xprt_transmit: RPC:    39 xprt_transmit(84)
        rpc.nfsd-4710  [002] ....    48.617825: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4710  [002] ....    48.617825: xprt_transmit: RPC:    39 xmit complete
         rpcbind-1829  [000] ..s.    48.617834: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617835: xprt_complete_rqst: RPC:    39 xid f106d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617840: xprt_release: RPC:    39 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617848: xprt_alloc_slot: RPC:    40 reserved req ffff8800db829600 xid f206d5e8
        rpc.nfsd-4710  [002] ....    48.617849: xprt_prepare_transmit: RPC:    40 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617849: xprt_transmit: RPC:    40 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617851: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617851: xprt_transmit: RPC:    40 xmit complete
         rpcbind-1829  [000] ..s.    48.617860: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617861: xprt_complete_rqst: RPC:    40 xid f206d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617867: xprt_release: RPC:    40 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617868: xprt_alloc_slot: RPC:    41 reserved req ffff8800db829600 xid f306d5e8
        rpc.nfsd-4710  [002] ....    48.617869: xprt_prepare_transmit: RPC:    41 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617869: xprt_transmit: RPC:    41 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617871: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617871: xprt_transmit: RPC:    41 xmit complete
         rpcbind-1829  [000] ..s.    48.617881: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617881: xprt_complete_rqst: RPC:    41 xid f306d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617887: xprt_release: RPC:    41 release request ffff8800db829600
        rpc.nfsd-4710  [002] ....    48.617888: xprt_alloc_slot: RPC:    42 reserved req ffff8800db829600 xid f406d5e8
        rpc.nfsd-4710  [002] ....    48.617889: xprt_prepare_transmit: RPC:    42 xprt_prepare_transmit
        rpc.nfsd-4710  [002] ....    48.617889: xprt_transmit: RPC:    42 xprt_transmit(80)
        rpc.nfsd-4710  [002] ....    48.617891: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4710  [002] ....    48.617891: xprt_transmit: RPC:    42 xmit complete
         rpcbind-1829  [000] ..s.    48.617901: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [000] ..s.    48.617902: xprt_complete_rqst: RPC:    42 xid f406d5e8 complete (28 bytes received)
        rpc.nfsd-4710  [002] ....    48.617907: xprt_release: RPC:    42 release request ffff8800db829600
          <idle>-0     [003] ..s.    57.765235: inet_bind_hash: add 2049
          <idle>-0     [003] ..s.    57.765278: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => csum_block_add_ext
 => __skb_gro_checksum_complete
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => try_to_wake_up
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
   kworker/u32:7-118   [000] ....    57.767716: xs_setup_tcp: RPC:       set up xprt to 192.168.23.22 (port 55201) via tcp
   kworker/u32:7-118   [000] ....    57.767726: xprt_create_transport: RPC:       created transport ffff88040b251000 with 65536 slots
    kworker/0:1H-128   [000] ....    57.767758: xprt_alloc_slot: RPC:    43 reserved req ffff8804033c3800 xid f4185658
    kworker/0:1H-128   [000] ....    57.767764: xprt_connect: RPC:    43 xprt_connect xprt ffff88040b251000 is not connected
    kworker/0:1H-128   [000] ....    57.767767: xs_connect: RPC:       xs_connect scheduled xprt ffff88040b251000
    kworker/0:1H-128   [000] ..s.    57.767780: inet_csk_get_port: snum 684
    kworker/0:1H-128   [000] ..s.    57.767792: <stack trace>
 => inet_addr_type
 => inet_bind
 => xs_bind
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.18
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => kthread
 => ret_from_fork
 => kthread
    kworker/0:1H-128   [000] ..s.    57.767793: inet_bind_hash: add 684
    kworker/0:1H-128   [000] ..s.    57.767801: <stack trace>
 => inet_csk_get_port
 => inet_addr_type
 => inet_bind
 => xs_bind
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.18
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => kthread
 => ret_from_fork
 => kthread
    kworker/0:1H-128   [000] ....    57.767803: xs_bind: RPC:       xs_bind 4.136.255.255:684: ok (0)
    kworker/0:1H-128   [000] ....    57.767805: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff88040b251000 via tcp to 192.168.23.22 (port 55201)
    kworker/0:1H-128   [000] ....    57.767841: xs_tcp_setup_socket: RPC:       ffff88040b251000 connect status 115 connected 0 sock state 2
          <idle>-0     [003] ..s.    57.768178: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040b251000...
          <idle>-0     [003] ..s.    57.768180: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/3:1H-127   [003] ....    57.768216: xprt_connect_status: RPC:    43 xprt_connect_status: retrying
    kworker/3:1H-127   [003] ....    57.768218: xprt_prepare_transmit: RPC:    43 xprt_prepare_transmit
    kworker/3:1H-127   [003] ....    57.768229: xprt_transmit: RPC:    43 xprt_transmit(72)
    kworker/3:1H-127   [003] ....    57.768245: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/3:1H-127   [003] ....    57.768246: xprt_transmit: RPC:    43 xmit complete
          <idle>-0     [003] ..s.    57.768621: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
          <idle>-0     [003] ..s.    57.768622: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
          <idle>-0     [003] ..s.    57.768624: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
          <idle>-0     [003] ..s.    57.768625: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
          <idle>-0     [003] ..s.    57.768626: xs_tcp_data_recv: RPC:       reading request with XID f4185658
          <idle>-0     [003] ..s.    57.768627: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
          <idle>-0     [003] ..s.    57.768628: xs_tcp_data_recv: RPC:       read reply XID f4185658
          <idle>-0     [003] ..s.    57.768630: xs_tcp_data_recv: RPC:       XID f4185658 read 16 bytes
          <idle>-0     [003] ..s.    57.768631: xs_tcp_data_recv: RPC:       xprt = ffff88040b251000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
          <idle>-0     [003] ..s.    57.768632: xprt_complete_rqst: RPC:    43 xid f4185658 complete (24 bytes received)
          <idle>-0     [003] .Ns.    57.768637: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/3:1H-127   [003] ....    57.768656: xprt_release: RPC:    43 release request ffff8804033c3800
          <idle>-0     [003] ..s.    96.518571: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.    96.518612: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => try_to_wake_up
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
          <idle>-0     [003] ..s.   138.868936: inet_bind_hash: add 22
          <idle>-0     [003] ..s.   138.868978: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
          <idle>-0     [003] ..s.   144.103035: inet_bind_hash: add 22
          <idle>-0     [003] ..s.   144.103078: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => try_to_wake_up
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
          <idle>-0     [003] ..s.   174.758123: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   174.758151: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => try_to_wake_up
 => ipt_do_table
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
          <idle>-0     [003] ..s.   216.551651: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   216.551689: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => try_to_wake_up
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
    kworker/3:1H-127   [003] ..s.   358.800834: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040b251000...
    kworker/3:1H-127   [003] ..s.   358.800837: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.   358.801180: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040b251000...
          <idle>-0     [003] ..s.   358.801182: xs_tcp_state_change: RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.   358.801204: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040b251000...
          <idle>-0     [003] ..s.   358.801205: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.   358.801206: xprt_disconnect_done: RPC:       disconnected transport ffff88040b251000
          <idle>-0     [003] ..s.   358.801207: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff88040b251000...
          <idle>-0     [003] ..s.   358.801208: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.   358.801208: xprt_disconnect_done: RPC:       disconnected transport ffff88040b251000
          <idle>-0     [003] ..s.   358.801209: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
          <idle>-0     [003] ..s.   476.855136: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   476.855172: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_check_req
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ip_local_deliver_finish
 => __netif_receive_skb_core
 => netif_receive_skb
 => netif_receive_skb_internal
 => br_handle_frame_finish
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => net_rx_action
 => add_interrupt_randomness
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary

-- Steve

