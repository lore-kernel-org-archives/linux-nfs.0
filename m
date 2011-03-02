Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52875 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482Ab1CBNEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2011 08:04:24 -0500
Received: by eyx24 with SMTP id 24so2039557eyx.19
        for <linux-nfs@vger.kernel.org>; Wed, 02 Mar 2011 05:04:21 -0800 (PST)
Message-ID: <4D6E4052.7050201@monstr.eu>
Date: Wed, 02 Mar 2011 14:04:18 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
To: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: NFS problem on Microblaze LE
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am getting some troubles to get nfs work on new Microblaze little-endian platform and I would like 
to ask you for some recommendations how to debug it.

First of all I need to write that Microblaze big-endian platforms have no problem.
The problem only happen if I use mount without -o nolock option
(mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt)
If I use -o nolock option I have no problem to use nfs.

I use xilinx emaclite and axi emac(it is not in the mainline now) driver and I have no problem to 
use dhcp, ftp, http, telnet and other internet protocols.

I compared debug logs on big and little endian platform(rootfs has the same setting) I found that 
little-endian got packet which is shorter than on big endian which I have added to the log below.
The second thing, which I think is connected to the previous point, is that I am getting BADCRED in 
rpc_verify_headers.

Is there any option/macro/recommended debug technique how to see packets? I need to get some clue 
how to see packet and then how they are passed to rpc_verify_header function.

Thanks for you help,
Michal



sp605-emaclite-chipscope login: root
Password:
~ # echo 65535 > /proc/sys/sunrpc/nfs_debug
~ # echo 65535 > /proc/sys/sunrpc/nfsd_debug
~ # echo 65535 > /proc/sys/sunrpc/nlm_debug
~ # echo 65535 > /proc/sys/sunrpc/rpc_debug
~ #
~ #
~ # mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt
RPC:       looking up machine cred
RPC:       allocated machine cred c6f9c320 for uid 0 gid 0
RPC:       set up xprt to 192.168.0.101 (port 2049) via udp
RPC:       created transport c6fac400 with 16 slots
RPC:       creating nfs client for 192.168.0.101 (xprt c6fac400)
RPC:       creating UNIX authenticator for client c6f322a0
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     1 __rpc_execute flags=0x680
RPC:     1 call_start nfs3 proc NULL (sync)
RPC:     1 call_reserve (status 0)
RPC:     1 reserved req c0810000 xid 2c351377
RPC:     1 call_reserveresult (status 0)
RPC:     1 call_refresh (status 0)
RPC:     1 holding NULL cred c0335c98
RPC:     1 refreshing NULL cred c0335c98
RPC:     1 call_refreshresult (status 0)
RPC:     1 call_allocate (status 0)
RPC:     1 allocated buffer of size 92 at c0811800
RPC:     1 call_bind (status 0)
RPC:     1 call_connect xprt c6fac400 is not connected
RPC:     1 xprt_connect xprt c6fac400 is not connected
RPC:     1 xprt_cwnd_limited cong = 0 cwnd = 256
RPC:     1 sleep_on(queue "xprt_pending" time 4294924896)
RPC:     1 added to queue c6fac5ac "xprt_pending"
RPC:     1 setting alarm for 700 ms
RPC:       xs_connect scheduled xprt c6fac400
RPC:     1 sync task going to sleep
RPC:       xs_bind4 0.0.0.0:1016: ok (0)
RPC:       worker connecting xprt c6fac400 via udp to 192.168.0.101 (port 2049)
RPC:     1 __rpc_wake_up_task (now 4294924904)
RPC:     1 disabling timer
RPC:     1 removed from queue c6fac5ac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:     1 sync task resuming
RPC:     1 xprt_connect_status: connection established
RPC:     1 call_connect_status (status 0)
RPC:     1 call_transmit (status 0)
RPC:     1 xprt_prepare_transmit
RPC:     1 rpc_xdr_encode (status 0)
RPC:     1 marshaling NULL cred c0335c98
RPC:     1 using AUTH_NULL cred c0335c98 to wrap rpc data
RPC:     1 xprt_transmit(40)
RPC:       xs_udp_data_ready...
RPC:       cong 256, cwnd was 256, now 512
RPC:     1 xid 2c351377 complete (24 bytes received)
RPC:       xs_udp_send_request(40) = 40
RPC:     1 xmit complete
RPC:       wake_up_next(c6fac554 "xprt_resend")
RPC:       wake_up_next(c6fac4fc "xprt_sending")
RPC:     1 call_status (status 24)
RPC:     1 call_decode (status 24)
RPC:     1 validating NULL cred c0335c98
RPC:     1 using AUTH_NULL cred c0335c98 to unwrap rpc data
RPC:     1 call_decode result 0
RPC:     1 return 0, status 0
RPC:     1 release task
RPC:       freeing buffer of size 92 at c0811800
RPC:     1 release request c0810000
RPC:       wake_up_next(c6fac604 "xprt_backlog")
RPC:       rpc_release_client(c6f322a0)
RPC:     1 freeing task
RPC:       set up xprt to 127.0.0.1 (port 111) via tcp
RPC:       created transport c080bc00 with 16 slots
RPC:       creating rpcbind client for localhost (xprt c080bc00)
RPC:       creating UNIX authenticator for client c6f323a0
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     2 __rpc_execute flags=0x680
RPC:     2 call_start rpcbind4 proc NULL (sync)
RPC:     2 call_reserve (status 0)
RPC:     2 reserved req c0812000 xid 562efd36
RPC:     2 call_reserveresult (status 0)
RPC:     2 call_refresh (status 0)
RPC:     2 holding NULL cred c0335c98
RPC:     2 refreshing NULL cred c0335c98
RPC:     2 call_refreshresult (status 0)
RPC:     2 call_allocate (status 0)
RPC:     2 allocated buffer of size 92 at c0811800
RPC:     2 call_bind (status 0)
RPC:     2 call_connect xprt c080bc00 is not connected
RPC:     2 xprt_connect xprt c080bc00 is not connected
RPC:     2 sleep_on(queue "xprt_pending" time 4294924982)
RPC:     2 added to queue c080bdac "xprt_pending"
RPC:     2 setting alarm for 60000 ms
RPC:       xs_connect scheduled xprt c080bc00
RPC:     2 sync task going to sleep
RPC:       xs_bind4 0.0.0.0:1006: ok (0)
RPC:       worker connecting xprt c080bc00 via tcp to 127.0.0.1 (port 111)
RPC:       xs_tcp_state_change client c080bc00...
RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
RPC:     2 __rpc_wake_up_task (now 4294924994)
RPC:     2 disabling timer
RPC:     2 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:     2 sync task resuming
RPC:     2 xprt_connect_status: retrying
RPC:     2 call_connect_status (status -11)
RPC:     2 call_transmit (status 0)
RPC:     2 xprt_prepare_transmit
RPC:     2 rpc_xdr_encode (status 0)
RPC:     2 marshaling NULL cred c0335c98
RPC:     2 using AUTH_NULL cred c0335c98 to wrap rpc data
RPC:     2 xprt_transmit(44)
RPC:       c080bc00 connect status 115 connected 1 sock state 1
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 32
RPC:       reading XID (4 bytes)
RPC:       reading request with XID 562efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 562efd36
RPC:       XID 562efd36 read 24 bytes
RPC:       xprt = c080bc00, tcp_copied = 32, tcp_offset = 32, tcp_reclen = 32
RPC:     2 xid 562efd36 complete (32 bytes received)
RPC:       xs_tcp_data_recv done
RPC:       xs_tcp_send_request(44) = 44
RPC:     2 xmit complete
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     2 call_status (status 32)
RPC:     2 call_decode (status 32)
RPC:     2 validating NULL cred c0335c98
RPC:     2 rpc_verify_header: program 100000, version 4 unsupported by server localhost
RPC:     2 rpc_verify_header: call failed with error -93
RPC:     2 return 0, status -93
RPC:     2 release task
RPC:       freeing buffer of size 92 at c0811800
RPC:     2 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f324a0)
RPC:     2 freeing task
RPC:       shutting down rpcbind client for localhost
RPC:       rpc_release_client(c6f324a0)
RPC:       destroying rpcbind client for localhost
RPC:       rpc_release_client(c6f323a0)
RPC:       failed to create local rpcbind v4 cleint (errno -93).
RPC:       unregistering (100021, 1, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     3 __rpc_execute flags=0x680
RPC:     3 call_start rpcbind2 proc UNSET (sync)
RPC:     3 call_reserve (status 0)
RPC:     3 reserved req c0812000 xid 572efd36
RPC:     3 call_reserveresult (status 0)
RPC:     3 call_refresh (status 0)
RPC:     3 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:       allocating UNIX cred for uid 0 gid 0
RPC:     3 refreshing UNIX cred c6fb7d60
RPC:     3 call_refreshresult (status 0)
RPC:     3 call_allocate (status 0)
RPC:     3 allocated buffer of size 412 at c0811800
RPC:     3 call_bind (status 0)
RPC:     3 call_connect xprt c080bc00 is connected
RPC:     3 call_transmit (status 0)
RPC:     3 xprt_prepare_transmit
RPC:     3 rpc_xdr_encode (status 0)
RPC:     3 marshaling UNIX cred c6fb7d60
RPC:     3 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     3 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     3 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     3 xmit complete
RPC:     3 sleep_on(queue "xprt_pending" time 4294925115)
RPC:     3 added to queue c080bdac "xprt_pending"
RPC:     3 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     3 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20

BIG endian MB gets length 28.

RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 572efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 572efd36
RPC:       XID 572efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     3 xid 572efd36 complete (20 bytes received)
RPC:     3 __rpc_wake_up_task (now 4294925146)
RPC:     3 disabling timer
RPC:     3 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     3 sync task resuming
RPC:     3 call_status (status 20)
RPC:     3 call_decode (status 20)

BADCRED here from rpc_verify_header


RPC:     3 rpc_verify_header: retry garbled creds
RPC:     3 call_bind (status 0)
RPC:     3 call_connect xprt c080bc00 is connected
RPC:     3 call_transmit (status 0)
RPC:     3 xprt_prepare_transmit
RPC:     3 rpc_xdr_encode (status 0)
RPC:     3 marshaling UNIX cred c6fb7d60
RPC:     3 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     3 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     3 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     3 xmit complete
RPC:     3 sleep_on(queue "xprt_pending" time 4294925182)
RPC:     3 added to queue c080bdac "xprt_pending"
RPC:     3 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     3 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 572efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 572efd36
RPC:       XID 572efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     3 xid 572efd36 complete (20 bytes received)
RPC:     3 __rpc_wake_up_task (now 4294925214)
RPC:     3 disabling timer
RPC:     3 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     3 sync task resuming
RPC:     3 call_status (status 20)
RPC:     3 call_decode (status 20)
RPC:     3 rpc_verify_header: retry garbled creds
RPC:     3 call_bind (status 0)
RPC:     3 call_connect xprt c080bc00 is connected
RPC:     3 call_transmit (status 0)
RPC:     3 xprt_prepare_transmit
RPC:     3 rpc_xdr_encode (status 0)
RPC:     3 marshaling UNIX cred c6fb7d60
RPC:     3 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     3 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     3 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     3 xmit complete
RPC:     3 sleep_on(queue "xprt_pending" time 4294925250)
RPC:     3 added to queue c080bdac "xprt_pending"
RPC:     3 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     3 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 572efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 572efd36
RPC:       XID 572efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     3 xid 572efd36 complete (20 bytes received)
RPC:     3 __rpc_wake_up_task (now 4294925281)
RPC:     3 disabling timer
RPC:     3 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     3 sync task resuming
RPC:     3 call_status (status 20)
RPC:     3 call_decode (status 20)
RPC:     3 rpc_verify_header: call rejected 1
RPC:     3 rpc_verify_header: call failed with error -13
RPC:     3 return 0, status -13
RPC:     3 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     3 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     3 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 3, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     4 __rpc_execute flags=0x680
RPC:     4 call_start rpcbind2 proc UNSET (sync)
RPC:     4 call_reserve (status 0)
RPC:     4 reserved req c0812000 xid 582efd36
RPC:     4 call_reserveresult (status 0)
RPC:     4 call_refresh (status 0)
RPC:     4 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     4 refreshing UNIX cred c6fb7d60
RPC:     4 call_refreshresult (status 0)
RPC:     4 call_allocate (status 0)
RPC:     4 allocated buffer of size 412 at c0811800
RPC:     4 call_bind (status 0)
RPC:     4 call_connect xprt c080bc00 is connected
RPC:     4 call_transmit (status 0)
RPC:     4 xprt_prepare_transmit
RPC:     4 rpc_xdr_encode (status 0)
RPC:     4 marshaling UNIX cred c6fb7d60
RPC:     4 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     4 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     4 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     4 xmit complete
RPC:     4 sleep_on(queue "xprt_pending" time 4294925356)
RPC:     4 added to queue c080bdac "xprt_pending"
RPC:     4 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     4 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 582efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 582efd36
RPC:       XID 582efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     4 xid 582efd36 complete (20 bytes received)
RPC:     4 __rpc_wake_up_task (now 4294925387)
RPC:     4 disabling timer
RPC:     4 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     4 sync task resuming
RPC:     4 call_status (status 20)
RPC:     4 call_decode (status 20)
RPC:     4 rpc_verify_header: retry garbled creds
RPC:     4 call_bind (status 0)
RPC:     4 call_connect xprt c080bc00 is connected
RPC:     4 call_transmit (status 0)
RPC:     4 xprt_prepare_transmit
RPC:     4 rpc_xdr_encode (status 0)
RPC:     4 marshaling UNIX cred c6fb7d60
RPC:     4 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     4 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     4 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     4 xmit complete
RPC:     4 sleep_on(queue "xprt_pending" time 4294925424)
RPC:     4 added to queue c080bdac "xprt_pending"
RPC:     4 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     4 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 582efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 582efd36
RPC:       XID 582efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     4 xid 582efd36 complete (20 bytes received)
RPC:     4 __rpc_wake_up_task (now 4294925455)
RPC:     4 disabling timer
RPC:     4 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     4 sync task resuming
RPC:     4 call_status (status 20)
RPC:     4 call_decode (status 20)
RPC:     4 rpc_verify_header: retry garbled creds
RPC:     4 call_bind (status 0)
RPC:     4 call_connect xprt c080bc00 is connected
RPC:     4 call_transmit (status 0)
RPC:     4 xprt_prepare_transmit
RPC:     4 rpc_xdr_encode (status 0)
RPC:     4 marshaling UNIX cred c6fb7d60
RPC:     4 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     4 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     4 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     4 xmit complete
RPC:     4 sleep_on(queue "xprt_pending" time 4294925491)
RPC:     4 added to queue c080bdac "xprt_pending"
RPC:     4 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     4 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 582efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 582efd36
RPC:       XID 582efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     4 xid 582efd36 complete (20 bytes received)
RPC:     4 __rpc_wake_up_task (now 4294925522)
RPC:     4 disabling timer
RPC:     4 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     4 sync task resuming
RPC:     4 call_status (status 20)
RPC:     4 call_decode (status 20)
RPC:     4 rpc_verify_header: call rejected 1
RPC:     4 rpc_verify_header: call failed with error -13
RPC:     4 return 0, status -13
RPC:     4 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     4 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     4 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 4, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     5 __rpc_execute flags=0x680
RPC:     5 call_start rpcbind2 proc UNSET (sync)
RPC:     5 call_reserve (status 0)
RPC:     5 reserved req c0812000 xid 592efd36
RPC:     5 call_reserveresult (status 0)
RPC:     5 call_refresh (status 0)
RPC:     5 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     5 refreshing UNIX cred c6fb7d60
RPC:     5 call_refreshresult (status 0)
RPC:     5 call_allocate (status 0)
RPC:     5 allocated buffer of size 412 at c0811800
RPC:     5 call_bind (status 0)
RPC:     5 call_connect xprt c080bc00 is connected
RPC:     5 call_transmit (status 0)
RPC:     5 xprt_prepare_transmit
RPC:     5 rpc_xdr_encode (status 0)
RPC:     5 marshaling UNIX cred c6fb7d60
RPC:     5 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     5 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     5 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     5 xmit complete
RPC:     5 sleep_on(queue "xprt_pending" time 4294925597)
RPC:     5 added to queue c080bdac "xprt_pending"
RPC:     5 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     5 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 592efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 592efd36
RPC:       XID 592efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     5 xid 592efd36 complete (20 bytes received)
RPC:     5 __rpc_wake_up_task (now 4294925629)
RPC:     5 disabling timer
RPC:     5 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     5 sync task resuming
RPC:     5 call_status (status 20)
RPC:     5 call_decode (status 20)
RPC:     5 rpc_verify_header: retry garbled creds
RPC:     5 call_bind (status 0)
RPC:     5 call_connect xprt c080bc00 is connected
RPC:     5 call_transmit (status 0)
RPC:     5 xprt_prepare_transmit
RPC:     5 rpc_xdr_encode (status 0)
RPC:     5 marshaling UNIX cred c6fb7d60
RPC:     5 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     5 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     5 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     5 xmit complete
RPC:     5 sleep_on(queue "xprt_pending" time 4294925665)
RPC:     5 added to queue c080bdac "xprt_pending"
RPC:     5 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     5 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 592efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 592efd36
RPC:       XID 592efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     5 xid 592efd36 complete (20 bytes received)
RPC:     5 __rpc_wake_up_task (now 4294925696)
RPC:     5 disabling timer
RPC:     5 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     5 sync task resuming
RPC:     5 call_status (status 20)
RPC:     5 call_decode (status 20)
RPC:     5 rpc_verify_header: retry garbled creds
RPC:     5 call_bind (status 0)
RPC:     5 call_connect xprt c080bc00 is connected
RPC:     5 call_transmit (status 0)
RPC:     5 xprt_prepare_transmit
RPC:     5 rpc_xdr_encode (status 0)
RPC:     5 marshaling UNIX cred c6fb7d60
RPC:     5 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     5 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     5 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     5 xmit complete
RPC:     5 sleep_on(queue "xprt_pending" time 4294925732)
RPC:     5 added to queue c080bdac "xprt_pending"
RPC:     5 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     5 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 592efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 592efd36
RPC:       XID 592efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     5 xid 592efd36 complete (20 bytes received)
RPC:     5 __rpc_wake_up_task (now 4294925763)
RPC:     5 disabling timer
RPC:     5 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     5 sync task resuming
RPC:     5 call_status (status 20)
RPC:     5 call_decode (status 20)
RPC:     5 rpc_verify_header: call rejected 1
RPC:     5 rpc_verify_header: call failed with error -13
RPC:     5 return 0, status -13
RPC:     5 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     5 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     5 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       registering (100021, 1, 17, 54688) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     6 __rpc_execute flags=0x680
RPC:     6 call_start rpcbind2 proc SET (sync)
RPC:     6 call_reserve (status 0)
RPC:     6 reserved req c0812000 xid 5a2efd36
RPC:     6 call_reserveresult (status 0)
RPC:     6 call_refresh (status 0)
RPC:     6 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     6 refreshing UNIX cred c6fb7d60
RPC:     6 call_refreshresult (status 0)
RPC:     6 call_allocate (status 0)
RPC:     6 allocated buffer of size 412 at c0811800
RPC:     6 call_bind (status 0)
RPC:     6 call_connect xprt c080bc00 is connected
RPC:     6 call_transmit (status 0)
RPC:     6 xprt_prepare_transmit
RPC:     6 rpc_xdr_encode (status 0)
RPC:     6 marshaling UNIX cred c6fb7d60
RPC:     6 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     6 encoding PMAP_SET call (100021, 1, 17, 54688)
RPC:     6 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     6 xmit complete
RPC:     6 sleep_on(queue "xprt_pending" time 4294925843)
RPC:     6 added to queue c080bdac "xprt_pending"
RPC:     6 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     6 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5a2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5a2efd36
RPC:       XID 5a2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     6 xid 5a2efd36 complete (20 bytes received)
RPC:     6 __rpc_wake_up_task (now 4294925874)
RPC:     6 disabling timer
RPC:     6 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     6 sync task resuming
RPC:     6 call_status (status 20)
RPC:     6 call_decode (status 20)
RPC:     6 rpc_verify_header: retry garbled creds
RPC:     6 call_bind (status 0)
RPC:     6 call_connect xprt c080bc00 is connected
RPC:     6 call_transmit (status 0)
RPC:     6 xprt_prepare_transmit
RPC:     6 rpc_xdr_encode (status 0)
RPC:     6 marshaling UNIX cred c6fb7d60
RPC:     6 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     6 encoding PMAP_SET call (100021, 1, 17, 54688)
RPC:     6 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     6 xmit complete
RPC:     6 sleep_on(queue "xprt_pending" time 4294925910)
RPC:     6 added to queue c080bdac "xprt_pending"
RPC:     6 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     6 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5a2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5a2efd36
RPC:       XID 5a2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     6 xid 5a2efd36 complete (20 bytes received)
RPC:     6 __rpc_wake_up_task (now 4294925941)
RPC:     6 disabling timer
RPC:     6 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     6 sync task resuming
RPC:     6 call_status (status 20)
RPC:     6 call_decode (status 20)
RPC:     6 rpc_verify_header: retry garbled creds
RPC:     6 call_bind (status 0)
RPC:     6 call_connect xprt c080bc00 is connected
RPC:     6 call_transmit (status 0)
RPC:     6 xprt_prepare_transmit
RPC:     6 rpc_xdr_encode (status 0)
RPC:     6 marshaling UNIX cred c6fb7d60
RPC:     6 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     6 encoding PMAP_SET call (100021, 1, 17, 54688)
RPC:     6 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     6 xmit complete
RPC:     6 sleep_on(queue "xprt_pending" time 4294925977)
RPC:     6 added to queue c080bdac "xprt_pending"
RPC:     6 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     6 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5a2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5a2efd36
RPC:       XID 5a2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     6 xid 5a2efd36 complete (20 bytes received)
RPC:     6 __rpc_wake_up_task (now 4294926008)
RPC:     6 disabling timer
RPC:     6 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     6 sync task resuming
RPC:     6 call_status (status 20)
RPC:     6 call_decode (status 20)
RPC:     6 rpc_verify_header: call rejected 1
RPC:     6 rpc_verify_header: call failed with error -13
RPC:     6 return 0, status -13
RPC:     6 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     6 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     6 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
svc: failed to register lockdv1 RPC service (errno 13).
RPC:       unregistering (100021, 1, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     7 __rpc_execute flags=0x680
RPC:     7 call_start rpcbind2 proc UNSET (sync)
RPC:     7 call_reserve (status 0)
RPC:     7 reserved req c0812000 xid 5b2efd36
RPC:     7 call_reserveresult (status 0)
RPC:     7 call_refresh (status 0)
RPC:     7 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     7 refreshing UNIX cred c6fb7d60
RPC:     7 call_refreshresult (status 0)
RPC:     7 call_allocate (status 0)
RPC:     7 allocated buffer of size 412 at c0811800
RPC:     7 call_bind (status 0)
RPC:     7 call_connect xprt c080bc00 is connected
RPC:     7 call_transmit (status 0)
RPC:     7 xprt_prepare_transmit
RPC:     7 rpc_xdr_encode (status 0)
RPC:     7 marshaling UNIX cred c6fb7d60
RPC:     7 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     7 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     7 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     7 xmit complete
RPC:     7 sleep_on(queue "xprt_pending" time 4294926087)
RPC:     7 added to queue c080bdac "xprt_pending"
RPC:     7 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     7 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5b2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5b2efd36
RPC:       XID 5b2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     7 xid 5b2efd36 complete (20 bytes received)
RPC:     7 __rpc_wake_up_task (now 4294926118)
RPC:     7 disabling timer
RPC:     7 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     7 sync task resuming
RPC:     7 call_status (status 20)
RPC:     7 call_decode (status 20)
RPC:     7 rpc_verify_header: retry garbled creds
RPC:     7 call_bind (status 0)
RPC:     7 call_connect xprt c080bc00 is connected
RPC:     7 call_transmit (status 0)
RPC:     7 xprt_prepare_transmit
RPC:     7 rpc_xdr_encode (status 0)
RPC:     7 marshaling UNIX cred c6fb7d60
RPC:     7 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     7 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     7 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     7 xmit complete
RPC:     7 sleep_on(queue "xprt_pending" time 4294926154)
RPC:     7 added to queue c080bdac "xprt_pending"
RPC:     7 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     7 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5b2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5b2efd36
RPC:       XID 5b2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     7 xid 5b2efd36 complete (20 bytes received)
RPC:     7 __rpc_wake_up_task (now 4294926185)
RPC:     7 disabling timer
RPC:     7 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     7 sync task resuming
RPC:     7 call_status (status 20)
RPC:     7 call_decode (status 20)
RPC:     7 rpc_verify_header: retry garbled creds
RPC:     7 call_bind (status 0)
RPC:     7 call_connect xprt c080bc00 is connected
RPC:     7 call_transmit (status 0)
RPC:     7 xprt_prepare_transmit
RPC:     7 rpc_xdr_encode (status 0)
RPC:     7 marshaling UNIX cred c6fb7d60
RPC:     7 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     7 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:     7 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     7 xmit complete
RPC:     7 sleep_on(queue "xprt_pending" time 4294926221)
RPC:     7 added to queue c080bdac "xprt_pending"
RPC:     7 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     7 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5b2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5b2efd36
RPC:       XID 5b2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     7 xid 5b2efd36 complete (20 bytes received)
RPC:     7 __rpc_wake_up_task (now 4294926252)
RPC:     7 disabling timer
RPC:     7 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     7 sync task resuming
RPC:     7 call_status (status 20)
RPC:     7 call_decode (status 20)
RPC:     7 rpc_verify_header: call rejected 1
RPC:     7 rpc_verify_header: call failed with error -13
RPC:     7 return 0, status -13
RPC:     7 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     7 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     7 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 3, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     8 __rpc_execute flags=0x680
RPC:     8 call_start rpcbind2 proc UNSET (sync)
RPC:     8 call_reserve (status 0)
RPC:     8 reserved req c0812000 xid 5c2efd36
RPC:     8 call_reserveresult (status 0)
RPC:     8 call_refresh (status 0)
RPC:     8 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     8 refreshing UNIX cred c6fb7d60
RPC:     8 call_refreshresult (status 0)
RPC:     8 call_allocate (status 0)
RPC:     8 allocated buffer of size 412 at c0811800
RPC:     8 call_bind (status 0)
RPC:     8 call_connect xprt c080bc00 is connected
RPC:     8 call_transmit (status 0)
RPC:     8 xprt_prepare_transmit
RPC:     8 rpc_xdr_encode (status 0)
RPC:     8 marshaling UNIX cred c6fb7d60
RPC:     8 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     8 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     8 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     8 xmit complete
RPC:     8 sleep_on(queue "xprt_pending" time 4294926327)
RPC:     8 added to queue c080bdac "xprt_pending"
RPC:     8 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     8 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5c2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5c2efd36
RPC:       XID 5c2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     8 xid 5c2efd36 complete (20 bytes received)
RPC:     8 __rpc_wake_up_task (now 4294926359)
RPC:     8 disabling timer
RPC:     8 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     8 sync task resuming
RPC:     8 call_status (status 20)
RPC:     8 call_decode (status 20)
RPC:     8 rpc_verify_header: retry garbled creds
RPC:     8 call_bind (status 0)
RPC:     8 call_connect xprt c080bc00 is connected
RPC:     8 call_transmit (status 0)
RPC:     8 xprt_prepare_transmit
RPC:     8 rpc_xdr_encode (status 0)
RPC:     8 marshaling UNIX cred c6fb7d60
RPC:     8 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     8 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     8 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     8 xmit complete
RPC:     8 sleep_on(queue "xprt_pending" time 4294926396)
RPC:     8 added to queue c080bdac "xprt_pending"
RPC:     8 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     8 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5c2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5c2efd36
RPC:       XID 5c2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     8 xid 5c2efd36 complete (20 bytes received)
RPC:     8 __rpc_wake_up_task (now 4294926427)
RPC:     8 disabling timer
RPC:     8 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     8 sync task resuming
RPC:     8 call_status (status 20)
RPC:     8 call_decode (status 20)
RPC:     8 rpc_verify_header: retry garbled creds
RPC:     8 call_bind (status 0)
RPC:     8 call_connect xprt c080bc00 is connected
RPC:     8 call_transmit (status 0)
RPC:     8 xprt_prepare_transmit
RPC:     8 rpc_xdr_encode (status 0)
RPC:     8 marshaling UNIX cred c6fb7d60
RPC:     8 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     8 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:     8 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     8 xmit complete
RPC:     8 sleep_on(queue "xprt_pending" time 4294926463)
RPC:     8 added to queue c080bdac "xprt_pending"
RPC:     8 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     8 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5c2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5c2efd36
RPC:       XID 5c2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     8 xid 5c2efd36 complete (20 bytes received)
RPC:     8 __rpc_wake_up_task (now 4294926494)
RPC:     8 disabling timer
RPC:     8 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     8 sync task resuming
RPC:     8 call_status (status 20)
RPC:     8 call_decode (status 20)
RPC:     8 rpc_verify_header: call rejected 1
RPC:     8 rpc_verify_header: call failed with error -13
RPC:     8 return 0, status -13
RPC:     8 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     8 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     8 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 4, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:     9 __rpc_execute flags=0x680
RPC:     9 call_start rpcbind2 proc UNSET (sync)
RPC:     9 call_reserve (status 0)
RPC:     9 reserved req c0812000 xid 5d2efd36
RPC:     9 call_reserveresult (status 0)
RPC:     9 call_refresh (status 0)
RPC:     9 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:     9 refreshing UNIX cred c6fb7d60
RPC:     9 call_refreshresult (status 0)
RPC:     9 call_allocate (status 0)
RPC:     9 allocated buffer of size 412 at c0811800
RPC:     9 call_bind (status 0)
RPC:     9 call_connect xprt c080bc00 is connected
RPC:     9 call_transmit (status 0)
RPC:     9 xprt_prepare_transmit
RPC:     9 rpc_xdr_encode (status 0)
RPC:     9 marshaling UNIX cred c6fb7d60
RPC:     9 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     9 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     9 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     9 xmit complete
RPC:     9 sleep_on(queue "xprt_pending" time 4294926569)
RPC:     9 added to queue c080bdac "xprt_pending"
RPC:     9 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     9 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5d2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5d2efd36
RPC:       XID 5d2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     9 xid 5d2efd36 complete (20 bytes received)
RPC:     9 __rpc_wake_up_task (now 4294926600)
RPC:     9 disabling timer
RPC:     9 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     9 sync task resuming
RPC:     9 call_status (status 20)
RPC:     9 call_decode (status 20)
RPC:     9 rpc_verify_header: retry garbled creds
RPC:     9 call_bind (status 0)
RPC:     9 call_connect xprt c080bc00 is connected
RPC:     9 call_transmit (status 0)
RPC:     9 xprt_prepare_transmit
RPC:     9 rpc_xdr_encode (status 0)
RPC:     9 marshaling UNIX cred c6fb7d60
RPC:     9 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     9 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     9 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     9 xmit complete
RPC:     9 sleep_on(queue "xprt_pending" time 4294926637)
RPC:     9 added to queue c080bdac "xprt_pending"
RPC:     9 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     9 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5d2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5d2efd36
RPC:       XID 5d2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     9 xid 5d2efd36 complete (20 bytes received)
RPC:     9 __rpc_wake_up_task (now 4294926668)
RPC:     9 disabling timer
RPC:     9 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     9 sync task resuming
RPC:     9 call_status (status 20)
RPC:     9 call_decode (status 20)
RPC:     9 rpc_verify_header: retry garbled creds
RPC:     9 call_bind (status 0)
RPC:     9 call_connect xprt c080bc00 is connected
RPC:     9 call_transmit (status 0)
RPC:     9 xprt_prepare_transmit
RPC:     9 rpc_xdr_encode (status 0)
RPC:     9 marshaling UNIX cred c6fb7d60
RPC:     9 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:     9 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:     9 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:     9 xmit complete
RPC:     9 sleep_on(queue "xprt_pending" time 4294926704)
RPC:     9 added to queue c080bdac "xprt_pending"
RPC:     9 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:     9 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5d2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5d2efd36
RPC:       XID 5d2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:     9 xid 5d2efd36 complete (20 bytes received)
RPC:     9 __rpc_wake_up_task (now 4294926735)
RPC:     9 disabling timer
RPC:     9 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:     9 sync task resuming
RPC:     9 call_status (status 20)
RPC:     9 call_decode (status 20)
RPC:     9 rpc_verify_header: call rejected 1
RPC:     9 rpc_verify_header: call failed with error -13
RPC:     9 return 0, status -13
RPC:     9 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:     9 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:     9 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       shutting down nfs client for 192.168.0.101
RPC:       rpc_release_client(c6f322a0)
RPC:       destroying nfs client for 192.168.0.101
RPC:       destroying transport c6fac400
RPC:       xs_destroy xprt c6fac400
RPC:       xs_close xprt c6fac400
RPC:       disconnected transport c6fac400
RPC:       looking up machine cred
RPC:       set up xprt to 192.168.0.101 (port 2049) via udp
RPC:       created transport c6fac400 with 16 slots
RPC:       creating nfs client for 192.168.0.101 (xprt c6fac400)
RPC:       creating UNIX authenticator for client c6f322a0
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    10 __rpc_execute flags=0x680
RPC:    10 call_start nfs3 proc NULL (sync)
RPC:    10 call_reserve (status 0)
RPC:    10 reserved req c0810000 xid 356611d2
RPC:    10 call_reserveresult (status 0)
RPC:    10 call_refresh (status 0)
RPC:    10 holding NULL cred c0335c98
RPC:    10 refreshing NULL cred c0335c98
RPC:    10 call_refreshresult (status 0)
RPC:    10 call_allocate (status 0)
RPC:    10 allocated buffer of size 92 at c0811800
RPC:    10 call_bind (status 0)
RPC:    10 call_connect xprt c6fac400 is not connected
RPC:    10 xprt_connect xprt c6fac400 is not connected
RPC:    10 xprt_cwnd_limited cong = 0 cwnd = 256
RPC:    10 sleep_on(queue "xprt_pending" time 4294926824)
RPC:    10 added to queue c6fac5ac "xprt_pending"
RPC:    10 setting alarm for 700 ms
RPC:       xs_connect scheduled xprt c6fac400
RPC:    10 sync task going to sleep
RPC:       xs_bind4 0.0.0.0:950: ok (0)
RPC:       worker connecting xprt c6fac400 via udp to 192.168.0.101 (port 2049)
RPC:    10 __rpc_wake_up_task (now 4294926832)
RPC:    10 disabling timer
RPC:    10 removed from queue c6fac5ac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:    10 sync task resuming
RPC:    10 xprt_connect_status: connection established
RPC:    10 call_connect_status (status 0)
RPC:    10 call_transmit (status 0)
RPC:    10 xprt_prepare_transmit
RPC:    10 rpc_xdr_encode (status 0)
RPC:    10 marshaling NULL cred c0335c98
RPC:    10 using AUTH_NULL cred c0335c98 to wrap rpc data
RPC:    10 xprt_transmit(40)
RPC:       xs_udp_data_ready...
RPC:       cong 256, cwnd was 256, now 512
RPC:    10 xid 356611d2 complete (24 bytes received)
RPC:       xs_udp_send_request(40) = 40
RPC:    10 xmit complete
RPC:       wake_up_next(c6fac554 "xprt_resend")
RPC:       wake_up_next(c6fac4fc "xprt_sending")
RPC:    10 call_status (status 24)
RPC:    10 call_decode (status 24)
RPC:    10 validating NULL cred c0335c98
RPC:    10 using AUTH_NULL cred c0335c98 to unwrap rpc data
RPC:    10 call_decode result 0
RPC:    10 return 0, status 0
RPC:    10 release task
RPC:       freeing buffer of size 92 at c0811800
RPC:    10 release request c0810000
RPC:       wake_up_next(c6fac604 "xprt_backlog")
RPC:       rpc_release_client(c6f322a0)
RPC:    10 freeing task
RPC:       unregistering (100021, 1, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    11 __rpc_execute flags=0x680
RPC:    11 call_start rpcbind2 proc UNSET (sync)
RPC:    11 call_reserve (status 0)
RPC:    11 reserved req c0812000 xid 5e2efd36
RPC:    11 call_reserveresult (status 0)
RPC:    11 call_refresh (status 0)
RPC:    11 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    11 refreshing UNIX cred c6fb7d60
RPC:    11 call_refreshresult (status 0)
RPC:    11 call_allocate (status 0)
RPC:    11 allocated buffer of size 412 at c0811800
RPC:    11 call_bind (status 0)
RPC:    11 call_connect xprt c080bc00 is connected
RPC:    11 call_transmit (status 0)
RPC:    11 xprt_prepare_transmit
RPC:    11 rpc_xdr_encode (status 0)
RPC:    11 marshaling UNIX cred c6fb7d60
RPC:    11 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    11 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    11 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    11 xmit complete
RPC:    11 sleep_on(queue "xprt_pending" time 4294926916)
RPC:    11 added to queue c080bdac "xprt_pending"
RPC:    11 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    11 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5e2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5e2efd36
RPC:       XID 5e2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    11 xid 5e2efd36 complete (20 bytes received)
RPC:    11 __rpc_wake_up_task (now 4294926947)
RPC:    11 disabling timer
RPC:    11 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    11 sync task resuming
RPC:    11 call_status (status 20)
RPC:    11 call_decode (status 20)
RPC:    11 rpc_verify_header: retry garbled creds
RPC:    11 call_bind (status 0)
RPC:    11 call_connect xprt c080bc00 is connected
RPC:    11 call_transmit (status 0)
RPC:    11 xprt_prepare_transmit
RPC:    11 rpc_xdr_encode (status 0)
RPC:    11 marshaling UNIX cred c6fb7d60
RPC:    11 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    11 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    11 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    11 xmit complete
RPC:    11 sleep_on(queue "xprt_pending" time 4294926983)
RPC:    11 added to queue c080bdac "xprt_pending"
RPC:    11 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    11 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5e2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5e2efd36
RPC:       XID 5e2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    11 xid 5e2efd36 complete (20 bytes received)
RPC:    11 __rpc_wake_up_task (now 4294927014)
RPC:    11 disabling timer
RPC:    11 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    11 sync task resuming
RPC:    11 call_status (status 20)
RPC:    11 call_decode (status 20)
RPC:    11 rpc_verify_header: retry garbled creds
RPC:    11 call_bind (status 0)
RPC:    11 call_connect xprt c080bc00 is connected
RPC:    11 call_transmit (status 0)
RPC:    11 xprt_prepare_transmit
RPC:    11 rpc_xdr_encode (status 0)
RPC:    11 marshaling UNIX cred c6fb7d60
RPC:    11 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    11 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    11 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    11 xmit complete
RPC:    11 sleep_on(queue "xprt_pending" time 4294927050)
RPC:    11 added to queue c080bdac "xprt_pending"
RPC:    11 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    11 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5e2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5e2efd36
RPC:       XID 5e2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    11 xid 5e2efd36 complete (20 bytes received)
RPC:    11 __rpc_wake_up_task (now 4294927081)
RPC:    11 disabling timer
RPC:    11 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    11 sync task resuming
RPC:    11 call_status (status 20)
RPC:    11 call_decode (status 20)
RPC:    11 rpc_verify_header: call rejected 1
RPC:    11 rpc_verify_header: call failed with error -13
RPC:    11 return 0, status -13
RPC:    11 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    11 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    11 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 3, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    12 __rpc_execute flags=0x680
RPC:    12 call_start rpcbind2 proc UNSET (sync)
RPC:    12 call_reserve (status 0)
RPC:    12 reserved req c0812000 xid 5f2efd36
RPC:    12 call_reserveresult (status 0)
RPC:    12 call_refresh (status 0)
RPC:    12 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    12 refreshing UNIX cred c6fb7d60
RPC:    12 call_refreshresult (status 0)
RPC:    12 call_allocate (status 0)
RPC:    12 allocated buffer of size 412 at c0811800
RPC:    12 call_bind (status 0)
RPC:    12 call_connect xprt c080bc00 is connected
RPC:    12 call_transmit (status 0)
RPC:    12 xprt_prepare_transmit
RPC:    12 rpc_xdr_encode (status 0)
RPC:    12 marshaling UNIX cred c6fb7d60
RPC:    12 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    12 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    12 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    12 xmit complete
RPC:    12 sleep_on(queue "xprt_pending" time 4294927157)
RPC:    12 added to queue c080bdac "xprt_pending"
RPC:    12 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    12 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5f2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5f2efd36
RPC:       XID 5f2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    12 xid 5f2efd36 complete (20 bytes received)
RPC:    12 __rpc_wake_up_task (now 4294927188)
RPC:    12 disabling timer
RPC:    12 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    12 sync task resuming
RPC:    12 call_status (status 20)
RPC:    12 call_decode (status 20)
RPC:    12 rpc_verify_header: retry garbled creds
RPC:    12 call_bind (status 0)
RPC:    12 call_connect xprt c080bc00 is connected
RPC:    12 call_transmit (status 0)
RPC:    12 xprt_prepare_transmit
RPC:    12 rpc_xdr_encode (status 0)
RPC:    12 marshaling UNIX cred c6fb7d60
RPC:    12 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    12 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    12 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    12 xmit complete
RPC:    12 sleep_on(queue "xprt_pending" time 4294927224)
RPC:    12 added to queue c080bdac "xprt_pending"
RPC:    12 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    12 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5f2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5f2efd36
RPC:       XID 5f2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    12 xid 5f2efd36 complete (20 bytes received)
RPC:    12 __rpc_wake_up_task (now 4294927255)
RPC:    12 disabling timer
RPC:    12 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    12 sync task resuming
RPC:    12 call_status (status 20)
RPC:    12 call_decode (status 20)
RPC:    12 rpc_verify_header: retry garbled creds
RPC:    12 call_bind (status 0)
RPC:    12 call_connect xprt c080bc00 is connected
RPC:    12 call_transmit (status 0)
RPC:    12 xprt_prepare_transmit
RPC:    12 rpc_xdr_encode (status 0)
RPC:    12 marshaling UNIX cred c6fb7d60
RPC:    12 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    12 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    12 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    12 xmit complete
RPC:    12 sleep_on(queue "xprt_pending" time 4294927291)
RPC:    12 added to queue c080bdac "xprt_pending"
RPC:    12 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    12 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 5f2efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 5f2efd36
RPC:       XID 5f2efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    12 xid 5f2efd36 complete (20 bytes received)
RPC:    12 __rpc_wake_up_task (now 4294927322)
RPC:    12 disabling timer
RPC:    12 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    12 sync task resuming
RPC:    12 call_status (status 20)
RPC:    12 call_decode (status 20)
RPC:    12 rpc_verify_header: call rejected 1
RPC:    12 rpc_verify_header: call failed with error -13
RPC:    12 return 0, status -13
RPC:    12 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    12 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    12 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 4, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    13 __rpc_execute flags=0x680
RPC:    13 call_start rpcbind2 proc UNSET (sync)
RPC:    13 call_reserve (status 0)
RPC:    13 reserved req c0812000 xid 602efd36
RPC:    13 call_reserveresult (status 0)
RPC:    13 call_refresh (status 0)
RPC:    13 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    13 refreshing UNIX cred c6fb7d60
RPC:    13 call_refreshresult (status 0)
RPC:    13 call_allocate (status 0)
RPC:    13 allocated buffer of size 412 at c0811800
RPC:    13 call_bind (status 0)
RPC:    13 call_connect xprt c080bc00 is connected
RPC:    13 call_transmit (status 0)
RPC:    13 xprt_prepare_transmit
RPC:    13 rpc_xdr_encode (status 0)
RPC:    13 marshaling UNIX cred c6fb7d60
RPC:    13 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    13 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    13 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    13 xmit complete
RPC:    13 sleep_on(queue "xprt_pending" time 4294927398)
RPC:    13 added to queue c080bdac "xprt_pending"
RPC:    13 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    13 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 602efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 602efd36
RPC:       XID 602efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    13 xid 602efd36 complete (20 bytes received)
RPC:    13 __rpc_wake_up_task (now 4294927429)
RPC:    13 disabling timer
RPC:    13 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    13 sync task resuming
RPC:    13 call_status (status 20)
RPC:    13 call_decode (status 20)
RPC:    13 rpc_verify_header: retry garbled creds
RPC:    13 call_bind (status 0)
RPC:    13 call_connect xprt c080bc00 is connected
RPC:    13 call_transmit (status 0)
RPC:    13 xprt_prepare_transmit
RPC:    13 rpc_xdr_encode (status 0)
RPC:    13 marshaling UNIX cred c6fb7d60
RPC:    13 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    13 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    13 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    13 xmit complete
RPC:    13 sleep_on(queue "xprt_pending" time 4294927465)
RPC:    13 added to queue c080bdac "xprt_pending"
RPC:    13 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    13 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 602efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 602efd36
RPC:       XID 602efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    13 xid 602efd36 complete (20 bytes received)
RPC:    13 __rpc_wake_up_task (now 4294927496)
RPC:    13 disabling timer
RPC:    13 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    13 sync task resuming
RPC:    13 call_status (status 20)
RPC:    13 call_decode (status 20)
RPC:    13 rpc_verify_header: retry garbled creds
RPC:    13 call_bind (status 0)
RPC:    13 call_connect xprt c080bc00 is connected
RPC:    13 call_transmit (status 0)
RPC:    13 xprt_prepare_transmit
RPC:    13 rpc_xdr_encode (status 0)
RPC:    13 marshaling UNIX cred c6fb7d60
RPC:    13 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    13 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    13 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    13 xmit complete
RPC:    13 sleep_on(queue "xprt_pending" time 4294927532)
RPC:    13 added to queue c080bdac "xprt_pending"
RPC:    13 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    13 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 602efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 602efd36
RPC:       XID 602efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    13 xid 602efd36 complete (20 bytes received)
RPC:    13 __rpc_wake_up_task (now 4294927564)
RPC:    13 disabling timer
RPC:    13 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    13 sync task resuming
RPC:    13 call_status (status 20)
RPC:    13 call_decode (status 20)
RPC:    13 rpc_verify_header: call rejected 1
RPC:    13 rpc_verify_header: call failed with error -13
RPC:    13 return 0, status -13
RPC:    13 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    13 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    13 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       registering (100021, 1, 17, 43037) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    14 __rpc_execute flags=0x680
RPC:    14 call_start rpcbind2 proc SET (sync)
RPC:    14 call_reserve (status 0)
RPC:    14 reserved req c0812000 xid 612efd36
RPC:    14 call_reserveresult (status 0)
RPC:    14 call_refresh (status 0)
RPC:    14 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    14 refreshing UNIX cred c6fb7d60
RPC:    14 call_refreshresult (status 0)
RPC:    14 call_allocate (status 0)
RPC:    14 allocated buffer of size 412 at c0811800
RPC:    14 call_bind (status 0)
RPC:    14 call_connect xprt c080bc00 is connected
RPC:    14 call_transmit (status 0)
RPC:    14 xprt_prepare_transmit
RPC:    14 rpc_xdr_encode (status 0)
RPC:    14 marshaling UNIX cred c6fb7d60
RPC:    14 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    14 encoding PMAP_SET call (100021, 1, 17, 43037)
RPC:    14 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    14 xmit complete
RPC:    14 sleep_on(queue "xprt_pending" time 4294927644)
RPC:    14 added to queue c080bdac "xprt_pending"
RPC:    14 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    14 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 612efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 612efd36
RPC:       XID 612efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    14 xid 612efd36 complete (20 bytes received)
RPC:    14 __rpc_wake_up_task (now 4294927675)
RPC:    14 disabling timer
RPC:    14 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    14 sync task resuming
RPC:    14 call_status (status 20)
RPC:    14 call_decode (status 20)
RPC:    14 rpc_verify_header: retry garbled creds
RPC:    14 call_bind (status 0)
RPC:    14 call_connect xprt c080bc00 is connected
RPC:    14 call_transmit (status 0)
RPC:    14 xprt_prepare_transmit
RPC:    14 rpc_xdr_encode (status 0)
RPC:    14 marshaling UNIX cred c6fb7d60
RPC:    14 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    14 encoding PMAP_SET call (100021, 1, 17, 43037)
RPC:    14 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    14 xmit complete
RPC:    14 sleep_on(queue "xprt_pending" time 4294927711)
RPC:    14 added to queue c080bdac "xprt_pending"
RPC:    14 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    14 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 612efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 612efd36
RPC:       XID 612efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    14 xid 612efd36 complete (20 bytes received)
RPC:    14 __rpc_wake_up_task (now 4294927742)
RPC:    14 disabling timer
RPC:    14 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    14 sync task resuming
RPC:    14 call_status (status 20)
RPC:    14 call_decode (status 20)
RPC:    14 rpc_verify_header: retry garbled creds
RPC:    14 call_bind (status 0)
RPC:    14 call_connect xprt c080bc00 is connected
RPC:    14 call_transmit (status 0)
RPC:    14 xprt_prepare_transmit
RPC:    14 rpc_xdr_encode (status 0)
RPC:    14 marshaling UNIX cred c6fb7d60
RPC:    14 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    14 encoding PMAP_SET call (100021, 1, 17, 43037)
RPC:    14 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    14 xmit complete
RPC:    14 sleep_on(queue "xprt_pending" time 4294927778)
RPC:    14 added to queue c080bdac "xprt_pending"
RPC:    14 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    14 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 612efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 612efd36
RPC:       XID 612efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    14 xid 612efd36 complete (20 bytes received)
RPC:    14 __rpc_wake_up_task (now 4294927809)
RPC:    14 disabling timer
RPC:    14 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    14 sync task resuming
RPC:    14 call_status (status 20)
RPC:    14 call_decode (status 20)
RPC:    14 rpc_verify_header: call rejected 1
RPC:    14 rpc_verify_header: call failed with error -13
RPC:    14 return 0, status -13
RPC:    14 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    14 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    14 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
svc: failed to register lockdv1 RPC service (errno 13).
RPC:       unregistering (100021, 1, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    15 __rpc_execute flags=0x680
RPC:    15 call_start rpcbind2 proc UNSET (sync)
RPC:    15 call_reserve (status 0)
RPC:    15 reserved req c0812000 xid 622efd36
RPC:    15 call_reserveresult (status 0)
RPC:    15 call_refresh (status 0)
RPC:    15 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    15 refreshing UNIX cred c6fb7d60
RPC:    15 call_refreshresult (status 0)
RPC:    15 call_allocate (status 0)
RPC:    15 allocated buffer of size 412 at c0811800
RPC:    15 call_bind (status 0)
RPC:    15 call_connect xprt c080bc00 is connected
RPC:    15 call_transmit (status 0)
RPC:    15 xprt_prepare_transmit
RPC:    15 rpc_xdr_encode (status 0)
RPC:    15 marshaling UNIX cred c6fb7d60
RPC:    15 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    15 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    15 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    15 xmit complete
RPC:    15 sleep_on(queue "xprt_pending" time 4294927887)
RPC:    15 added to queue c080bdac "xprt_pending"
RPC:    15 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    15 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 622efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 622efd36
RPC:       XID 622efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    15 xid 622efd36 complete (20 bytes received)
RPC:    15 __rpc_wake_up_task (now 4294927918)
RPC:    15 disabling timer
RPC:    15 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    15 sync task resuming
RPC:    15 call_status (status 20)
RPC:    15 call_decode (status 20)
RPC:    15 rpc_verify_header: retry garbled creds
RPC:    15 call_bind (status 0)
RPC:    15 call_connect xprt c080bc00 is connected
RPC:    15 call_transmit (status 0)
RPC:    15 xprt_prepare_transmit
RPC:    15 rpc_xdr_encode (status 0)
RPC:    15 marshaling UNIX cred c6fb7d60
RPC:    15 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    15 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    15 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    15 xmit complete
RPC:    15 sleep_on(queue "xprt_pending" time 4294927954)
RPC:    15 added to queue c080bdac "xprt_pending"
RPC:    15 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    15 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 622efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 622efd36
RPC:       XID 622efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    15 xid 622efd36 complete (20 bytes received)
RPC:    15 __rpc_wake_up_task (now 4294927985)
RPC:    15 disabling timer
RPC:    15 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    15 sync task resuming
RPC:    15 call_status (status 20)
RPC:    15 call_decode (status 20)
RPC:    15 rpc_verify_header: retry garbled creds
RPC:    15 call_bind (status 0)
RPC:    15 call_connect xprt c080bc00 is connected
RPC:    15 call_transmit (status 0)
RPC:    15 xprt_prepare_transmit
RPC:    15 rpc_xdr_encode (status 0)
RPC:    15 marshaling UNIX cred c6fb7d60
RPC:    15 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    15 encoding PMAP_UNSET call (100021, 1, 0, 0)
RPC:    15 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    15 xmit complete
RPC:    15 sleep_on(queue "xprt_pending" time 4294928021)
RPC:    15 added to queue c080bdac "xprt_pending"
RPC:    15 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    15 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 622efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 622efd36
RPC:       XID 622efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    15 xid 622efd36 complete (20 bytes received)
RPC:    15 __rpc_wake_up_task (now 4294928053)
RPC:    15 disabling timer
RPC:    15 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    15 sync task resuming
RPC:    15 call_status (status 20)
RPC:    15 call_decode (status 20)
RPC:    15 rpc_verify_header: call rejected 1
RPC:    15 rpc_verify_header: call failed with error -13
RPC:    15 return 0, status -13
RPC:    15 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    15 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    15 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 3, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    16 __rpc_execute flags=0x680
RPC:    16 call_start rpcbind2 proc UNSET (sync)
RPC:    16 call_reserve (status 0)
RPC:    16 reserved req c0812000 xid 632efd36
RPC:    16 call_reserveresult (status 0)
RPC:    16 call_refresh (status 0)
RPC:    16 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    16 refreshing UNIX cred c6fb7d60
RPC:    16 call_refreshresult (status 0)
RPC:    16 call_allocate (status 0)
RPC:    16 allocated buffer of size 412 at c0811800
RPC:    16 call_bind (status 0)
RPC:    16 call_connect xprt c080bc00 is connected
RPC:    16 call_transmit (status 0)
RPC:    16 xprt_prepare_transmit
RPC:    16 rpc_xdr_encode (status 0)
RPC:    16 marshaling UNIX cred c6fb7d60
RPC:    16 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    16 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    16 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    16 xmit complete
RPC:    16 sleep_on(queue "xprt_pending" time 4294928128)
RPC:    16 added to queue c080bdac "xprt_pending"
RPC:    16 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    16 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 632efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 632efd36
RPC:       XID 632efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    16 xid 632efd36 complete (20 bytes received)
RPC:    16 __rpc_wake_up_task (now 4294928159)
RPC:    16 disabling timer
RPC:    16 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    16 sync task resuming
RPC:    16 call_status (status 20)
RPC:    16 call_decode (status 20)
RPC:    16 rpc_verify_header: retry garbled creds
RPC:    16 call_bind (status 0)
RPC:    16 call_connect xprt c080bc00 is connected
RPC:    16 call_transmit (status 0)
RPC:    16 xprt_prepare_transmit
RPC:    16 rpc_xdr_encode (status 0)
RPC:    16 marshaling UNIX cred c6fb7d60
RPC:    16 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    16 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    16 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    16 xmit complete
RPC:    16 sleep_on(queue "xprt_pending" time 4294928196)
RPC:    16 added to queue c080bdac "xprt_pending"
RPC:    16 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    16 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 632efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 632efd36
RPC:       XID 632efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    16 xid 632efd36 complete (20 bytes received)
RPC:    16 __rpc_wake_up_task (now 4294928227)
RPC:    16 disabling timer
RPC:    16 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    16 sync task resuming
RPC:    16 call_status (status 20)
RPC:    16 call_decode (status 20)
RPC:    16 rpc_verify_header: retry garbled creds
RPC:    16 call_bind (status 0)
RPC:    16 call_connect xprt c080bc00 is connected
RPC:    16 call_transmit (status 0)
RPC:    16 xprt_prepare_transmit
RPC:    16 rpc_xdr_encode (status 0)
RPC:    16 marshaling UNIX cred c6fb7d60
RPC:    16 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    16 encoding PMAP_UNSET call (100021, 3, 0, 0)
RPC:    16 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    16 xmit complete
RPC:    16 sleep_on(queue "xprt_pending" time 4294928263)
RPC:    16 added to queue c080bdac "xprt_pending"
RPC:    16 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    16 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 632efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 632efd36
RPC:       XID 632efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    16 xid 632efd36 complete (20 bytes received)
RPC:    16 __rpc_wake_up_task (now 4294928294)
RPC:    16 disabling timer
RPC:    16 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    16 sync task resuming
RPC:    16 call_status (status 20)
RPC:    16 call_decode (status 20)
RPC:    16 rpc_verify_header: call rejected 1
RPC:    16 rpc_verify_header: call failed with error -13
RPC:    16 return 0, status -13
RPC:    16 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    16 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    16 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       unregistering (100021, 4, 0, 0) with local rpcbind
RPC:       new task initialized, procpid 68
RPC:       allocated task c786fc20
RPC:    17 __rpc_execute flags=0x680
RPC:    17 call_start rpcbind2 proc UNSET (sync)
RPC:    17 call_reserve (status 0)
RPC:    17 reserved req c0812000 xid 642efd36
RPC:    17 call_reserveresult (status 0)
RPC:    17 call_refresh (status 0)
RPC:    17 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:    17 refreshing UNIX cred c6fb7d60
RPC:    17 call_refreshresult (status 0)
RPC:    17 call_allocate (status 0)
RPC:    17 allocated buffer of size 412 at c0811800
RPC:    17 call_bind (status 0)
RPC:    17 call_connect xprt c080bc00 is connected
RPC:    17 call_transmit (status 0)
RPC:    17 xprt_prepare_transmit
RPC:    17 rpc_xdr_encode (status 0)
RPC:    17 marshaling UNIX cred c6fb7d60
RPC:    17 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    17 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    17 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    17 xmit complete
RPC:    17 sleep_on(queue "xprt_pending" time 4294928369)
RPC:    17 added to queue c080bdac "xprt_pending"
RPC:    17 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    17 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 642efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 642efd36
RPC:       XID 642efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    17 xid 642efd36 complete (20 bytes received)
RPC:    17 __rpc_wake_up_task (now 4294928400)
RPC:    17 disabling timer
RPC:    17 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    17 sync task resuming
RPC:    17 call_status (status 20)
RPC:    17 call_decode (status 20)
RPC:    17 rpc_verify_header: retry garbled creds
RPC:    17 call_bind (status 0)
RPC:    17 call_connect xprt c080bc00 is connected
RPC:    17 call_transmit (status 0)
RPC:    17 xprt_prepare_transmit
RPC:    17 rpc_xdr_encode (status 0)
RPC:    17 marshaling UNIX cred c6fb7d60
RPC:    17 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    17 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    17 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    17 xmit complete
RPC:    17 sleep_on(queue "xprt_pending" time 4294928437)
RPC:    17 added to queue c080bdac "xprt_pending"
RPC:    17 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    17 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 642efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 642efd36
RPC:       XID 642efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    17 xid 642efd36 complete (20 bytes received)
RPC:    17 __rpc_wake_up_task (now 4294928468)
RPC:    17 disabling timer
RPC:    17 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    17 sync task resuming
RPC:    17 call_status (status 20)
RPC:    17 call_decode (status 20)
RPC:    17 rpc_verify_header: retry garbled creds
RPC:    17 call_bind (status 0)
RPC:    17 call_connect xprt c080bc00 is connected
RPC:    17 call_transmit (status 0)
RPC:    17 xprt_prepare_transmit
RPC:    17 rpc_xdr_encode (status 0)
RPC:    17 marshaling UNIX cred c6fb7d60
RPC:    17 using AUTH_UNIX cred c6fb7d60 to wrap rpc data
RPC:    17 encoding PMAP_UNSET call (100021, 4, 0, 0)
RPC:    17 xprt_transmit(108)
RPC:       xs_tcp_send_request(108) = 108
RPC:    17 xmit complete
RPC:    17 sleep_on(queue "xprt_pending" time 4294928504)
RPC:    17 added to queue c080bdac "xprt_pending"
RPC:    17 setting alarm for 60000 ms
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")
RPC:    17 sync task going to sleep
RPC:       xs_tcp_data_ready...0xc6fc6040 0
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 20
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 642efd36
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 642efd36
RPC:       XID 642efd36 read 12 bytes
RPC:       xprt = c080bc00, tcp_copied = 20, tcp_offset = 20, tcp_reclen = 20
RPC:    17 xid 642efd36 complete (20 bytes received)
RPC:    17 __rpc_wake_up_task (now 4294928535)
RPC:    17 disabling timer
RPC:    17 removed from queue c080bdac "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:    17 sync task resuming
RPC:    17 call_status (status 20)
RPC:    17 call_decode (status 20)
RPC:    17 rpc_verify_header: call rejected 1
RPC:    17 rpc_verify_header: call failed with error -13
RPC:    17 return 0, status -13
RPC:    17 release task
RPC:       freeing buffer of size 412 at c0811800
RPC:    17 release request c0812000
RPC:       wake_up_next(c080be04 "xprt_backlog")
RPC:       rpc_release_client(c6f323a0)
RPC:    17 freeing task
RPC:       failed to contact local rpcbind server (errno 13).
RPC:       shutting down nfs client for 192.168.0.101
RPC:       rpc_release_client(c6f322a0)
RPC:       destroying nfs client for 192.168.0.101
RPC:       destroying transport c6fac400
RPC:       xs_destroy xprt c6fac400
RPC:       xs_close xprt c6fac400
RPC:       disconnected transport c6fac400
~ # RPC:       xs_close xprt c080bc00
RPC:       disconnected transport c080bc00
RPC:       wake_up_next(c080bd54 "xprt_resend")
RPC:       wake_up_next(c080bcfc "xprt_sending")


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
