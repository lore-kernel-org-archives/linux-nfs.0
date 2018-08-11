Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:43133 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727333AbeHKQWi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 11 Aug 2018 12:22:38 -0400
MIME-Version: 1.0
Message-ID: <trinity-694a6909-affa-4beb-abc2-532c65335273-1533995301719@3c-app-webde-bs02>
From: c.monty@web.de
To: linux-nfs@vger.kernel.org
Subject: mount.nfs: Connection timed out
Content-Type: text/plain; charset=UTF-8
Date: Sat, 11 Aug 2018 15:48:21 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The issue is that I get a timeout error 
mount.nfs: Connection timed out 
when I try to connect to NFS server.
I've verified this with 2 different clients; client1 is connected via WLAN and client2 is connected via LAN.

The following console output is from client 1:
root@pc8-nb:/home/thomas# showmount -e 192.168.1.14
Export list for 192.168.1.14:
/mnt/exthdd/musik 192.168.1.0/24

root@pc8-nb:/home/thomas# mount -v -t nfs 192.168.1.14:/mnt/exthdd/musik /mnt/nfs/
mount.nfs: timeout set for Sat Aug 11 09:56:49 2018
mount.nfs: trying text-based options 'vers=4.2,addr=192.168.1.14,clientaddr=192.168.1.42'
mount.nfs: mount(2): Connection timed out
mount.nfs: Connection timed out
root@pc8-nb:/home/thomas#

I started debugging using using rpcdebug:
Aug 11 15:30:45 pc2-desk sudo[6021]:   thomas : TTY=pts/0 ; PWD=/home/thomas ; USER=root ; COMMAND=/usr/bin/mount -v -t nfs 192.168.1.14:/mnt/exthdd/musik /mnt/nfs/
Aug 11 15:30:45 pc2-desk sudo[6021]: pam_unix(sudo:session): session opened for user root by thomas(uid=0)
Aug 11 15:30:45 pc2-desk kernel: NFS: nfs mount opts='vers=4.2,addr=192.168.1.14,clientaddr=192.168.1.42'
Aug 11 15:30:45 pc2-desk kernel: NFS:   parsing nfs mount option 'vers=4.2'
Aug 11 15:30:45 pc2-desk kernel: NFS:   parsing nfs mount option 'addr=192.168.1.14'
Aug 11 15:30:45 pc2-desk kernel: NFS:   parsing nfs mount option 'clientaddr=192.168.1.42'
Aug 11 15:30:45 pc2-desk kernel: NFS: MNTPATH: '/mnt/exthdd/musik'
Aug 11 15:30:45 pc2-desk kernel: --> nfs4_try_mount()
Aug 11 15:30:45 pc2-desk kernel: RPC:       looking up machine cred for service *
Aug 11 15:30:45 pc2-desk kernel: NFS: get client cookie (0x000000002f89ec3a/0x000000005b4658ca)
Aug 11 15:30:45 pc2-desk kernel: RPC:       set up xprt to 192.168.1.14 (port 2049) via tcp
Aug 11 15:30:45 pc2-desk kernel: RPC:       created transport 00000000aea467b3 with 65536 slots
Aug 11 15:30:45 pc2-desk kernel: RPC:       creating nfs client for 192.168.1.14 (xprt 00000000aea467b3)
Aug 11 15:30:45 pc2-desk kernel: RPC:       creating GSS authenticator for client 00000000eb77d136
Aug 11 15:30:45 pc2-desk kernel: RPC:       Couldn't create auth handle (flavor 390004)
Aug 11 15:30:45 pc2-desk kernel: RPC:       destroying transport 00000000aea467b3
Aug 11 15:30:45 pc2-desk kernel: nfs_create_rpc_client: cannot create RPC client. Error = -22
Aug 11 15:30:45 pc2-desk kernel: RPC:       xs_destroy xprt 00000000aea467b3
Aug 11 15:30:45 pc2-desk kernel: RPC:       xs_close xprt 00000000aea467b3
Aug 11 15:30:45 pc2-desk kernel: RPC:       disconnected transport 00000000aea467b3
Aug 11 15:30:45 pc2-desk kernel: RPC:       set up xprt to 192.168.1.14 (port 2049) via tcp
Aug 11 15:30:45 pc2-desk kernel: RPC:       created transport 00000000d0b42a97 with 65536 slots
Aug 11 15:30:45 pc2-desk kernel: RPC:       creating nfs client for 192.168.1.14 (xprt 00000000d0b42a97)
Aug 11 15:30:45 pc2-desk kernel: RPC:       creating UNIX authenticator for client 0000000078c90a28
Aug 11 15:30:45 pc2-desk kernel: RPC:       new task initialized, procpid 6030
Aug 11 15:30:45 pc2-desk kernel: RPC:       allocated task 00000000dd1c9a45
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 __rpc_execute flags=0x680
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_start nfs4 proc NULL (sync)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_reserve (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 reserved req 00000000eb77d136 xid 1938103e
Aug 11 15:30:45 pc2-desk kernel: RPC:       wake_up_first(000000002c5e17b0 "xprt_sending")
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_reserveresult (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_refresh (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 holding NULL cred 0000000099b5f795
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 refreshing NULL cred 0000000099b5f795
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_refreshresult (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_allocate (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 allocated buffer of size 96 at 00000000d731b993
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_bind (status 0)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 call_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 xprt_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 sleep_on(queue "xprt_pending" time 4295861800)
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 added to queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 setting alarm for 60000 ms
Aug 11 15:30:45 pc2-desk kernel: RPC:       xs_connect scheduled xprt 00000000d0b42a97
Aug 11 15:30:45 pc2-desk kernel: RPC:    42 sync task going to sleep
Aug 11 15:30:45 pc2-desk kernel: RPC:       xs_bind 0.0.0.0:828: ok (0)
Aug 11 15:30:45 pc2-desk kernel: RPC:       worker connecting xprt 00000000d0b42a97 via tcp to 192.168.1.14 (port 2049)
Aug 11 15:30:45 pc2-desk kernel: RPC:       00000000d0b42a97 connect status 115 connected 0 sock state 2
Aug 11 15:30:45 pc2-desk kernel: RPC:       wake_up_first(000000002c5e17b0 "xprt_sending")
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 timeout
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 __rpc_wake_up_task (now 4295880192)
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 disabling timer
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 removed from queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:31:46 pc2-desk kernel: RPC:       __rpc_wake_up_task done
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 sync task resuming
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 xprt_connect_status: connect attempt timed out
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 call_connect_status (status -110)
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 call_timeout (minor)
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 call_bind (status 0)
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 call_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 xprt_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 sleep_on(queue "xprt_pending" time 4295880192)
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 added to queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 setting alarm for 120000 ms
Aug 11 15:31:46 pc2-desk kernel: RPC:    42 sync task going to sleep
Aug 11 15:32:55 pc2-desk kernel: RPC:       xs_error_report client 00000000d0b42a97, error=110...
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 __rpc_wake_up_task (now 4295900672)
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 disabling timer
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 removed from queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:32:55 pc2-desk kernel: RPC:       __rpc_wake_up_task done
Aug 11 15:32:55 pc2-desk kernel: RPC:       xs_tcp_state_change client 00000000d0b42a97...
Aug 11 15:32:55 pc2-desk kernel: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 sync task resuming
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 xprt_connect_status: connect attempt timed out
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 call_connect_status (status -110)
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 call_timeout (minor)
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 call_bind (status 0)
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 call_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 xprt_connect xprt 00000000d0b42a97 is not connected
Aug 11 15:32:55 pc2-desk kernel: RPC:       xs_tcp_state_change client 00000000d0b42a97...
Aug 11 15:32:55 pc2-desk kernel: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 sleep_on(queue "xprt_pending" time 4295900672)
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 added to queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 setting alarm for 180000 ms
Aug 11 15:32:55 pc2-desk kernel: RPC:       xs_connect scheduled xprt 00000000d0b42a97
Aug 11 15:32:55 pc2-desk kernel: RPC:       xs_bind 0.0.0.0:828: ok (0)
Aug 11 15:32:55 pc2-desk kernel: RPC:       worker connecting xprt 00000000d0b42a97 via tcp to 192.168.1.14 (port 2049)
Aug 11 15:32:55 pc2-desk kernel: RPC:       00000000d0b42a97 connect status 115 connected 0 sock state 2
Aug 11 15:32:55 pc2-desk kernel: RPC:       wake_up_first(000000002c5e17b0 "xprt_sending")
Aug 11 15:32:55 pc2-desk kernel: RPC:    42 sync task going to sleep
Aug 11 15:35:04 pc2-desk sudo[6021]: pam_unix(sudo:session): session closed for user root
Aug 11 15:35:04 pc2-desk kernel: RPC:       xs_error_report client 00000000d0b42a97, error=110...
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 __rpc_wake_up_task (now 4295939584)
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 disabling timer
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 removed from queue 0000000014e8eff8 "xprt_pending"
Aug 11 15:35:04 pc2-desk kernel: RPC:       __rpc_wake_up_task done
Aug 11 15:35:04 pc2-desk kernel: RPC:       xs_tcp_state_change client 00000000d0b42a97...
Aug 11 15:35:04 pc2-desk kernel: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 sync task resuming
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 xprt_connect_status: connect attempt timed out
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 call_connect_status (status -110)
Aug 11 15:35:04 pc2-desk kernel: RPC:       xs_tcp_state_change client 00000000d0b42a97...
Aug 11 15:35:04 pc2-desk kernel: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 call_timeout (major)
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 return 0, status -110
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 release task
Aug 11 15:35:04 pc2-desk kernel: RPC:       freeing buffer of size 96 at 00000000d731b993
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 release request 00000000eb77d136
Aug 11 15:35:04 pc2-desk kernel: RPC:       wake_up_first(000000009bc33209 "xprt_backlog")
Aug 11 15:35:04 pc2-desk kernel: RPC:       rpc_release_client(0000000078c90a28)
Aug 11 15:35:04 pc2-desk kernel: RPC:    42 freeing task
Aug 11 15:35:04 pc2-desk kernel: RPC:       wake_up_first(000000002c5e17b0 "xprt_sending")
Aug 11 15:35:04 pc2-desk kernel: RPC:       shutting down nfs client for 192.168.1.14
Aug 11 15:35:04 pc2-desk kernel: RPC:       rpc_release_client(0000000078c90a28)
Aug 11 15:35:04 pc2-desk kernel: RPC:       destroying UNIX authenticator 00000000f731ddeb
Aug 11 15:35:04 pc2-desk kernel: RPC:       destroying nfs client for 192.168.1.14
Aug 11 15:35:04 pc2-desk kernel: RPC:       destroying transport 00000000d0b42a97
Aug 11 15:35:04 pc2-desk kernel: nfs_create_rpc_client: cannot create RPC client. Error = -110
Aug 11 15:35:04 pc2-desk kernel: NFS: releasing client cookie (0x000000002f89ec3a/0x000000005b4658ca)
Aug 11 15:35:04 pc2-desk kernel: <-- nfs4_try_mount() = -110 [error]
Aug 11 15:35:04 pc2-desk kernel: RPC:       xs_destroy xprt 00000000d0b42a97
Aug 11 15:35:04 pc2-desk kernel: RPC:       xs_close xprt 00000000d0b42a97
Aug 11 15:35:04 pc2-desk kernel: RPC:       disconnected transport 00000000d0b42a97


And I have made 2 observations:
1. When I execute showmount -e 192.168.1.14 on client1 I have to wait min. 60s for the result. On client2 the result is displayed immediatelly.
2. After replacing managed switch "D-Link DGS-1100-16" with an unmanaged switch there's no timeout error on any client.

IMO this indicates that the issue is related to the managed switch (or its configuration).

Could you please advice how to continue analysis to identify the (potential) root cause with the managed switch?

THX
 
