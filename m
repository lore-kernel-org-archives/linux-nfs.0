From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Kernel oops, RHEL 4
Date: Tue, 29 Jan 2008 11:05:55 -0500
Message-ID: <479F4EE3.8060708@RedHat.com>
References: <56D01C1B776AEE4385D29F25E83E515C0D3166A1@0599-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbYA2QHI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 11:07:08 -0500
In-Reply-To: <56D01C1B776AEE4385D29F25E83E515C0D3166A1-sbQP5OViTqfyjpQT3Si/rsM9+qvyE0V4QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Murata, Dennis wrote:
> We have had two system crashes in the past two weeks of a RHEL 4U2 nfs
> server.  The server is running with 128 nfsd daemons, has 6GB of memory,
> kernel is 2.6.9-22.Elsmp on Dell 2850 4 cpu server.  When the kernel
> oops occurs, the system must be rebooted from the DRAC.  The server has
> approximately 600 clients.  Something very curious to me is the crashes
> both occurred on a Sunday, when there was little or no client activity.
> 
> I am enclosing part of the output from crash, we do have diskdump
> enabled.  I haven't looked at the dump myself, but am enclosing comments
> from a fellow admin:
> 
> Here's what I found from the core dump. The panic was caused by nfsd,
> but it's hard to tell exactly what triggered it. The next call in the
> stack was to ext3, so it could be a combination of ext3 and NFS. That's
> just speculation, but we may see improvement with a newer kernel.
>  Shawn
> crash> sys
> KERNEL: /usr/lib/debug/lib/modules/2.6.9-22.ELsmp/vmlinux
> DUMPFILE: vmcore
> CPUS: 4
> DATE: Sun Jan 27 10:12:10 2008
> UPTIME: 13 days, 23:40:25
> LOAD AVERAGE: 1.13, 1.16, 1.13
> TASKS: 268
> NODENAME: cis2
> RELEASE: 2.6.9-22.ELsmp
> VERSION: #1 SMP Mon Sep 19 18:00:54 EDT 2005
> MACHINE: x86_64 (3591 Mhz)
> MEMORY: 7 GB
> PANIC: "Oops: 0000 [1] SMP " (check log for details) crash> log
> [shortened for brevity] Unable to handle kernel NULL pointer dereference
> at 0000000000000018 RIP: 
> <ffffffff801e729c>{rb_insert_color+30}
> PML4 66da5067 PGD 193413067 PMD 0 
> Oops: 0000 [1] SMP 
> CPU 2 
> Modules linked in: scsi_dump diskdump nfs nfsd exportfs lockd md5 ipv6
> autofs4 sunrpc ds yenta_socket pcmcia_core dm_mirror dm_mod j
> oydev button battery ac uhci_hcd ehci_hcd hw_random shpchp e1000 floppy
> sg ext3 jbd megaraid_mbox megaraid_mm sd_mod scsi_mod
> Pid: 12055, comm: nfsd Not tainted 2.6.9-22.ELsmp
> RIP: 0010:[<ffffffff801e729c>] <ffffffff801e729c>{rb_insert_color+30}
> RSP: 0018:00000101b9d7d870 EFLAGS: 00010246
> RAX: 00000000f1927c6e RBX: 00000101ba07e508 RCX: 0000000000000000
> RDX: 00000101ba07e500 RSI: 00000101bda91880 RDI: 00000101bd374188
> RBP: 0000000000000000 R08: 00000101bd374180 R09: 00000000de3f5426
> R10: 0000000007070707 R11: 0000000007070707 R12: 00000101bd374188
> R13: 00000101bda91880 R14: 00000101bda91880 R15: 00000000f1e84300
> FS: 0000002a9589fb00(0000) GS:ffffffff804d3200(0000)
> knlGS:0000000000000000
> CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000018 CR3: 00000000bff3e000 CR4: 00000000000006e0
> Process nfsd (pid: 12055, threadinfo 00000101b9d7c000, task
> 00000101b9d517f0)
> Stack: 000001008463a18c 0000000000000040 00000101ba07e518
> 00000101ba07e508 
> ffffffffa004f894 de3f5426ba0234a8 000001008463a18c 00000101ba0234a8 
> 00000101b9d7d968 000001008463aff8 
> Call Trace:<ffffffffa004f894>{:ext3:ext3_htree_store_dirent+274} 
> <ffffffffa005539e>{:ext3:htree_dirblock_to_tree+144} 
> <ffffffffa0055460>{:ext3:ext3_htree_fill_tree+119} 
> <ffffffff802501d7>{cfq_next_request+59}
> <ffffffffa01b863c>{:exportfs:filldir_one+0} 
> <ffffffffa004faba>{:ext3:ext3_readdir+371} <ffffffff8018e923>{iput+77} 
> <ffffffffa01b863c>{:exportfs:filldir_one+0}
> <ffffffffa0055dc1>{:ext3:ext3_get_parent+148} 
> <ffffffffa01b863c>{:exportfs:filldir_one+0}
> <ffffffff80188723>{vfs_readdir+155} 
> <ffffffffa01b872d>{:exportfs:get_name+190}
> <ffffffffa01b835b>{:exportfs:find_exported_dentry+859} 
> <ffffffffa01bd064>{:nfsd:nfsd_acceptable+0}
> <ffffffff802b8258>{qdisc_restart+30} 
> <ffffffff802a9ab7>{dev_queue_xmit+525}
> <ffffffff802c5555>{ip_finish_output+356} 
> <ffffffff802c75f7>{ip_push_pending_frames+833}
> <ffffffff801313f5>{recalc_task_prio+337} 
> <ffffffff802e2043>{udp_push_pending_frames+548}
> <ffffffff802a3798>{release_sock+16} 
> <ffffffff80131483>{activate_task+124}
> <ffffffff80131931>{try_to_wake_up+734} 
> <ffffffffa01c1a9b>{:nfsd:svc_expkey_lookup+623}
> <ffffffff80145092>{set_current_groups+376} 
> <ffffffffa01b88f6>{:exportfs:export_decode_fh+87}
> <ffffffffa01bdd43>{:nfsd:fh_verify+1049} 
> <ffffffffa01c64fc>{:nfsd:nfsd3_proc_getattr+133}
> <ffffffffa01bb7af>{:nfsd:nfsd_dispatch+219} 
> <ffffffffa012d240>{:sunrpc:svc_process+1160}
> <ffffffff80132e8d>{default_wake_function+0} 
> <ffffffffa01bb2fc>{:nfsd:nfsd+0} <ffffffffa01bb534>{:nfsd:nfsd+568} 
> <ffffffff80110ca3>{child_rip+8} <ffffffffa01bb2fc>{:nfsd:nfsd+0} 
> <ffffffffa01bb2fc>{:nfsd:nfsd+0} <ffffffff80110c9b>{child_rip+0} 
> Code: 48 8b 45 18 48 39 c3 75 44 48 8b 45 10 48 85 c0 74 06 83 78 
> RIP <ffffffff801e729c>{rb_insert_color+30} RSP <00000101b9d7d870>
> CR2: 0000000000000018 
> crash> bt 
> PID: 12055 TASK: 101b9d517f0 CPU: 2 COMMAND: "nfsd"
> #0 [101b9d7d6a0] start_disk_dump at ffffffffa023828f
> #1 [101b9d7d6d0] try_crashdump at ffffffff8014a8f2
> #2 [101b9d7d6e0] do_page_fault at ffffffff80123572
> #3 [101b9d7d740] thread_return at ffffffff80303358
> #4 [101b9d7d7c0] error_exit at ffffffff80110aed
> RIP: ffffffff801e729c RSP: 00000101b9d7d870 RFLAGS: 00010246
> RAX: 00000000f1927c6e RBX: 00000101ba07e508 RCX: 0000000000000000
> RDX: 00000101ba07e500 RSI: 00000101bda91880 RDI: 00000101bd374188
> RBP: 0000000000000000 R8: 00000101bd374180 R9: 00000000de3f5426
> R10: 0000000007070707 R11: 0000000007070707 R12: 00000101bd374188
> R13: 00000101bda91880 R14: 00000101bda91880 R15: 00000000f1e84300
> ORIG_RAX: ffffffffffffffff CS: 0010 SS: 0018
> #5 [101b9d7d890] ext3_htree_store_dirent at ffffffffa004f894
> #6 [101b9d7d8d0] htree_dirblock_to_tree at ffffffffa005539e
> #7 [101b9d7d920] ext3_htree_fill_tree at ffffffffa0055460
> #8 [101b9d7d980] cfq_next_request at ffffffff802501d7
> #9 [101b9d7d9c0] ext3_readdir at ffffffffa004faba
> #10 [101b9d7d9e0] iput at ffffffff8018e923
> #11 [101b9d7da20] ext3_get_parent at ffffffffa0055dc1
> #12 [101b9d7dac0] vfs_readdir at ffffffff80188723
> #13 [101b9d7daf0] get_name at ffffffffa01b872d
> #14 [101b9d7db40] find_exported_dentry at ffffffffa01b835b
> #15 [101b9d7db90] qdisc_restart at ffffffff802b8258
> #16 [101b9d7dbd0] dev_queue_xmit at ffffffff802a9ab7
> #17 [101b9d7dbf0] ip_finish_output at ffffffff802c5555
> #18 [101b9d7dc20] ip_push_pending_frames at ffffffff802c75f7
> #19 [101b9d7dc60] recalc_task_prio at ffffffff801313f5
> #20 [101b9d7dc70] udp_push_pending_frames at ffffffff802e2043
> #21 [101b9d7dc90] release_sock at ffffffff802a3798
> #22 [101b9d7dcd0] activate_task at ffffffff80131483
> #23 [101b9d7dd00] try_to_wake_up at ffffffff80131931
> #24 [101b9d7dd10] svc_expkey_lookup at ffffffffa01c1a9b
> #25 [101b9d7dd70] set_current_groups at ffffffff80145092
> #26 [101b9d7ddb0] export_decode_fh at ffffffffa01b88f6
> #27 [101b9d7ddc0] fh_verify at ffffffffa01bdd43
> #28 [101b9d7de30] nfsd3_proc_getattr at ffffffffa01c64fc
> #29 [101b9d7de60] nfsd_dispatch at ffffffffa01bb7af
> #30 [101b9d7de90] svc_process at ffffffffa012d240
> #31 [101b9d7def0] nfsd at ffffffffa01bb534
> #32 [101b9d7df50] kernel_thread at ffffffff80110ca3 

> We have many identical servers at different sites that don't seem to
> have this problem.  The only real difference is transport, we are the
> only site using udp rather than tcp.
> Is the kernel oops caused by nfsd?  Would a system/kernel upgrade fix
> this.  We are looking at upgrading to RHEL 4 U6.
IMHO... this clearly looks like an ext3 problem to me. The fact that 
only one of your identical server is seeing this problem is just 
good luck or bad luck depending on how you look at it... ;-) Maybe
the disk on the one server might be having problems... I would
look for other error in /var/log/message prior to this crash.

Its always a good thing to keep updated to the latest released
kernel, but with out searching bugzilla.redhat.com, this problem
by or may not be fixed...

steved.
