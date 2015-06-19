Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0111.hostedemail.com ([216.40.44.111]:34681 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752679AbbFSRSE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 13:18:04 -0400
Date: Fri, 19 Jun 2015 13:17:59 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>, bfields@fieldses.org
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150619131759.7b38d9de@gandalf.local.home>
In-Reply-To: <20150619122553.43d2d86c@gandalf.local.home>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2015 12:25:53 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:


> I don't see that 55201 anywhere. But then again, I didn't look for it
> before the port disappeared. I could reboot and look for it again. I
> should have saved the full netstat -tapn as well :-/

Of course I didn't find it anywhere, that's the port on my wife's box
that port 947 was connected to.

Now I even went over to my wife's box and ran

 # rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  34243  status
    100024    1   tcp  34498  status

which doesn't show anything.

but something is listening to that port...

 # netstat -ntap |grep 55201
tcp        0      0 0.0.0.0:55201           0.0.0.0:*               LISTEN   

I rebooted again, but this time I ran this on my wife's box:

 # trace-cmd record -e nfs -e nfs4 -e net -e skb -e sock -e udp -e workqueue -e sunrpc

I started it when my server started booting the kernel, and kept it
running till the port vanished.

The full trace can be downloaded from
http://rostedt.homelinux.com/private/wife-trace.txt

Here's some interesting output from that trace:

ksoftirq-13      1..s. 12272627.681760: netif_receive_skb:    dev=lo skbaddr=0xffff88020944c600 len=88
ksoftirq-13      1..s. 12272627.681776: net_dev_queue:        dev=eth0 skbaddr=0xffff880234e5b100 len=42
ksoftirq-13      1..s. 12272627.681777: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff880234e5b100 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0806 ip_
summed=0 len=42 data_len=0 network_offset=14 transport_offset_valid=0 transport_offset=65533 tx_flags=0 gso_size=0 gso_segs=0 gso_type=0
ksoftirq-13      1..s. 12272627.681779: net_dev_xmit:         dev=eth0 skbaddr=0xffff880234e5b100 len=42 rc=0
ksoftirq-13      1..s. 12272627.681780: kfree_skb:            skbaddr=0xffff88023444cf00 protocol=2048 location=0xffffffff81422a72
ksoftirq-13      1..s. 12272627.681783: rpc_socket_error:     error=-113 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=2 ()
ksoftirq-13      1..s. 12272627.681785: rpc_task_wakeup:      task:18128@0 flags=5281 state=0006 status=-113 timeout=45000 queue=xprt_pending
ksoftirq-13      1d.s. 12272627.681786: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
ksoftirq-13      1d.s. 12272627.681787: workqueue_activate_work: work struct 0xffff8800b5a94588
ksoftirq-13      1..s. 12272627.681791: rpc_socket_state_change: socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=7 ()
ksoftirq-13      1..s. 12272627.681792: kfree_skb:            skbaddr=0xffff88020944c600 protocol=2048 location=0xffffffff81482c05
kworker/-20111   1.... 12272627.681796: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272627.681797: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-113 action=call_connect_status
kworker/-20111   1.... 12272627.681798: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-113 action=call_connect_status
kworker/-20111   1.... 12272627.681798: rpc_connect_status:   task:18128@0, status -113
kworker/-20111   1..s. 12272627.681799: rpc_task_sleep:       task:18128@0 flags=5281 state=0005 status=0 timeout=750 queue=delayq
kworker/-20111   1.... 12272627.681800: workqueue_execute_end: work struct 0xffff8800b5a94588

  <idle>-0       1..s. 12272630.688741: rpc_task_wakeup:      task:18128@0 flags=5281 state=0006 status=-110 timeout=750 queue=delayq
  <idle>-0       1dNs. 12272630.688749: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1dNs. 12272630.688749: workqueue_activate_work: work struct 0xffff8800b5a94588
kworker/-20111   1.... 12272630.688758: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272630.688759: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-110 action=call_timeout
kworker/-20111   1.... 12272630.688760: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_timeout
kworker/-20111   1.... 12272630.688760: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_bind
kworker/-20111   1.... 12272630.688761: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_connect
kworker/-20111   1..s. 12272630.688762: rpc_task_sleep:       task:18128@0 flags=5281 state=0005 status=0 timeout=45000 queue=xprt_pending
kworker/-20111   1.... 12272630.688765: workqueue_execute_end: work struct 0xffff8800b5a94588
  <idle>-0       3d.s. 12272630.696742: workqueue_queue_work: work struct=0xffff880234ac9060 function=disk_events_workfn workqueue=0xffff8802370d9000 req_cpu=512 cpu=3
  <idle>-0       3d.s. 12272630.696744: workqueue_activate_work: work struct 0xffff880234ac9060
kworker/-7491    3.... 12272630.696760: workqueue_execute_start: work struct 0xffff880234ac9060: function disk_events_workfn
kworker/-7491    3d... 12272630.696827: workqueue_queue_work: work struct=0xffff8802347440b8 function=ata_sff_pio_task workqueue=0xffff880234491c00 req_cpu=512 cpu=3
kworker/-7491    3d... 12272630.696828: workqueue_activate_work: work struct 0xffff8802347440b8
kworker/-16140   3.... 12272630.696837: workqueue_execute_start: work struct 0xffff8802347440b8: function ata_sff_pio_task
kworker/-16140   3.... 12272630.696853: workqueue_execute_end: work struct 0xffff8802347440b8
kworker/-7491    3.... 12272630.697383: workqueue_execute_end: work struct 0xffff880234ac9060

  <idle>-0       1d.s. 12272654.753029: workqueue_queue_work: work struct=0xffff8802361f4de0 function=xs_tcp_setup_socket workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1d.s. 12272654.753031: workqueue_activate_work: work struct 0xffff8802361f4de0
kworker/-20111   1.... 12272654.753049: workqueue_execute_start: work struct 0xffff8802361f4de0: function xs_tcp_setup_socket
kworker/-20111   1..s. 12272654.753054: rpc_socket_error:     error=-113 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=7 ()
kworker/-20111   1.... 12272654.753055: rpc_socket_reset_connection: error=0 socket:[11886206] dstaddr=192.168.23.9/2049 state=1 () sk_state=7 ()
kworker/-20111   1..s. 12272654.753075: net_dev_queue:        dev=eth0 skbaddr=0xffff880082117ae8 len=74
kworker/-20111   1..s. 12272654.753083: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff880082117ae8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=74 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
kworker/-20111   1..s. 12272654.753088: net_dev_xmit:         dev=eth0 skbaddr=0xffff880082117ae8 len=74 rc=0
kworker/-20111   1.... 12272654.753090: rpc_socket_connect:   error=-115 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=2 ()
kworker/-20111   1.... 12272654.753093: workqueue_execute_end: work struct 0xffff8802361f4de0
  <idle>-0       1..s. 12272654.753320: consume_skb:          skbaddr=0xffff880082117ae8
  <idle>-0       1..s. 12272654.753503: napi_gro_receive_entry: dev=eth0 napi_id=0 queue_mapping=0 skbaddr=0xffff8801f647d100 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0806 ip_summed=0 hash=0x00000000 l4_hash=0 len=46 data_len=0 truesize=704 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0
  <idle>-0       1.Ns. 12272654.753508: netif_receive_skb:    dev=eth0 skbaddr=0xffff8801f647d100 len=46
  <idle>-0       1.Ns. 12272654.753519: consume_skb:          skbaddr=0xffff8800a9aa2d00
  <idle>-0       1.Ns. 12272654.753522: net_dev_queue:        dev=eth0 skbaddr=0xffff8800a9aa2d00 len=42
  <idle>-0       1.Ns. 12272654.753523: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff8800a9aa2d00 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0806 ip_summed=0 len=42 data_len=0 network_offset=14 transport_offset_valid=0 transport_offset=65533 tx_flags=0 gso_size=0 gso_segs=0 gso_type=0
  <idle>-0       1.Ns. 12272654.753525: net_dev_xmit:         dev=eth0 skbaddr=0xffff8800a9aa2d00 len=42 rc=0
  <idle>-0       1.Ns. 12272654.753526: consume_skb:          skbaddr=0xffff8801f647d100
  <idle>-0       1..s. 12272654.753585: napi_gro_receive_entry: dev=eth0 napi_id=0 queue_mapping=0 skbaddr=0xffff8801f647d100 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=1 hash=0x00000000 l4_hash=0 len=46 data_len=0 truesize=704 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0
  <idle>-0       1.Ns. 12272654.753589: netif_receive_skb:    dev=eth0 skbaddr=0xffff8801f647d100 len=46
  <idle>-0       1.Ns. 12272654.753595: rpc_socket_error:     error=-111 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=2 ()
  <idle>-0       1.Ns. 12272654.753597: rpc_task_wakeup:      task:18128@0 flags=5281 state=0006 status=-111 timeout=45000 queue=xprt_pending
  <idle>-0       1dNs. 12272654.753598: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1dNs. 12272654.753599: workqueue_activate_work: work struct 0xffff8800b5a94588
  <idle>-0       1.Ns. 12272654.753601: rpc_socket_state_change: socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=7 ()
kworker/-20111   1.... 12272654.753607: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272654.753608: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-111 action=call_connect_status
kworker/-20111   1.... 12272654.753609: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-111 action=call_connect_status
kworker/-20111   1.... 12272654.753609: rpc_connect_status:   task:18128@0, status -111
kworker/-20111   1..s. 12272654.753610: rpc_task_sleep:       task:18128@0 flags=5281 state=0005 status=0 timeout=750 queue=delayq
kworker/-20111   1.... 12272654.753612: workqueue_execute_end: work struct 0xffff8800b5a94588
  <idle>-0       1..s. 12272654.753692: consume_skb:          skbaddr=0xffff8800a9aa2d00

  <idle>-0       1.Ns. 12272657.605105: netif_receive_skb:    dev=eth0 skbaddr=0xffff8802223d1e00 len=345
  <idle>-0       1.Ns. 12272657.605108: kfree_skb:            skbaddr=0xffff8802223d1e00 protocol=2048 location=0xffffffff8147e361
  <idle>-0       1..s. 12272657.760044: rpc_task_wakeup:      task:18128@0 flags=5281 state=0006 status=-110 timeout=750 queue=delayq
  <idle>-0       1dNs. 12272657.760051: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1dNs. 12272657.760052: workqueue_activate_work: work struct 0xffff8800b5a94588
kworker/-20111   1.... 12272657.760063: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272657.760064: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-110 action=call_timeout
kworker/-20111   1.... 12272657.760065: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_timeout
kworker/-20111   1.... 12272657.760066: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_bind
kworker/-20111   1.... 12272657.760066: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_connect
kworker/-20111   1..s. 12272657.760068: rpc_task_sleep:       task:18128@0 flags=5281 state=0005 status=0 timeout=45000 queue=xprt_pending
kworker/-20111   1.... 12272657.760070: workqueue_execute_end: work struct 0xffff8800b5a94588
  <idle>-0       3d.s. 12272657.824024: workqueue_queue_work: work struct=0xffff8800b5551760 function=disk_events_workfn workqueue=0xffff8802370d9000 req_cpu=512 cpu=3
  <idle>-0       3d.s. 12272657.824025: workqueue_activate_work: work struct 0xffff8800b5551760
kworker/-7491    3.... 12272657.824041: workqueue_execute_start: work struct 0xffff8800b5551760: function disk_events_workfn
kworker/-7491    3.... 12272657.824807: workqueue_execute_end: work struct 0xffff8800b5551760


  <idle>-0       1d.s. 12272705.808564: workqueue_queue_work: work struct=0xffff8802361f4de0 function=xs_tcp_setup_socket workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1d.s. 12272705.808565: workqueue_activate_work: work struct 0xffff8802361f4de0
kworker/-20111   1.... 12272705.808574: workqueue_execute_start: work struct 0xffff8802361f4de0: function xs_tcp_setup_socket
kworker/-20111   1..s. 12272705.808580: rpc_socket_error:     error=-111 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=7 ()
kworker/-20111   1.... 12272705.808581: rpc_socket_reset_connection: error=0 socket:[11886206] dstaddr=192.168.23.9/2049 state=1 () sk_state=7 ()
kworker/-20111   1..s. 12272705.808599: net_dev_queue:        dev=eth0 skbaddr=0xffff880082117ae8 len=74
kworker/-20111   1..s. 12272705.808602: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff880082117ae8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=74 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
kworker/-20111   1..s. 12272705.808605: net_dev_xmit:         dev=eth0 skbaddr=0xffff880082117ae8 len=74 rc=0
kworker/-20111   1.... 12272705.808614: rpc_socket_connect:   error=-115 socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=2 ()
kworker/-20111   1.... 12272705.808615: workqueue_execute_end: work struct 0xffff8802361f4de0
  <idle>-0       1..s. 12272705.808841: napi_gro_receive_entry: dev=eth0 napi_id=0 queue_mapping=0 skbaddr=0xffff8800a60e8900 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=1 hash=0x00000000 l4_hash=0 len=60 data_len=0 truesize=768 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0
  <idle>-0       1.Ns. 12272705.808849: netif_receive_skb:    dev=eth0 skbaddr=0xffff8800a60e8900 len=60
  <idle>-0       1.Ns. 12272705.808872: rpc_socket_state_change: socket:[11886206] dstaddr=192.168.23.9/2049 state=2 () sk_state=1 ()
  <idle>-0       1.Ns. 12272705.808874: rpc_task_wakeup:      task:18128@0 flags=5281 state=0006 status=-11 timeout=45000 queue=xprt_pending
  <idle>-0       1dNs. 12272705.808875: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1dNs. 12272705.808876: workqueue_activate_work: work struct 0xffff8800b5a94588
  <idle>-0       1.Ns. 12272705.808881: net_dev_queue:        dev=eth0 skbaddr=0xffff8800a60e8500 len=66
  <idle>-0       1.Ns. 12272705.808883: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff8800a60e8500 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=66 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
  <idle>-0       1.Ns. 12272705.808885: net_dev_xmit:         dev=eth0 skbaddr=0xffff8800a60e8500 len=66 rc=0
  <idle>-0       1.Ns. 12272705.808887: consume_skb:          skbaddr=0xffff880082117ae8
kworker/-20111   1.... 12272705.808895: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272705.808896: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-11 action=call_connect_status
kworker/-20111   1.... 12272705.808897: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=-11 action=call_connect_status
kworker/-20111   1.... 12272705.808897: rpc_connect_status:   task:18128@0, status -11
kworker/-20111   1.... 12272705.808897: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_timeout
kworker/-20111   1.... 12272705.808898: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_bind
kworker/-20111   1.... 12272705.808899: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_connect
kworker/-20111   1.... 12272705.808899: rpc_task_run_action:  task:18128@0 flags=5281 state=0005 status=0 action=call_transmit
kworker/-20111   1..s. 12272705.808912: net_dev_queue:        dev=eth0 skbaddr=0xffff880082117ae8 len=162
kworker/-20111   1..s. 12272705.808913: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff880082117ae8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=162 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
kworker/-20111   1..s. 12272705.808913: net_dev_xmit:         dev=eth0 skbaddr=0xffff880082117ae8 len=162 rc=0
kworker/-20111   1..s. 12272705.808916: rpc_task_sleep:       task:18128@0 flags=5a81 state=0005 status=0 timeout=45000 queue=xprt_pending
kworker/-20111   1.... 12272705.808917: workqueue_execute_end: work struct 0xffff8800b5a94588
  <idle>-0       1..s. 12272705.809098: consume_skb:          skbaddr=0xffff8800a60e8500

  <idle>-0       1.Ns. 12272705.809840: rpc_task_wakeup:      task:18128@0 flags=5a81 state=0006 status=0 timeout=45000 queue=xprt_pending
  <idle>-0       1dNs. 12272705.809842: workqueue_queue_work: work struct=0xffff8800b5a94588 function=rpc_async_schedule workqueue=0xffff880234666800 req_cpu=512 cpu=1
  <idle>-0       1dNs. 12272705.809842: workqueue_activate_work: work struct 0xffff8800b5a94588
kworker/-20111   1.... 12272705.809853: workqueue_execute_start: work struct 0xffff8800b5a94588: function rpc_async_schedule
kworker/-20111   1.... 12272705.809853: rpc_task_run_action:  task:18128@0 flags=5a81 state=0005 status=0 action=call_status
kworker/-20111   1.... 12272705.809854: rpc_task_run_action:  task:18128@0 flags=5a81 state=0005 status=0 action=call_status
kworker/-20111   1.... 12272705.809854: rpc_task_run_action:  task:18128@0 flags=5a81 state=0005 status=44 action=call_decode
kworker/-20111   1.... 12272705.809856: rpc_task_run_action:  task:18128@0 flags=5a81 state=0005 status=-10022 action=rpc_exit_task
kworker/-20111   1.... 12272705.809858: nfs4_renew_async:     error=-10022 () dstaddr=192.168.23.9
  <idle>-0       1.Ns. 12272705.810000: consume_skb:          skbaddr=0xffff8800a60e8900
kworker/-20111   1.... 12272705.810033: workqueue_execute_end: work struct 0xffff8800b5a94588
192.168.-16171   3.... 12272705.810062: rpc_task_begin:       task:0@0 flags=5280 state=0000 status=0 action=irq_stack_union
192.168.-16171   3.... 12272705.810068: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_start
192.168.-16171   3.... 12272705.810069: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_reserve
192.168.-16171   3.... 12272705.810071: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_reserveresult
192.168.-16171   3.... 12272705.810071: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_refresh
192.168.-16171   3.... 12272705.810073: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_refreshresult
192.168.-16171   3.... 12272705.810073: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_allocate
192.168.-16171   3.... 12272705.810074: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_bind
192.168.-16171   3.... 12272705.810075: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_connect
192.168.-16171   3.... 12272705.810075: rpc_task_run_action:  task:18129@0 flags=5280 state=0005 status=0 action=call_transmit
192.168.-16171   3..s. 12272705.810095: net_dev_queue:        dev=eth0 skbaddr=0xffff8800a9b924e8 len=162
192.168.-16171   3..s. 12272705.810097: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff8800a9b924e8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=162 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
192.168.-16171   3..s. 12272705.810098: net_dev_xmit:         dev=eth0 skbaddr=0xffff8800a9b924e8 len=162 rc=0
192.168.-16171   3..s. 12272705.810101: rpc_task_sleep:       task:18129@0 flags=5a80 state=0005 status=0 timeout=15000 queue=xprt_pending
  <idle>-0       1..s. 12272705.810318: napi_gro_receive_entry: dev=eth0 napi_id=0 queue_mapping=0 skbaddr=0xffff8800a60e8900 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=1 hash=0x00000000 l4_hash=0 len=100 data_len=0 truesize=768 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0
  <idle>-0       1.Ns. 12272705.810326: netif_receive_skb:    dev=eth0 skbaddr=0xffff8800a60e8900 len=100
  <idle>-0       1.Ns. 12272705.810344: rpc_task_wakeup:      task:18129@0 flags=5a80 state=0006 status=0 timeout=15000 queue=xprt_pending
  <idle>-0       1.Ns. 12272705.810349: consume_skb:          skbaddr=0xffff8800a9b924e8
192.168.-16171   3.... 12272705.810379: rpc_task_run_action:  task:18129@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.810385: rpc_task_run_action:  task:18129@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.810385: rpc_task_run_action:  task:18129@0 flags=5a80 state=0005 status=44 action=call_decode
192.168.-16171   3.... 12272705.810387: rpc_task_run_action:  task:18129@0 flags=5a80 state=0005 status=-10022 action=rpc_exit_task
192.168.-16171   3.... 12272705.810397: rpc_task_begin:       task:0@0 flags=5280 state=0000 status=0 action=irq_stack_union
192.168.-16171   3.... 12272705.810398: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_start
192.168.-16171   3.... 12272705.810398: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_reserve
192.168.-16171   3.... 12272705.810399: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_reserveresult
192.168.-16171   3.... 12272705.810399: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_refresh
192.168.-16171   3.... 12272705.810400: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_refreshresult
192.168.-16171   3.... 12272705.810400: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_allocate
192.168.-16171   3.... 12272705.810404: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_bind
192.168.-16171   3.... 12272705.810404: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_connect
192.168.-16171   3.... 12272705.810404: rpc_task_run_action:  task:18130@0 flags=5280 state=0005 status=0 action=call_transmit
192.168.-16171   3..s. 12272705.810417: net_dev_queue:        dev=eth0 skbaddr=0xffff8800a9b92ae8 len=254
192.168.-16171   3..s. 12272705.810418: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff8800a9b92ae8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=254 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
192.168.-16171   3..s. 12272705.810426: net_dev_xmit:         dev=eth0 skbaddr=0xffff8800a9b92ae8 len=254 rc=0
192.168.-16171   3..s. 12272705.810428: rpc_task_sleep:       task:18130@0 flags=5a80 state=0005 status=0 timeout=15000 queue=xprt_pending
192.168.-16171   3.... 12272705.810902: rpc_task_run_action:  task:18130@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.810908: rpc_task_run_action:  task:18130@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.810908: rpc_task_run_action:  task:18130@0 flags=5a80 state=0005 status=60 action=call_decode
192.168.-16171   3.... 12272705.810910: rpc_task_run_action:  task:18130@0 flags=5a80 state=0005 status=0 action=rpc_exit_task
192.168.-16171   3.... 12272705.810914: nfs4_setclientid:     error=0 (ACCESS) dstaddr=192.168.23.9
192.168.-16171   3.... 12272705.810915: rpc_task_begin:       task:0@0 flags=5280 state=0000 status=0 action=irq_stack_union
192.168.-16171   3.... 12272705.810916: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_start
192.168.-16171   3.... 12272705.810916: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_reserve
192.168.-16171   3.... 12272705.810917: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_reserveresult
192.168.-16171   3.... 12272705.810917: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_refresh
192.168.-16171   3.... 12272705.810918: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_refreshresult
192.168.-16171   3.... 12272705.810918: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_allocate
192.168.-16171   3.... 12272705.810919: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_bind
192.168.-16171   3.... 12272705.810919: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_connect
192.168.-16171   3.... 12272705.810919: rpc_task_run_action:  task:18131@0 flags=5280 state=0005 status=0 action=call_transmit
192.168.-16171   3..s. 12272705.810931: net_dev_queue:        dev=eth0 skbaddr=0xffff8800a9b92ce8 len=170
192.168.-16171   3..s. 12272705.810932: net_dev_start_xmit:   dev=eth0 queue_mapping=0 skbaddr=0xffff8800a9b92ce8 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x0000 protocol=0x0800 ip_summed=0 len=170 data_len=0 network_offset=14 transport_offset_valid=1 transport_offset=34 tx_flags=0 gso_size=0 gso_segs=1 gso_type=0
192.168.-16171   3..s. 12272705.810933: net_dev_xmit:         dev=eth0 skbaddr=0xffff8800a9b92ce8 len=170 rc=0
192.168.-16171   3..s. 12272705.810936: rpc_task_sleep:       task:18131@0 flags=5a80 state=0005 status=0 timeout=15000 queue=xprt_pending
192.168.-16171   3.... 12272705.811213: rpc_task_run_action:  task:18131@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.811220: rpc_task_run_action:  task:18131@0 flags=5a80 state=0005 status=0 action=call_status
192.168.-16171   3.... 12272705.811220: rpc_task_run_action:  task:18131@0 flags=5a80 state=0005 status=44 action=call_decode
192.168.-16171   3.... 12272705.811222: rpc_task_run_action:  task:18131@0 flags=5a80 state=0005 status=0 action=rpc_exit_task
192.168.-16171   3.... 12272705.811227: nfs4_setclientid_confirm: error=0 (ACCESS) dstaddr=192.168.23.9


And it goes on, but you can look at the full  trace. I just searched
for "rpc".

Maybe this will shed more light on the issue. I'll keep this kernel on
my server for a little longer, but it's going to start triggering
rkhunter warnings about hidden ports again.

-- Steve


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
