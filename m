From: <Tsutomu_Miyashita@Dell.com>
Subject: Access to NFS area hungs
Date: Fri, 10 Nov 2006 11:43:33 +0900
Message-ID: <1AEE73FE081093499412BAAB316BA024018F5FEB@nrtx3mdc102.japn.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GiMPv-0005T4-58
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 18:46:55 -0800
Received: from ausc60pc101.us.dell.com ([143.166.85.206])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GiMPv-00016L-5x
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 18:46:56 -0800
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Dear mailing list members

I have a trouble of NFS.
Any information about this trouble is welcomed.

Thanks.
Tsutomu


[Trouble Summary]
Access to NFS area on NFS client hungs.


[Trouble Detail]
While the trouble is in progress on the NFS client,
access to the NFS area hungs like following.

#> ls -l /belle/     ----> no responce

#> df -k
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda1             41286796   3591456  35598056  10% /
/dev/sda5             25015800     78144  23666920   1% /bdata
none                    512544         0    512544   0% /dev/shm
----> at the point of displaying NFS area, output of
this command stops.

While this trouble is in progress, same trouble doesn't
happen on the other NFS client which mounts
same NFS server filesystem. So I think the cause of
the trouble may be on the client side.
If I want to resolv this trouble, remounting the NFS
filesystem on the NFS client repairs it. But after a few
days, the trouble happens again.


[Environment]
NFS server and client
	OS	:CentOS4.2
	kernel	:2.6.9-34
	nfs-utils	:1.0.6-65
/proc/mounts on NFS client
	10.34.36.160:/export3/belle /belle nfs
rw,v3,rsize=32768,wsize=32768,soft,intr,tcp,lock,addr=10.34.36.160 0 0
/proc/fs/nfsd/exports on NFS server
	/export3
10.34.36.0/255.255.255.0(rw,no_root_squash,async,wdelay)
network beeing used by NFS
	10.34.36.0/255.255.255.0


[Debug Information]
I collected debug information on both the NFS client
happenning this NFS trouble and the NFS client not
happenning by upgrading debug level under /proc/sys/sunrpc.
Thease were collected when I accessed to the NFS
area using ls command.

--------------good one--------------
Oct 26 09:56:21 bs0057 kernel: NFS: revalidating (0:18/2)
Oct 26 09:56:21 bs0057 kernel: NFS call  getattr
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 new task procpid 22248
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 allocated task
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 looking up UNIX cred
Oct 26 09:56:21 bs0057 kernel: RPC: gc'ing RPC credentials for auth
000001003f81d9c0
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 rpc_execute flgs 280
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_start nfs3 proc 1 (sync)
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_reserve
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 reserved req 000001002a09ed68
xid ddb46e85
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_reserveresult (status 0)
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_allocate (status 0)
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_bind xprt
000001003f85a400 is not connected
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 call_connect status 0
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 xprt_connect xprt
000001003f85a400 is not connected
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 sleep_on(queue "xprt_pending"
time 9999220260)
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 added to queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 setting alarm for 60000 ms
Oct 26 09:56:21 bs0057 kernel: RPC:      xprt_create_socket(tcp 6)
Oct 26 09:56:21 bs0057 kernel: RPC: 000001003f85a400  connect status 115
connected 0 sock state 2
Oct 26 09:56:21 bs0057 kernel: RPC: 25013 sync task going to sleep
Oct 26 09:56:21 bs0057 kernel: RPC:      tcp_state_change client
000001003f85a400...
Oct 26 09:56:22 bs0057 kernel: RPC:      state 1 conn 0 dead 0 zapped 1
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 __rpc_wake_up_task (now
9999220262 inh 0)
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 disabling timer
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 removed from queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:22 bs0057 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 sync task resuming
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 xprt_connect_status:
connection established
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 deleting timer
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 call_transmit (status 0)
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 xprt_prepare_transmit
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 call_encode (status 0)
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 marshaling UNIX cred
0000010037d4a580
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 using UNIX cred
0000010037d4a580 to wrap rpc data
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 xprt_transmit(128)
Oct 26 09:56:22 bs0057 kernel: RPC:      xprt_sendmsg(128) = 128
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 xmit complete
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 sleep_on(queue "xprt_pending"
time 9999220262)
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 added to queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:22 bs0057 kernel: RPC: 25013 setting alarm for 60000 ms
Oct 26 09:56:22 bs0057 kernel: RPC:      wake_up_next(000001003f85a4a8
"xprt_resend")
Oct 26 09:56:23 bs0057 kernel: RPC:      wake_up_next(000001003f85a460
"xprt_sending")
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 sync task going to sleep
Oct 26 09:56:23 bs0057 kernel: RPC:      tcp_data_ready...
Oct 26 09:56:23 bs0057 kernel: RPC:      tcp_data_recv
Oct 26 09:56:23 bs0057 kernel: RPC:      reading TCP record fragment of
length 112
Oct 26 09:56:23 bs0057 kernel: RPC:      reading XID (4 bytes)
Oct 26 09:56:23 bs0057 kernel: RPC:      reading reply for XID ddb46e85
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 received reply complete
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 has input (112 bytes)
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 __rpc_wake_up_task (now
9999220262 inh 0)
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 disabling timer
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 removed from queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:23 bs0057 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:56:23 bs0057 kernel: RPC:      tcp_data_recv done
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 sync task resuming
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 deleting timer
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 call_status (status 112)
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 call_decode (status 112)
Oct 26 09:56:23 bs0057 kernel: RPC: 25013 validating UNIX cred
0000010037d4a580
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 using UNIX cred
0000010037d4a580 to unwrap rpc data
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 call_decode result 0
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 exit() = 0
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 release task
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 disabling timer
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 release request
000001002a09ed68
Oct 26 09:56:24 bs0057 kernel: RPC:      wake_up_next(000001003f85a538
"xprt_backlog")
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 releasing UNIX cred
0000010037d4a580
Oct 26 09:56:24 bs0057 kernel: RPC:
rpc_release_client(000001002aa87e00, 1)
Oct 26 09:56:24 bs0057 kernel: RPC: 25013 freeing task
Oct 26 09:56:24 bs0057 kernel: NFS reply getattr
Oct 26 09:56:24 bs0057 kernel: NFS: nfs_update_inode(0:18/2 ct=1
info=0x6)
Oct 26 09:56:24 bs0057 kernel: NFS: (0:18/2) revalidation complete
Oct 26 09:56:24 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/2, 32768) =
0000000000000000
Oct 26 09:56:24 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/2, 16384) =
0000000000000000
Oct 26 09:56:24 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:24 bs0057 kernel: NFS call  access
Oct 26 09:56:24 bs0057 kernel: RPC: 25014 new task procpid 22248
Oct 26 09:56:24 bs0057 kernel: RPC: 25014 allocated task
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 holding UNIX cred
0000010037d4a580
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 rpc_execute flgs 280
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_start nfs3 proc 4 (sync)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_reserve
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 reserved req 000001002a09ed68
xid ddb46e86
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_reserveresult (status 0)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_allocate (status 0)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_bind xprt
000001003f85a400 is connected
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_transmit (status 0)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 xprt_prepare_transmit
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 call_encode (status 0)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 marshaling UNIX cred
0000010037d4a580
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 using UNIX cred
0000010037d4a580 to wrap rpc data
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 xprt_transmit(132)
Oct 26 09:56:25 bs0057 kernel: RPC:      xprt_sendmsg(132) = 132
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 xmit complete
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 sleep_on(queue "xprt_pending"
time 9999220263)
Oct 26 09:56:25 bs0057 kernel: RPC: 25014 added to queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 setting alarm for 60000 ms
Oct 26 09:56:26 bs0057 kernel: RPC:      wake_up_next(000001003f85a4a8
"xprt_resend")
Oct 26 09:56:26 bs0057 kernel: RPC:      wake_up_next(000001003f85a460
"xprt_sending")
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 sync task going to sleep
Oct 26 09:56:26 bs0057 kernel: RPC:      tcp_data_ready...
Oct 26 09:56:26 bs0057 kernel: RPC:      tcp_data_recv
Oct 26 09:56:26 bs0057 kernel: RPC:      reading TCP record fragment of
length 120
Oct 26 09:56:26 bs0057 kernel: RPC:      reading XID (4 bytes)
Oct 26 09:56:26 bs0057 kernel: RPC:      reading reply for XID ddb46e86
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 received reply complete
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 has input (120 bytes)
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 __rpc_wake_up_task (now
9999220263 inh 0)
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 disabling timer
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 removed from queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:26 bs0057 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:56:26 bs0057 kernel: RPC:      tcp_data_recv done
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 sync task resuming
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 deleting timer
Oct 26 09:56:26 bs0057 kernel: RPC: 25014 call_status (status 120)
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 call_decode (status 120)
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 validating UNIX cred
0000010037d4a580
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 using UNIX cred
0000010037d4a580 to unwrap rpc data
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 call_decode result 0
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 exit() = 0
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 release task
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 disabling timer
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 release request
000001002a09ed68
Oct 26 09:56:27 bs0057 kernel: RPC:      wake_up_next(000001003f85a538
"xprt_backlog")
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 releasing UNIX cred
0000010037d4a580
Oct 26 09:56:27 bs0057 kernel: RPC:
rpc_release_client(000001002aa87e00, 1)
Oct 26 09:56:27 bs0057 kernel: RPC: 25014 freeing task
Oct 26 09:56:27 bs0057 kernel: NFS reply access, status = 0
Oct 26 09:56:27 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:27 bs0057 kernel: NFS: readdir_search_pagecache() searching
for cookie 0
Oct 26 09:56:27 bs0057 kernel: NFS: find_dirent_page() searching
directory page 0
Oct 26 09:56:27 bs0057 kernel: NFS: found cookie 116459507
Oct 26 09:56:27 bs0057 kernel: NFS: find_dirent() returns 0
Oct 26 09:56:28 bs0057 kernel: NFS: find_dirent_page() returns 0
Oct 26 09:56:28 bs0057 kernel: NFS: readdir_search_pagecache() returned
0
Oct 26 09:56:28 bs0057 kernel: NFS: nfs_do_filldir() filling starting @
cookie 0
Oct 26 09:56:28 bs0057 kernel: NFS: nfs_do_filldir() filling ended @
cookie 2147483647; returning = 0
Oct 26 09:56:28 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:28 bs0057 kernel: NFS: revalidating (0:18/7440161)
Oct 26 09:56:28 bs0057 kernel: NFS call  getattr
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 new task procpid 22248
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 allocated task
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 looking up UNIX cred
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 rpc_execute flgs 280
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_start nfs3 proc 1 (sync)
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_reserve
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 reserved req 000001002a09ed68
xid ddb46e87
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_reserveresult (status 0)
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_allocate (status 0)
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_bind xprt
000001003f85a400 is connected
Oct 26 09:56:28 bs0057 kernel: RPC: 25015 call_transmit (status 0)
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 xprt_prepare_transmit
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 call_encode (status 0)
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 marshaling UNIX cred
0000010037d4a580
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 using UNIX cred
0000010037d4a580 to wrap rpc data
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 xprt_transmit(136)
Oct 26 09:56:29 bs0057 kernel: RPC:      xprt_sendmsg(136) = 136
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 xmit complete
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 sleep_on(queue "xprt_pending"
time 9999220263)
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 added to queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 setting alarm for 60000 ms
Oct 26 09:56:29 bs0057 kernel: RPC:      wake_up_next(000001003f85a4a8
"xprt_resend")
Oct 26 09:56:29 bs0057 kernel: RPC:      wake_up_next(000001003f85a460
"xprt_sending")
Oct 26 09:56:29 bs0057 kernel: RPC: 25015 sync task going to sleep
Oct 26 09:56:29 bs0057 kernel: RPC:      tcp_data_ready...
Oct 26 09:56:29 bs0057 kernel: RPC:      tcp_data_recv
Oct 26 09:56:29 bs0057 kernel: RPC:      reading TCP record fragment of
length 112
Oct 26 09:56:29 bs0057 kernel: RPC:      reading XID (4 bytes)
Oct 26 09:56:29 bs0057 kernel: RPC:      reading reply for XID ddb46e87
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 received reply complete
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 has input (112 bytes)
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 __rpc_wake_up_task (now
9999220263 inh 0)
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 disabling timer
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 removed from queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:30 bs0057 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:56:30 bs0057 kernel: RPC:      tcp_data_recv done
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 sync task resuming
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 deleting timer
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 call_status (status 112)
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 call_decode (status 112)
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 validating UNIX cred
0000010037d4a580
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 using UNIX cred
0000010037d4a580 to unwrap rpc data
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 call_decode result 0
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 exit() = 0
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 release task
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 disabling timer
Oct 26 09:56:30 bs0057 kernel: RPC: 25015 release request
000001002a09ed68
Oct 26 09:56:30 bs0057 kernel: RPC:      wake_up_next(000001003f85a538
"xprt_backlog")
Oct 26 09:56:31 bs0057 kernel: RPC: 25015 releasing UNIX cred
0000010037d4a580
Oct 26 09:56:31 bs0057 kernel: RPC:
rpc_release_client(000001002aa87e00, 1)
Oct 26 09:56:31 bs0057 kernel: RPC: 25015 freeing task
Oct 26 09:56:31 bs0057 kernel: NFS reply getattr
Oct 26 09:56:31 bs0057 kernel: NFS: nfs_update_inode(0:18/7440161 ct=1
info=0x6)
Oct 26 09:56:31 bs0057 kernel: NFS: (0:18/7440161) revalidation complete
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/7440161,
32768) = 0000000000000000
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/7440161,
16384) = 0000000000000000
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/5543329,
32768) = 0000000000000000
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/5543329,
16384) = 0000000000000000
Oct 26 09:56:31 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:31 bs0057 kernel: NFS: revalidating (0:18/3711905)
Oct 26 09:56:31 bs0057 kernel: NFS call  getattr
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 new task procpid 22248
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 allocated task
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 looking up UNIX cred
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 rpc_execute flgs 280
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_start nfs3 proc 1 (sync)
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_reserve
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 reserved req 000001002a09ed68
xid ddb46e88
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_reserveresult (status 0)
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_allocate (status 0)
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_bind xprt
000001003f85a400 is connected
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_transmit (status 0)
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 xprt_prepare_transmit
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 call_encode (status 0)
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 marshaling UNIX cred
0000010037d4a580
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 using UNIX cred
0000010037d4a580 to wrap rpc data
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 xprt_transmit(136)
Oct 26 09:56:32 bs0057 kernel: RPC:      xprt_sendmsg(136) = 136
Oct 26 09:56:32 bs0057 kernel: RPC: 25016 xmit complete
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 sleep_on(queue "xprt_pending"
time 9999220263)
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 added to queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 setting alarm for 60000 ms
Oct 26 09:56:33 bs0057 kernel: RPC:      wake_up_next(000001003f85a4a8
"xprt_resend")
Oct 26 09:56:33 bs0057 kernel: RPC:      wake_up_next(000001003f85a460
"xprt_sending")
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 sync task going to sleep
Oct 26 09:56:33 bs0057 kernel: RPC:      tcp_data_ready...
Oct 26 09:56:33 bs0057 kernel: RPC:      tcp_data_recv
Oct 26 09:56:33 bs0057 kernel: RPC:      reading TCP record fragment of
length 112
Oct 26 09:56:33 bs0057 kernel: RPC:      reading XID (4 bytes)
Oct 26 09:56:33 bs0057 kernel: RPC:      reading reply for XID ddb46e88
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 received reply complete
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 has input (112 bytes)
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 __rpc_wake_up_task (now
9999220264 inh 0)
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 disabling timer
Oct 26 09:56:33 bs0057 kernel: RPC: 25016 removed from queue
000001003f85a4f0 "xprt_pending"
Oct 26 09:56:33 bs0057 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:56:33 bs0057 kernel: RPC:      tcp_data_recv done
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 sync task resuming
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 deleting timer
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 call_status (status 112)
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 call_decode (status 112)
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 validating UNIX cred
0000010037d4a580
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 using UNIX cred
0000010037d4a580 to unwrap rpc data
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 call_decode result 0
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 exit() = 0
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 release task
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 disabling timer
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 release request
000001002a09ed68
Oct 26 09:56:34 bs0057 kernel: RPC:      wake_up_next(000001003f85a538
"xprt_backlog")
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 releasing UNIX cred
0000010037d4a580
Oct 26 09:56:34 bs0057 kernel: RPC:
rpc_release_client(000001002aa87e00, 1)
Oct 26 09:56:34 bs0057 kernel: RPC: 25016 freeing task
Oct 26 09:56:34 bs0057 kernel: NFS reply getattr
Oct 26 09:56:34 bs0057 kernel: NFS: nfs_update_inode(0:18/3711905 ct=1
info=0x6)
Oct 26 09:56:34 bs0057 kernel: NFS: (0:18/3711905) revalidation complete
Oct 26 09:56:34 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/3711905,
32768) = 0000000000000000
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/3711905,
16384) = 0000000000000000
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: dentry_delete(//lost+found, 8)
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/11, 32768)
= 0000000000000000
Oct 26 09:56:35 bs0057 kernel: NFS: dentry_delete(//lost+found, 8)
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/11, 16384)
= 0000000000000000
Oct 26 09:56:35 bs0057 kernel: NFS: dentry_delete(//lost+found, 8)
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/6786081,
32768) = 0000000000000000
Oct 26 09:56:35 bs0057 kernel: RPC:     looking up UNIX cred
Oct 26 09:56:35 bs0057 kernel: NFS: nfs3_get_cached_acl(0:18/6786081,
16384) = 0000000000000000
Oct 26 09:56:35 bs0057 kernel: NFS: readdir_search_pagecache() searching
for cookie 2147483647
Oct 26 09:56:35 bs0057 kernel: NFS: find_dirent_page() searching
directory page 0
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 116459507
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 265002669
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 769009438
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 1053294787
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 1684130150
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 1895114176
Oct 26 09:56:36 bs0057 kernel: NFS: found cookie 2147483647
Oct 26 09:56:36 bs0057 kernel: NFS: find_dirent() returns -523
Oct 26 09:56:36 bs0057 kernel: NFS: find_dirent_page() returns -523
Oct 26 09:56:36 bs0057 kernel: NFS: readdir_search_pagecache() returned
-523
--------------good one--------------

--------------bad one--------------
Oct 26 09:54:45 bs0058 kernel: NFS: revalidating (0:18/2)
Oct 26 09:54:45 bs0058 kernel: NFS call  getattr
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 new task procpid 23458
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 allocated task
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 looking up UNIX cred
Oct 26 09:54:45 bs0058 kernel: RPC: gc'ing RPC credentials for auth
000001003f8303c0
Oct 26 09:54:45 bs0058 kernel: RPC:      allocating UNIX cred for uid 0
gid 0
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 rpc_execute flgs 280
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_start nfs3 proc 1 (sync)
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_reserve
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 reserved req 000001002a53e948
xid 93d8edda
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_reserveresult (status 0)
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_allocate (status 0)
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_bind xprt
0000010037e30400 is not connected
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 call_connect status 0
Oct 26 09:54:45 bs0058 kernel: RPC: 51104 xprt_connect xprt
0000010037e30400 is not connected
Oct 26 09:54:46 bs0058 kernel: RPC: 51104 sleep_on(queue "xprt_pending"
time 9999158856)
Oct 26 09:54:46 bs0058 kernel: RPC: 51104 added to queue
0000010037e304f0 "xprt_pending"
Oct 26 09:54:46 bs0058 kernel: RPC: 51104 setting alarm for 60000 ms
Oct 26 09:54:46 bs0058 kernel: RPC: 51104 sync task going to sleep
Oct 26 09:55:00 bs0058 kernel: RPC:      xprt_create_socket(tcp 6)
Oct 26 09:55:00 bs0058 kernel: RPC: 0000010037e30400  connect status 115
connected 0 sock state 2
Oct 26 09:55:28 bs0058 kernel: NFS: revalidating (0:19/2)
Oct 26 09:55:28 bs0058 kernel: NFS call  getattr
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 new task procpid 23472
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 allocated task
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 looking up UNIX cred
Oct 26 09:55:28 bs0058 kernel: RPC: gc'ing RPC credentials for auth
0000010037d4b680
Oct 26 09:55:28 bs0058 kernel: RPC:      allocating UNIX cred for uid 0
gid 0
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 rpc_execute flgs 280
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_start nfs3 proc 1 (sync)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_reserve
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 reserved req 000001000fc2c108
xid 7257a96b
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_reserveresult (status 0)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_allocate (status 0)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_bind xprt
000001003fd30400 is connected
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_transmit (status 0)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 xprt_prepare_transmit
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 call_encode (status 0)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 marshaling UNIX cred
000001003f832ec0
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 using UNIX cred
000001003f832ec0 to wrap rpc data
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 xprt_transmit(100)
Oct 26 09:55:28 bs0058 kernel: RPC:      xprt_sendmsg(100) = 100
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 xmit complete
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 sleep_on(queue "xprt_pending"
time 9999201220)
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 added to queue
000001003fd304f0 "xprt_pending"
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 setting alarm for 60000 ms
Oct 26 09:55:28 bs0058 kernel: RPC:      wake_up_next(000001003fd304a8
"xprt_resend")
Oct 26 09:55:28 bs0058 kernel: RPC:      wake_up_next(000001003fd30460
"xprt_sending")
Oct 26 09:55:28 bs0058 kernel: RPC: 51105 sync task going to sleep
Oct 26 09:55:29 bs0058 kernel: RPC:      tcp_data_ready...
Oct 26 09:55:29 bs0058 kernel: RPC:      tcp_data_recv
Oct 26 09:55:29 bs0058 kernel: RPC:      reading TCP record fragment of
length 112
Oct 26 09:55:29 bs0058 kernel: RPC:      reading XID (4 bytes)
Oct 26 09:55:29 bs0058 kernel: RPC:      reading reply for XID 7257a96b
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 received reply complete
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 has input (112 bytes)
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 __rpc_wake_up_task (now
9999201221 inh 0)
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 disabling timer
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 removed from queue
000001003fd304f0 "xprt_pending"
Oct 26 09:55:29 bs0058 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:55:29 bs0058 kernel: RPC:      tcp_data_recv done
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 sync task resuming
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 deleting timer
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 call_status (status 112)
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 call_decode (status 112)
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 validating UNIX cred
000001003f832ec0
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 using UNIX cred
000001003f832ec0 to unwrap rpc data
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 call_decode result 0
Oct 26 09:55:29 bs0058 kernel: RPC: 51105 exit() = 0
Oct 26 09:55:30 bs0058 kernel: RPC: 51105 release task
Oct 26 09:55:30 bs0058 kernel: RPC: 51105 disabling timer
Oct 26 09:55:30 bs0058 kernel: RPC: 51105 release request
000001000fc2c108
Oct 26 09:55:30 bs0058 kernel: RPC:      wake_up_next(000001003fd30538
"xprt_backlog")
Oct 26 09:55:30 bs0058 kernel: RPC: 51105 releasing UNIX cred
000001003f832ec0
Oct 26 09:55:30 bs0058 kernel: RPC:
rpc_release_client(000001002ab5d600, 1)
Oct 26 09:55:30 bs0058 kernel: RPC: 51105 freeing task
Oct 26 09:55:30 bs0058 kernel: NFS reply getattr
Oct 26 09:55:30 bs0058 kernel: NFS: nfs_update_inode(0:19/2 ct=1
info=0x6)
Oct 26 09:55:30 bs0058 kernel: NFS: (0:19/2) revalidation complete
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 running timer
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 timeout (default timer)
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 __rpc_wake_up_task (now
9999218856 inh 0)
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 disabling timer
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 removed from queue
0000010037e304f0 "xprt_pending"
Oct 26 09:55:45 bs0058 kernel: RPC:      __rpc_wake_up_task done
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 sync task resuming
Oct 26 09:55:45 bs0058 kernel: RPC: error 5 connecting to server
bs0040i.hnet.kek.jp
Oct 26 09:55:45 bs0058 kernel: RPC:      wake_up_next(0000010037e304a8
"xprt_resend")
Oct 26 09:55:45 bs0058 kernel: RPC:      wake_up_next(0000010037e30460
"xprt_sending")
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 exit() = -5
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 release task
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 disabling timer
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 release request
000001002a53e948
Oct 26 09:55:45 bs0058 kernel: RPC:      wake_up_next(0000010037e30538
"xprt_backlog")
Oct 26 09:55:45 bs0058 kernel: RPC: 51104 releasing UNIX cred
000001003ff51680
Oct 26 09:55:46 bs0058 kernel: RPC:
rpc_release_client(000001000230d800, 1)
Oct 26 09:55:46 bs0058 kernel: RPC: 51104 freeing task
Oct 26 09:55:46 bs0058 kernel: NFS reply getattr
Oct 26 09:55:46 bs0058 kernel: nfs_revalidate_inode: (0:18/2) getattr
failed, error=-5
--------------bad one--------------

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
