From: Craig Tierney <Craig.Tierney@noaa.gov>
Subject: NFS mounts are hanging (root-over-nfs)
Date: Tue, 23 Sep 2008 12:14:43 -0600
Message-ID: <48D93213.5050600@noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rome.boulder.noaa.gov ([140.172.10.146]:44334 "EHLO
	rome.boulder.noaa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbYIWTOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 15:14:45 -0400
Received: from biplane.fsl.noaa.gov (biplane.fsl.noaa.gov [137.75.132.153])
 by email.boulder.noaa.gov
 (iPlanet Messaging Server 5.2 HotFix 2.01 (built Aug 26 2004))
 with ESMTPSA id <0K7N00794UOJNH-t2Wrdh78OVRWMI3FmOMLgad1ezVvVTDh@public.gmane.org> for
 linux-nfs@vger.kernel.org; Tue, 23 Sep 2008 18:14:44 +0000 (GMT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have been trying to track down a problem with my diskless
nodes that mount their root filesystems over NFS.  The base
OS is Centos 5.1, but we have replaced the kernel with a stock
linux-2.6.22.19.

We have two sets of nodes, one set which have 4 cores (dual
socket Woodcrest and one set that has 8 cores (dual socket Harpertown).
The reason I bring this up is that the number of hangs we get
on the Harpertown nodes is about an order-of-magnitude more than
hangs on the Woodcrest nodes.  It is a hard bug to reliably trigger,
so the hangs could be a function of the jobs run more than a race
condition that happens when a system has more cores.

When a node hangs, it is typically pingable.  I know that processes
are still running because I can get messages through syslogd and
other processes communicate (Grid Engine Daemon).

 From SysRq, I see the following process blocked:

Sep 18 15:34:27 h66 kernel: SysRq : Show Blocked State
Sep 18 15:34:27 h66 kernel:
Sep 18 15:34:27 h66 kernel:                                  free                        sibling
Sep 18 15:34:27 h66 kernel:   task                 PC        stack   pid father child younger older
Sep 18 15:34:27 h66 kernel: automount     D ffff810011c62a20     0  7115      1 (NOTLB)
Sep 18 15:34:27 h66 kernel:  ffff810267c87b18 0000000000000046 0000000000000000 0000000000000000
Sep 18 15:34:27 h66 kernel:  ffff810267c87a98 ffff8101f4e382c0 ffff81042fc9d560 000000000000045e
Sep 18 15:34:27 h66 kernel:  ffff8101f4e38470 000000018022827d 0000000104f26361 000000002f806ec0
Sep 18 15:34:27 h66 kernel: Call Trace:
Sep 18 15:34:27 h66 kernel:  [<ffffffff804994f2>] wait_for_completion+0xb2/0x100
Sep 18 15:34:27 h66 kernel:  [<ffffffff802286c0>] default_wake_function+0x0/0x10
Sep 18 15:34:27 h66 kernel:  [<ffffffff8023ebb0>] flush_cpu_workqueue+0x50/0x80
Sep 18 15:34:27 h66 kernel:  [<ffffffff8023eca0>] wq_barrier_func+0x0/0x10
Sep 18 15:34:27 h66 kernel:  [<ffffffff8023f203>] flush_workqueue+0x43/0x60
Sep 18 15:34:27 h66 kernel:  [<ffffffff804893da>] __rpc_execute+0x6a/0x270
Sep 18 15:34:27 h66 kernel:
Sep 18 15:34:27 h66 kernel: Call Trace:
Sep 18 15:34:27 h66 kernel:  [<ffffffff802fa185>] nfs_file_write+0x185/0x1f0
Sep 18 15:34:27 h66 kernel:
Sep 18 15:34:27 h66 kernel:  0000000000000000 ffff8101a14d2380 ffff81042fd275e0 000000000000188a
Sep 18 15:34:27 h66 kernel: Call Trace:
Sep 18 15:34:27 h66 kernel:  [<ffffffff8021bd7c>] do_page_fault+0x1fc/0x830
Sep 18 15:34:27 h66 kernel:

Here is another example of automounter blocking, but it seems to show a deeper call tree:

Sep 18 19:24:54 h32 kernel:                                  free                        sibling
Sep 18 19:24:54 h32 kernel:   task                 PC        stack   pid father child younger older
Sep 18 19:24:54 h32 kernel: automount     D ffff8102e09d3ba0     0 24707      1 (NOTLB)
Sep 18 19:24:54 h32 kernel:  ffff8102e09d3b18 0000000000000046 0000000000000000 ffffffff80225cdc
Sep 18 19:24:54 h32 kernel:  ffff8102e09d3a98 ffff81041571e8a0 ffff81042f057760 0000000000003a12
Sep 18 19:24:54 h32 kernel:  ffff81041571ea50 000000078022827d ffff81042cf3b9c8 000000002e95be80
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff80225cdc>] task_rq_lock+0x4c/0x90
Sep 18 19:24:54 h32 kernel:  [<ffffffff804994f2>] wait_for_completion+0xb2/0x100
Sep 18 19:24:54 h32 kernel:  [<ffffffff802286c0>] default_wake_function+0x0/0x10
Sep 18 19:24:54 h32 kernel:  [<ffffffff8023ebb0>] flush_cpu_workqueue+0x50/0x80
Sep 18 19:24:54 h32 kernel:  [<ffffffff8023eca0>] wq_barrier_func+0x0/0x10
Sep 18 19:24:54 h32 kernel:  [<ffffffff8023f203>] flush_workqueue+0x43/0x60
Sep 18 19:24:54 h32 kernel:  [<ffffffff80305031>] nfs3_proc_getattr+0x51/0x90
Sep 18 19:24:54 h32 kernel:  [<ffffffff8027ee13>] vfs_lstat_fd+0x43/0x70
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel:  0000000000000000 ffff81031a1a0080 ffff81042fd5d620 0000000000005eec
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff80256e78>] sync_page+0x38/0x50
Sep 18 19:24:54 h32 kernel:  [<ffffffff802599ba>] generic_file_aio_read+0xda/0x170
Sep 18 19:24:54 h32 kernel:  [<ffffffff8027be05>] vfs_read+0xc5/0x160
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel:  ffff8103673a1bb8 ffff810421f88a20 ffff81042fd275e0 000000000000217b
Sep 18 19:24:54 h32 kernel:  ffff810421f88bd0 0000000380256d1d 00000001017e837a 00000000673a1ba8
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff80499e2a>] __wait_on_bit_lock+0x4a/0x80
Sep 18 19:24:54 h32 kernel:  [<ffffffff80256e1f>] __lock_page+0x5f/0x70
Sep 18 19:24:54 h32 kernel:  [<ffffffff802fb344>] nfs_invalidate_mapping_nolock+0x24/0xf0
Sep 18 19:24:54 h32 kernel:  [<ffffffff802fc5a9>] nfs_revalidate_mapping+0xd9/0xe0
Sep 18 19:24:54 h32 kernel:  [<ffffffff8028cdd1>] fcntl_setlk+0x71/0x2c0
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel:  0000000000000000 ffff81042d275720 ffff81042fcd35a0 000000000000134f
Sep 18 19:24:54 h32 kernel:  ffff81042d2758d0 0000000200000001 00000001017e900d 0000000000000780
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049a25a>] __mutex_lock_slowpath+0x6a/0xb0
Sep 18 19:24:54 h32 kernel:  [<ffffffff802fc567>] nfs_revalidate_mapping+0x97/0xe0
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049b3e9>] _spin_unlock_irq+0x9/0x10
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel:  ffff81023b9d7cf8 0000000000000046 0000000000000000 0000000000000000
Sep 18 19:24:54 h32 kernel:  0000000000000000 ffff81042194ab20 ffff81042fd5d620 00000000000015f0
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049a0a2>] mutex_lock+0x22/0x30
Sep 18 19:24:54 h32 kernel:  [<ffffffff8028cdd1>] fcntl_setlk+0x71/0x2c0
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049b3e9>] _spin_unlock_irq+0x9/0x10
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel: sshd          D ffff810011c86a20     0 24440   3686 (NOTLB)
Sep 18 19:24:54 h32 kernel:  ffff810309d69cf8 0000000000000046 0000000000000000 0000000000000000
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049b3f9>] _read_unlock_irq+0x9/0x10
Sep 18 19:24:54 h32 kernel:  [<ffffffff802fb308>] nfs_zap_caches+0x28/0x40
Sep 18 19:24:54 h32 kernel:  [<ffffffff80209b6e>] system_call+0x7e/0x83
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049a25a>] __mutex_lock_slowpath+0x6a/0xb0
Sep 18 19:24:54 h32 kernel:  [<ffffffff8049b3f9>] _read_unlock_irq+0x9/0x10
Sep 18 19:24:54 h32 kernel:  [<ffffffff8027b4e9>] do_sync_read+0xd9/0x120
Sep 18 19:24:54 h32 kernel:  [<ffffffff8027c2e3>] sys_read+0x53/0x90
Sep 18 19:24:54 h32 kernel:
Sep 18 19:24:54 h32 kernel:  ffff8101fe8c1cf8 0000000000000046 0000000000000000 0000000000000000
Sep 18 19:24:54 h32 kernel:  0000000000000000 ffff8101ee13f620 ffff81042fd5d620 0000000000000dca
Sep 18 19:24:54 h32 kernel: Call Trace:
Sep 18 19:24:54 h32 kernel:  [<ffffffff8028cdd1>] fcntl_setlk+0x71/0x2c0
Sep 18 19:24:54 h32 kernel:

Other processes get stuck.   These include sshd, udevd, agetty, and init.  Automounter seems
to be the common thread.

Also, since the problem looked like NFS, I turned on both rpc_debug and nfs_debug
on all nodes.  When I did this, I was not able trigger a failure.  The only filesystems
that are managed by automounter is /home (no timeout specified, so it is 600 seconds).

Any advice on how to proceed debugging this would be appreciated.

Thanks,
Craig




-- 
Craig Tierney (craig.tierney@noaa.gov)

