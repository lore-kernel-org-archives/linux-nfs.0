From: Kevin Jamieson <kevin@kevinjamieson.com>
Subject: Re: several oopses of nfsd in 2.6.16.29
Date: Tue, 05 Dec 2006 21:33:16 -0800
Message-ID: <4576561C.9040607@kevinjamieson.com>
Reply-To: kevin@kevinjamieson.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQJ-0006YC-W5
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:28 -0800
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]
	helo=pd2mo1so.prod.shaw.ca)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GrpQK-0008Cn-RC
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:29 -0800
Received: from pd4mr3so.prod.shaw.ca
	(pd4mr3so-qfe3.prod.shaw.ca [10.0.141.214]) by l-daemon
	(Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
	with ESMTP id <0J9U00AHR7EZGR40@l-daemon> for nfs@lists.sourceforge.net;
	Tue, 05 Dec 2006 22:32:59 -0700 (MST)
Received: from pn2ml1so.prod.shaw.ca ([10.0.121.145])
	by pd4mr3so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05
	(built Sep
	5 2006)) with ESMTP id <0J9U00JT17EWU671@pd4mr3so.prod.shaw.ca> for
	nfs@lists.sourceforge.net; Tue, 05 Dec 2006 22:32:59 -0700 (MST)
Received: from mail.kevinjamieson.com ([24.87.84.75])
	by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15
	2004))
	with ESMTP id <0J9U005VL7EWUN30@l-daemon> for nfs@lists.sourceforge.net;
	Tue, 05 Dec 2006 22:32:56 -0700 (MST)
Received: from [192.168.1.110] (bender.lan.kevinjamieson.com [192.168.1.110])
	by mail.kevinjamieson.com (Postfix) with ESMTP id 6ACDBE6326	for
	<nfs@lists.sourceforge.net>; Tue, 05 Dec 2006 21:33:29 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

 > There's a remote chance this is related to ACLs though, as the
 > first crash is in an ACL call. Are you using ACLs at all?

I am seeing similar oopses on a 2.6.16.21 Linux server in conjunction 
with a Solaris 8 client using NFSv2 with ACL support enabled (although 
no ACLs actually created). The problem does not occur with NFSv3 or with 
ACL support disabled.

On the Linux server:

dc1-gn1:~ # uname -a
Linux dc1-gn1 2.6.16.21-0.8-smp #1 SMP Mon Jul 3 18:25:39 UTC 2006 i686 
i686 i386 GNU/Linux
dc1-gn1:~ # cat /etc/exports
/tmp 192.168.0.0/16(ro,all_squash,anonuid=60000,sync)
dc1-gn1:~ # ls /tmp
foo
dc1-gn1:~ #

On the Solaris client:

bash-2.03# uname -a
SunOS diamond 5.8 Generic_108528-29 sun4u sparc SUNW,Ultra-60
bash-2.03# mount -F nfs -o vers=2 192.168.130.41:/tmp /mnt/dev 

bash-2.03# ls /mnt/dev
bash-2.03# ls /mnt/dev


The second "ls" from the client triggers an oops on the server (the 
first oops in the below log).

Running a local "ls" on the Linux server itself anytime after the first 
"ls" on the Solaris client also triggers an oops (the second oops in the 
below log) and causes ls to abort:

dc1-gn1:~ # ls /tmp
Segmentation fault


This was found on the stock SuSE SLES 10 2.6.16.21 kernel, which has the 
following config:

CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_NCPFS_NFS_NS=y

The problem could not be reproduced using NFS vers=3 on the Solaris 
client (with or without ACLs enabled), and could also not be reproduced 
after rebuilding the kernel with ACLs disabled (CONFIG_NFSD_V2_ACL=n and 
CONFIG_NFSD_V3_ACL=n). So it looks like something in the NFSv2 ACL code 
may be clobbering memory.

(I also briefly tested a more recent SuSE kernel (2.6.18.2), and the 
problem was still reproducible.)


Kernel log output with nfsd debug logging enabled:

(The mount)

Dec  6 05:04:08 dc1-gn1 kernel: nfsd: exp_rootfh(/tmp [f795fd74] 
192.168.0.0/16:sda1/170370)
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: fh_compose(exp 08:01/170370 //tmp, 
ino=170370)
Dec  6 05:04:08 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 0
Dec  6 05:04:08 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 3
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: GETATTR  32: 00000001 01000800 
00029982 00000000 00000000 00000000
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: Dropping request due to malloc 
failure!
Dec  6 05:04:08 dc1-gn1 kernel: found domain 192.168.0.0/16
Dec  6 05:04:08 dc1-gn1 kernel: found fsidtype 0
Dec  6 05:04:08 dc1-gn1 kernel: found fsid length 8
Dec  6 05:04:08 dc1-gn1 kernel: Path seems to be </tmp>
Dec  6 05:04:08 dc1-gn1 kernel: Found the path /tmp
Dec  6 05:04:08 dc1-gn1 kernel: And found export
Dec  6 05:04:08 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 3
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: GETATTR  32: 00000001 01000800 
00029982 00000000 00000000 00000000
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)
Dec  6 05:04:08 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 17
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: STATFS   32: 00000001 01000800 
00029982 00000000 00000000 00000000
Dec  6 05:04:08 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)

(The first "ls" from the client)

Dec  6 05:04:21 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 3
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: GETATTR  32: 00000001 01000800 
00029982 00000000 00000000 00000000
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)
Dec  6 05:04:21 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 4
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: ACCESS(2acl)   32: 00000001 
01000800 00029982 00000000 00000000 00000000 0x1
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)
Dec  6 05:04:21 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 16
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: READDIR  32: 00000001 01000800 
00029982 00000000 00000000 00000000 1048 bytes at 0
Dec  6 05:04:21 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)

(The second "ls" from the client)

Dec  6 05:04:29 dc1-gn1 kernel: nfsd_dispatch: vers 2 proc 3
Dec  6 05:04:29 dc1-gn1 kernel: nfsd: GETATTR  32: 00000001 01000800 
00029982 00000000 00000000 00000000
Dec  6 05:04:29 dc1-gn1 kernel: nfsd: fh_verify(32: 00000001 01000800 
00029982 00000000 00000000 00000000)
Dec  6 05:04:29 dc1-gn1 kernel: Unable to handle kernel paging request 
at virtual address 207a4133
Dec  6 05:04:29 dc1-gn1 kernel:  printing eip:
Dec  6 05:04:29 dc1-gn1 kernel: c0163819
Dec  6 05:04:29 dc1-gn1 kernel: *pde = 00000000
Dec  6 05:04:29 dc1-gn1 kernel: Oops: 0000 [#1]
Dec  6 05:04:29 dc1-gn1 kernel: SMP
Dec  6 05:04:29 dc1-gn1 kernel: last sysfs file: 
/devices/pci0000:00/0000:00:1e.0/0000:04:03.0/subsystem_device
Dec  6 05:04:29 dc1-gn1 kernel: Modules linked in: nfsd lockd nfs_acl 
sunrpc xt_pkttype ipt_LOG xt_limit ip6t_REJECT xt_tcpudp ipt_REJECT 
xt_state iptable_mangle iptable_nat ip_nat iptable_filter 
ip6table_mangle ip_conntrack nfnetlink ip_tables ip6table_filter 
ip6_tables x_tables ipv6 xfs_quota loop xfs_dmapi xfs exportfs dmapi 
shpchp pci_hotplug i2c_i801 i2c_core i8xx_tco e100 intel_agp mii 
uhci_hcd agpgart e1000 ehci_hcd usbcore ext3 jbd edd fan thermal 
processor sg sr_mod cdrom ata_piix libata sd_mod scsi_mod
Dec  6 05:04:29 dc1-gn1 kernel: CPU:    0
Dec  6 05:04:29 dc1-gn1 kernel: EIP:    0060:[<c0163819>]    Not tainted VLI
Dec  6 05:04:29 dc1-gn1 kernel: EFLAGS: 00010246   (2.6.16.21-0.8-smp #1)
Dec  6 05:04:29 dc1-gn1 kernel: EIP is at vfs_getattr+0x39/0x9f
Dec  6 05:04:29 dc1-gn1 kernel: eax: 207a40f7   ebx: f79bc0d3   ecx: 
f6597f08   edx: f795fd74
Dec  6 05:04:29 dc1-gn1 kernel: esi: f6597f08   edi: f795fd74   ebp: 
f6597f08   esp: f6597ef0
Dec  6 05:04:29 dc1-gn1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  6 05:04:29 dc1-gn1 kernel: Process nfsd (pid: 4866, 
threadinfo=f6596000 task=dfc0e330)
Dec  6 05:04:29 dc1-gn1 kernel: Stack: <0>dfd42ac0 f61e7000 f6597f08 
f6060020 dfeba200 f95c6fc5 0000fffe f795fd74
Dec  6 05:04:29 dc1-gn1 kernel:        f795fd74 f6b63a80 f795fd74 
f95c174f 00000000 dfeba200 f6597f38 00000005
Dec  6 05:04:29 dc1-gn1 kernel:        f61e7008 dfeba200 f6060000 
c01204a7 f61e7800 f61e7000 dfeba200 dfeba200
Dec  6 05:04:29 dc1-gn1 kernel: Call Trace:
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95c6fc5>] 
nfs2svc_encode_fattr+0x25/0x39 [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95c174f>] fh_verify+0x45f/0x4c4 [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<c01204a7>] printk+0x14/0x18
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95c7f64>] 
nfsaclsvc_encode_attrstatres+0x0/0x1b [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95c7f6c>] 
nfsaclsvc_encode_attrstatres+0x8/0x1b [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95bf135>] nfsd_dispatch+0x125/0x170 
[nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f956f2c8>] svc_process+0x366/0x5b2 
[sunrpc]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95bf57b>] nfsd+0x18e/0x2eb [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<f95bf3ed>] nfsd+0x0/0x2eb [nfsd]
Dec  6 05:04:29 dc1-gn1 kernel:  [<c0102005>] kernel_thread_helper+0x5/0xb
Dec  6 05:04:29 dc1-gn1 kernel: Code: 8b 5a 0c f6 83 4d 01 00 00 02 75 
19 83 3d 44 ff 3b c0 00 74 10 8b 0d 40 ff 3b c0 ff 91 c4 00 00 00 85 c0 
75 66 8b 83 94 00 00 00 <8b> 70 3c 85 f6 74 0b 8b 04 24 89 e9 89 fa ff 
d6 eb 4e 89 d8 89

(The local "ls")

Dec  6 05:05:24 dc1-gn1 kernel:  NFSD: laundromat service - starting
Dec  6 05:05:24 dc1-gn1 kernel: NFSD: end of grace period
Dec  6 05:05:24 dc1-gn1 kernel: NFSD: laundromat_main - sleeping for 90 
seconds
Dec  6 05:05:25 dc1-gn1 kernel: Unable to handle kernel paging request 
at virtual address 207a411f
Dec  6 05:05:25 dc1-gn1 kernel:  printing eip:
Dec  6 05:05:25 dc1-gn1 kernel: c0168a61
Dec  6 05:05:25 dc1-gn1 kernel: *pde = 00000000
Dec  6 05:05:25 dc1-gn1 kernel: Oops: 0000 [#2]
Dec  6 05:05:25 dc1-gn1 kernel: SMP
Dec  6 05:05:25 dc1-gn1 kernel: last sysfs file: 
/devices/pci0000:00/0000:00:1e.0/0000:04:03.0/subsystem_device
Dec  6 05:05:25 dc1-gn1 kernel: Modules linked in: nfsd lockd nfs_acl 
sunrpc xt_pkttype ipt_LOG xt_limit ip6t_REJECT xt_tcpudp ipt_REJECT 
xt_state iptable_mangle iptable_nat ip_nat iptable_filter 
ip6table_mangle ip_conntrack nfnetlink ip_tables ip6table_filter 
ip6_tables x_tables ipv6 xfs_quota loop xfs_dmapi xfs exportfs dmapi 
shpchp pci_hotplug i2c_i801 i2c_core i8xx_tco e100 intel_agp mii 
uhci_hcd agpgart e1000 ehci_hcd usbcore ext3 jbd edd fan thermal 
processor sg sr_mod cdrom ata_piix libata sd_mod scsi_mod
Dec  6 05:05:25 dc1-gn1 kernel: CPU:    0
Dec  6 05:05:25 dc1-gn1 kernel: EIP:    0060:[<c0168a61>]    Not tainted VLI
Dec  6 05:05:25 dc1-gn1 kernel: EFLAGS: 00210202   (2.6.16.21-0.8-smp #1)
Dec  6 05:05:25 dc1-gn1 kernel: EIP is at __link_path_walk+0x851/0xc7e
Dec  6 05:05:25 dc1-gn1 kernel: eax: 207a40f7   ebx: f79bc0d3   ecx: 
f7ddf004   edx: f795fd74
Dec  6 05:05:25 dc1-gn1 kernel: esi: f7d36d3c   edi: f7ddf001   ebp: 
f72e9f10   esp: f72e9e20
Dec  6 05:05:25 dc1-gn1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  6 05:05:25 dc1-gn1 kernel: Process ls (pid: 6162, 
threadinfo=f72e8000 task=c1a9f350)
Dec  6 05:05:25 dc1-gn1 kernel: Stack: <0>f7ddf004 00000000 00000001 
c01419c1 00000003 c0304350 f76e6000 c0304350
Dec  6 05:05:25 dc1-gn1 kernel:        00000000 00295e98 00000003 
f7ddf001 dfd42ac0 f795fd74 f72e8000 f72e9f10
Dec  6 05:05:25 dc1-gn1 kernel:        dfc76cf0 dfd42ac0 c0168ed7 
f7ddf000 dfc76cf0 dfd42ac0 00000000 f663b0cc
Dec  6 05:05:25 dc1-gn1 kernel: Call Trace:
Dec  6 05:05:25 dc1-gn1 kernel:  [<c01419c1>] find_get_page+0x18/0x38
Dec  6 05:05:25 dc1-gn1 kernel:  [<c0168ed7>] link_path_walk+0x49/0xbd
Dec  6 05:05:25 dc1-gn1 kernel:  [<c0149da8>] vma_prio_tree_insert+0x17/0x2a
Dec  6 05:05:25 dc1-gn1 kernel:  [<c016926c>] do_path_lookup+0x1df/0x242
Dec  6 05:05:25 dc1-gn1 kernel:  [<c01699c4>] __user_walk_fd+0x29/0x3a
Dec  6 05:05:25 dc1-gn1 kernel:  [<c0163926>] vfs_stat_fd+0x15/0x3c
Dec  6 05:05:25 dc1-gn1 kernel:  [<c0149da8>] vma_prio_tree_insert+0x17/0x2a
Dec  6 05:05:25 dc1-gn1 kernel:  [<c01639da>] sys_stat64+0xf/0x23
Dec  6 05:05:25 dc1-gn1 kernel:  [<c029131e>] do_page_fault+0x16e/0x525
Dec  6 05:05:25 dc1-gn1 kernel:  [<c02911b0>] do_page_fault+0x0/0x525
Dec  6 05:05:25 dc1-gn1 kernel:  [<c0103beb>] sysenter_past_esp+0x54/0x79
Dec  6 05:05:25 dc1-gn1 kernel: Code: 04 00 00 8b 44 24 34 f6 44 24 08 
01 8b 58 0c 0f 84 f1 02 00 00 85 db 0f 84 e9 02 00 00 8b 83 94 00 00 00 
85 c0 0f 84 db 02 00 00 <83> 78 28 00 0f 84 d1 02 00 00 b8 00 e0 ff ff 
21 e0 8b 00 83 b8


Let me know if there is any additional information I can provide that 
would be useful.

Thanks,

Kevin


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
