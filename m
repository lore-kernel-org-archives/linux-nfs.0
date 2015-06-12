Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0091.hostedemail.com ([216.40.44.91]:33727 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751151AbbFLPun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 11:50:43 -0400
Date: Fri, 12 Jun 2015 11:50:38 -0400
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
Message-ID: <20150612115038.44e20ccd@gandalf.local.home>
In-Reply-To: <20150612113420.5c114183@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Jun 2015 11:34:20 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Fri, 12 Jun 2015 07:40:35 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Strange, because the usual way to not have time-wait is to use SO_LINGER
> > with linger=0
> > 
> > And apparently xs_tcp_finish_connecting() has this :
> > 
> >                 sock_reset_flag(sk, SOCK_LINGER);
> >                 tcp_sk(sk)->linger2 = 0;
> > 
> > Are you sure SO_REUSEADDR was not the thing you wanted ?
> > 
> > Steven, have you tried kmemleak ?
> 
> Nope, and again, I'm hesitant on adding too much debug. This is my main
> server (build server, ssh server, web server, mail server, proxy
> server, irc server, etc).
> 
> Although, I made dprintk() into trace_printk() in xprtsock.c and
> xprt.c, and reran it. Here's the output:
> 

I reverted the following commits:

c627d31ba0696cbd829437af2be2f2dee3546b1e
9e2b9f37760e129cee053cc7b6e7288acc2a7134
caf4ccd4e88cf2795c927834bc488c8321437586

And the issue goes away. That is, I watched the port go from
ESTABLISHED to TIME_WAIT, and then gone, and theirs no hidden port.

In fact, I watched the port with my portlist.c module, and it
disappeared there too when it entered the TIME_WAIT state.

Here's the trace of that run:

# tracer: nop
#
# entries-in-buffer/entries-written: 397/397   #P:4
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
        rpc.nfsd-3932  [002] ....    44.098689: xs_local_setup_socket: RPC:       worker connecting xprt ffff88040b6f5800 via AF_LOCAL to /var/run/rpcbind.sock
        rpc.nfsd-3932  [002] ....    44.098699: xs_local_setup_socket: RPC:       xprt ffff88040b6f5800 connected to /var/run/rpcbind.sock
        rpc.nfsd-3932  [002] ....    44.098700: xs_setup_local: RPC:       set up xprt to /var/run/rpcbind.sock via AF_LOCAL
        rpc.nfsd-3932  [002] ....    44.098704: xprt_create_transport: RPC:       created transport ffff88040b6f5800 with 65536 slots
        rpc.nfsd-3932  [002] ....    44.098717: xprt_alloc_slot: RPC:     1 reserved req ffff8800d8cc6800 xid 0850084b
        rpc.nfsd-3932  [002] ....    44.098720: xprt_prepare_transmit: RPC:     1 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.098721: xprt_transmit: RPC:     1 xprt_transmit(44)
        rpc.nfsd-3932  [002] ....    44.098724: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-3932  [002] ....    44.098724: xprt_transmit: RPC:     1 xmit complete
         rpcbind-1829  [001] ..s.    44.098812: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.098815: xprt_complete_rqst: RPC:     1 xid 0850084b complete (24 bytes received)
        rpc.nfsd-3932  [002] ....    44.098854: xprt_release: RPC:     1 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.098864: xprt_alloc_slot: RPC:     2 reserved req ffff8800d8cc6800 xid 0950084b
        rpc.nfsd-3932  [002] ....    44.098865: xprt_prepare_transmit: RPC:     2 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.098865: xprt_transmit: RPC:     2 xprt_transmit(44)
        rpc.nfsd-3932  [002] ....    44.098870: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-3932  [002] ....    44.098870: xprt_transmit: RPC:     2 xmit complete
         rpcbind-1829  [001] ..s.    44.098915: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.098917: xprt_complete_rqst: RPC:     2 xid 0950084b complete (24 bytes received)
        rpc.nfsd-3932  [002] ....    44.098968: xprt_release: RPC:     2 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.098971: xprt_alloc_slot: RPC:     3 reserved req ffff8800d8cc6800 xid 0a50084b
        rpc.nfsd-3932  [002] ....    44.098972: xprt_prepare_transmit: RPC:     3 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.098973: xprt_transmit: RPC:     3 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.098978: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.098978: xprt_transmit: RPC:     3 xmit complete
         rpcbind-1829  [001] ..s.    44.099029: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099031: xprt_complete_rqst: RPC:     3 xid 0a50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099083: xprt_release: RPC:     3 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099086: xprt_alloc_slot: RPC:     4 reserved req ffff8800d8cc6800 xid 0b50084b
        rpc.nfsd-3932  [002] ....    44.099086: xprt_prepare_transmit: RPC:     4 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099087: xprt_transmit: RPC:     4 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.099091: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.099092: xprt_transmit: RPC:     4 xmit complete
         rpcbind-1829  [001] ..s.    44.099145: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099147: xprt_complete_rqst: RPC:     4 xid 0b50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099155: xprt_release: RPC:     4 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099157: xprt_alloc_slot: RPC:     5 reserved req ffff8800d8cc6800 xid 0c50084b
        rpc.nfsd-3932  [002] ....    44.099157: xprt_prepare_transmit: RPC:     5 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099158: xprt_transmit: RPC:     5 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.099161: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.099162: xprt_transmit: RPC:     5 xmit complete
         rpcbind-1829  [001] ..s.    44.099172: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099173: xprt_complete_rqst: RPC:     5 xid 0c50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099180: xprt_release: RPC:     5 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099181: xprt_alloc_slot: RPC:     6 reserved req ffff8800d8cc6800 xid 0d50084b
        rpc.nfsd-3932  [002] ....    44.099181: xprt_prepare_transmit: RPC:     6 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099182: xprt_transmit: RPC:     6 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.099184: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.099184: xprt_transmit: RPC:     6 xmit complete
         rpcbind-1829  [001] ..s.    44.099204: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099205: xprt_complete_rqst: RPC:     6 xid 0d50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099212: xprt_release: RPC:     6 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099213: xprt_alloc_slot: RPC:     7 reserved req ffff8800d8cc6800 xid 0e50084b
        rpc.nfsd-3932  [002] ....    44.099214: xprt_prepare_transmit: RPC:     7 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099214: xprt_transmit: RPC:     7 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.099217: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.099217: xprt_transmit: RPC:     7 xmit complete
         rpcbind-1829  [001] ..s.    44.099228: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099229: xprt_complete_rqst: RPC:     7 xid 0e50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099236: xprt_release: RPC:     7 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099241: xprt_alloc_slot: RPC:     8 reserved req ffff8800d8cc6800 xid 0f50084b
        rpc.nfsd-3932  [002] ....    44.099241: xprt_prepare_transmit: RPC:     8 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099242: xprt_transmit: RPC:     8 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099244: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099244: xprt_transmit: RPC:     8 xmit complete
         rpcbind-1829  [001] ..s.    44.099261: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099263: xprt_complete_rqst: RPC:     8 xid 0f50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099270: xprt_release: RPC:     8 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099271: xprt_alloc_slot: RPC:     9 reserved req ffff8800d8cc6800 xid 1050084b
        rpc.nfsd-3932  [002] ....    44.099272: xprt_prepare_transmit: RPC:     9 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099272: xprt_transmit: RPC:     9 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099275: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099275: xprt_transmit: RPC:     9 xmit complete
         rpcbind-1829  [001] ..s.    44.099290: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099291: xprt_complete_rqst: RPC:     9 xid 1050084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099298: xprt_release: RPC:     9 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099300: xprt_alloc_slot: RPC:    10 reserved req ffff8800d8cc6800 xid 1150084b
        rpc.nfsd-3932  [002] ....    44.099301: xprt_prepare_transmit: RPC:    10 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099301: xprt_transmit: RPC:    10 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099303: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099304: xprt_transmit: RPC:    10 xmit complete
         rpcbind-1829  [001] ..s.    44.099318: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099320: xprt_complete_rqst: RPC:    10 xid 1150084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099327: xprt_release: RPC:    10 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099329: xprt_alloc_slot: RPC:    11 reserved req ffff8800d8cc6800 xid 1250084b
        rpc.nfsd-3932  [002] ....    44.099329: xprt_prepare_transmit: RPC:    11 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099330: xprt_transmit: RPC:    11 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099332: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099332: xprt_transmit: RPC:    11 xmit complete
         rpcbind-1829  [001] ..s.    44.099344: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099345: xprt_complete_rqst: RPC:    11 xid 1250084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099352: xprt_release: RPC:    11 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099354: xprt_alloc_slot: RPC:    12 reserved req ffff8800d8cc6800 xid 1350084b
        rpc.nfsd-3932  [002] ....    44.099354: xprt_prepare_transmit: RPC:    12 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099355: xprt_transmit: RPC:    12 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099357: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099357: xprt_transmit: RPC:    12 xmit complete
         rpcbind-1829  [001] ..s.    44.099368: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099369: xprt_complete_rqst: RPC:    12 xid 1350084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099376: xprt_release: RPC:    12 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099394: xprt_alloc_slot: RPC:    13 reserved req ffff8800d8cc6800 xid 1450084b
        rpc.nfsd-3932  [002] ....    44.099395: xprt_prepare_transmit: RPC:    13 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099395: xprt_transmit: RPC:    13 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099399: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099399: xprt_transmit: RPC:    13 xmit complete
         rpcbind-1829  [001] ..s.    44.099405: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099406: xprt_complete_rqst: RPC:    13 xid 1450084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099413: xprt_release: RPC:    13 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099414: xprt_alloc_slot: RPC:    14 reserved req ffff8800d8cc6800 xid 1550084b
        rpc.nfsd-3932  [002] ....    44.099415: xprt_prepare_transmit: RPC:    14 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099415: xprt_transmit: RPC:    14 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099418: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099418: xprt_transmit: RPC:    14 xmit complete
         rpcbind-1829  [001] ..s.    44.099424: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099425: xprt_complete_rqst: RPC:    14 xid 1550084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099431: xprt_release: RPC:    14 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099433: xprt_alloc_slot: RPC:    15 reserved req ffff8800d8cc6800 xid 1650084b
        rpc.nfsd-3932  [002] ....    44.099433: xprt_prepare_transmit: RPC:    15 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099434: xprt_transmit: RPC:    15 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099436: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099436: xprt_transmit: RPC:    15 xmit complete
         rpcbind-1829  [001] ..s.    44.099443: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099443: xprt_complete_rqst: RPC:    15 xid 1650084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099449: xprt_release: RPC:    15 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099451: xprt_alloc_slot: RPC:    16 reserved req ffff8800d8cc6800 xid 1750084b
        rpc.nfsd-3932  [002] ....    44.099451: xprt_prepare_transmit: RPC:    16 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099452: xprt_transmit: RPC:    16 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099454: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099455: xprt_transmit: RPC:    16 xmit complete
         rpcbind-1829  [001] ..s.    44.099461: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099461: xprt_complete_rqst: RPC:    16 xid 1750084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099467: xprt_release: RPC:    16 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.099469: xprt_alloc_slot: RPC:    17 reserved req ffff8800d8cc6800 xid 1850084b
        rpc.nfsd-3932  [002] ....    44.099469: xprt_prepare_transmit: RPC:    17 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.099470: xprt_transmit: RPC:    17 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.099472: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.099472: xprt_transmit: RPC:    17 xmit complete
         rpcbind-1829  [001] ..s.    44.099479: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.099479: xprt_complete_rqst: RPC:    17 xid 1850084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.099485: xprt_release: RPC:    17 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100111: xprt_alloc_slot: RPC:    18 reserved req ffff8800d8cc6800 xid 1950084b
        rpc.nfsd-3932  [002] ....    44.100112: xprt_prepare_transmit: RPC:    18 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100113: xprt_transmit: RPC:    18 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100118: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100118: xprt_transmit: RPC:    18 xmit complete
         rpcbind-1829  [001] ..s.    44.100124: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100125: xprt_complete_rqst: RPC:    18 xid 1950084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100132: xprt_release: RPC:    18 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100134: xprt_alloc_slot: RPC:    19 reserved req ffff8800d8cc6800 xid 1a50084b
        rpc.nfsd-3932  [002] ....    44.100135: xprt_prepare_transmit: RPC:    19 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100135: xprt_transmit: RPC:    19 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100138: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100138: xprt_transmit: RPC:    19 xmit complete
         rpcbind-1829  [001] ..s.    44.100144: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100145: xprt_complete_rqst: RPC:    19 xid 1a50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100151: xprt_release: RPC:    19 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100153: xprt_alloc_slot: RPC:    20 reserved req ffff8800d8cc6800 xid 1b50084b
        rpc.nfsd-3932  [002] ....    44.100153: xprt_prepare_transmit: RPC:    20 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100154: xprt_transmit: RPC:    20 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100156: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100156: xprt_transmit: RPC:    20 xmit complete
         rpcbind-1829  [001] ..s.    44.100162: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100163: xprt_complete_rqst: RPC:    20 xid 1b50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100169: xprt_release: RPC:    20 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100171: xprt_alloc_slot: RPC:    21 reserved req ffff8800d8cc6800 xid 1c50084b
        rpc.nfsd-3932  [002] ....    44.100171: xprt_prepare_transmit: RPC:    21 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100172: xprt_transmit: RPC:    21 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100174: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100174: xprt_transmit: RPC:    21 xmit complete
         rpcbind-1829  [001] ..s.    44.100180: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100181: xprt_complete_rqst: RPC:    21 xid 1c50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100187: xprt_release: RPC:    21 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100189: xprt_alloc_slot: RPC:    22 reserved req ffff8800d8cc6800 xid 1d50084b
        rpc.nfsd-3932  [002] ....    44.100189: xprt_prepare_transmit: RPC:    22 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100190: xprt_transmit: RPC:    22 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100192: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100192: xprt_transmit: RPC:    22 xmit complete
         rpcbind-1829  [001] ..s.    44.100198: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100199: xprt_complete_rqst: RPC:    22 xid 1d50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100205: xprt_release: RPC:    22 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100223: xprt_alloc_slot: RPC:    23 reserved req ffff8800d8cc6800 xid 1e50084b
        rpc.nfsd-3932  [002] ....    44.100223: xprt_prepare_transmit: RPC:    23 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100224: xprt_transmit: RPC:    23 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100227: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100227: xprt_transmit: RPC:    23 xmit complete
         rpcbind-1829  [001] ..s.    44.100233: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100234: xprt_complete_rqst: RPC:    23 xid 1e50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100241: xprt_release: RPC:    23 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100242: xprt_alloc_slot: RPC:    24 reserved req ffff8800d8cc6800 xid 1f50084b
        rpc.nfsd-3932  [002] ....    44.100243: xprt_prepare_transmit: RPC:    24 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100243: xprt_transmit: RPC:    24 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100246: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100246: xprt_transmit: RPC:    24 xmit complete
         rpcbind-1829  [001] ..s.    44.100252: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100253: xprt_complete_rqst: RPC:    24 xid 1f50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100259: xprt_release: RPC:    24 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100260: xprt_alloc_slot: RPC:    25 reserved req ffff8800d8cc6800 xid 2050084b
        rpc.nfsd-3932  [002] ....    44.100261: xprt_prepare_transmit: RPC:    25 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100261: xprt_transmit: RPC:    25 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100263: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100264: xprt_transmit: RPC:    25 xmit complete
         rpcbind-1829  [001] ..s.    44.100270: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100270: xprt_complete_rqst: RPC:    25 xid 2050084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100276: xprt_release: RPC:    25 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100278: xprt_alloc_slot: RPC:    26 reserved req ffff8800d8cc6800 xid 2150084b
        rpc.nfsd-3932  [002] ....    44.100278: xprt_prepare_transmit: RPC:    26 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100279: xprt_transmit: RPC:    26 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100281: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100281: xprt_transmit: RPC:    26 xmit complete
         rpcbind-1829  [001] ..s.    44.100287: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100288: xprt_complete_rqst: RPC:    26 xid 2150084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100294: xprt_release: RPC:    26 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100296: xprt_alloc_slot: RPC:    27 reserved req ffff8800d8cc6800 xid 2250084b
        rpc.nfsd-3932  [002] ....    44.100296: xprt_prepare_transmit: RPC:    27 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100297: xprt_transmit: RPC:    27 xprt_transmit(80)
        rpc.nfsd-3932  [002] ....    44.100299: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-3932  [002] ....    44.100299: xprt_transmit: RPC:    27 xmit complete
         rpcbind-1829  [001] ..s.    44.100305: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100306: xprt_complete_rqst: RPC:    27 xid 2250084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100312: xprt_release: RPC:    27 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100403: xprt_alloc_slot: RPC:    28 reserved req ffff8800d8cc6800 xid 2350084b
        rpc.nfsd-3932  [002] ....    44.100404: xprt_prepare_transmit: RPC:    28 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100405: xprt_transmit: RPC:    28 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.100409: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.100409: xprt_transmit: RPC:    28 xmit complete
         rpcbind-1829  [001] ..s.    44.100415: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100416: xprt_complete_rqst: RPC:    28 xid 2350084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100422: xprt_release: RPC:    28 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100423: xprt_alloc_slot: RPC:    29 reserved req ffff8800d8cc6800 xid 2450084b
        rpc.nfsd-3932  [002] ....    44.100424: xprt_prepare_transmit: RPC:    29 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100424: xprt_transmit: RPC:    29 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.100427: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.100427: xprt_transmit: RPC:    29 xmit complete
         rpcbind-1829  [001] ..s.    44.100432: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100433: xprt_complete_rqst: RPC:    29 xid 2450084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100439: xprt_release: RPC:    29 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100440: xprt_alloc_slot: RPC:    30 reserved req ffff8800d8cc6800 xid 2550084b
        rpc.nfsd-3932  [002] ....    44.100441: xprt_prepare_transmit: RPC:    30 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100441: xprt_transmit: RPC:    30 xprt_transmit(68)
        rpc.nfsd-3932  [002] ....    44.100443: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-3932  [002] ....    44.100444: xprt_transmit: RPC:    30 xmit complete
         rpcbind-1829  [001] ..s.    44.100450: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100450: xprt_complete_rqst: RPC:    30 xid 2550084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100456: xprt_release: RPC:    30 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100463: xprt_alloc_slot: RPC:    31 reserved req ffff8800d8cc6800 xid 2650084b
        rpc.nfsd-3932  [002] ....    44.100463: xprt_prepare_transmit: RPC:    31 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100464: xprt_transmit: RPC:    31 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100467: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100467: xprt_transmit: RPC:    31 xmit complete
         rpcbind-1829  [001] ..s.    44.100473: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100474: xprt_complete_rqst: RPC:    31 xid 2650084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100480: xprt_release: RPC:    31 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100482: xprt_alloc_slot: RPC:    32 reserved req ffff8800d8cc6800 xid 2750084b
        rpc.nfsd-3932  [002] ....    44.100482: xprt_prepare_transmit: RPC:    32 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100483: xprt_transmit: RPC:    32 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100485: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100485: xprt_transmit: RPC:    32 xmit complete
         rpcbind-1829  [001] ..s.    44.100492: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100493: xprt_complete_rqst: RPC:    32 xid 2750084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100498: xprt_release: RPC:    32 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100500: xprt_alloc_slot: RPC:    33 reserved req ffff8800d8cc6800 xid 2850084b
        rpc.nfsd-3932  [002] ....    44.100501: xprt_prepare_transmit: RPC:    33 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100501: xprt_transmit: RPC:    33 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100504: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100504: xprt_transmit: RPC:    33 xmit complete
         rpcbind-1829  [001] ..s.    44.100510: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100511: xprt_complete_rqst: RPC:    33 xid 2850084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100517: xprt_release: RPC:    33 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100526: xprt_alloc_slot: RPC:    34 reserved req ffff8800d8cc6800 xid 2950084b
        rpc.nfsd-3932  [002] ....    44.100527: xprt_prepare_transmit: RPC:    34 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100528: xprt_transmit: RPC:    34 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100530: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100531: xprt_transmit: RPC:    34 xmit complete
         rpcbind-1829  [001] ..s.    44.100537: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100538: xprt_complete_rqst: RPC:    34 xid 2950084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100544: xprt_release: RPC:    34 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100546: xprt_alloc_slot: RPC:    35 reserved req ffff8800d8cc6800 xid 2a50084b
        rpc.nfsd-3932  [002] ....    44.100546: xprt_prepare_transmit: RPC:    35 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100547: xprt_transmit: RPC:    35 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100549: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100549: xprt_transmit: RPC:    35 xmit complete
         rpcbind-1829  [001] ..s.    44.100556: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100556: xprt_complete_rqst: RPC:    35 xid 2a50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100562: xprt_release: RPC:    35 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100564: xprt_alloc_slot: RPC:    36 reserved req ffff8800d8cc6800 xid 2b50084b
        rpc.nfsd-3932  [002] ....    44.100565: xprt_prepare_transmit: RPC:    36 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100565: xprt_transmit: RPC:    36 xprt_transmit(88)
        rpc.nfsd-3932  [002] ....    44.100567: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-3932  [002] ....    44.100568: xprt_transmit: RPC:    36 xmit complete
         rpcbind-1829  [001] ..s.    44.100574: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100575: xprt_complete_rqst: RPC:    36 xid 2b50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100581: xprt_release: RPC:    36 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100587: xprt_alloc_slot: RPC:    37 reserved req ffff8800d8cc6800 xid 2c50084b
        rpc.nfsd-3932  [002] ....    44.100587: xprt_prepare_transmit: RPC:    37 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100588: xprt_transmit: RPC:    37 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100590: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100590: xprt_transmit: RPC:    37 xmit complete
         rpcbind-1829  [001] ..s.    44.100597: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100597: xprt_complete_rqst: RPC:    37 xid 2c50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100604: xprt_release: RPC:    37 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100605: xprt_alloc_slot: RPC:    38 reserved req ffff8800d8cc6800 xid 2d50084b
        rpc.nfsd-3932  [002] ....    44.100606: xprt_prepare_transmit: RPC:    38 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100606: xprt_transmit: RPC:    38 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100608: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100609: xprt_transmit: RPC:    38 xmit complete
         rpcbind-1829  [001] ..s.    44.100615: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100616: xprt_complete_rqst: RPC:    38 xid 2d50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100622: xprt_release: RPC:    38 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100623: xprt_alloc_slot: RPC:    39 reserved req ffff8800d8cc6800 xid 2e50084b
        rpc.nfsd-3932  [002] ....    44.100624: xprt_prepare_transmit: RPC:    39 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100624: xprt_transmit: RPC:    39 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100626: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100627: xprt_transmit: RPC:    39 xmit complete
         rpcbind-1829  [001] ..s.    44.100633: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100634: xprt_complete_rqst: RPC:    39 xid 2e50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100640: xprt_release: RPC:    39 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100647: xprt_alloc_slot: RPC:    40 reserved req ffff8800d8cc6800 xid 2f50084b
        rpc.nfsd-3932  [002] ....    44.100648: xprt_prepare_transmit: RPC:    40 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100648: xprt_transmit: RPC:    40 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100651: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100651: xprt_transmit: RPC:    40 xmit complete
         rpcbind-1829  [001] ..s.    44.100657: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100658: xprt_complete_rqst: RPC:    40 xid 2f50084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100664: xprt_release: RPC:    40 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100666: xprt_alloc_slot: RPC:    41 reserved req ffff8800d8cc6800 xid 3050084b
        rpc.nfsd-3932  [002] ....    44.100666: xprt_prepare_transmit: RPC:    41 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100667: xprt_transmit: RPC:    41 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100669: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100669: xprt_transmit: RPC:    41 xmit complete
         rpcbind-1829  [001] ..s.    44.100675: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100676: xprt_complete_rqst: RPC:    41 xid 3050084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100682: xprt_release: RPC:    41 release request ffff8800d8cc6800
        rpc.nfsd-3932  [002] ....    44.100684: xprt_alloc_slot: RPC:    42 reserved req ffff8800d8cc6800 xid 3150084b
        rpc.nfsd-3932  [002] ....    44.100684: xprt_prepare_transmit: RPC:    42 xprt_prepare_transmit
        rpc.nfsd-3932  [002] ....    44.100685: xprt_transmit: RPC:    42 xprt_transmit(84)
        rpc.nfsd-3932  [002] ....    44.100687: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-3932  [002] ....    44.100687: xprt_transmit: RPC:    42 xmit complete
         rpcbind-1829  [001] ..s.    44.100693: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1829  [001] ..s.    44.100694: xprt_complete_rqst: RPC:    42 xid 3150084b complete (28 bytes received)
        rpc.nfsd-3932  [002] ....    44.100700: xprt_release: RPC:    42 release request ffff8800d8cc6800
          <idle>-0     [003] ..s.    52.302416: inet_bind_hash: add 22
          <idle>-0     [003] ..s.    52.302456: <stack trace>
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
 => delay_tsc
 => br_handle_frame
 => br_handle_frame
 => __netif_receive_skb_core
 => read_tsc
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => ack_ioapic_level
 => do_IRQ
 => net_rx_action
 => __do_softirq
 => ack_ioapic_level
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary
   kworker/u32:2-105   [001] ....    77.750302: xs_setup_tcp: RPC:       set up xprt to 192.168.23.22 (port 55201) via tcp
   kworker/u32:2-105   [001] ....    77.750310: xprt_create_transport: RPC:       created transport ffff8804082fb000 with 65536 slots
    kworker/1:1H-133   [001] ....    77.750352: xprt_alloc_slot: RPC:    43 reserved req ffff88040ab08200 xid 83da2dc3
    kworker/1:1H-133   [001] ....    77.750356: xprt_connect: RPC:    43 xprt_connect xprt ffff8804082fb000 is not connected
    kworker/1:1H-133   [001] ....    77.750358: xs_connect: RPC:       xs_connect scheduled xprt ffff8804082fb000
    kworker/1:1H-133   [001] ..s.    77.750365: inet_csk_get_port: snum 737
    kworker/1:1H-133   [001] ..s.    77.750374: <stack trace>
 => inet_addr_type
 => inet_bind
 => xs_bind
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => kthread
 => ret_from_fork
 => kthread
    kworker/1:1H-133   [001] ..s.    77.750374: inet_bind_hash: add 737
    kworker/1:1H-133   [001] ..s.    77.750377: <stack trace>
 => inet_csk_get_port
 => inet_addr_type
 => inet_bind
 => xs_bind
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => kthread
 => ret_from_fork
 => kthread
    kworker/1:1H-133   [001] ....    77.750378: xs_bind: RPC:       xs_bind 4.136.255.255:737: ok (0)
    kworker/1:1H-133   [001] ....    77.750379: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8804082fb000 via tcp to 192.168.23.22 (port 55201)
    kworker/1:1H-133   [001] ....    77.750397: xs_tcp_setup_socket: xprt=ffff8804082fb000 sock=ffff880408a47d40 status=-115
    kworker/1:1H-133   [001] ....    77.750397: xs_tcp_setup_socket: RPC:       ffff8804082fb000 connect status 115 connected 0 sock state 2
 fail2ban-server-4683  [002] ..s.    77.750554: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8804082fb000...
 fail2ban-server-4683  [002] ..s.    77.750555: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/2:1H-126   [002] ....    77.750571: xprt_connect_status: RPC:    43 xprt_connect_status: retrying
    kworker/2:1H-126   [002] ....    77.750572: xprt_prepare_transmit: RPC:    43 xprt_prepare_transmit
    kworker/2:1H-126   [002] ....    77.750573: xprt_transmit: RPC:    43 xprt_transmit(72)
    kworker/2:1H-126   [002] ....    77.750581: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/2:1H-126   [002] ....    77.750581: xprt_transmit: RPC:    43 xmit complete
 fail2ban-server-4683  [002] ..s.    77.750798: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
 fail2ban-server-4683  [002] ..s.    77.750799: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
 fail2ban-server-4683  [002] ..s.    77.750800: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
 fail2ban-server-4683  [002] ..s.    77.750800: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
 fail2ban-server-4683  [002] ..s.    77.750801: xs_tcp_data_recv: RPC:       reading request with XID 83da2dc3
 fail2ban-server-4683  [002] ..s.    77.750801: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
 fail2ban-server-4683  [002] ..s.    77.750801: xs_tcp_data_recv: RPC:       read reply XID 83da2dc3
 fail2ban-server-4683  [002] ..s.    77.750802: xs_tcp_data_recv: RPC:       XID 83da2dc3 read 16 bytes
 fail2ban-server-4683  [002] ..s.    77.750803: xs_tcp_data_recv: RPC:       xprt = ffff8804082fb000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
 fail2ban-server-4683  [002] ..s.    77.750803: xprt_complete_rqst: RPC:    43 xid 83da2dc3 complete (24 bytes received)
 fail2ban-server-4683  [002] .Ns.    77.750805: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/2:1H-126   [002] ....    77.750813: xprt_release: RPC:    43 release request ffff88040ab08200
          <idle>-0     [003] ..s.    94.613312: inet_bind_hash: add 22
          <idle>-0     [003] ..s.    94.613354: <stack trace>
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
          <idle>-0     [003] ..s.    98.776868: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.    98.776910: <stack trace>
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
          <idle>-0     [003] ..s.   151.179778: inet_bind_hash: add 80
          <idle>-0     [003] ..s.   151.179822: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_v6_syn_recv_sock
 => ipt_do_table
 => nf_conntrack_in
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
 => ktime_get
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
          <idle>-0     [003] ..s.   172.217453: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   172.217496: <stack trace>
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
          <idle>-0     [003] .Ns.   181.603150: inet_bind_hash: add 80
          <idle>-0     [003] .Ns.   181.603194: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_v6_syn_recv_sock
 => ipt_do_table
 => nf_conntrack_in
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
          <idle>-0     [003] ..s.   234.638237: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   234.638281: <stack trace>
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
          <idle>-0     [003] ..s.   241.694872: inet_bind_hash: add 57000
          <idle>-0     [003] ..s.   241.694915: <stack trace>
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
          <idle>-0     [003] ..s.   242.308627: inet_bind_hash: add 10993
          <idle>-0     [003] ..s.   242.308670: <stack trace>
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
          <idle>-0     [003] ..s.   296.125499: inet_bind_hash: add 80
          <idle>-0     [003] ..s.   296.125543: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_v6_syn_recv_sock
 => ipt_do_table
 => nf_conntrack_in
 => tcp_check_req
 => fib_validate_source
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
          <idle>-0     [003] ..s.   304.196576: inet_bind_hash: add 80
          <idle>-0     [003] ..s.   304.196618: <stack trace>
 => __inet_inherit_port
 => tcp_v4_syn_recv_sock
 => tcp_v6_syn_recv_sock
 => ipt_do_table
 => nf_conntrack_in
 => tcp_check_req
 => fib_validate_source
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
 => raise_softirq_irqoff
 => netif_schedule_queue
 => dev_watchdog
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
    kworker/2:1H-126   [002] ....   378.264745: xs_tcp_close: close %p
    kworker/2:1H-126   [002] ....   378.264748: xs_close: RPC:       xs_close xprt ffff8804082fb000
    kworker/2:1H-126   [002] ....   378.264786: xprt_disconnect_done: RPC:       disconnected transport ffff8804082fb000


-- Steve
