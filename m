From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: crash in net/sunrpc/cache.c:cache_clean() during shutdown.
Date: Fri, 29 Jun 2007 16:01:44 +0200
Message-ID: <20070629140144.GA23755@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4H2f-0005Sh-Na
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 07:01:49 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I4H2i-0003Ww-Ie
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 07:01:49 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

2.6.21.5:

Jun 29 15:40:15 nfs4 kernel: nfsd: last server has exited
Jun 29 15:40:15 nfs4 kernel: nfsd: unexporting all filesystems
Jun 29 15:40:15 nfs4 kernel: BUG: unable to handle kernel paging request at virtual address 6b6b6b6f
Jun 29 15:40:15 nfs4 kernel:  printing eip:
Jun 29 15:40:15 nfs4 kernel: c053f4d4
Jun 29 15:40:15 nfs4 kernel: *pde = 00000000
Jun 29 15:40:15 nfs4 kernel: Oops: 0000 [#1]
Jun 29 15:40:15 nfs4 kernel: SMP
Jun 29 15:40:15 nfs4 kernel: Modules linked in:
Jun 29 15:40:15 nfs4 kernel: CPU:    0
Jun 29 15:40:15 nfs4 kernel: EIP:    0060:[<c053f4d4>]    Not tainted VLI
Jun 29 15:40:15 nfs4 kernel: EFLAGS: 00010202   (2.6.21.5-x159 #1)
Jun 29 15:40:15 nfs4 kernel: EIP is at cache_clean+0x124/0x1e0
Jun 29 15:40:15 nfs4 kernel: eax: 00000000   ebx: 6b6b6b6b   ecx: c06dffa0   edx: c0a1f380
Jun 29 15:40:15 nfs4 kernel: esi: f70b7800   edi: 00000000   ebp: f5e77f40   esp: f5e77f34
Jun 29 15:40:15 nfs4 kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Jun 29 15:40:15 nfs4 kernel: Process nfsd (pid: 3478, ti=f5e76000 task=f5e12ae0 task.ti=f5e76000)
Jun 29 15:40:15 nfs4 kernel: Stack: c06dffa0 f7b8e0c4 f7b8e090 f5e77f48 c053f5df f5e77f54 c053f61a f7b8e0bc
Jun 29 15:40:15 nfs4 kernel:        f5e77f5c c020ef47 f5e77f70 c0205632 c06597c8 f7b8e0c4 f6d1c8c4 f5e77f94
Jun 29 15:40:15 nfs4 kernel:        c0537a63 f5e16000 f5e77f94 00000286 f7b8e0cc f5e16000 f6d1c8c4 f7b8e090
Jun 29 15:40:15 nfs4 kernel: Call Trace:
Jun 29 15:40:15 nfs4 kernel:  [<c01054a9>] show_trace_log_lvl+0x19/0x30
Jun 29 15:40:15 nfs4 kernel:  [<c010556b>] show_stack_log_lvl+0x8b/0xb0
Jun 29 15:40:15 nfs4 kernel:  [<c01057c6>] show_registers+0x1e6/0x310
Jun 29 15:40:15 nfs4 kernel:  [<c0105a4f>] die+0x10f/0x240
Jun 29 15:40:15 nfs4 kernel:  [<c0115f82>] do_page_fault+0x342/0x610
Jun 29 15:40:15 nfs4 kernel:  [<c054d0ec>] error_code+0x7c/0x90
Jun 29 15:40:15 nfs4 kernel:  [<c053f5df>] cache_flush+0xf/0x30
Jun 29 15:40:15 nfs4 kernel:  [<c053f61a>] cache_purge+0x1a/0x30
Jun 29 15:40:15 nfs4 kernel:  [<c020ef47>] nfsd_export_flush+0x17/0x30
Jun 29 15:40:15 nfs4 kernel:  [<c0205632>] nfsd_last_thread+0x72/0x80
Jun 29 15:40:15 nfs4 kernel:  [<c0537a63>] svc_destroy+0x103/0x140
Jun 29 15:40:15 nfs4 kernel:  [<c0537f0a>] svc_exit_thread+0x8a/0x90
Jun 29 15:40:15 nfs4 kernel:  [<c0205ceb>] nfsd+0x24b/0x2a0
Jun 29 15:40:15 nfs4 kernel:  [<c0105317>] kernel_thread_helper+0x7/0x10
Jun 29 15:40:15 nfs4 kernel:  =======================
Jun 29 15:40:15 nfs4 kernel: Code: c0 8b 51 08 8d 34 82 8b 1e 85 db 75 1e eb 64 8b 0d 88 a6 a4 c0 8b 41 50 39 43 08 7c 25 89 de 8b 1b 85 db 74 4e 8b 0d 88 a6 a4 c0 <8b> 43 04 39 41 5c 7e 07 40 89 41 5c 8b 43 04 3b 05 00 4e 7f c0
Jun 29 15:40:15 nfs4 kernel: EIP: [<c053f4d4>] cache_clean+0x124/0x1e0 SS:ESP 0068:f5e77f34
Jun 29 15:40:24 nfs4 kernel: BUG: soft lockup detected on CPU#0!
Jun 29 15:40:24 nfs4 kernel:  [<c01054a9>] show_trace_log_lvl+0x19/0x30
Jun 29 15:40:24 nfs4 kernel:  [<c01054d2>] show_trace+0x12/0x20
Jun 29 15:40:24 nfs4 kernel:  [<c01055d4>] dump_stack+0x14/0x20
Jun 29 15:40:24 nfs4 kernel:  [<c014a8e2>] softlockup_tick+0xa2/0xc0
Jun 29 15:40:24 nfs4 kernel:  [<c012bf02>] run_local_timers+0x12/0x20
Jun 29 15:40:24 nfs4 kernel:  [<c012bd1d>] update_process_times+0x5d/0x90
Jun 29 15:40:24 nfs4 kernel:  [<c013da4c>] tick_sched_timer+0x5c/0xd0
Jun 29 15:40:24 nfs4 kernel:  [<c01393f7>] hrtimer_interrupt+0x177/0x1e0
Jun 29 15:40:24 nfs4 kernel:  [<c010fb07>] local_apic_timer_interrupt+0x57/0x60
Jun 29 15:40:24 nfs4 kernel:  [<c010fb33>] smp_apic_timer_interrupt+0x23/0x40
Jun 29 15:40:24 nfs4 kernel:  [<c0105158>] apic_timer_interrupt+0x28/0x30
Jun 29 15:40:24 nfs4 kernel:  [<c0294429>] __delay+0x9/0x10
Jun 29 15:40:24 nfs4 kernel:  [<c0296255>] __spin_lock_debug+0x55/0xd0
Jun 29 15:40:24 nfs4 kernel:  [<c0296325>] _raw_spin_lock+0x55/0x80
Jun 29 15:40:24 nfs4 kernel:  [<c054cc22>] _spin_lock+0x32/0x40
Jun 29 15:40:24 nfs4 kernel:  [<c053f3c2>] cache_clean+0x12/0x1e0
Jun 29 15:40:24 nfs4 kernel:  [<c053f5df>] cache_flush+0xf/0x30
Jun 29 15:40:24 nfs4 kernel:  [<c0540865>] write_flush+0x95/0xb0
Jun 29 15:40:24 nfs4 kernel:  [<c016e836>] vfs_write+0x86/0x130
Jun 29 15:40:24 nfs4 kernel:  [<c016e98d>] sys_write+0x3d/0x70
Jun 29 15:40:24 nfs4 kernel:  [<c0104120>] syscall_call+0x7/0xb
Jun 29 15:40:24 nfs4 kernel:  =======================


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
