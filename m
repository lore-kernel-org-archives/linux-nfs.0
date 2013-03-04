Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares07.inai.de ([5.9.24.206]:44508 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758429Ab3CDTK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 14:10:28 -0500
Date: Mon, 4 Mar 2013 20:10:25 +0100 (CET)
From: Jan Engelhardt <jengelh@inai.de>
To: Chuck Lever <chuck.lever@oracle.com>
cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: Inconsistent error codes between NFSv4 and v3 on network
 issues
In-Reply-To: <6AADB1AD-6FB9-42AD-8BF2-6B0B706927E5@oracle.com>
Message-ID: <alpine.LNX.2.01.1303041957050.18372@nerf07.vanv.qr>
References: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr> <6AADB1AD-6FB9-42AD-8BF2-6B0B706927E5@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Monday 2013-03-04 18:47, Chuck Lever wrote:
>> 
>> linux-3lzm:~ # strace -fe mount mount -t nfs 134.76.12.5:/X /mnt
>> Process 1477 attached
>> [pid  1515] mount("134.76.12.5:/X", "/mnt", "nfs", 0, "vers=4,addr=134.76.12.5,clientaddr=0.0.0.0") = -1 EIO (Input/output error)
>
>"clientaddr=0.0.0.0" is interesting: perhaps the mount.nfs command
>should have failed right there.

Maybe (since there is no route). Maybe not: I would interpret 0.0.0.0
as "kernel will pick something".

This kernel 3.7.9 system has rpcbind-0.2.0_git201103171419-7.1.1.x86_64
and nfs-client-1.2.7-2.1.1.x86_64.


>But, let's find out why the kernel is returning EIO.  Enter:
>
> # rpcdebug -m nfs -s all
> # rpcdebug -m rpc -s call xprt
>
>Try your NFSv4 mount command again, then post relevant excerpts from the kernel log.

[205196.949572] NFS: nfs mount opts='vers=4,addr=134.76.12.5,clientaddr=0.0.0.0'
[205196.949580] NFS:   parsing nfs mount option 'vers=4'
[205196.949586] NFS:   parsing nfs mount option 'addr=134.76.12.5'
[205196.949592] NFS:   parsing nfs mount option 'clientaddr=0.0.0.0'
[205196.949597] NFS: MNTPATH: '/X'
[205196.949600] --> nfs4_try_mount()
[205196.949607] --> nfs4_create_server()
[205196.949639] --> nfs4_init_server()
[205196.949641] --> nfs4_set_client()
[205196.949644] --> nfs_get_client(134.76.12.5,v4)
[205196.949651] NFS: get client cookie (0xffff88007abe3800/0xffff88007ba29420)
[205196.949666] RPC:       created transport ffff88007ba50800 with 65536 slots
[205196.949670] RPC:       creating nfs client for 134.76.12.5 (xprt ffff88007ba50800)
[205196.949693] RPC:     2 call_start nfs4 proc NULL (sync)
[205196.949705] RPC:     2 call_reserve (status 0)
[205196.949709] RPC:     2 reserved req ffff88007b342800 xid 11fca56c
[205196.949712] RPC:     2 call_reserveresult (status 0)
[205196.949714] RPC:     2 call_refresh (status 0)
[205196.949716] RPC:     2 call_refreshresult (status 0)
[205196.949718] RPC:     2 call_allocate (status 0)
[205196.949722] RPC:     2 call_bind (status 0)
[205196.949724] RPC:     2 call_connect xprt ffff88007ba50800 is not connected
[205196.949727] RPC:     2 xprt_connect xprt ffff88007ba50800 is not connected
[205196.949765] RPC:     2 xprt_connect_status: error 101 connecting to server 134.76.12.5
[205196.949779] RPC:     2 call_connect_status (status -5)
[205196.949791] RPC:     2 release request ffff88007b342800
[205196.949794] RPC:       rpc_release_client(ffff88007b342e00)
[205196.949797] RPC:       shutting down nfs client for 134.76.12.5
[205196.949798] RPC:       rpc_release_client(ffff88007b342e00)
[205196.949801] RPC:       destroying nfs client for 134.76.12.5
[205196.949803] RPC:       destroying transport ffff88007ba50800
[205196.949812] RPC:       disconnected transport ffff88007ba50800
[205196.949816] nfs_create_rpc_client: cannot create RPC client. Error = -5
[205196.949818] --> nfs_put_client({1})
[205196.949820] --> nfs_free_client(4)
[205196.949822] NFS: releasing client cookie (0xffff88007abe3800/0xffff88007ba29420)
[205196.949824] <-- nfs_free_client()
[205196.949826] <-- nfs4_init_client() = xerror -5
[205196.949828] <-- nfs4_set_client() = xerror -5
[205196.949829] <-- nfs4_init_server() = -5
[205196.949831] --> nfs_free_server()
[205196.949850] <-- nfs_free_server()
[205196.949852] <-- nfs4_create_server() = error -5
[205196.949856] <-- nfs4_try_mount() = -5 [error]

Just nuke your default route, and it should be easily reproducible.


>By the way, does this happen on older kernels?

On kernel 3.0.51 with rpcbind-0.1.6+git20080930-6.18.1 and
nfs-utils-1.2.3, I observe that

rtsnode1:~ # strace -fe mount -s 65535 mount -t nfs 134.76.12.5:/X /mnt -o
nfsvers=4
Process 24358 attached
Process 24357 suspended
[pid 24358] mount("134.76.12.5:/X", "/mnt", "nfs", 0,
"nfsvers=4,addr=134.76.12.5,clientaddr=0.0.0.0"
<hang, but interruptible>

rpcdebug/dmesg:
[790206.304549] NFS: nfs mount opts='nfsvers=4,addr=134.76.12.5,clientaddr=0.0.0.0'
[790206.304549] NFS:   parsing nfs mount option 'nfsvers=4'
[790206.304549] NFS:   parsing nfs mount option 'addr=134.76.12.5'
[790206.304549] NFS:   parsing nfs mount option 'clientaddr=0.0.0.0'
[790206.304549] NFS: MNTPATH: '/X'
[790206.304549] --> nfs4_try_mount()
[790206.304549] --> nfs4_create_server()
[790206.304549] --> nfs4_init_server()
[790206.304549] --> nfs4_set_client()
[790206.304549] --> nfs_get_client(134.76.12.5,v4)
[790206.304549] NFS: get client cookie (0xffff880079a16400/0xffff880079cd41e0)
[790206.304549] RPC:       created transport ffff880078f26800 with 16 slots
[790206.304549] RPC:       creating nfs client for 134.76.12.5 (xprt ffff880078f26800)
[790206.304550] RPC:    45 call_start nfs4 proc NULL (sync)
[790206.304550] RPC:    45 call_reserve (status 0)
[790206.304550] RPC:    45 reserved req ffff880037a16000 xid 68604dfd
[790206.304550] RPC:    45 call_reserveresult (status 0)
[790206.304550] RPC:    45 call_refresh (status 0)
[790206.304550] RPC:    45 call_refreshresult (status 0)
[790206.304550] RPC:    45 call_allocate (status 0)
[790206.304550] RPC:    45 call_bind (status 0)
[790206.304550] RPC:    45 call_connect xprt ffff880078f26800 is not connected
[790206.304550] RPC:    45 xprt_connect xprt ffff880078f26800 is not connected

<no further output until Ctrl-C issued>

[790320.020951] RPC:    45 xprt_connect_status: error 512 connecting to server 134.76.12.5
[790320.020960] RPC:    45 release request ffff880037a16000
[790320.020963] RPC:       rpc_release_client(ffff880079bc0200)
[790320.020968] RPC:       shutting down nfs client for 134.76.12.5
[790320.020970] RPC:       rpc_release_client(ffff880079bc0200)
[790320.020973] RPC:       destroying nfs client for 134.76.12.5
[790320.024752] RPC:       destroying transport ffff880078f26800
[790320.024767] RPC:       disconnected transport ffff880078f26800
[790320.024772] nfs_create_rpc_client: cannot create RPC client. Error = -5
[790320.024775] <-- nfs4_init_client() = xerror -5
[790320.024777] --> nfs_put_client({1})
[790320.024781] --> nfs_free_client(4)
[790320.024783] NFS: releasing client cookie (0xffff880079a16400/0xffff880079cd41e0)
[790320.024788] <-- nfs_free_client()
[790320.024789] <-- nfs4_set_client() = xerror -5
[790320.024791] <-- nfs4_init_server() = -5
[790320.024810] --> nfs_free_server()
[790320.024816] <-- nfs_free_server()
[790320.024818] <-- nfs4_create_server() = error -5
[790320.024822] <-- nfs4_try_mount() = -5 [error]



And, if network connectivity is present, this occurs:


# strace -fe mount -s 65535 mount -t nfs 134.76.12.5:/X /mnt -o nfsvers=4
Process 24383 attached
Process 24382 suspended
[pid 24383] mount("134.76.12.5:/X", "/mnt", "nfs", 0,
"nfsvers=4,addr=134.76.12.5,clientaddr=10.10.7.142" <short wait> ) = 0
Process 24382 resumed
Process 24383 detached
--- SIGCHLD (Child exited) @ 0 (0) ---


And that then probably answers your clientaddr= concern.

So what 3.7.x does better is that it immediately identifies
EHOSTUNREACH/ENETUNREACH while 3.0.x waits for Godot.
