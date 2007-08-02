From: "Chakri n" <chakriin5@gmail.com>
Subject: OOPS in shrink_dcache_for_umount
Date: Thu, 2 Aug 2007 14:27:04 -0700
Message-ID: <92cbf19b0708021427l7c88c642g3901e393ac2b90b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGiCE-0006Ue-AR
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 14:27:03 -0700
Received: from nz-out-0506.google.com ([64.233.162.239])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGiCI-0000Sc-4o
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 14:27:06 -0700
Received: by nz-out-0506.google.com with SMTP id f1so1134039nzc
	for <nfs@lists.sourceforge.net>; Thu, 02 Aug 2007 14:27:05 -0700 (PDT)
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

Hi,

We are seeing this problem while unmounting file systems. It happens
once in a while.
I am able to grab the trace and core from linux-2.6.18-1.8.el5, but I
have observed the same problem with linux-2.6.20.1 kernel.

Has this problem fixed in recent kernel?

BUG: Dentry f7498f70{i=12803e,n=client72} still in use (1) [unmount of nfs 0:18]
------------[ cut here ]------------
kernel BUG at fs/dcache.c:615!
invalid opcode: 0000 [#1]
SMP
last sysfs file: /block/ram0/range
Modules linked in: nfs fscache nfsd exportfs lockd nfs_acl
ipmi_msghandler kazprocs(U) sunrpc ipv6
 dm_mirror dm_mod video sbs i2c_ec button battery asus_acpi ac lp
floppy snd_intel8x0 snd_ac97_cod
ec snd_ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
snd_seq_device snd_pcm_oss sn
d_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc ide_cd e100
parport_pc i2c_i801 mii par
port pcspkr i2c_core cdrom serio_raw ata_piix libata sd_mod scsi_mod
ext3 jbd ehci_hcd ohci_hcd uh
ci_hcd
CPU:    0
EIP:    0060:[<c047e49f>]    Not tainted VLI
EFLAGS: 00010246   (2.6.18-8.el5 #1)
EIP is at shrink_dcache_for_umount_subtree+0x133/0x1c1
eax: 00000054   ebx: f7498f70   ecx: c0621b24   edx: de121ee8
esi: 00000001   edi: f7835740   ebp: 0012803e   esp: de121ee4
ds: 007b   es: 007b   ss: 0068
Process umount.nfs (pid: 29559, ti=de121000 task=ebbe5000 task.ti=de121000)
Stack: c0621b24 f7498f70 0012803e f7498fd4 00000001 f8d55765 f7835740 f7835600
       f8d67980 00000000 00000000 c047ec5d f7835600 c0470153 00000018 f8d67960
       c0470248 e1b0d380 f8d3a175 f7835600 c04702d7 f74629c0 f7835600 c0483165
Call Trace:
 [<c047ec5d>] shrink_dcache_for_umount+0x2e/0x3a
 [<c0470153>] generic_shutdown_super+0x16/0xd5
 [<c0470248>] kill_anon_super+0x9/0x2f
 [<f8d3a175>] nfs_kill_super+0xc/0x14 [nfs]
 [<c04702d7>] deactivate_super+0x52/0x65
 [<c0483165>] sys_umount+0x1f0/0x218
 [<c059c9eb>] release_sock+0xc/0x91
 [<c05fd48f>] do_page_fault+0x20a/0x4b8
 [<c05fd4f9>] do_page_fault+0x274/0x4b8
 [<c0483198>] sys_oldumount+0xb/0xe
 [<c0403eff>] syscall_call+0x7/0xb
 =======================
Code: ed 8b 53 0c 8b 33 8b 4b 24 8d b8 40 01 00 00 8b 40 1c 85 d2 8b
00 74 03 8b 6a 20 57 50 56 51
 55 53 68 24 1b 62 c0 e8 c5 5c fa ff <0f> 0b 67 02 18 1b 62 c0 83 c4
1c 8b 73 18 39 de 75 04 31 f6
 eb
EIP: [<c047e49f>] shrink_dcache_for_umount_subtree+0x133/0x1c1 SS:ESP
0068:de121ee4


Thanks
--Chakri

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
