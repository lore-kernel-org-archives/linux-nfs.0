From: Kyle Rose <krose+linuxnfs@krose.org>
Subject: NFS oops in 2.6.0-test11
Date: Fri, 05 Dec 2003 11:37:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87fzfz5igi.fsf@nausicaa.krose.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASIxa-0005c7-RC
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 08:37:42 -0800
Received: from dsl092-073-159.bos1.dsl.speakeasy.net ([66.92.73.159] helo=yupa.krose.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1ASIxY-000230-TK
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 08:37:41 -0800
Received: from nausicaa.krose.org (root@nausicaa.krose.org [66.92.73.211])
	by yupa.krose.org (8.12.10/8.12.10/Debian-5) with ESMTP id hB5GbXAZ020059
	for <nfs@lists.sourceforge.net>; Fri, 5 Dec 2003 11:37:33 -0500
Received: from nausicaa.krose.org (krose@localhost [127.0.0.1])
	by nausicaa.krose.org (8.12.10/8.12.10/Debian-5) with ESMTP id hB5GbXen006362
	for <nfs@lists.sourceforge.net>; Fri, 5 Dec 2003 11:37:33 -0500
To: nfs <nfs@lists.sourceforge.net>
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

--=-=-=

Got this oops using the SFS (http://www.fs.net/) userspace NFS client.
(Basically, sfscd acts as an NFSv3 server so the SFS guys don't have
to maintain separate kernel modules for every OS they want to support:
instead, they use the kernel's native NFSv3 client support to populate
the required mount points.)

Dec  2 21:50:33 nausicaa kernel: Unable to handle kernel paging request at virtual address fffe4000
Dec  2 21:50:33 nausicaa kernel:  printing eip:
Dec  2 21:50:33 nausicaa kernel: f8cf8896
Dec  2 21:50:33 nausicaa kernel: *pde = 00003067
Dec  2 21:50:33 nausicaa kernel: *pte = 00000000
Dec  2 21:50:33 nausicaa kernel: Oops: 0000 [#1]
Dec  2 21:50:33 nausicaa kernel: CPU:    1
Dec  2 21:50:33 nausicaa kernel: EIP:    0060:[__crc_xfrm_state_register_afinfo+3825223/3984503]    Tainted: PF 
Dec  2 21:50:33 nausicaa kernel: EFLAGS: 00210246
Dec  2 21:50:33 nausicaa kernel: EIP is at nfs3_xdr_readdirres+0xf6/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel: eax: fffe3ff8   ebx: fffe3fdc   ecx: 00000002   edx: fffe4000
Dec  2 21:50:33 nausicaa kernel: esi: fffe4000   edi: 00000017   ebp: fffe3000   esp: c3d9dae4
Dec  2 21:50:33 nausicaa kernel: ds: 007b   es: 007b   ss: 0068
Dec  2 21:50:33 nausicaa kernel: Process ls (pid: 3445, threadinfo=c3d9c000 task=f6d5b900)
Dec  2 21:50:33 nausicaa kernel: Stack: c19eeee0 00000003 00000000 c3d9db88 dacff0d4 dacff110 dacff078 f8988131 
Dec  2 21:50:33 nausicaa kernel:        dacff078 e06b847c c3d9dc78 c3d9dbe4 f8cf87a0 c3d9c000 c3d9db88 ffffe000 
Dec  2 21:50:33 nausicaa kernel:        c3d9dc04 f898bc9e c3d9db88 00000090 00000090 c3d9c000 00000000 f6d5b900 
Dec  2 21:50:33 nausicaa kernel: Call Trace:
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Dec  2 21:50:33 nausicaa kernel: 
Dec  2 21:50:33 nausicaa kernel: Code: 8b 48 08 8d 50 0c 85 c9 74 07 8d 50 60 39 f2 77 3e 8b 02 83 
Dec  2 21:50:33 nausicaa kernel:  <6>note: ls[3445] exited with preempt_count 1
Dec  2 21:50:33 nausicaa kernel: bad: scheduling while atomic!
Dec  2 21:50:33 nausicaa kernel: Call Trace:
Dec  2 21:50:33 nausicaa kernel:  [schedule+1554/1568] schedule+0x612/0x620
Dec  2 21:50:33 nausicaa kernel:  [reiserfs_commit_write+355/480] reiserfs_commit_write+0x163/0x1e0
Dec  2 21:50:33 nausicaa kernel:  [block_prepare_write+52/80] block_prepare_write+0x34/0x50
Dec  2 21:50:33 nausicaa kernel:  [generic_file_aio_write_nolock+1564/2976] generic_file_aio_write_nolock+0x61c/0xba0
Dec  2 21:50:33 nausicaa kernel:  [sock_def_readable+125/128] sock_def_readable+0x7d/0x80
Dec  2 21:50:33 nausicaa kernel:  [udp_queue_rcv_skb+449/704] udp_queue_rcv_skb+0x1c1/0x2c0
Dec  2 21:50:33 nausicaa kernel:  [ip_local_deliver+169/480] ip_local_deliver+0xa9/0x1e0
Dec  2 21:50:33 nausicaa kernel:  [ip_rcv+806/1110] ip_rcv+0x326/0x456
Dec  2 21:50:33 nausicaa kernel:  [generic_file_write_nolock+126/160] generic_file_write_nolock+0x7e/0xa0
Dec  2 21:50:33 nausicaa kernel:  [vt_console_print+97/752] vt_console_print+0x61/0x2f0
Dec  2 21:50:33 nausicaa last message repeated 3 times
Dec  2 21:50:33 nausicaa kernel:  [generic_file_write+92/128] generic_file_write+0x5c/0x80
Dec  2 21:50:33 nausicaa kernel:  [reiserfs_file_write+1898/1905] reiserfs_file_write+0x76a/0x771
Dec  2 21:50:33 nausicaa kernel:  [printk+350/400] printk+0x15e/0x190
Dec  2 21:50:33 nausicaa kernel:  [__print_symbol+300/368] __print_symbol+0x12c/0x170
Dec  2 21:50:33 nausicaa kernel:  [__print_symbol+63/368] __print_symbol+0x3f/0x170
Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Dec  2 21:50:33 nausicaa kernel:  [recalc_task_prio+142/432] recalc_task_prio+0x8e/0x1b0
Dec  2 21:50:33 nausicaa kernel:  [vt_console_print+97/752] vt_console_print+0x61/0x2f0
Dec  2 21:50:33 nausicaa kernel:  [process_timeout+0/16] process_timeout+0x0/0x10
Dec  2 21:50:33 nausicaa kernel:  [do_acct_process+639/656] do_acct_process+0x27f/0x290
Dec  2 21:50:33 nausicaa kernel:  [acct_process+67/96] acct_process+0x43/0x60
Dec  2 21:50:33 nausicaa kernel:  [do_exit+117/944] do_exit+0x75/0x3b0
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [die+225/240] die+0xe1/0xf0
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+611/1268] do_page_fault+0x263/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [udp_sendmsg+429/2160] udp_sendmsg+0x1ad/0x870
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+267265/3984503] xdr_sendpages+0xe0/0x2b0 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [error_code+45/56] error_code+0x2d/0x38
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825223/3984503] nfs3_xdr_readdirres+0xf6/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Dec  2 21:50:33 nausicaa kernel: 
Dec  2 21:50:33 nausicaa kernel: bad: scheduling while atomic!
Dec  2 21:50:33 nausicaa kernel: Call Trace:
Dec  2 21:50:33 nausicaa kernel:  [schedule+1554/1568] schedule+0x612/0x620
Dec  2 21:50:33 nausicaa kernel:  [zap_pmd_range+75/112] zap_pmd_range+0x4b/0x70
Dec  2 21:50:33 nausicaa kernel:  [free_pages_and_swap_cache+86/144] free_pages_and_swap_cache+0x56/0x90
Dec  2 21:50:33 nausicaa kernel:  [unmap_vmas+527/688] unmap_vmas+0x20f/0x2b0
Dec  2 21:50:33 nausicaa kernel:  [exit_mmap+222/528] exit_mmap+0xde/0x210
Dec  2 21:50:33 nausicaa kernel:  [mmput+98/176] mmput+0x62/0xb0
Dec  2 21:50:33 nausicaa kernel:  [do_exit+299/944] do_exit+0x12b/0x3b0
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [die+225/240] die+0xe1/0xf0
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+611/1268] do_page_fault+0x263/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [udp_sendmsg+429/2160] udp_sendmsg+0x1ad/0x870
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+267265/3984503] xdr_sendpages+0xe0/0x2b0 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
Dec  2 21:50:33 nausicaa kernel:  [error_code+45/56] error_code+0x2d/0x38
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825223/3984503] nfs3_xdr_readdirres+0xf6/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+218850/3984503] call_decode+0xf1/0x210 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3824977/3984503] nfs3_xdr_readdirres+0x0/0x210 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+234063/3984503] __rpc_execute+0x21e/0x310 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+215983/3984503] rpc_call_sync+0x7e/0xc0 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+230769/3984503] rpc_run_timer+0x0/0x80 [sunrpc]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3811947/3984503] nfs3_rpc_wrapper+0x3a/0x90 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3817856/3984503] nfs3_proc_readdir+0x14f/0x1c0 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [kmem_flagcheck+6/48] kmem_flagcheck+0x6/0x30
Dec  2 21:50:33 nausicaa kernel:  [invalidate_mapping_pages+93/256] invalidate_mapping_pages+0x5d/0x100
Dec  2 21:50:33 nausicaa kernel:  [radix_tree_insert+161/192] radix_tree_insert+0xa1/0xc0
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761862/3984503] nfs_readdir_filler+0xa5/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [read_cache_page+114/560] read_cache_page+0x72/0x230
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3762807/3984503] nfs_readdir+0x186/0x730 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3761697/3984503] nfs_readdir_filler+0x0/0x160 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3813565/3984503] nfs3_proc_access+0x11c/0x150 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [buffered_rmqueue+195/336] buffered_rmqueue+0xc3/0x150
Dec  2 21:50:33 nausicaa kernel:  [__crc_xfrm_state_register_afinfo+3825505/3984503] nfs3_decode_dirent+0x0/0x250 [nfs]
Dec  2 21:50:33 nausicaa kernel:  [vfs_readdir+126/128] vfs_readdir+0x7e/0x80
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [sys_getdents64+111/169] sys_getdents64+0x6f/0xa9
Dec  2 21:50:33 nausicaa kernel:  [filldir64+0/272] filldir64+0x0/0x110
Dec  2 21:50:33 nausicaa kernel:  [syscall_call+7/11] syscall_call+0x7/0xb

I don't really have any other interesting information to share at the
moment.  I can reproduce this reliably by accessing an SFS share,
waiting (say) 15 minutes, and then trying to access it again,
presumably after it has timed out.

I cannot reproduce this with vanilla NFS, but this is essentially
irrelevant to the kernel's correctness: a userspace program should
never be able to cause the kernel to panic, no matter how ill-behaved
it is (short of mucking directly with /proc/k{core,mem}).

Suggestions?  SFS is basically unusable for me until this is fixed,
which is unfortunate since I use it as my main file server.  It
probably has nothing to do with the server: 2.4 clients can access a
2.6 server just fine.  It may also have something to do with my
particular setup, so I'm attaching my kernel config.  My hardware
platform is:

AMD Dual Opteron 244
Tyan Thunder K8W
1GB 333MHz SDRAM

Kernel is compiled with -march=athlon.

Cheers,
Kyle


--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=.config

#
# Automatically generated make config: don't edit
#
CONFIG_X86=y
CONFIG_MMU=y
CONFIG_UID16=y
CONFIG_GENERIC_ISA_DMA=y

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=y
CONFIG_CLEAN_COMPILE=y
CONFIG_STANDALONE=y

#
# General setup
#
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_SYSCTL=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
# CONFIG_EMBEDDED is not set
CONFIG_KALLSYMS=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y

#
# Loadable module support
#
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_OBSOLETE_MODPARM=y
CONFIG_MODVERSIONS=y
CONFIG_KMOD=y

#
# Processor type and features
#
CONFIG_X86_PC=y
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
CONFIG_MK7=y
# CONFIG_MK8 is not set
# CONFIG_MELAN is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CMPXCHG=y
CONFIG_X86_XADD=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_USE_3DNOW=y
CONFIG_HPET_TIMER=y
# CONFIG_HPET_EMULATE_RTC is not set
CONFIG_SMP=y
CONFIG_NR_CPUS=2
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_TSC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_NONFATAL=y
# CONFIG_X86_MCE_P4THERMAL is not set
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
CONFIG_MICROCODE=m
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
# CONFIG_EDD is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
CONFIG_HIGHMEM=y
# CONFIG_HIGHPTE is not set
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
CONFIG_HAVE_DEC_LOCK=y

#
# Power management options (ACPI, APM)
#
CONFIG_PM=y
# CONFIG_SOFTWARE_SUSPEND is not set
# CONFIG_PM_DISK is not set

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI=y
CONFIG_ACPI_BOOT=y
CONFIG_ACPI_INTERPRETER=y
# CONFIG_ACPI_SLEEP is not set
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_THERMAL=m
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_BUS=y
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_PCI=y
CONFIG_ACPI_SYSTEM=y
# CONFIG_ACPI_RELAXED_AML is not set

#
# APM (Advanced Power Management) BIOS Support
#
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
# CONFIG_CPU_FREQ_PROC_INTF is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=m
# CONFIG_CPU_FREQ_24_API is not set
CONFIG_CPU_FREQ_TABLE=m

#
# CPUFreq processor drivers
#
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_POWERNOW_K6 is not set
# CONFIG_X86_POWERNOW_K7 is not set
CONFIG_X86_POWERNOW_K8=m
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_SPEEDSTEP_ICH is not set
# CONFIG_X86_SPEEDSTEP_SMI is not set
# CONFIG_X86_P4_CLOCKMOD is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set

#
# Bus options (PCI, PCMCIA, EISA, MCA, ISA)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
CONFIG_PCI_GODIRECT=y
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_DIRECT=y
CONFIG_PCI_LEGACY_PROC=y
CONFIG_PCI_NAMES=y
CONFIG_ISA=y
# CONFIG_EISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
CONFIG_HOTPLUG=y

#
# PCMCIA/CardBus support
#
# CONFIG_PCMCIA is not set
CONFIG_PCMCIA_PROBE=y

#
# PCI Hotplug Support
#
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_AOUT=m
CONFIG_BINFMT_MISC=m

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_FW_LOADER=m

#
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Parallel port support
#
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_PC_CML1=m
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_OTHER is not set
# CONFIG_PARPORT_1284 is not set

#
# Plug and Play support
#
# CONFIG_PNP is not set

#
# Block devices
#
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_DEV_XD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_NBD=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_INITRD is not set
# CONFIG_LBD is not set

#
# ATA/ATAPI/MFM/RLL support
#
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_HD_IDE is not set
CONFIG_BLK_DEV_IDEDISK=y
CONFIG_IDEDISK_MULTI_MODE=y
# CONFIG_IDEDISK_STROKE is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDETAPE=m
CONFIG_BLK_DEV_IDEFLOPPY=m
CONFIG_BLK_DEV_IDESCSI=m
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_TASKFILE_IO=y

#
# IDE chipset support/bugfixes
#
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
CONFIG_IDEDMA_PCI_AUTO=y
# CONFIG_IDEDMA_ONLYDISK is not set
# CONFIG_IDEDMA_PCI_WIP is not set
CONFIG_BLK_DEV_ADMA=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=m
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_IDE_CHIPSETS is not set
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_IVB is not set
CONFIG_IDEDMA_AUTO=y
# CONFIG_DMA_NONPCI is not set
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
CONFIG_SCSI=m
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=m

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_REPORT_LUNS is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set

#
# SCSI low-level drivers
#
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_7000FASST is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AHA152X is not set
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_MEGARAID is not set
# CONFIG_SCSI_SATA is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_CPQFCTS is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_DTC3280 is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_EATA_PIO is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_GENERIC_NCR5380_MMIO is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
# CONFIG_SCSI_NCR53C406A is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_PSI240I is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
# CONFIG_SCSI_QLOGIC_ISP is not set
# CONFIG_SCSI_QLOGIC_FC is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_SYM53C416 is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_T128 is not set
# CONFIG_SCSI_U14_34F is not set
# CONFIG_SCSI_ULTRASTOR is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set

#
# Old CD-ROM drivers (not SCSI, not IDE)
#
# CONFIG_CD_NO_IDESCSI is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# Fusion MPT device support
#
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support (EXPERIMENTAL)
#
CONFIG_IEEE1394=m

#
# Subsystem Options
#
# CONFIG_IEEE1394_VERBOSEDEBUG is not set
# CONFIG_IEEE1394_OUI_DB is not set

#
# Device Drivers
#
CONFIG_IEEE1394_PCILYNX=m
CONFIG_IEEE1394_OHCI1394=m

#
# Protocol Drivers
#
CONFIG_IEEE1394_VIDEO1394=m
CONFIG_IEEE1394_SBP2=m
# CONFIG_IEEE1394_SBP2_PHYS_DMA is not set
CONFIG_IEEE1394_ETH1394=m
CONFIG_IEEE1394_DV1394=m
CONFIG_IEEE1394_RAWIO=m
CONFIG_IEEE1394_CMP=m
CONFIG_IEEE1394_AMDTP=m

#
# I2O device support
#
# CONFIG_I2O is not set

#
# Networking support
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
# CONFIG_NETLINK_DEV is not set
CONFIG_UNIX=y
CONFIG_NET_KEY=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
# CONFIG_INET_ECN is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
# CONFIG_IPV6 is not set
# CONFIG_DECNET is not set
# CONFIG_BRIDGE is not set
# CONFIG_NETFILTER is not set
CONFIG_XFRM=y
CONFIG_XFRM_USER=m

#
# SCTP Configuration (EXPERIMENTAL)
#
CONFIG_IPV6_SCTP__=y
CONFIG_IP_SCTP=m
# CONFIG_SCTP_ADLER32 is not set
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_HMAC_NONE=y
# CONFIG_SCTP_HMAC_SHA1 is not set
# CONFIG_SCTP_HMAC_MD5 is not set
# CONFIG_ATM is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_NET_DIVERT is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_NET_FASTROUTE is not set
# CONFIG_NET_HW_FLOWCONTROL is not set

#
# QoS and/or fair queueing
#
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NETDEVICES=y

#
# ARCnet devices
#
# CONFIG_ARCNET is not set
CONFIG_DUMMY=m
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set

#
# Ethernet (10 or 100Mbit)
#
# CONFIG_NET_ETHERNET is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SK98LIN is not set
CONFIG_TIGON3=m

#
# Ethernet (10000 Mbit)
#
# CONFIG_IXGB is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Wireless LAN (non-hamradio)
#
# CONFIG_NET_RADIO is not set

#
# Token Ring devices
#
# CONFIG_TR is not set
# CONFIG_NET_FC is not set
# CONFIG_RCPCI is not set
# CONFIG_SHAPER is not set

#
# Wan interfaces
#
# CONFIG_WAN is not set

#
# Amateur Radio support
#
# CONFIG_HAMRADIO is not set

#
# IrDA (infrared) support
#
# CONFIG_IRDA is not set

#
# Bluetooth support
#
# CONFIG_BT is not set

#
# ISDN subsystem
#
# CONFIG_ISDN_BOOL is not set

#
# Telephony Support
#
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_TSDEV is not set
CONFIG_INPUT_EVDEV=m
# CONFIG_INPUT_EVBUG is not set

#
# Input I/O drivers
#
CONFIG_GAMEPORT=m
CONFIG_SOUND_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=m
# CONFIG_GAMEPORT_VORTEX is not set
# CONFIG_GAMEPORT_FM801 is not set
# CONFIG_GAMEPORT_CS461x is not set
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=m
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
# CONFIG_JOYSTICK_GF2K is not set
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=m
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
# CONFIG_JOYSTICK_SPACEORB is not set
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDDLER is not set
# CONFIG_JOYSTICK_DB9 is not set
# CONFIG_JOYSTICK_GAMECON is not set
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_INPUT_JOYDUMP is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_PCSPKR=m
CONFIG_INPUT_UINPUT=m

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=m
# CONFIG_SERIAL_8250_ACPI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=m
CONFIG_UNIX98_PTYS=y
CONFIG_UNIX98_PTY_COUNT=256
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
# CONFIG_TIPAR is not set

#
# I2C support
#
CONFIG_I2C=m
CONFIG_I2C_CHARDEV=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
# CONFIG_I2C_ALGOPCF is not set

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=m
# CONFIG_I2C_ELV is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_ISA is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_PHILIPSPAR is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VELLEMAN is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set

#
# I2C Hardware Sensors Chip support
#
CONFIG_I2C_SENSOR=m
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM85=m
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_W83781D=m

#
# Mice
#
# CONFIG_BUSMOUSE is not set
# CONFIG_QIC02_TAPE is not set

#
# IPMI
#
# CONFIG_IPMI_HANDLER is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
CONFIG_HW_RANDOM=m
CONFIG_NVRAM=m
CONFIG_RTC=m
CONFIG_GEN_RTC=m
CONFIG_GEN_RTC_X=y
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# Ftape, the floppy tape device driver
#
CONFIG_AGP=m
# CONFIG_AGP_ALI is not set
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
CONFIG_AGP_AMD64=m
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_NVIDIA is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_SWORKS is not set
# CONFIG_AGP_VIA is not set
CONFIG_DRM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_GAMMA is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_HANGCHECK_TIMER=m

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# Digital Video Broadcasting Devices
#
# CONFIG_DVB is not set

#
# Graphics support
#
# CONFIG_FB is not set
CONFIG_VIDEO_SELECT=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_MDA_CONSOLE is not set
CONFIG_DUMMY_CONSOLE=y

#
# Sound
#
CONFIG_SOUND=m

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=m
CONFIG_SND_SEQUENCER=m
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_RTCTIMER=m
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set

#
# Generic devices
#
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set

#
# ISA devices
#
# CONFIG_SND_AD1848 is not set
# CONFIG_SND_CS4231 is not set
# CONFIG_SND_CS4232 is not set
# CONFIG_SND_CS4236 is not set
# CONFIG_SND_ES1688 is not set
# CONFIG_SND_ES18XX is not set
# CONFIG_SND_GUSCLASSIC is not set
# CONFIG_SND_GUSEXTREME is not set
# CONFIG_SND_GUSMAX is not set
# CONFIG_SND_INTERWAVE is not set
# CONFIG_SND_INTERWAVE_STB is not set
# CONFIG_SND_OPTI92X_AD1848 is not set
# CONFIG_SND_OPTI92X_CS4231 is not set
# CONFIG_SND_OPTI93X is not set
# CONFIG_SND_SB8 is not set
# CONFIG_SND_SB16 is not set
# CONFIG_SND_SBAWE is not set
# CONFIG_SND_WAVEFRONT is not set
# CONFIG_SND_CMI8330 is not set
# CONFIG_SND_OPL3SA2 is not set
# CONFIG_SND_SGALAXY is not set
# CONFIG_SND_SSCAPE is not set

#
# PCI devices
#
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS4281 is not set
CONFIG_SND_EMU10K1=m
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_YMFPCI is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=m
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VX222 is not set

#
# ALSA USB devices
#
# CONFIG_SND_USB_AUDIO is not set

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set

#
# USB support
#
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_BANDWIDTH is not set
# CONFIG_USB_DYNAMIC_MINORS is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_UHCI_HCD=m

#
# USB Device Class drivers
#
CONFIG_USB_AUDIO=m
CONFIG_USB_BLUETOOTH_TTY=m
CONFIG_USB_MIDI=m
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_HP8200e is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set

#
# USB Human Interface Devices (HID)
#
CONFIG_USB_HID=m
CONFIG_USB_HIDINPUT=y
# CONFIG_HID_FF is not set
CONFIG_USB_HIDDEV=y

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set
# CONFIG_USB_AIPTEK is not set
# CONFIG_USB_WACOM is not set
# CONFIG_USB_KBTAB is not set
# CONFIG_USB_POWERMATE is not set
# CONFIG_USB_XPAD is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_SCANNER is not set
# CONFIG_USB_MICROTEK is not set
CONFIG_USB_HPUSBSCSI=m

#
# USB Multimedia devices
#
# CONFIG_USB_DABUSB is not set

#
# Video4Linux support is needed for USB Multimedia device support
#

#
# USB Network adaptors
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set

#
# USB Serial Converter support
#
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OMNINET is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_TIGL is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_BRLVGER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GADGET is not set

#
# File systems
#
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=m
# CONFIG_EXT3_FS_XATTR is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
CONFIG_MINIX_FS=m
# CONFIG_ROMFS_FS is not set
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_ZISOFS_FS=m
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_DEVFS_FS=y
CONFIG_DEVFS_MOUNT=y
# CONFIG_DEVFS_DEBUG is not set
CONFIG_DEVPTS_FS=y
# CONFIG_DEVPTS_FS_XATTR is not set
CONFIG_TMPFS=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_RAMFS=y

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V4 is not set
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V4 is not set
# CONFIG_NFSD_TCP is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_SUNRPC=m
# CONFIG_SUNRPC_GSS is not set
CONFIG_SMB_FS=m
CONFIG_SMB_NLS_DEFAULT=y
CONFIG_SMB_NLS_REMOTE="cp437"
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_INTERMEZZO_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_SMB_NLS=y
CONFIG_NLS=y

#
# Native Language Support
#
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=m
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ISO8859_1=m
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=m

#
# Profiling support
#
# CONFIG_PROFILING is not set

#
# Kernel hacking
#
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_IOVIRT is not set
CONFIG_MAGIC_SYSRQ=y
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_HIGHMEM is not set
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_FRAME_POINTER is not set
CONFIG_X86_EXTRA_IRQS=y
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y

#
# Security options
#
# CONFIG_SECURITY is not set

#
# Cryptographic options
#
CONFIG_CRYPTO=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=m
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_TWOFISH=m
# CONFIG_CRYPTO_SERPENT is not set
CONFIG_CRYPTO_AES=m
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_TEST is not set

#
# Library routines
#
CONFIG_CRC32=m
CONFIG_ZLIB_INFLATE=m
CONFIG_ZLIB_DEFLATE=m
CONFIG_X86_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_PC=y

--=-=-=--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
