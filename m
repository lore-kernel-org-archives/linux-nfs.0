Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0185.hostedemail.com ([216.40.44.185]:46881 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751080AbcFVQ6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 12:58:04 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by smtpgrave02.hostedemail.com (Postfix) with ESMTP id AC5BC4191
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 16:42:12 +0000 (UTC)
Date: Wed, 22 Jun 2016 12:41:40 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bruce James Fields <bfields@fieldses.org>
Subject: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
Message-ID: <20160622124140.59de5e03@gandalf.local.home>
In-Reply-To: <20150619212706.2f13a44e@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
	<20150619122553.43d2d86c@gandalf.local.home>
	<20150619131759.7b38d9de@gandalf.local.home>
	<CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	<20150619155226.7c5d6637@synchrony.poochiereds.net>
	<1434745818.8838.1.camel@primarydata.com>
	<20150619181440.22f54e6a@gandalf.local.home>
	<1434756359.8498.2.camel@primarydata.com>
	<20150619212706.2f13a44e@gandalf.local.home>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/mrjkPp/yhul_Dj_5_1sjGk7"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/mrjkPp/yhul_Dj_5_1sjGk7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I've hit this again. Not sure when it started, but I applied my old
debug trace_printk() patch (attached) and rebooted (4.5.7). I just
tested the latest kernel from Linus's tree (from last nights pull), and
it still gives me the problem.

Here's the trace I have:

    kworker/3:1H-134   [003] ..s.    61.036129: inet_csk_get_port: snum 805
    kworker/3:1H-134   [003] ..s.    61.036135: <stack trace>
 =3D> sched_clock
 =3D> inet_addr_type_table
 =3D> security_capable
 =3D> inet_bind
 =3D> xs_bind
 =3D> release_sock
 =3D> sock_setsockopt
 =3D> __sock_create
 =3D> xs_create_sock.isra.19
 =3D> xs_tcp_setup_socket
 =3D> process_one_work
 =3D> worker_thread
 =3D> worker_thread
 =3D> kthread
 =3D> ret_from_fork
 =3D> kthread
    kworker/3:1H-134   [003] ..s.    61.036136: inet_bind_hash: add 805
    kworker/3:1H-134   [003] ..s.    61.036138: <stack trace>
 =3D> inet_csk_get_port
 =3D> sched_clock
 =3D> inet_addr_type_table
 =3D> security_capable
 =3D> inet_bind
 =3D> xs_bind
 =3D> release_sock
 =3D> sock_setsockopt
 =3D> __sock_create
 =3D> xs_create_sock.isra.19
 =3D> xs_tcp_setup_socket
 =3D> process_one_work
 =3D> worker_thread
 =3D> worker_thread
 =3D> kthread
 =3D> ret_from_fork
 =3D> kthread
    kworker/3:1H-134   [003] ....    61.036139: xs_bind: RPC:       xs_bind=
 4.136.255.255:805: ok (0)
    kworker/3:1H-134   [003] ....    61.036140: xs_tcp_setup_socket: RPC:  =
     worker connecting xprt ffff880407eca800 via tcp to 192.168.23.22 (port=
 43651)
    kworker/3:1H-134   [003] ....    61.036162: xs_tcp_setup_socket: RPC:  =
     ffff880407eca800 connect status 115 connected 0 sock state 2
          <idle>-0     [001] ..s.    61.036450: xs_tcp_state_change: RPC:  =
     xs_tcp_state_change client ffff880407eca800...
          <idle>-0     [001] ..s.    61.036452: xs_tcp_state_change: RPC:  =
     state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/1:1H-136   [001] ....    61.036476: xprt_connect_status: RPC:  =
  43 xprt_connect_status: retrying
    kworker/1:1H-136   [001] ....    61.036478: xprt_prepare_transmit: RPC:=
    43 xprt_prepare_transmit
    kworker/1:1H-136   [001] ....    61.036479: xprt_transmit: RPC:    43 x=
prt_transmit(72)
    kworker/1:1H-136   [001] ....    61.036486: xs_tcp_send_request: RPC:  =
     xs_tcp_send_request(72) =3D 0
    kworker/1:1H-136   [001] ....    61.036487: xprt_transmit: RPC:    43 x=
mit complete
          <idle>-0     [001] ..s.    61.036789: xs_tcp_data_ready: RPC:    =
   xs_tcp_data_ready...
    kworker/1:1H-136   [001] ....    61.036798: xs_tcp_data_recv: RPC:     =
  xs_tcp_data_recv started
    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:     =
  reading TCP record fragment of length 24
    kworker/1:1H-136   [001] ....    61.036799: xs_tcp_data_recv: RPC:     =
  reading XID (4 bytes)
    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:     =
  reading request with XID 2f4c3f88
    kworker/1:1H-136   [001] ....    61.036800: xs_tcp_data_recv: RPC:     =
  reading CALL/REPLY flag (4 bytes)
    kworker/1:1H-136   [001] ....    61.036801: xs_tcp_data_recv: RPC:     =
  read reply XID 2f4c3f88
    kworker/1:1H-136   [001] ..s.    61.036801: xs_tcp_data_recv: RPC:     =
  XID 2f4c3f88 read 16 bytes
    kworker/1:1H-136   [001] ..s.    61.036802: xs_tcp_data_recv: RPC:     =
  xprt =3D ffff880407eca800, tcp_copied =3D 24, tcp_offset =3D 24, tcp_recl=
en =3D 24
    kworker/1:1H-136   [001] ..s.    61.036802: xprt_complete_rqst: RPC:   =
 43 xid 2f4c3f88 complete (24 bytes received)
    kworker/1:1H-136   [001] ....    61.036803: xs_tcp_data_recv: RPC:     =
  xs_tcp_data_recv done
    kworker/1:1H-136   [001] ....    61.036812: xprt_release: RPC:    43 re=
lease request ffff88040b270800


# unhide-tcp=20
Unhide-tcp 20130526
Copyright =C2=A9 2013 Yago Jesus & Patrick Gouin
License GPLv3+ : GNU GPL version 3 or later
http://www.unhide-forensics.info
Used options:=20
[*]Starting TCP checking

Found Hidden port that not appears in ss: 805

-- Steve

--MP_/mrjkPp/yhul_Dj_5_1sjGk7
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=debug-hidden-port-4.7.patch

---
 net/ipv4/inet_connection_sock.c |    4 ++++
 net/ipv4/inet_hashtables.c      |    5 +++++
 net/sunrpc/xprt.c               |    5 +++++
 net/sunrpc/xprtsock.c           |    5 +++++
 5 files changed, 22 insertions(+)

Index: linux-build.git/net/ipv4/inet_connection_sock.c
===================================================================
--- linux-build.git.orig/net/ipv4/inet_connection_sock.c	2016-06-22 11:55:05.952267493 -0400
+++ linux-build.git/net/ipv4/inet_connection_sock.c	2016-06-22 11:56:20.002662092 -0400
@@ -232,6 +232,10 @@ tb_found:
 		}
 	}
 success:
+	if (!current->mm) {
+		trace_printk("snum %d\n", snum);
+		trace_dump_stack(1);
+	}
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, port);
 	WARN_ON(inet_csk(sk)->icsk_bind_hash != tb);
Index: linux-build.git/net/ipv4/inet_hashtables.c
===================================================================
--- linux-build.git.orig/net/ipv4/inet_hashtables.c	2016-06-22 11:55:05.952267493 -0400
+++ linux-build.git/net/ipv4/inet_hashtables.c	2016-06-22 11:55:05.948267360 -0400
@@ -93,6 +93,11 @@ void inet_bind_bucket_destroy(struct kme
 void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 		    const unsigned short snum)
 {
+	if (!current->mm) {
+		trace_printk("add %d\n", snum);
+		trace_dump_stack(1);
+	}
+
 	inet_sk(sk)->inet_num = snum;
 	sk_add_bind_node(sk, &tb->owners);
 	tb->num_owners++;
Index: linux-build.git/net/sunrpc/xprt.c
===================================================================
--- linux-build.git.orig/net/sunrpc/xprt.c	2016-06-22 11:55:05.952267493 -0400
+++ linux-build.git/net/sunrpc/xprt.c	2016-06-22 11:55:05.948267360 -0400
@@ -54,6 +54,11 @@
 
 #include "sunrpc.h"
 
+#undef dprintk
+#undef dprintk_rcu
+#define dprintk(args...)	trace_printk(args)
+#define dprintk_rcu(args...)	trace_printk(args)
+
 /*
  * Local variables
  */
Index: linux-build.git/net/sunrpc/xprtsock.c
===================================================================
--- linux-build.git.orig/net/sunrpc/xprtsock.c	2016-06-22 11:55:05.952267493 -0400
+++ linux-build.git/net/sunrpc/xprtsock.c	2016-06-22 11:55:05.948267360 -0400
@@ -51,6 +51,11 @@
 
 #include "sunrpc.h"
 
+#undef dprintk
+#undef dprintk_rcu
+#define dprintk(args...)	trace_printk(args)
+#define dprintk_rcu(args...)	trace_printk(args)
+
 static void xs_close(struct rpc_xprt *xprt);
 
 /*

--MP_/mrjkPp/yhul_Dj_5_1sjGk7--
