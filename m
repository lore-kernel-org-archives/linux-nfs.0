From: linuxkernel@arcor.de
Subject: several oopses of nfsd in 2.6.16.29
Date: Fri, 1 Dec 2006 09:06:35 +0100 (CET)
Message-ID: <20695426.1164960395196.JavaMail.ngmail@webmail13>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_61688_29341678.1164960395195"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq3Q4-0004C8-8n
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 00:06:52 -0800
Received: from mail-in-13.arcor-online.net ([151.189.21.53])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gq3Q3-0002IM-UN
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 00:06:53 -0800
Received: from mail-in-08-z2.arcor-online.net (mail-in-08-z2.arcor-online.net
	[151.189.8.20])
	by mail-in-13.arcor-online.net (Postfix) with ESMTP id DEA1F1E549A
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 09:06:47 +0100 (CET)
Received: from mail-in-04.arcor-online.net (mail-in-04.arcor-online.net
	[151.189.21.44])
	by mail-in-08-z2.arcor-online.net (Postfix) with ESMTP id D389B2130B4
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 09:06:47 +0100 (CET)
Received: from webmail13 (webmail13.arcor-online.net [151.189.8.66])
	by mail-in-04.arcor-online.net (Postfix) with ESMTP id BA1381FF001
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 09:06:47 +0100 (CET)
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

------=_Part_61688_29341678.1164960395195
Content-Type: multipart/alternative;
	boundary="----=_Part_61687_19331430.1164960395195"

------=_Part_61687_19331430.1164960395195
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello,

it happened again, but this time without /proc/fs/nfsd mounted.  This is getting on my nerves.
Please see attached the oopses.  Now I switched to 2.6.16.33.

cheers,

        Peter
------=_Part_61687_19331430.1164960395195--

------=_Part_61688_29341678.1164960395195
Content-Type: application/octet-stream
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=nfs.oopses

Dec  1 00:00:15 sith-1 kernel: Unable to handle kernel paging request at virtual address 00010514
Dec  1 00:00:15 sith-1 kernel:  printing eip:
Dec  1 00:00:15 sith-1 kernel: 00010514
Dec  1 00:00:15 sith-1 kernel: *pde = 00000000
Dec  1 00:00:15 sith-1 kernel: Oops: 0000 [#1]
Dec  1 00:00:15 sith-1 kernel: SMP
Dec  1 00:00:15 sith-1 kernel: Modules linked in: parport_pc lp parport mptctl ipv6 quota_v2 ext2 nfsd exportfs lockd nfs_acl sunrpc ide_disk mousedev tsdev i2c_piix4 sworks_agppsmouse i2c_core serio_raw shpchp pcspkr pci_hotplug rtc evdev agpgart floppy sg ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_generic ide_cd cdrom serverworks generic ohci_hcd ide_core sd_mod usbcore mptspi mptscsih mptbase tg3 ips scsi_mod thermal processor fan
Dec  1 00:00:15 sith-1 kernel: CPU:    1
Dec  1 00:00:15 sith-1 kernel: EIP:    0060:[<00010514>]    Not tainted VLI
Dec  1 00:00:15 sith-1 kernel: EFLAGS: 00010206   (2.6.16.29 #1)
Dec  1 00:00:15 sith-1 kernel: EIP is at 0x10514
Dec  1 00:00:15 sith-1 kernel: eax: e83f60dc   ebx: dc0110c3   ecx: dfacc440   edx: e813b7c8
Dec  1 00:00:15 sith-1 kernel: esi: e813b7c8   edi: f6d2bed4   ebp: dfacc440   esp: f6d2bea4
Dec  1 00:00:15 sith-1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  1 00:00:15 sith-1 kernel: Process nfsd (pid: 4435, threadinfo=f6d2a000 task=dfc16560)
Dec  1 00:00:15 sith-1 kernel: Stack: <0>b015e4aa dfacc440 e813b7c8 f6d2bed4 f6d0a000 f6d2bed4 f8ec072c d2ee2018
Dec  1 00:00:15 sith-1 kernel:        f8e9e38e dfacc440 e813b7c8 f6d2bed4 f8e9808c e813b7c8 f7042f40 e813b7c8
Dec  1 00:00:15 sith-1 kernel:        f8e981ed f7042f40 f8ec0480 00000001 f7e8eb20 00000006 f6d0a00c df955600
Dec  1 00:00:15 sith-1 kernel: Call Trace:
Dec  1 00:00:15 sith-1 kernel:  [vfs_getattr+65/150] vfs_getattr+0x41/0x96
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219539854/1338422272] nfs2svc_encode_fattr+0x20/0x35 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219514508/1338422272] fh_verify+0x368/0x4e3 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219514861/1338422272] fh_verify+0x4c9/0x4e3 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219544148/1338422272] nfsacld_proc_getattr+0x6a/0x71 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219545091/1338422272] nfsaclsvc_encode_attrstatres+0x13/0x29 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219507921/1338422272] nfsd_dispatch+0x133/0x17e [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219164674/1338422272] svc_process+0x352/0x588 [sunrpc]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219507262/1338422272] nfsd+0x191/0x2f1 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [pg0+1219506861/1338422272] nfsd+0x0/0x2f1 [nfsd]
Dec  1 00:00:15 sith-1 kernel:  [kernel_thread_helper+5/11] kernel_thread_helper+0x5/0xb
Dec  1 00:00:15 sith-1 kernel: Code:  Bad EIP value.
Dec  1 00:00:57 sith-1 kernel: Unable to handle kernel paging request at virtual address 00010514
Dec  1 00:00:57 sith-1 kernel:  printing eip:
Dec  1 00:00:57 sith-1 kernel: 00010514
Dec  1 00:00:57 sith-1 kernel: *pde = 00000000
Dec  1 00:00:57 sith-1 kernel: Oops: 0000 [#2]
Dec  1 00:00:57 sith-1 kernel: SMP
Dec  1 00:00:57 sith-1 kernel: Modules linked in: parport_pc lp parport mptctl ipv6 quota_v2 ext2 nfsd exportfs lockd nfs_acl sunrpc ide_disk mousedev tsdev i2c_piix4 sworks_agppsmouse i2c_core serio_raw shpchp pcspkr pci_hotplug rtc evdev agpgart floppy sg ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_generic ide_cd cdrom serverworks generic ohci_hcd ide_core sd_mod usbcore mptspi mptscsih mptbase tg3 ips scsi_mod thermal processor fan
Dec  1 00:00:57 sith-1 kernel: CPU:    2
Dec  1 00:00:57 sith-1 kernel: EIP:    0060:[<00010514>]    Not tainted VLI
Dec  1 00:00:57 sith-1 kernel: EFLAGS: 00010206   (2.6.16.29 #1)
Dec  1 00:00:57 sith-1 kernel: EIP is at 0x10514
Dec  1 00:00:57 sith-1 kernel: eax: e83f60dc   ebx: dc0110c3   ecx: dfacc440   edx: e813b7c8
Dec  1 00:00:57 sith-1 kernel: esi: e813b7c8   edi: f6d07ebc   ebp: dfacc440   esp: f6d07e7c
Dec  1 00:00:57 sith-1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  1 00:00:57 sith-1 kernel: Process nfsd (pid: 4433, threadinfo=f6d06000 task=df9a1a90)
Dec  1 00:00:57 sith-1 kernel: Stack: <0>b015e4aa dfacc440 e813b7c8 f6d07ebc b489e034 f7ee5900 f6d07ebc f7ee58ec
Dec  1 00:00:57 sith-1 kernel:        f8ea0b7f dfacc440 e813b7c8 f6d07ebc f7ee58f8 e813b7c8 f8e985af e813b7c8
Dec  1 00:00:57 sith-1 kernel:        f7ee58f8 f6d07ed4 00000000 00000001 dc0110c3 01010000 00000002 e813b7c8
Dec  1 00:00:57 sith-1 kernel: Call Trace:
Dec  1 00:00:57 sith-1 kernel:  [vfs_getattr+65/150] vfs_getattr+0x41/0x96
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219550079/1338422272] encode_post_op_attr+0x3b/0x223 [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219515823/1338422272] fh_compose+0x3a8/0x3d4 [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [dput+27/283] dput+0x1b/0x11b
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219517675/1338422272] nfsd_lookup+0x360/0x378 [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219558366/1338422272] nfs3svc_encode_diropres+0x6b/0x9b [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219507921/1338422272] nfsd_dispatch+0x133/0x17e [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219164674/1338422272] svc_process+0x352/0x588 [sunrpc]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219507262/1338422272] nfsd+0x191/0x2f1 [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [pg0+1219506861/1338422272] nfsd+0x0/0x2f1 [nfsd]
Dec  1 00:00:57 sith-1 kernel:  [kernel_thread_helper+5/11] kernel_thread_helper+0x5/0xb
Dec  1 00:00:57 sith-1 kernel: Code:  Bad EIP value.
Dec  1 00:03:15 sith-1 kernel: Unable to handle kernel paging request at virtual address 00010514
Dec  1 00:03:15 sith-1 kernel:  printing eip:
Dec  1 00:03:15 sith-1 kernel: 00010514
Dec  1 00:03:15 sith-1 kernel: *pde = 00000000
Dec  1 00:03:15 sith-1 kernel: Oops: 0000 [#3]
Dec  1 00:03:15 sith-1 kernel: SMP
Dec  1 00:03:15 sith-1 kernel: Modules linked in: parport_pc lp parport mptctl ipv6 quota_v2 ext2 nfsd exportfs lockd nfs_acl sunrpc ide_disk mousedev tsdev i2c_piix4 sworks_agppsmouse i2c_core serio_raw shpchp pcspkr pci_hotplug rtc evdev agpgart floppy sg ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_generic ide_cd cdrom serverworks generic ohci_hcd ide_core sd_mod usbcore mptspi mptscsih mptbase tg3 ips scsi_mod thermal processor fan
Dec  1 00:03:15 sith-1 kernel: CPU:    1
Dec  1 00:03:15 sith-1 kernel: EIP:    0060:[<00010514>]    Not tainted VLI
Dec  1 00:03:15 sith-1 kernel: EFLAGS: 00010206   (2.6.16.29 #1)
Dec  1 00:03:15 sith-1 kernel: EIP is at 0x10514
Dec  1 00:03:15 sith-1 kernel: eax: e83f60dc   ebx: dc0110c3   ecx: dfacc440   edx: e813b7c8
Dec  1 00:03:15 sith-1 kernel: esi: e813b7c8   edi: f6dbded4   ebp: dfacc440   esp: f6dbdea4
Dec  1 00:03:15 sith-1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  1 00:03:15 sith-1 kernel: Process nfsd (pid: 4446, threadinfo=f6dbc000 task=f6d90030)
Dec  1 00:03:15 sith-1 kernel: Stack: <0>b015e4aa dfacc440 e813b7c8 f6dbded4 f6da5000 f6dbded4 f8ec072c e8533018
Dec  1 00:03:15 sith-1 kernel:        f8e9e38e dfacc440 e813b7c8 f6dbded4 f8e9808c e813b7c8 f7042f40 e813b7c8
Dec  1 00:03:15 sith-1 kernel:        f8e981ed f7042f40 f8ec0480 00000001 f7e8eb20 00000006 f6da500c f7eab800
Dec  1 00:03:15 sith-1 kernel: Call Trace:
Dec  1 00:03:15 sith-1 kernel:  [vfs_getattr+65/150] vfs_getattr+0x41/0x96
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219539854/1338422272] nfs2svc_encode_fattr+0x20/0x35 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219514508/1338422272] fh_verify+0x368/0x4e3 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219514861/1338422272] fh_verify+0x4c9/0x4e3 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219544148/1338422272] nfsacld_proc_getattr+0x6a/0x71 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219545091/1338422272] nfsaclsvc_encode_attrstatres+0x13/0x29 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219507921/1338422272] nfsd_dispatch+0x133/0x17e [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219164674/1338422272] svc_process+0x352/0x588 [sunrpc]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219507262/1338422272] nfsd+0x191/0x2f1 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [pg0+1219506861/1338422272] nfsd+0x0/0x2f1 [nfsd]
Dec  1 00:03:15 sith-1 kernel:  [kernel_thread_helper+5/11] kernel_thread_helper+0x5/0xb
Dec  1 00:03:15 sith-1 kernel: Code:  Bad EIP value.
Dec  1 00:06:15 sith-1 kernel: Unable to handle kernel paging request at virtual address 00010514
Dec  1 00:06:15 sith-1 kernel:  printing eip:
Dec  1 00:06:15 sith-1 kernel: 00010514
Dec  1 00:06:15 sith-1 kernel: *pde = 00000000
Dec  1 00:06:15 sith-1 kernel: Oops: 0000 [#4]
Dec  1 00:06:15 sith-1 kernel: SMP
Dec  1 00:06:15 sith-1 kernel: Modules linked in: parport_pc lp parport mptctl ipv6 quota_v2 ext2 nfsd exportfs lockd nfs_acl sunrpc ide_disk mousedev tsdev i2c_piix4 sworks_agppsmouse i2c_core serio_raw shpchp pcspkr pci_hotplug rtc evdev agpgart floppy sg ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_generic ide_cd cdrom serverworks generic ohci_hcd ide_core sd_mod usbcore mptspi mptscsih mptbase tg3 ips scsi_mod thermal processor fan
Dec  1 00:06:15 sith-1 kernel: CPU:    1
Dec  1 00:06:15 sith-1 kernel: EIP:    0060:[<00010514>]    Not tainted VLI
Dec  1 00:06:15 sith-1 kernel: EFLAGS: 00010206   (2.6.16.29 #1)
Dec  1 00:06:15 sith-1 kernel: EIP is at 0x10514
Dec  1 00:06:15 sith-1 kernel: eax: e83f60dc   ebx: dc0110c3   ecx: dfacc440   edx: e813b7c8
Dec  1 00:06:15 sith-1 kernel: esi: e813b7c8   edi: f6d51ed4   ebp: dfacc440   esp: f6d51ea4
Dec  1 00:06:15 sith-1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  1 00:06:15 sith-1 kernel: Process nfsd (pid: 4439, threadinfo=f6d50000 task=dfcf1a90)
Dec  1 00:06:15 sith-1 kernel: Stack: <0>b015e4aa dfacc440 e813b7c8 f6d51ed4 f6d3e000 f6d51ed4 f8ec072c be6b2018
Dec  1 00:06:15 sith-1 kernel:        f8e9e38e dfacc440 e813b7c8 f6d51ed4 f8e9808c e813b7c8 f7042f40 e813b7c8
Dec  1 00:06:15 sith-1 kernel:        f8e981ed f7042f40 f8ec0480 00000001 f7e8eb20 00000006 f6d3e00c df993600
Dec  1 00:06:15 sith-1 kernel: Call Trace:
Dec  1 00:06:15 sith-1 kernel:  [vfs_getattr+65/150] vfs_getattr+0x41/0x96
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219539854/1338422272] nfs2svc_encode_fattr+0x20/0x35 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219514508/1338422272] fh_verify+0x368/0x4e3 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219514861/1338422272] fh_verify+0x4c9/0x4e3 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219544148/1338422272] nfsacld_proc_getattr+0x6a/0x71 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219545091/1338422272] nfsaclsvc_encode_attrstatres+0x13/0x29 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219507921/1338422272] nfsd_dispatch+0x133/0x17e [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219164674/1338422272] svc_process+0x352/0x588 [sunrpc]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219507262/1338422272] nfsd+0x191/0x2f1 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [pg0+1219506861/1338422272] nfsd+0x0/0x2f1 [nfsd]
Dec  1 00:06:15 sith-1 kernel:  [kernel_thread_helper+5/11] kernel_thread_helper+0x5/0xb
Dec  1 00:06:15 sith-1 kernel: Code:  Bad EIP value.
Dec  1 00:09:15 sith-1 kernel: Unable to handle kernel paging request at virtual address 00010514
Dec  1 00:09:15 sith-1 kernel:  printing eip:
Dec  1 00:09:15 sith-1 kernel: 00010514
Dec  1 00:09:15 sith-1 kernel: *pde = 00000000
Dec  1 00:09:15 sith-1 kernel: Oops: 0000 [#5]
Dec  1 00:09:15 sith-1 kernel: SMP
Dec  1 00:09:15 sith-1 kernel: Modules linked in: parport_pc lp parport mptctl ipv6 quota_v2 ext2 nfsd exportfs lockd nfs_acl sunrpc ide_disk mousedev tsdev i2c_piix4 sworks_agppsmouse i2c_core serio_raw shpchp pcspkr pci_hotplug rtc evdev agpgart floppy sg ext3 jbd mbcache dm_mirror dm_snapshot dm_mod ide_generic ide_cd cdrom serverworks generic ohci_hcd ide_core sd_mod usbcore mptspi mptscsih mptbase tg3 ips scsi_mod thermal processor fan
Dec  1 00:09:15 sith-1 kernel: CPU:    1
Dec  1 00:09:15 sith-1 kernel: EIP:    0060:[<00010514>]    Not tainted VLI
Dec  1 00:09:15 sith-1 kernel: EFLAGS: 00010206   (2.6.16.29 #1)
Dec  1 00:09:15 sith-1 kernel: EIP is at 0x10514
Dec  1 00:09:15 sith-1 kernel: eax: e83f60dc   ebx: dc0110c3   ecx: dfacc440   edx: e813b7c8
Dec  1 00:09:15 sith-1 kernel: esi: e813b7c8   edi: f6d4ded4   ebp: dfacc440   esp: f6d4dea4
Dec  1 00:09:15 sith-1 kernel: ds: 007b   es: 007b   ss: 0068
Dec  1 00:09:15 sith-1 kernel: Process nfsd (pid: 4437, threadinfo=f6d4c000 task=df9ab560)
Dec  1 00:09:15 sith-1 kernel: Stack: <0>b015e4aa dfacc440 e813b7c8 f6d4ded4 f6d22000 f6d4ded4 f8ec072c c8810018
Dec  1 00:09:15 sith-1 kernel:        f8e9e38e dfacc440 e813b7c8 f6d4ded4 f8e9808c e813b7c8 f7042f40 e813b7c8
Dec  1 00:09:15 sith-1 kernel:        f8e981ed f7042f40 f8ec0480 00000001 f7e8eb20 00000006 f6d2200c df955400
Dec  1 00:09:15 sith-1 kernel: Call Trace:
Dec  1 00:09:15 sith-1 kernel:  [vfs_getattr+65/150] vfs_getattr+0x41/0x96
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219539854/1338422272] nfs2svc_encode_fattr+0x20/0x35 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219514508/1338422272] fh_verify+0x368/0x4e3 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219514861/1338422272] fh_verify+0x4c9/0x4e3 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219544148/1338422272] nfsacld_proc_getattr+0x6a/0x71 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219545091/1338422272] nfsaclsvc_encode_attrstatres+0x13/0x29 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219507921/1338422272] nfsd_dispatch+0x133/0x17e [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219164674/1338422272] svc_process+0x352/0x588 [sunrpc]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219507262/1338422272] nfsd+0x191/0x2f1 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [pg0+1219506861/1338422272] nfsd+0x0/0x2f1 [nfsd]
Dec  1 00:09:15 sith-1 kernel:  [kernel_thread_helper+5/11] kernel_thread_helper+0x5/0xb
Dec  1 00:09:15 sith-1 kernel: Code:  Bad EIP value.

------=_Part_61688_29341678.1164960395195
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
------=_Part_61688_29341678.1164960395195
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------=_Part_61688_29341678.1164960395195--
