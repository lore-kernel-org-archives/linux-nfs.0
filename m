Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from devi.upf.edu ([193.145.56.107]:57492 "EHLO devi.upf.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755005Ab1BIN5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 08:57:55 -0500
Received: from devi.upf.edu (localhost [127.0.0.1])
	by devi.upf.edu (8.13.6/8.13.6) with ESMTP id p19Dvqwq019775
	for <linux-nfs@vger.kernel.org>; Wed, 9 Feb 2011 14:57:52 +0100
Message-ID: <4D529D65.3040107@upf.edu>
Date: Wed, 09 Feb 2011 14:57:57 +0100
From: Txema Heredia Genestar <txema.heredia@upf.edu>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
References: <4D2DE18D.40604@upf.edu> <20110112183557.GB11718@fieldses.org> <4D2F1ECA.50703@upf.edu> <20110113161913.GG20946@fieldses.org> <4D2F3583.8090502@upf.edu> <20110113180534.GK20946@fieldses.org> <4D303D55.1080908@upf.edu> <B5CA5C80A1BA4CFAA7CBB56F752F6337@ws075402> <20110209000921.GA13617@fieldses.org>
In-Reply-To: <20110209000921.GA13617@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  El 09/02/11 1:09, 'J. Bruce Fields' escribió:
> On Tue, Feb 08, 2011 at 07:07:08PM +0100, Txema Heredia wrote:
>> Hi all,
>>
>> After a month or so struggling with this, and some other problems 
>> with NFSD
>> in my "old" kernel (2.6.16.60-0.39.3-smp) related with MTUs larger 
>> than 1500
>> stalling the server, I think I have found something related with my
>> inability to serve v4 filesystems:
>>
>> In /usr/src/linux/include/linux/nfsd/const.h there is this defined:
>> /*
>> * Maximum protocol version supported by knfsd
>> */
>> #define NFSSVC_MAXVERS 3
>>
>> And in /usr/src/linux/fs/nfsd/nfsctl.c we can find this:
>> err = -EINVAL;
>> if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
>> goto out;
>> ...
>> out:
>> return err;
>>
>>
>> And I found exactly the same in 2.6.34.7
>>
>> Is this "real" or some old thing that is no longer used and I shouldn't
>> worry about?
>
> Probably irrelevant.
>
> Could you tell us exactly what you've tried to do and why it's failing?
>
> --b.
I am still having the same problems with NFSv4 as described here: 
http://thread.gmane.org/gmane.linux.nfs/38156

We reached the conclusion that my kernel was way too old and I would 
need to update it in order to get new versions of pretty much everything 
involved in NFS. But as the server was in production, I wasn't (and 
still am not) able to update it in a while.

More recently I have found some other issues with NFS, this time v3:
If MTUs in both client and server are set to 9000, the server starts 16 
or more threads (in an 8 core, 10Gb RAM, 10Gb Swap system), and 24 
clients start sending write requests, the server crashes, usually (but 
not always) leaving a message as follows:

Jan 31 12:40:34 server kernel: Unable to handle kernel paging request at 
ffffa63e7c000000 RIP:
Jan 31 12:40:34 server kernel: <ffffffff8016efdd>{__handle_mm_fault+201}
Jan 31 12:40:34 server kernel: PGD 0
Jan 31 12:40:34 server kernel: Oops: 0000 [1] SMP
Jan 31 12:40:34 server kernel: last sysfs file: 
/devices/pci0000:00/0000:00:07.0/0000:05:00.0/0000:06:00.0/irq
Jan 31 12:40:34 server kernel: CPU 3
Jan 31 12:40:34 server kernel: Modules linked in: nfsd exportfs lockd 
nfs_acl xt_pkttype ipt_TCPMSS ipt_LOG xt_limit autofs4 sunrpc dock 
button battery ac softdog ip6t_REJECT xt_tcpudp ipt_REJECT xt_state ipta
ble_mangle iptable_nat ip_nat iptable_filter ip6table_mangle 
ip_conntrack nfnetlink ip_tables ip6table_filter ip6_tables x_tables 
ipv6 apparmor ext3 jbd loop usbhid uhci_hcd ehci_hcd mptctl shpchp bnx2 
usbcore
  pci_hotplug hw_random reiserfs dm_alua dm_hp_sw dm_rdac dm_emc 
dm_round_robin dm_multipath dm_snapshot edd dm_mod fan thermal processor 
qla2xxx sg firmware_class scsi_transport_fc mptsas mptscsih mptbase scsi
_transport_sas ata_piix libata sd_mod scsi_mod
Jan 31 12:40:34 server kernel: Pid: 11609, comm: top Not tainted 
2.6.16.60-0.39.3-smp #1
Jan 31 12:40:34 server kernel: RIP: 0010:[<ffffffff8016efdd>] 
<ffffffff8016efdd>{__handle_mm_fault+201}
Jan 31 12:40:34 server kernel: RSP: 0018:ffff81027b427cd8  EFLAGS: 00010286
Jan 31 12:40:34 server kernel: RAX: 0000000000000000 RBX: 
ffffa63e7c000000 RCX: ffff8102a0fb4f00
Jan 31 12:40:34 server kernel: RDX: 0000253e7c000000 RSI: 
0000000000000001 RDI: 0000000000000090
Jan 31 12:40:34 server kernel: RBP: ffff81029354c140 R08: 
0000000000000000 R09: ffff8102a0fb4f00
Jan 31 12:40:34 server kernel: R10: 0000000000000000 R11: 
ffff810299bb1f70 R12: ffff810000000000
Jan 31 12:40:34 server kernel: R13: ffff81027b427e68 R14: 
00000000005184a0 R15: 00003ffffffff000
Jan 31 12:40:34 server kernel: FS:  00002b8f521f7d70(0000) 
GS:ffff8102a5ddc940(0000) knlGS:0000000000000000
Jan 31 12:40:34 server kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
000000008005003b
Jan 31 12:40:34 server kernel: CR2: ffffa63e7c000000 CR3: 
000000029128b000 CR4: 00000000000006e0
Jan 31 12:40:34 server kernel: Process top (pid: 11609, threadinfo 
ffff81027b426000, task ffff8102a63d17e0)
Jan 31 12:40:34 server kernel: Stack: 0000000000000286 000000018013cea6 
ffff8102a0fb4f00 00000000ffffffff
Jan 31 12:40:34 server kernel:        0000000000000286 ffffffff8013cf1b 
ffff8102a53d82f0 00000001000a3051
Jan 31 12:40:34 server kernel:        0000000000000286 ffff81027b427d48
Jan 31 12:40:34 server kernel: Call Trace: 
<ffffffff8013cf1b>{try_to_del_timer_sync+84}
Jan 31 12:40:34 server kernel: <ffffffff8013cf30>{del_timer_sync+12} 
<ffffffff802ede4c>{do_page_fault+966}
Jan 31 12:40:34 server kernel: <ffffffff80199215>{__pollwait+0} 
<ffffffff8010bced>{error_exit+0}
Jan 31 12:40:34 server kernel: <ffffffff801fb293>{copy_user_generic+147} 
<ffffffff80199604>{sys_select+297}
Jan 31 12:40:34 server kernel: <ffffffff8010ae16>{system_call+126}
Jan 31 12:40:34 server kernel:
Jan 31 12:40:34 server kernel: Code: 48 83 3b 00 75 18 48 8b 7c 24 10 4c 
89 f2 48 89 de e8 d9 e1
Jan 31 12:40:34 server kernel: RIP 
<ffffffff8016efdd>{__handle_mm_fault+201} RSP <ffff81027b427cd8>
Jan 31 12:40:34 server kernel: CR2: ffffa63e7c000000
Jan 31 12:40:34 server kernel:  mm/memory.c:104: bad pgd 
ffff81029128b000(5f88a53e7c000080).
Jan 31 12:40:34 server kernel: ----------- [cut here ] --------- [please 
bite here ] ---------
Jan 31 12:40:34 server kernel: Kernel BUG at mm/mmap.c:1994
Jan 31 12:40:34 server kernel: invalid opcode: 0000 [2] SMP
Jan 31 12:40:34 server kernel: last sysfs file: 
/devices/pci0000:00/0000:00:07.0/0000:05:00.0/0000:06:00.0/irq
Jan 31 12:40:34 server kernel: CPU 3
Jan 31 12:40:34 server kernel: Modules linked in: nfsd exportfs lockd 
nfs_acl xt_pkttype ipt_TCPMSS ipt_LOG xt_limit autofs4 sunrpc dock 
button battery ac softdog ip6t_REJECT xt_tcpudp ipt_REJECT xt_state ipta
ble_mangle iptable_nat ip_nat iptable_filter ip6table_mangle 
ip_conntrack nfnetlink ip_tables ip6table_filter ip6_tables x_tables 
ipv6 apparmor ext3 jbd loop usbhid uhci_hcd ehci_hcd mptctl shpchp bnx2 
usbcore
  pci_hotplug hw_random reiserfs dm_alua dm_hp_sw dm_rdac dm_emc 
dm_round_robin dm_multipath dm_snapshot edd dm_mod fan thermal processor 
qla2xxx sg firmware_class scsi_transport_fc mptsas mptscsih mptbase scsi
_transport_sas ata_piix libata sd_mod scsi_mod
Jan 31 12:40:34 server kernel: Pid: 11609, comm: top Not tainted 
2.6.16.60-0.39.3-smp #1
Jan 31 12:40:34 server kernel: RIP: 0010:[<ffffffff80171b83>] 
<ffffffff80171b83>{exit_mmap+244}
Jan 31 12:40:34 server kernel: RSP: 0018:ffff81027b427a88  EFLAGS: 00010202
Jan 31 12:40:34 server kernel: RAX: 0000000000000000 RBX: 
00007fff58e76000 RCX: 000000000000003e
Jan 31 12:40:34 server kernel: RDX: ffff8102936d1a98 RSI: 
ffff8102936d1590 RDI: 00000000002936d1
Jan 31 12:40:34 server kernel: RBP: ffff8102a0fb4f00 R08: 
0000000000000000 R09: 0000000000000010
Jan 31 12:40:34 server kernel: R10: 0000000000000000 R11: 
0000000000000000 R12: ffff810001058580
Jan 31 12:40:34 server kernel: R13: 0000000000000000 R14: 
0000000000000000 R15: ffff8102a63d17e0
Jan 31 12:40:34 server kernel: FS:  0000000000000000(0000) 
GS:ffff8102a5ddc940(0000) knlGS:0000000000000000
Jan 31 12:40:34 server kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
000000008005003b
Jan 31 12:40:34 server kernel: CR2: ffffa63e7c000000 CR3: 
0000000000101000 CR4: 00000000000006e0
Jan 31 12:40:34 server kernel: Process top (pid: 11609, threadinfo 
ffff81027b426000, task ffff8102a63d17e0)
Jan 31 12:40:34 server kernel: Stack: 0000000000000246 0000000000000098 
ffff810001058580 ffff8102a0fb4f00
Jan 31 12:40:34 server kernel:        ffff8102a0fb4f80 ffff8102a0fb4f00 
0000000000000001 ffffffff80131770
Jan 31 12:40:34 server kernel:        ffff8102a63d17e0 0000000000000009
Jan 31 12:40:34 server kernel: Call Trace: <ffffffff80131770>{mmput+47} 
<ffffffff8013724a>{do_exit+614}
Jan 31 12:40:34 server kernel: <ffffffff802ec7fc>{__die+218} 
<ffffffff802ee153>{do_page_fault+1741}
Jan 31 12:40:34 server kernel: <ffffffff801bbe47>{proc_alloc_inode+64} 
<ffffffff8019e499>{alloc_inode+266}
Jan 31 12:40:34 server kernel: <ffffffff801fb013>{find_next_bit+89} 
<ffffffff8010bced>{error_exit+0}
Jan 31 12:40:34 server kernel: <ffffffff8016efdd>{__handle_mm_fault+201} 
<ffffffff8016ef50>{__handle_mm_fault+60}
Jan 31 12:40:34 server kernel: 
<ffffffff8013cf1b>{try_to_del_timer_sync+84} 
<ffffffff8013cf30>{del_timer_sync+12}
Jan 31 12:40:34 server kernel: <ffffffff802ede4c>{do_page_fault+966} 
<ffffffff80199215>{__pollwait+0}
Jan 31 12:40:34 server kernel: <ffffffff8010bced>{error_exit+0} 
<ffffffff801fb293>{copy_user_generic+147}
Jan 31 12:40:34 server kernel: <ffffffff80199604>{sys_select+297} 
<ffffffff8010ae16>{system_call+126}
Jan 31 12:40:34 server kernel:
Jan 31 12:40:34 server kernel: Code: 0f 0b 68 80 46 31 80 c2 ca 07 48 83 
c4 18 5b 5d 41 5c 41 5d
Jan 31 12:40:34 server kernel: RIP <ffffffff80171b83>{exit_mmap+244} RSP 
<ffff81027b427a88>
Jan 31 12:40:34 server kernel: <1>Fixing recursive fault but reboot is 
needed!
etc...
and then the system freezes.

That kernel bug points here:
(in function "void exit_mmap(struct mm_struct *mm)" )
1994: BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);


 From what I have read I can tell that this bug has been fixed recently 
in the kernel. The problem is that the fix was only to prevent showing 
the bug message when an OOM happens, as they simply added this:
vma = mm->mmap;
if (!vma) /* Can happen if dup_mmap() received an OOM */
return;

So the issue that completely freezes the system is still not handled.

This happens immediately after the first write requests are received 
when USE_KERNEL_NFSD_NUMBER is set to 16 or higher. When the number of 
threads is set to 4, this tends to also happen most of the time, but not 
always. When this occurs, that bug message is not always shown (but 
still completely freezing the server). This happens both in TCP and UDP, 
and with any r/wsize.
Nothing of this happens with MTU=1500.

Could this all be due to my old kernel or is there something else I'm 
missing?

Txema.
