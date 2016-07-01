Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0080.hostedemail.com ([216.40.44.80]:58092 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752348AbcGAXTd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2016 19:19:33 -0400
Date: Fri, 1 Jul 2016 19:19:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "Eric Dumazet" <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        Torvalds Linus <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Message-ID: <20160701191929.0f1edd3d@gandalf.local.home>
In-Reply-To: <20160701191745.58ba1ef6@gandalf.local.home>
References: <20160701172401.3ba89015@gandalf.local.home>
	<0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
	<20160701183912.1f9d376b@gandalf.local.home>
	<CB98840B-1CEE-48C6-9ABB-82DA8D213BAF@primarydata.com>
	<20160701191745.58ba1ef6@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Jul 2016 19:17:45 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:


> See my previous email that describes all this (I removed the debugging
> from my kernel, and I need to spend time with the family so I can't get
> to this again till Tuesday)
> 
> http://lkml.kernel.org/r/20160630175618.51a725ee@gandalf.local.home

Ug, that link is ugly.

Here's a cut and paste of that email:


On Thu, 30 Jun 2016 16:07:26 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I can reproduce this by having the client unmount and remount the
> directory.  

It gets even more interesting. When I unmount the directory, the hidden
port does not go away. It is still there. But if I mount it again, it
goes away (until it times out again).

Even more info:

When I first mount it, it creates 3 sockets, where one immediately is
closed:

tcp        0      0 192.168.23.9:892        192.168.23.22:44672     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:2049       192.168.23.22:815       ESTABLISHED -                   
tcp        0      0 192.168.23.9:754        192.168.23.22:44672     ESTABLISHED -                   

(192.168.23.22 is the machine remotely mounting a directory from the
server 192.168.23.9)

The trace of port 892 is this:

   kworker/u32:1-13473 [000] ....  4093.915114: xs_setup_tcp: RPC:       set up xprt to 192.168.23.22 (port 44672) via tcp
   kworker/u32:1-13473 [000] ....  4093.915122: xprt_create_transport: RPC:       created transport ffff8803b1c38000 with 65536 slots
    kworker/0:1H-129   [000] ....  4093.915152: xprt_alloc_slot: RPC:    47 reserved req ffff88040b27ca00 xid c50ccaff
    kworker/0:1H-129   [000] ....  4093.915157: xprt_connect: RPC:    47 xprt_connect xprt ffff8803b1c38000 is not connected
    kworker/0:1H-129   [000] ....  4093.915159: xs_connect: RPC:       xs_connect scheduled xprt ffff8803b1c38000
    kworker/0:1H-129   [000] ..s.  4093.915170: inet_csk_get_port: snum 892
    kworker/0:1H-129   [000] ..s.  4093.915177: <stack trace>
 => sched_clock
 => inet_addr_type_table
 => security_capable
 => inet_bind
 => xs_bind
 => release_sock
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  
    kworker/0:1H-129   [000] ..s.  4093.915178: inet_bind_hash: add 892 ffff8803bb9b5cc0
    kworker/0:1H-129   [000] ..s.  4093.915184: <stack trace>
 => inet_csk_get_port
 => sched_clock
 => inet_addr_type_table
 => security_capable
 => inet_bind
 => xs_bind
 => release_sock
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  
    kworker/0:1H-129   [000] ....  4093.915185: xs_bind: RPC:       xs_bind 4.136.255.255:892: ok (0)
    kworker/0:1H-129   [000] ....  4093.915186: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8803b1c38000 via tcp to 192.168.23.22 (port 44672)
    kworker/0:1H-129   [000] ....  4093.915221: xs_tcp_setup_socket: RPC:       ffff8803b1c38000 connect status 115 connected 0 sock state 2
          <idle>-0     [003] ..s.  4093.915434: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b1c38000...
          <idle>-0     [003] ..s.  4093.915435: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/3:1H-145   [003] ....  4093.915558: xprt_connect_status: RPC:    47 xprt_connect_status: retrying
    kworker/3:1H-145   [003] ....  4093.915560: xprt_prepare_transmit: RPC:    47 xprt_prepare_transmit
    kworker/3:1H-145   [003] ....  4093.915562: xprt_transmit: RPC:    47 xprt_transmit(72)
    kworker/3:1H-145   [003] ....  4093.915588: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/3:1H-145   [003] ....  4093.915589: xprt_transmit: RPC:    47 xmit complete
          <idle>-0     [003] ..s.  4093.915969: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
    kworker/3:1H-145   [003] ....  4093.916081: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
    kworker/3:1H-145   [003] ....  4093.916083: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
    kworker/3:1H-145   [003] ....  4093.916084: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
    kworker/3:1H-145   [003] ....  4093.916085: xs_tcp_data_recv: RPC:       reading request with XID c50ccaff
    kworker/3:1H-145   [003] ....  4093.916086: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
    kworker/3:1H-145   [003] ....  4093.916087: xs_tcp_data_recv: RPC:       read reply XID c50ccaff
    kworker/3:1H-145   [003] ..s.  4093.916088: xs_tcp_data_recv: RPC:       XID c50ccaff read 16 bytes
    kworker/3:1H-145   [003] ..s.  4093.916089: xs_tcp_data_recv: RPC:       xprt = ffff8803b1c38000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
    kworker/3:1H-145   [003] ..s.  4093.916090: xprt_complete_rqst: RPC:    47 xid c50ccaff complete (24 bytes received)
    kworker/3:1H-145   [003] ....  4093.916091: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/3:1H-145   [003] ....  4093.916098: xprt_release: RPC:    47 release request ffff88040b27ca00
   kworker/u32:1-13473 [002] ....  4093.976056: xprt_destroy: RPC:       destroying transport ffff8803b1c38000
   kworker/u32:1-13473 [002] ....  4093.976068: xs_destroy: RPC:       xs_destroy xprt ffff8803b1c38000
   kworker/u32:1-13473 [002] ....  4093.976069: xs_close: RPC:       xs_close xprt ffff8803b1c38000
   kworker/u32:1-13473 [002] ..s.  4093.976096: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b1c38000...
   kworker/u32:1-13473 [002] ..s.  4093.976098: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
   kworker/u32:1-13473 [002] ....  4093.976103: xprt_disconnect_done: RPC:       disconnected transport ffff8803b1c38000
   kworker/u32:1-13473 [002] ....  4093.976104: xprt_disconnect_done: disconnect transport!
   kworker/u32:1-13473 [002] ....  4093.976113: <stack trace>
 => xs_destroy
 => xprt_switch_free
 => rpc_free_client
 => rpc_release_client
 => rpc_shutdown_client
 => load_balance
 => ttwu_do_wakeup
 => nfsd4_process_cb_update.isra.14
 => __switch_to
 => pick_next_task_fair
 => nfsd4_run_cb_work
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  


Immediately followed by setting up of the port that will eventually turn into the hidden port:

   kworker/u32:1-13473 [002] ....  4093.976128: xs_setup_tcp: RPC:       set up xprt to 192.168.23.22 (port 44672) via tcp
   kworker/u32:1-13473 [002] ....  4093.976136: xprt_create_transport: RPC:       created transport ffff8803b8c22000 with 65536 slots
    kworker/2:1H-144   [002] ....  4093.976209: xprt_alloc_slot: RPC:    48 reserved req ffff8803bfe89c00 xid 10c028fe
    kworker/2:1H-144   [002] ....  4093.976213: xprt_connect: RPC:    48 xprt_connect xprt ffff8803b8c22000 is not connected
    kworker/2:1H-144   [002] ....  4093.976215: xs_connect: RPC:       xs_connect scheduled xprt ffff8803b8c22000
    kworker/2:1H-144   [002] ..s.  4093.976231: inet_csk_get_port: snum 754
    kworker/2:1H-144   [002] ..s.  4093.976239: <stack trace>
 => sched_clock
 => inet_addr_type_table
 => security_capable
 => inet_bind
 => xs_bind
 => release_sock
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  
    kworker/2:1H-144   [002] ..s.  4093.976239: inet_bind_hash: add 754 ffff8803afc20e40
    kworker/2:1H-144   [002] ..s.  4093.976247: <stack trace>
 => inet_csk_get_port
 => sched_clock
 => inet_addr_type_table
 => security_capable
 => inet_bind
 => xs_bind
 => release_sock
 => sock_setsockopt
 => __sock_create
 => xs_create_sock.isra.19
 => xs_tcp_setup_socket
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  
    kworker/2:1H-144   [002] ....  4093.976248: xs_bind: RPC:       xs_bind 4.136.255.255:754: ok (0)
    kworker/2:1H-144   [002] ....  4093.976250: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8803b8c22000 via tcp to 192.168.23.22 (port 44672)
    kworker/2:1H-144   [002] ....  4093.976284: xs_tcp_setup_socket: RPC:       ffff8803b8c22000 connect status 115 connected 0 sock state 2
          <idle>-0     [003] ..s.  4093.976456: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b8c22000...
          <idle>-0     [003] ..s.  4093.976458: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/3:1H-145   [003] ....  4093.976588: xprt_connect_status: RPC:    48 xprt_connect_status: retrying
    kworker/3:1H-145   [003] ....  4093.976590: xprt_prepare_transmit: RPC:    48 xprt_prepare_transmit
    kworker/3:1H-145   [003] ....  4093.976604: xprt_transmit: RPC:    48 xprt_transmit(72)
    kworker/3:1H-145   [003] ....  4093.976622: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/3:1H-145   [003] ....  4093.976623: xprt_transmit: RPC:    48 xmit complete
          <idle>-0     [003] ..s.  4093.977040: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
    kworker/3:1H-145   [003] ....  4093.977151: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
    kworker/3:1H-145   [003] ....  4093.977153: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
    kworker/3:1H-145   [003] ....  4093.977154: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
    kworker/3:1H-145   [003] ....  4093.977155: xs_tcp_data_recv: RPC:       reading request with XID 10c028fe
    kworker/3:1H-145   [003] ....  4093.977156: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
    kworker/3:1H-145   [003] ....  4093.977157: xs_tcp_data_recv: RPC:       read reply XID 10c028fe
    kworker/3:1H-145   [003] ..s.  4093.977158: xs_tcp_data_recv: RPC:       XID 10c028fe read 16 bytes
    kworker/3:1H-145   [003] ..s.  4093.977159: xs_tcp_data_recv: RPC:       xprt = ffff8803b8c22000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
    kworker/3:1H-145   [003] ..s.  4093.977160: xprt_complete_rqst: RPC:    48 xid 10c028fe complete (24 bytes received)
    kworker/3:1H-145   [003] ....  4093.977161: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/3:1H-145   [003] ....  4093.977167: xprt_release: RPC:    48 release request ffff8803bfe89c00


That "2049" port is what is used for all transferring of data.

When the FIN/ACK is sent by the client, the socket is destroyed (no more connections
can be used) but the port is not freed up, because it appears there's still an owner
attached to it. That means this port will *never* be used again. Even if the client
unmount the directory. That port is still in limbo.

When the FIN/ACK comes in, it goes into the TIME_WAIT state here:

    kworker/3:1H-145   [003] ..s.  4394.370019: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b8c22000...
    kworker/3:1H-145   [003] ..s.  4394.370022: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.  4394.370352: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b8c22000...
          <idle>-0     [003] ..s.  4394.370354: xs_tcp_state_change: RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [003] ..s.  4394.370375: tcp_time_wait: moving xs_bind sock to time wait
          <idle>-0     [003] ..s.  4394.370396: <stack trace>
 => tcp_data_queue
 => tcp_rcv_state_process
 => tcp_v4_inbound_md5_hash
 => tcp_v4_do_rcv
 => tcp_v4_rcv
 => ipv4_confirm
 => nf_iterate
 => ip_local_deliver_finish
 => ip_local_deliver
 => ip_local_deliver_finish
 => ip_rcv
 => packet_rcv
 => ip_rcv_finish
 => __netif_receive_skb_core
 => kmem_cache_alloc
 => netif_receive_skb_internal
 => br_pass_frame_up
 => br_flood
 => br_handle_frame
 => br_handle_frame_finish
 => enqueue_task_fair
 => br_handle_frame
 => br_handle_frame
 => find_busiest_group
 => __netif_receive_skb_core
 => inet_gro_receive
 => netif_receive_skb_internal
 => napi_gro_receive
 => e1000_clean_rx_irq
 => e1000_clean
 => net_rx_action
 => __do_softirq
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary  


Then eventually, the socket is freed, and 'netstat' no longer shows it.

          <idle>-0     [003] .Ns.  4454.371802: inet_bind_bucket_destroy: destroy 754 empty=0 ffff8803afc20e40
          <idle>-0     [003] .Ns.  4454.371813: <stack trace>
 => inet_twsk_bind_unhash
 => inet_twsk_kill
 => tw_timer_handler
 => call_timer_fn
 => tw_timer_handler
 => run_timer_softirq
 => __do_softirq
 => irq_exit
 => do_IRQ
 => ret_from_intr
 => cpuidle_enter_state
 => cpuidle_enter_state
 => cpu_startup_entry
 => start_secondary  


"empty=0" means the tb->owners associated with the port is not empty, and the
freeing of the port is skipped.

Now when I go and remount the directory from the client, the code finally cleans
up the port:

   kworker/u32:0-25031 [000] ....  4544.674603: xprt_destroy: RPC:       destroying transport ffff8803b8c22000
   kworker/u32:0-25031 [000] ....  4544.674616: xs_destroy: RPC:       xs_destroy xprt ffff8803b8c22000
   kworker/u32:0-25031 [000] ....  4544.674617: xs_close: RPC:       xs_close xprt ffff8803b8c22000
   kworker/u32:0-25031 [000] ..s.  4544.674619: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803b8c22000...
   kworker/u32:0-25031 [000] ..s.  4544.674620: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
   kworker/u32:0-25031 [000] ..s.  4544.674621: xprt_disconnect_done: RPC:       disconnected transport ffff8803b8c22000
   kworker/u32:0-25031 [000] ..s.  4544.674621: xprt_disconnect_done: disconnect transport!


   kworker/u32:0-25031 [000] ..s.  4544.674647: inet_bind_bucket_destroy: destroy 754 empty=1 ffff8803afc20e40
   kworker/u32:0-25031 [000] ..s.  4544.674655: <stack trace>
 => inet_put_port
 => tcp_v4_destroy_sock
 => inet_csk_destroy_sock
 => tcp_close
 => inet_release
 => sock_release
 => xs_close
 => xs_destroy
 => xprt_switch_free
 => rpc_free_client
 => rpc_release_client
 => rpc_shutdown_client
 => nfsd4_process_cb_update.isra.14
 => update_curr
 => dequeue_task_fair
 => __switch_to
 => pick_next_task_fair
 => nfsd4_run_cb_work
 => process_one_work
 => worker_thread
 => worker_thread
 => kthread
 => ret_from_fork
 => kthread  
   kworker/u32:0-25031 [000] ....  4544.674660: xprt_disconnect_done: RPC:       disconnected transport ffff8803b8c22000

Notice that "empty=1" now, and the port is freed.

Then it goes back doing everything all over again:

    kworker/3:1H-145   [003] ....  4558.442458: xs_bind: RPC:       xs_bind 4.136.255.255:973: ok (0)
    kworker/3:1H-145   [003] ....  4558.442460: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8803d7fd3800 via tcp to 192.168.23.22 (port 45075)
    kworker/3:1H-145   [003] ....  4558.442496: xs_tcp_setup_socket: RPC:       ffff8803d7fd3800 connect status 115 connected 0 sock state 2
          <idle>-0     [002] ..s.  4558.442691: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803d7fd3800...
          <idle>-0     [002] ..s.  4558.442693: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/2:1H-144   [002] ....  4558.442732: xprt_connect_status: RPC:    49 xprt_connect_status: retrying
    kworker/2:1H-144   [002] ....  4558.442734: xprt_prepare_transmit: RPC:    49 xprt_prepare_transmit
    kworker/2:1H-144   [002] ....  4558.442737: xprt_transmit: RPC:    49 xprt_transmit(72)
    kworker/2:1H-144   [002] ....  4558.442753: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/2:1H-144   [002] ....  4558.442754: xprt_transmit: RPC:    49 xmit complete
            nfsd-4382  [002] ..s.  4558.443203: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
    kworker/2:1H-144   [002] ....  4558.443227: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
    kworker/2:1H-144   [002] ....  4558.443229: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
    kworker/2:1H-144   [002] ....  4558.443230: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
    kworker/2:1H-144   [002] ....  4558.443231: xs_tcp_data_recv: RPC:       reading request with XID e2e1dc21
    kworker/2:1H-144   [002] ....  4558.443232: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
    kworker/2:1H-144   [002] ....  4558.443233: xs_tcp_data_recv: RPC:       read reply XID e2e1dc21
    kworker/2:1H-144   [002] ..s.  4558.443235: xs_tcp_data_recv: RPC:       XID e2e1dc21 read 16 bytes
    kworker/2:1H-144   [002] ..s.  4558.443236: xs_tcp_data_recv: RPC:       xprt = ffff8803d7fd3800, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
    kworker/2:1H-144   [002] ..s.  4558.443237: xprt_complete_rqst: RPC:    49 xid e2e1dc21 complete (24 bytes received)
    kworker/2:1H-144   [002] ....  4558.443238: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/2:1H-144   [002] ....  4558.443246: xprt_release: RPC:    49 release request ffff8800dba14800
   kworker/u32:1-13473 [003] ....  4558.496850: xprt_destroy: RPC:       destroying transport ffff8803d7fd3800
   kworker/u32:1-13473 [003] ....  4558.496860: xs_destroy: RPC:       xs_destroy xprt ffff8803d7fd3800
   kworker/u32:1-13473 [003] ....  4558.496861: xs_close: RPC:       xs_close xprt ffff8803d7fd3800
   kworker/u32:1-13473 [003] ..s.  4558.496888: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803d7fd3800...
   kworker/u32:1-13473 [003] ..s.  4558.496889: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
   kworker/u32:1-13473 [003] ....  4558.496894: xprt_disconnect_done: RPC:       disconnected transport ffff8803d7fd3800
   kworker/u32:1-13473 [003] ....  4558.496895: xprt_disconnect_done: disconnect transport!

Where 973 is the port that gets added and disconnected right away (and freed)

    kworker/3:1H-145   [003] ....  4558.496991: xs_bind: RPC:       xs_bind 4.136.255.255:688: ok (0)
    kworker/3:1H-145   [003] ....  4558.496993: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8803bb889000 via tcp to 192.168.23.22 (port 45075)
    kworker/3:1H-145   [003] ....  4558.497024: xs_tcp_setup_socket: RPC:       ffff8803bb889000 connect status 115 connected 0 sock state 2
          <idle>-0     [002] .Ns.  4558.497171: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8803bb889000...
          <idle>-0     [002] .Ns.  4558.497173: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
    kworker/2:1H-144   [002] ....  4558.497196: xprt_connect_status: RPC:    50 xprt_connect_status: retrying
    kworker/2:1H-144   [002] ....  4558.497197: xprt_prepare_transmit: RPC:    50 xprt_prepare_transmit
    kworker/2:1H-144   [002] ....  4558.497199: xprt_transmit: RPC:    50 xprt_transmit(72)
    kworker/2:1H-144   [002] ....  4558.497210: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/2:1H-144   [002] ....  4558.497210: xprt_transmit: RPC:    50 xmit complete
          <idle>-0     [002] ..s.  4558.497475: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
    kworker/2:1H-144   [002] ....  4558.497569: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
    kworker/2:1H-144   [002] ....  4558.497571: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
    kworker/2:1H-144   [002] ....  4558.497571: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
    kworker/2:1H-144   [002] ....  4558.497572: xs_tcp_data_recv: RPC:       reading request with XID a4418f34
    kworker/2:1H-144   [002] ....  4558.497573: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
    kworker/2:1H-144   [002] ....  4558.497573: xs_tcp_data_recv: RPC:       read reply XID a4418f34
    kworker/2:1H-144   [002] ..s.  4558.497574: xs_tcp_data_recv: RPC:       XID a4418f34 read 16 bytes
    kworker/2:1H-144   [002] ..s.  4558.497575: xs_tcp_data_recv: RPC:       xprt = ffff8803bb889000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
    kworker/2:1H-144   [002] ..s.  4558.497575: xprt_complete_rqst: RPC:    50 xid a4418f34 complete (24 bytes received)
    kworker/2:1H-144   [002] ....  4558.497577: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/2:1H-144   [002] ....  4558.497581: xprt_release: RPC:    50 release request ffff8800db28d800

And 688 will be the port that becomes the new hidden port.

Thus it looks like there's something that is not cleaning up ports properly. There's
some timing issues here.

Any thoughts why. Because this is obviously wrong, and not only is it wasting a port
and memory to store it, but it's causing rkhunter to report it, because it's one of
the things that rootkits do.

-- Steve
