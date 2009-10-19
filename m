From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.31.4: Oops
Date: Sun, 18 Oct 2009 20:49:50 -0700
Message-ID: <20091018204950.7cc299ec.akpm@linux-foundation.org>
References: <20091014115306.2a87a7a4.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34305 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbZJSDwN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Oct 2009 23:52:13 -0400
In-Reply-To: <20091014115306.2a87a7a4.skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Wed, 14 Oct 2009 11:53:06 +0200 Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org> wrote:

> Hello all,
> 
> just received this one:
> 
> Oct 13 20:16:02 box kernel: BUG: unable to handle kernel paging request at ffffff98
> Oct 13 20:16:02 box kernel: IP: [<f827b2e4>] nfs_writepages+0x13/0xad [nfs]
> Oct 13 20:16:02 box kernel: *pde = 0042d067 *pte = 00000000
> Oct 13 20:16:02 box kernel: Oops: 0002 [#1]
> Oct 13 20:16:02 box kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:03:08.0/subsystem_device
> Oct 13 20:16:02 box kernel: Modules linked in: speedstep_lib freq_table nfs lockd sunrpc e100 mii e1000
> Oct 13 20:16:02 box kernel:
> Oct 13 20:16:02 box kernel: Pid: 4638, comm: httpd2-prefork Not tainted (2.6.31.4 #1)
> Oct 13 20:16:02 box kernel: EIP: 0060:[<f827b2e4>] EFLAGS: 00010292 CPU: 0
> Oct 13 20:16:02 box kernel: EIP is at nfs_writepages+0x13/0xad [nfs]
> Oct 13 20:16:02 box kernel: EAX: f0d0f654 EBX: 0000000a ECX: 00000020 EDX: f6393ecc
> Oct 13 20:16:02 box kernel: ESI: f0d0f654 EDI: 00000000 EBP: ffffff98 ESP: f6393e38
> Oct 13 20:16:02 box kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> Oct 13 20:16:02 box kernel: Process httpd2-prefork (pid: 4638, ti=f6392000 task=f63f7850 task.ti=f6392000)
> Oct 13 20:16:03 box kernel: Stack:
> Oct 13 20:16:03 box kernel:  f6393ecc f0d0f654 00000000 c0161f93 002283a0 00000000 00000000 f6088052
> Oct 13 20:16:03 box kernel: <0> f4d0f7ec f6393e6c f715ca00 f827362e f700d900 f4d08a14 0000000a f0d0f654
> Oct 13 20:16:03 box kernel: <0> f6393ecc 00000020 f827c7ce 0000000a f6393ec4 f6393ef4 f0d0f654 f827c85e
> Oct 13 20:16:03 box kernel: Call Trace:
> Oct 13 20:16:03 box kernel:  [<c0161f93>] ? __link_path_walk+0x840/0x910
> Oct 13 20:16:03 box kernel:  [<f827362e>] ? __nfs_revalidate_inode+0x105/0x18a [nfs]
> Oct 13 20:16:03 box kernel:  [<f827c7ce>] ? __nfs_write_mapping+0xf/0x3b [nfs]
> Oct 13 20:16:03 box kernel:  [<f827c85e>] ? nfs_write_mapping+0x64/0x6c [nfs]
> Oct 13 20:16:03 box kernel:  [<c01e0341>] ? __copy_to_user_ll+0x3e/0x45
> Oct 13 20:16:03 box kernel:  [<f8273238>] ? nfs_getattr+0x34/0xaf [nfs]
> Oct 13 20:16:03 box kernel:  [<f8273204>] ? nfs_getattr+0x0/0xaf [nfs]
> Oct 13 20:16:03 box kernel:  [<c015dce1>] ? vfs_getattr+0x21/0x30
> Oct 13 20:16:03 box kernel:  [<c015dd6e>] ? vfs_fstatat+0x4d/0x61
> Oct 13 20:16:03 box kernel:  [<c015dda7>] ? vfs_lstat+0x13/0x15
> Oct 13 20:16:03 box kernel:  [<c015e2fc>] ? sys_lstat64+0xf/0x23
> Oct 13 20:16:03 box kernel:  [<c0102848>] ? sysenter_do_call+0x12/0x26
> Oct 13 20:16:03 box kernel: Code: c3 56 89 c6 53 e8 4a ff ff ff 89 c3 89 f0 e8 5b 0e ec c7 89 d8 5b 5e c3 55 57 56 53 83 ec 38 89 44 24 04 89 14 24 8b 38 8d 6f 98 <0f> ba 6f 98 04 19 c0 31 d2 85 c0 74 19 68 82 00 00 00 ba 04 00
> Oct 13 20:16:03 box kernel: EIP: [<f827b2e4>] nfs_writepages+0x13/0xad [nfs] SS:ESP 0068:f6393e38
> Oct 13 20:16:03 box kernel: CR2: 00000000ffffff98
> Oct 13 20:16:03 box kernel: ---[ end trace 8d9ba71dd690c760 ]---
> 
> box is:
> 
> 0000:00:00.0 Host bridge: Intel Corp. 82875P Memory Controller Hub (rev 02)
> 0000:00:01.0 PCI bridge: Intel Corp. 82875P Processor to AGP Controller (rev 02)
> 0000:00:03.0 PCI bridge: Intel Corp. 82875P Processor to PCI to CSA Bridge (rev 02)
> 0000:00:06.0 System peripheral: Intel Corp. 82875P Processor to I/O Memory Interface (rev 02)
> 0000:00:1d.0 USB Controller: Intel Corp. 82801EB USB (rev 02)
> 0000:00:1d.1 USB Controller: Intel Corp. 82801EB USB (rev 02)
> 0000:00:1d.2 USB Controller: Intel Corp. 82801EB USB (rev 02)
> 0000:00:1d.3 USB Controller: Intel Corp. 82801EB USB (rev 02)
> 0000:00:1d.7 USB Controller: Intel Corp. 82801EB USB2 (rev 02)
> 0000:00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev c2)
> 0000:00:1f.0 ISA bridge: Intel Corp. 82801EB LPC Interface Controller (rev 02)
> 0000:00:1f.1 IDE interface: Intel Corp. 82801EB Ultra ATA Storage Controller (rev 02)
> 0000:00:1f.3 SMBus: Intel Corp. 82801EB SMBus Controller (rev 02)
> 0000:02:01.0 Ethernet controller: Intel Corp. 82547EI Gigabit Ethernet Controller (LOM)
> 0000:03:02.0 Ethernet controller: Intel Corp. 82541EI Gigabit Ethernet Controller (Copper)
> 0000:03:07.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
> 0000:03:08.0 Ethernet controller: Intel Corp.: Unknown device 1051 (rev 02)
> 
> mem is:
> 
> # cat /proc/meminfo 
> MemTotal:        2076260 kB
> MemFree:           93704 kB
> Buffers:          112964 kB
> Cached:          1510252 kB
> SwapCached:            0 kB
> Active:           366932 kB
> Inactive:        1492284 kB
> Active(anon):     144868 kB
> Inactive(anon):    91208 kB
> Active(file):     222064 kB
> Inactive(file):  1401076 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:       1187784 kB
> HighFree:          20336 kB
> LowTotal:         888476 kB
> LowFree:           73368 kB
> SwapTotal:        497972 kB
> SwapFree:         497972 kB
> Dirty:               104 kB
> Writeback:             0 kB
> AnonPages:        236012 kB
> Mapped:            12640 kB
> Slab:             115316 kB
> SReclaimable:     107848 kB
> SUnreclaim:         7468 kB
> PageTables:         2544 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     1536100 kB
> Committed_AS:     791912 kB
> VmallocTotal:     122880 kB
> VmallocUsed:        1828 kB
> VmallocChunk:     120184 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       4096 kB
> DirectMap4k:        8184 kB
> DirectMap4M:      901120 kB
> 
> Feel free to ask further questions when necessary.

