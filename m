From: bert hubert <ahu@ds9a.nl>
Subject: 2.5.44: three ways to get an unkillable process
Date: Wed, 23 Oct 2002 23:15:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023211518.GA11435@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from outpost.ds9a.nl ([213.244.168.210])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184SqY-0004BN-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 14:15:23 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

After not using NFS for the past five years or so I was very happily
surprised that in 2.5.44 "it just worked", which is good.

However, some things are noteworthy.

#1 of 3

Between 2.5.44 on machines doing both NFSv3, v4, and TCP ('everything on'),
the following blocks reliably, leading to an unkillable mount process:

$ sudo mount -o udp,nfsvers=4 10.0.0.11:/ /common
NFSv5 not supported!
NFSv5 not supported!

It also logs this:
'RPC: error 97 connecting to server ,addr=10.0.0.11'

Note the missing server name.
Same for nfsvers=5! Traceback of the mount process, followed by the mount -o
tcp traceback for which I saw a patch floating around, but still.

mount         D CBF44980     0   592    569                     (NOTLB)
Call Trace:
 [<cc86ece0>] call_connect+0x70/0xa0 [sunrpc]
 [<cc872a75>] __rpc_execute+0x135/0x350 [sunrpc]
 [<c0113170>] default_wake_function+0x0/0x40
 [<cc86e53d>] rpc_call_sync+0xbd/0x100 [sunrpc]
 [<cc883518>] childq+0x0/0xc [sunrpc]
 [<cc883518>] childq+0x0/0xc [sunrpc]
 [<cc883530>] all_tasks+0x0/0x8 [sunrpc]
 [<cc883518>] childq+0x0/0xc [sunrpc]
 [<cc86ed50>] call_transmit+0x0/0x90 [sunrpc]
 [<cc871ef0>] rpc_run_timer+0x0/0x90 [sunrpc]
 [<cc8c0ba3>] nfs_proc_get_root+0x53/0x90 [nfs]
 [<cc8bbf24>] nfs_get_root+0x44/0x90 [nfs]
 [<c01bbe97>] vsnprintf+0x207/0x450
 [<c01bc107>] snprintf+0x27/0x30
 [<cc8bc024>] nfs_sb_init+0xb4/0x530 [nfs]
 [<cc8d0815>] .rodata.str1.1+0x239/0x11e4 [nfs]
 [<c011435a>] __put_task_struct+0x3a/0x80
 [<c011a149>] sys_wait4+0x1d9/0x3e0
 [<cc8d6d3c>] nfs_program+0x0/0x24 [nfs]
 [<cc873f43>] rpcauth_init_credcache+0x23/0x40 [sunrpc]
 [<cc874930>] unx_create+0x50/0x80 [sunrpc]
 [<cc873ee5>] rpcauth_create+0x25/0x40 [sunrpc]
 [<cc86e15e>] rpc_create_client+0xfe/0x1b0 [sunrpc]
 [<cc87389d>] rpciod_up+0x2d/0x130 [sunrpc]
 [<cc87bad9>] .rodata.str1.1+0x401/0x968 [sunrpc]
 [<cc8bc7c6>] nfs_fill_super+0x326/0x3d0 [nfs]
 [<cc8d6d3c>] nfs_program+0x0/0x24 [nfs]
 [<c0116741>] printk+0x111/0x150
 [<c0143699>] sget+0xc9/0x100
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]
 [<cc8be38c>] nfs_get_sb+0x1ac/0x240 [nfs]
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]
 [<c014400f>] do_kern_mount+0x5f/0xe0
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]
 [<c0156ff0>] do_add_mount+0x90/0x190
 [<c0157341>] do_mount+0x181/0x1d0
 [<c02b7a54>] crc32_be+0x1c14/0x31e0
 [<c01577d1>] sys_mount+0xb1/0xe0
 [<c01076af>] syscall_call+0x7/0xb


#2 of 3

Another one:
# mount -o tcp 10.0.0.11:/ /common
Hangs as well, traceback of mount process:
mount         D C6A1A000     0   643	558                 566 (NOTLB)
Call Trace:
 [<cc86ed81>] call_transmit+0x31/0x90 [sunrpc]
 [<cc872a75>] __rpc_execute+0x135/0x350 [sunrpc]
 [<c0113170>] default_wake_function+0x0/0x40
 [<cc86e53d>] rpc_call_sync+0xbd/0x100 [sunrpc]
 [<cc883530>] all_tasks+0x0/0x8 [sunrpc]
 [<cc883530>] all_tasks+0x0/0x8 [sunrpc]
 [<cc870980>] xprt_timer+0x0/0x110 [sunrpc]
 [<cc86ede0>] call_status+0x0/0x100 [sunrpc]
 [<cc871ef0>] rpc_run_timer+0x0/0x90 [sunrpc]
 [<c02710bf>] nf_hook_slow+0xdf/0x1b0
 [<cc8c5824>] nfs3_rpc_wrapper+0x44/0x90 [nfs]
 [<cc8c5913>] nfs3_proc_get_root+0x53/0x90 [nfs]
 [<cc8bbf24>] nfs_get_root+0x44/0x90 [nfs]
 [<c01bbe97>] vsnprintf+0x207/0x450
 [<c01bc107>] snprintf+0x27/0x30   
 [<cc8bc024>] nfs_sb_init+0xb4/0x530 [nfs]
 [<cc8d0815>] .rodata.str1.1+0x239/0x11e4 [nfs]
 [<c011435a>] __put_task_struct+0x3a/0x80
 [<c011a149>] sys_wait4+0x1d9/0x3e0
 [<cc8d6d3c>] nfs_program+0x0/0x24 [nfs]
 [<cc873f43>] rpcauth_init_credcache+0x23/0x40 [sunrpc]
 [<cc874930>] unx_create+0x50/0x80 [sunrpc]
 [<cc873ee5>] rpcauth_create+0x25/0x40 [sunrpc]
 [<cc86e15e>] rpc_create_client+0xfe/0x1b0 [sunrpc]
 [<cc87389d>] rpciod_up+0x2d/0x130 [sunrpc]
 [<cc87bad9>] .rodata.str1.1+0x401/0x968 [sunrpc]
 [<cc8bc7c6>] nfs_fill_super+0x326/0x3d0 [nfs]   
 [<cc8d6d3c>] nfs_program+0x0/0x24 [nfs]
 [<c0143699>] sget+0xc9/0x100
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]
 [<cc8be38c>] nfs_get_sb+0x1ac/0x240 [nfs]
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]  
 [<c014400f>] do_kern_mount+0x5f/0xe0     
 [<cc8d6de0>] nfs_fs_type+0x0/0x20 [nfs]  
 [<c0156ff0>] do_add_mount+0x90/0x190     
 [<c0157341>] do_mount+0x181/0x1d0        
 [<c01577d1>] sys_mount+0xb1/0xe0         
 [<c01076af>] syscall_call+0x7/0xb        

#3 of 3

# mount 10.0.0.11:/ /common
$ cp kernel-image-2.5.44_10.00.Custom_i386.deb /common/tmp

Freezes, unkillable. The file is 0 bytes long when viewed locally on
10.0.0.11, file is about 2 megabytes. Traceback of cp process:

cp            D 00000000     0   590	556			(NOTLB)
Call Trace:
 [<cc8c03c5>] nfs_wait_on_request+0x85/0x160 [nfs]
 [<c0113170>] default_wake_function+0x0/0x40
 [<cc8c093c>] nfs_try_to_free_pages+0x2c/0x110 [nfs]
 [<cc8c006c>] nfs_create_request+0x8c/0x110 [nfs]   
 [<c01144f0>] autoremove_wake_function+0x0/0x50     
 [<cc8c3d89>] nfs_update_request+0xb9/0x2e0 [nfs]   
 [<cc8c41b8>] nfs_updatepage+0xc8/0x2b0 [nfs]
 [<c012c5b0>] generic_file_write_nolock+0x3a0/0xa30
 [<c0108e85>] do_IRQ+0xc5/0xd0
 [<cc8d6c40>] nfs_file_aops+0x0/0x40 [nfs]
 [<c012b782>] file_read_actor+0x32/0x100  
 [<c012b5a4>] do_generic_mapping_read+0x1e4/0x390
 [<c012b750>] file_read_actor+0x0/0x100
 [<c012ba26>] __generic_file_aio_read+0x1d6/0x210
 [<c012ccd0>] generic_file_write+0x70/0x90
 [<cc8bb634>] nfs_file_write+0x94/0xf0 [nfs]
 [<cc8d6b80>] nfs_file_operations+0x0/0x60 [nfs]
 [<c013db0c>] do_sync_write+0x8c/0xc0
 [<c011ee76>] update_process_times+0x46/0x60
 [<c011113f>] x86_profile_hook+0x1f/0x30
 [<c013dc1c>] vfs_write+0xdc/0x150
 [<c013dd2e>] sys_write+0x3e/0x60 
 [<c01076af>] syscall_call+0x7/0xb

The same happens when mounting with nfsvers=3.

tcpdump shows this:
23:01:43.856500 10.0.0.11 > 10.0.0.216: icmp: ip reassembly time exceeded
[tos 0xc0] 

The problem goes away with wsize=1024,rsize=1024. Traffic the other way
however, 'pull', always works.

Let me know how I can help resolve these issues.

Good luck!

Regardsm

bert hubert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
