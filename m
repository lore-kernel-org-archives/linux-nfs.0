From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS server not responding
Date: Tue, 09 Dec 2003 14:47:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FD626ED.1010100@RedHat.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>	<shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com>	<shsr7zk5sw4.fsf@guts.uio.no> <3FCF86E9.2030300@RedHat.com>	<1070571324.8472.2.camel@opus> <3FCFA606.8030809@RedHat.com> <87y8tsj7py.fsf@nausicaa.krose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATnp4-0006X2-Hj
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 11:47:06 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ATnp3-0007Qt-Iy
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 11:47:05 -0800
To: Kyle Rose <krose@krose.org>
In-Reply-To: <87y8tsj7py.fsf@nausicaa.krose.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


This is happening on a Fedora Core kernel, right?

If so, Could you send me the exact steps you do to cause this
to happen....

SteveD.

Kyle Rose wrote:

>Got this oops using the SFS (http://www.fs.net/) userspace NFS client.
>(Basically, sfscd acts as an NFSv3 server so the SFS guys don't have
>to maintain separate kernel modules for every OS they want to support:
>instead, they use the kernel's native NFSv3 client support to populate
>the required mount points.)
>
>Dec  2 21:50:33 nausicaa kernel: Unable to handle kernel paging request at virtual address fffe4000
>Dec  2 21:50:33 nausicaa kernel:  printing eip:
>Dec  2 21:50:33 nausicaa kernel: f8cf8896
>Dec  2 21:50:33 nausicaa kernel: *pde = 00003067
>Dec  2 21:50:33 nausicaa kernel: *pte = 00000000
>Dec  2 21:50:33 nausicaa kernel: Oops: 0000 [#1]
>Dec  2 21:50:33 nausicaa kernel: CPU:    1
>Dec  2 21:50:33 nausicaa kernel: EIP:    0060:[__crc_xfrm_state_register_afinfo+3825223/3984503]    Tainted: PF 
>Dec  2 21:50:33 nausicaa kernel: EFLAGS: 00210246
>Dec  2 21:50:33 nausicaa kernel: EIP is at nfs3_xdr_readdirres+0xf6/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel: eax: fffe3ff8   ebx: fffe3fdc   ecx: 00000002   edx: fffe4000
>Dec  2 21:50:33 nausicaa kernel: esi: fffe4000   edi: 00000017   ebp: fffe3000   esp: c3d9dae4
>Dec  2 21:50:33 nausicaa kernel: ds: 007b   es: 007b   ss: 0068
>Dec  2 21:50:33 nausicaa kernel: Process ls (pid: 3445, threadinfo=c3d9c000 task=f6d5b900)
>Dec  2 21:50:33 nausicaa kernel: Stack: c19eeee0 00000003 00000000 c3d9db88 dacff0d4 dacff110 dacff078 f8988131 
>Dec  2 21:50:33 nausicaa kernel:        dacff078 e06b847c c3d9dc78 c3d9dbe4 f8cf87a0 c3d9c000 c3d9db88 ffffe000 
>Dec  2 21:50:33 nausicaa kernel:        c3d9dc04 f898bc9e c3d9db88 00000090 00000090 c3d9c000 00000000 f6d5b900 
>Dec  2 21:50:33 nausicaa kernel: Call Trace:
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
>Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
>Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>Dec  2 21:50:33 nausicaa kernel: 
>Dec  2 21:50:33 nausicaa kernel: Code: 8b 48 08 8d 50 0c 85 c9 74 07 8d 50 60 39 f2 77 3e 8b 02 83 
>Dec  2 21:50:33 nausicaa kernel:  <6>note: ls[3445] exited with preempt_count 1
>Dec  2 21:50:33 nausicaa kernel: bad: scheduling while atomic!
>Dec  2 21:50:33 nausicaa kernel: Call Trace:
>Dec  2 21:50:33 nausicaa kernel:  [schedule+1554/1568] schedule+0x612/0x620
>Dec  2 21:50:33 nausicaa kernel:  [reiserfs_commit_write+355/480] reiserfs_commit_write+0x163/0x1e0
>Dec  2 21:50:33 nausicaa kernel:  [block_prepare_write+52/80] block_prepare_write+0x34/0x50
>Dec  2 21:50:33 nausicaa kernel:  [generic_file_aio_write_nolock+1564/2976] generic_file_aio_write_nolock+0x61c/0xba0
>Dec  2 21:50:33 nausicaa kernel:  [sock_def_readable+125/128] sock_def_readable+0x7d/0x80
>Dec  2 21:50:33 nausicaa kernel:  [udp_queue_rcv_skb+449/704] udp_queue_rcv_skb+0x1c1/0x2c0
>Dec  2 21:50:33 nausicaa kernel:  [ip_local_deliver+169/480] ip_local_deliver+0xa9/0x1e0
>Dec  2 21:50:33 nausicaa kernel:  [ip_rcv+806/1110] ip_rcv+0x326/0x456
>Dec  2 21:50:33 nausicaa kernel:  [generic_file_write_nolock+126/160] generic_file_write_nolock+0x7e/0xa0
>Dec  2 21:50:33 nausicaa kernel:  [vt_console_print+97/752] vt_console_print+0x61/0x2f0
>Dec  2 21:50:33 nausicaa last message repeated 3 times
>Dec  2 21:50:33 nausicaa kernel:  [generic_file_write+92/128] generic_file_write+0x5c/0x80
>Dec  2 21:50:33 nausicaa kernel:  [reiserfs_file_write+1898/1905] reiserfs_file_write+0x76a/0x771
>Dec  2 21:50:33 nausicaa kernel:  [printk+350/400] printk+0x15e/0x190
>Dec  2 21:50:33 nausicaa kernel:  [__print_symbol+300/368] __print_symbol+0x12c/0x170
>Dec  2 21:50:33 nausicaa kernel:  [__print_symbol+63/368] __print_symbol+0x3f/0x170
>Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>Dec  2 21:50:33 nausicaa kernel:  [recalc_task_prio+142/432] recalc_task_prio+0x8e/0x1b0
>Dec  2 21:50:33 nausicaa kernel:  [vt_console_print+97/752] vt_console_print+0x61/0x2f0
>Dec  2 21:50:33 nausicaa kernel:  [process_timeout+0/16] process_timeout+0x0/0x10
>Dec  2 21:50:33 nausicaa kernel:  [do_acct_process+639/656] do_acct_process+0x27f/0x290
>Dec  2 21:50:33 nausicaa kernel:  [acct_process+67/96] acct_process+0x43/0x60
>Dec  2 21:50:33 nausicaa kernel:  [do_exit+117/944] do_exit+0x75/0x3b0
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [die+225/240] die+0xe1/0xf0
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+611/1268] do_page_fault+0x263/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [udp_sendmsg+429/2160] udp_sendmsg+0x1ad/0x870
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+267265/3984503] xdr_sendpages+0xe0/0x2b0 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [error_code+45/56] error_code+0x2d/0x38
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825223/3984503] nfs3_xdr_readdirres+0xf6/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
>Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
>Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>Dec  2 21:50:33 nausicaa kernel: 
>Dec  2 21:50:33 nausicaa kernel: bad: scheduling while atomic!
>Dec  2 21:50:33 nausicaa kernel: Call Trace:
>Dec  2 21:50:33 nausicaa kernel:  [schedule+1554/1568] schedule+0x612/0x620
>Dec  2 21:50:33 nausicaa kernel:  [zap_pmd_range+75/112] zap_pmd_range+0x4b/0x70
>Dec  2 21:50:33 nausicaa kernel:  [free_pages_and_swap_cache+86/144] free_pages_and_swap_cache+0x56/0x90
>Dec  2 21:50:33 nausicaa kernel:  [unmap_vmas+527/688] unmap_vmas+0x20f/0x2b0
>Dec  2 21:50:33 nausicaa kernel:  [exit_mmap+222/528] exit_mmap+0xde/0x210
>Dec  2 21:50:33 nausicaa kernel:  [mmput+98/176] mmput+0x62/0xb0
>Dec  2 21:50:33 nausicaa kernel:  [do_exit+299/944] do_exit+0x12b/0x3b0
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [die+225/240] die+0xe1/0xf0
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+611/1268] do_page_fault+0x263/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [udp_sendmsg+429/2160] udp_sendmsg+0x1ad/0x870
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+267265/3984503] xdr_sendpages+0xe0/0x2b0 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
>Dec  2 21:50:33 nausicaa kernel:  [error_code+45/56] error_code+0x2d/0x38
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825223/3984503] nfs3_xdr_readdirres+0xf6/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
>Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
>Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
>Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
>Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
>Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
>Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>
>I don't really have any other interesting information to share at the
>moment.  I can reproduce this reliably by accessing an SFS share,
>waiting (say) 15 minutes, and then trying to access it again,
>presumably after it has timed out.
>
>I cannot reproduce this with vanilla NFS, but this is essentially
>irrelevant to the kernel's correctness: a userspace program should
>never be able to cause the kernel to panic, no matter how ill-behaved
>it is (short of mucking directly with /proc/k{core,mem}).
>
>Suggestions?  SFS is basically unusable for me until this is fixed,
>which is unfortunate since I use it as my main file server.  It
>probably has nothing to do with the server: 2.4 clients can access a
>2.6 server just fine.  It may also have something to do with my
>particular setup, so I'm attaching my kernel config.  My hardware
>platform is:
>
>AMD Dual Opteron 244
>Tyan Thunder K8W
>1GB 333MHz SDRAM
>
>Kernel is compiled with -march=athlon.
>
>Cheers,
>Kyle
>  
>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
