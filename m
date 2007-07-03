From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: BUG: unable to handle kernel paging request at virtual
	address 6b6b6b6f
Date: Tue, 3 Jul 2007 09:17:35 +0200
Message-ID: <20070703071735.GA9481@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5cdi-0003rN-U8
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 00:17:35 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5cdl-0005X9-SB
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 00:17:38 -0700
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


I've reported this earlier but now I figured out how to reproduce it:
start nfsd with 50 instances and then try to stop it.

Jul  3 09:10:39 kernel: BUG: unable to handle kernel paging request at virtual address 6b6b6b6f
Jul  3 09:10:39 kernel:  printing eip:
Jul  3 09:10:39 kernel: c053f594
Jul  3 09:10:39 kernel: *pde = 00000000
Jul  3 09:10:39 kernel: Oops: 0000 [#1]
Jul  3 09:10:39 kernel: SMP
Jul  3 09:10:39 kernel: Modules linked in: vmthrottle
Jul  3 09:10:39 kernel: CPU:    1
Jul  3 09:10:39 kernel: EIP:    0060:[<c053f594>]    Not tainted VLI
Jul  3 09:10:39 kernel: EFLAGS: 00010202   (2.6.21.5-x160 #1)
Jul  3 09:10:39 kernel: EIP is at cache_clean+0x124/0x1e0
Jul  3 09:10:39 kernel: eax: 00000000   ebx: 6b6b6b6b   ecx: c06dffa0   edx: c0a1f380
Jul  3 09:10:39 kernel: esi: f672d800   edi: 00000000   ebp: f5a11f40   esp: f5a11f34
Jul  3 09:10:39 kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Jul  3 09:10:39 kernel: Process nfsd (pid: 4420, ti=f5a10000 task=f596c070 task.ti=f5a10000)
Jul  3 09:10:39 kernel: Stack: c06dffa0 f6a3c268 f6a3c234 f5a11f48 c053f69f f5a11f54 c053f6da f6a3c260
Jul  3 09:10:39 kernel:        f5a11f5c c020ef47 f5a11f70 c0205632 c06597c8 f6a3c268 f6a3c7ac f5a11f94
Jul  3 09:10:39 kernel:        c0537b23 f59b2000 f5a11f94 00000286 f6a3c270 f59b2000 f6a3c7ac f6a3c234
Jul  3 09:10:39 kernel: Call Trace:
Jul  3 09:10:39 kernel:  [<c01054a9>] show_trace_log_lvl+0x19/0x30
Jul  3 09:10:39 kernel:  [<c010556b>] show_stack_log_lvl+0x8b/0xb0
Jul  3 09:10:39 kernel:  [<c01057c6>] show_registers+0x1e6/0x310
Jul  3 09:10:39 kernel:  [<c0105a4f>] die+0x10f/0x240
Jul  3 09:10:39 kernel:  [<c0115f82>] do_page_fault+0x342/0x610
Jul  3 09:10:39 kernel:  [<c054d1ac>] error_code+0x7c/0x90
Jul  3 09:10:39 kernel:  [<c053f69f>] cache_flush+0xf/0x30
Jul  3 09:10:39 kernel:  [<c053f6da>] cache_purge+0x1a/0x30
Jul  3 09:10:39 kernel:  [<c020ef47>] nfsd_export_flush+0x17/0x30
Jul  3 09:10:39 kernel:  [<c0205632>] nfsd_last_thread+0x72/0x80
Jul  3 09:10:39 kernel:  [<c0537b23>] svc_destroy+0x103/0x140
Jul  3 09:10:39 kernel:  [<c0537fca>] svc_exit_thread+0x8a/0x90
Jul  3 09:10:39 kernel:  [<c0205ceb>] nfsd+0x24b/0x2a0
Jul  3 09:10:39 kernel:  [<c0105317>] kernel_thread_helper+0x7/0x10
Jul  3 09:10:39 kernel:  =======================
Jul  3 09:10:39 kernel: Code: c0 8b 51 08 8d 34 82 8b 1e 85 db 75 1e eb 64 8b 0d 88 a6 a4 c0 8b 41 50 39 43 08 7c 25 89 de 8b 1b 85 db 74 4e 8b 0d 88 a6 a4 c0 <8b> 43 04 39 41 5c 7e 07 40 89 41 5c 8b 43 04 3b 05 00 4e 7f c0
Jul  3 09:10:39 kernel: EIP: [<c053f594>] cache_clean+0x124/0x1e0 SS:ESP 0068:f5a11f34
Jul  3 09:10:48 kernel: BUG: soft lockup detected on CPU#1!
Jul  3 09:10:48 kernel:  [<c01054a9>] show_trace_log_lvl+0x19/0x30
Jul  3 09:10:48 kernel:  [<c01054d2>] show_trace+0x12/0x20
Jul  3 09:10:48 kernel:  [<c01055d4>] dump_stack+0x14/0x20
Jul  3 09:10:48 kernel:  [<c014a8e2>] softlockup_tick+0xa2/0xc0
Jul  3 09:10:48 kernel:  [<c012bf02>] run_local_timers+0x12/0x20
Jul  3 09:10:48 kernel:  [<c012bd1d>] update_process_times+0x5d/0x90
Jul  3 09:10:48 kernel:  [<c013da4c>] tick_sched_timer+0x5c/0xd0
Jul  3 09:10:48 kernel:  [<c01393f7>] hrtimer_interrupt+0x177/0x1e0
Jul  3 09:10:48 kernel:  [<c010fb07>] local_apic_timer_interrupt+0x57/0x60
Jul  3 09:10:48 kernel:  [<c010fb33>] smp_apic_timer_interrupt+0x23/0x40
Jul  3 09:10:48 kernel:  [<c0105158>] apic_timer_interrupt+0x28/0x30
Jul  3 09:10:48 kernel:  [<c02944e9>] __delay+0x9/0x10
Jul  3 09:10:48 kernel:  [<c0296315>] __spin_lock_debug+0x55/0xd0
Jul  3 09:10:48 kernel:  [<c02963e5>] _raw_spin_lock+0x55/0x80
Jul  3 09:10:48 kernel:  [<c054cce2>] _spin_lock+0x32/0x40
Jul  3 09:10:48 kernel:  [<c053f482>] cache_clean+0x12/0x1e0
Jul  3 09:10:48 kernel:  [<c053f69f>] cache_flush+0xf/0x30
Jul  3 09:10:48 kernel:  [<c0540925>] write_flush+0x95/0xb0
Jul  3 09:10:48 kernel:  [<c016e836>] vfs_write+0x86/0x130
Jul  3 09:10:48 kernel:  [<c016e98d>] sys_write+0x3d/0x70
Jul  3 09:10:48 kernel:  [<c0104120>] syscall_call+0x7/0xb
Jul  3 09:10:48 kernel:  =======================

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
