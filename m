From: Sujay Godbole <sujay@fsl.cs.sunysb.edu>
Subject: NFSv4 client crash
Date: Tue, 14 Apr 2009 17:40:13 -0400
Message-ID: <4733da850904141440s26c73658wcd26485c569a758e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vasily Tarasov <tarasov-q12XvdSUhMJ7tPAFqOLdPg@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:15917 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZDNVkg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2009 17:40:36 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2850615ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Apr 2009 14:40:35 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am not sure this is a right mailing list to report the errors
regarding NFsv4 client.=A0 I am running Centos 5.3 NFSv4 client against
Solaris 10 (x86 64 bit architecture) NFS server. I received following
coredump while running iozone benchmark for 2GB file size. I got this
error in=A0 single client as well as multiple client scenario. After th=
e
initial dump, machine is extremely slow and I can see keyboard input
after a minute.

Here are the details of machine configuration:
Distribution : Centos 5.3
kernel version : 2.6.18-128.el5


Here is the dump :
Apr 13 19:57:10 localhost kernel: BUG: soft lockup - CPU#1 stuck for
10s! [192.168.0.104-r:3188]
Apr 13 19:57:10 localhost kernel: CPU 1:
Apr 13 19:57:10 localhost kernel: Modules linked in: nfs lockd fscache
nfs_acl ipv6 xfrm_nalgo crypto_api autofs4 hidp rfcomm l2cap bluetooth
sunrpc dm_mirror dm_multipath scsi_dh video hwmon backlight sbs i2c_ec
i2c_core button battery asus_acpi acpi_memhotplug ac lp parport_pc
parport serio_raw e752x_edac e1000 edac_mc pcspkr sg dm_raid45
dm_message dm_region_hash dm_log dm_mod dm_mem_cache ata_piix libata
shpchp aacraid sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Apr 13 19:57:10 localhost kernel: Pid: 3188, comm: 192.168.0.104-r Not
tainted 2.6.18-128.el5 #1
Apr 13 19:57:10 localhost kernel: RIP: 0010:[<ffffffff8844d093>]
[<ffffffff8844d093>] :nfs:nfs4_open_expired+0x90/0x16c
Apr 13 19:57:10 localhost kernel: RSP: 0018:ffff810032da3e40=A0 EFLAGS:=
 00000247
Apr 13 19:57:10 localhost kernel: RAX: 000000000001a002 RBX:
0000000000000000 RCX: 000000010019e262
Apr 13 19:57:10 localhost kernel: RDX: 0000000000000000 RSI:
ffff81002b1989c0 RDI: ffff81003f395fd8
Apr 13 19:57:10 localhost kernel: RBP: ffff81003e9e29c0 R08:
0000000000000000 R09: ffff810037ddf080
Apr 13 19:57:10 localhost kernel: R10: ffff810030850250 R11:
fffffffffffffeff R12: ffff810035de4b40
Apr 13 19:57:10 localhost kernel: R13: ffff81002b198ac0 R14:
0000000000000004 R15: ffffffff8843703e
Apr 13 19:57:10 localhost kernel: FS:=A0 0000000000000000(0000)
GS:ffff810037d237c0(0000) knlGS:0000000000000000
Apr 13 19:57:10 localhost kernel: CS:=A0 0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Apr 13 19:57:10 localhost kernel: CR2: 00002aaaaacd3000 CR3:
000000003d95d000 CR4: 00000000000006e0
Apr 13 19:57:10 localhost kernel:
Apr 13 19:57:10 localhost kernel: Call Trace:
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff884540b5>]
:nfs:nfs4_reclaim_open_state+0x2d/0x150
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff8845437c>]
:nfs:reclaimer+0x1a4/0x2ac
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff884541d8>] :nfs:reclaime=
r+0x0/0x2ac
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff80032360>] kthread+0xfe/=
0x132
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff8005dfb1>] child_rip+0xa=
/0x11
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff80032262>] kthread+0x0/0=
x132
Apr 13 19:57:10 localhost kernel:=A0 [<ffffffff8005dfa7>] child_rip+0x0=
/0x11
Apr 13 19:57:10 localhost kernel:
Apr 13 19:57:20 localhost kernel: BUG: soft lockup - CPU#1 stuck for
10s! [192.168.0.104-r:3188]
Apr 13 19:57:20 localhost kernel: CPU 1:
Apr 13 19:57:20 localhost kernel: Modules linked in: nfs lockd fscache
nfs_acl ipv6 xfrm_nalgo crypto_api autofs4 hidp rfcomm l2cap bluetooth
sunrpc dm_mirror dm_multipath scsi_dh video hwmon backlight sbs i2c_ec
i2c_core button battery asus_acpi acpi_memhotplug ac lp parport_pc
parport serio_raw e752x_edac e1000 edac_mc pcspkr sg dm_raid45
dm_message dm_region_hash dm_log dm_mod dm_mem_cache ata_piix libata
shpchp aacraid sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Apr 13 19:57:20 localhost kernel: Pid: 3188, comm: 192.168.0.104-r Not
tainted 2.6.18-128.el5 #1
Apr 13 19:57:20 localhost kernel: RIP: 0010:[<ffffffff8014c625>]
[<ffffffff8014c625>] __list_add+0x32/0x68
Apr 13 19:57:20 localhost kernel: RSP: 0018:ffff810032da3d80=A0 EFLAGS:=
 00000246
Apr 13 19:57:20 localhost kernel: RAX: ffff81002b1989c0 RBX:
ffff81002b1989c0 RCX: 000000010019e262
Apr 13 19:57:20 localhost kernel: RDX: ffff81002b1989c0 RSI:
ffff81002b1989c0 RDI: ffff81003f395fd8
Apr 13 19:57:20 localhost kernel: RBP: ffffffff882dc746 R08:
0000000000000000 R09: ffff810037ddf080
Apr 13 19:57:20 localhost kernel: R10: ffff810030850250 R11:
fffffffffffffeff R12: ffff8100308502f8
Apr 13 19:57:20 localhost kernel: R13: ffff810030850250 R14:
ffff810006403e00 R15: ffff81003effac00
Apr 13 19:57:20 localhost kernel: FS:=A0 0000000000000000(0000)
GS:ffff810037d237c0(0000) knlGS:0000000000000000
Apr 13 19:57:20 localhost kernel: CS:=A0 0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Apr 13 19:57:20 localhost kernel: CR2: 00002aaaaacd3000 CR3:
000000003d95d000 CR4: 00000000000006e0
Apr 13 19:57:20 localhost kernel:
Apr 13 19:57:20 localhost kernel: Call Trace:
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8843703e>]
:nfs:nfs_access_get_cached+0xab/0xfa
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8844c2f9>]
:nfs:_nfs4_do_access+0x2d/0x85
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8844d06f>]
:nfs:nfs4_open_expired+0x6c/0x16c
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff884540b5>]
:nfs:nfs4_reclaim_open_state+0x2d/0x150
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8845437c>]
:nfs:reclaimer+0x1a4/0x2ac
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff884541d8>] :nfs:reclaime=
r+0x0/0x2ac
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff80032360>] kthread+0xfe/=
0x132
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8005dfb1>] child_rip+0xa=
/0x11
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff80032262>] kthread+0x0/0=
x132
Apr 13 19:57:20 localhost kernel:=A0 [<ffffffff8005dfa7>] child_rip+0x0=
/0x11
Apr 13 19:57:20 localhost kernel:
Apr 13 19:57:30 localhost kernel: BUG: soft lockup - CPU#1 stuck for
10s! [192.168.0.104-r:3188]
Apr 13 19:57:30 localhost kernel: CPU 1:
Apr 13 19:57:30 localhost kernel: Modules linked in: nfs lockd fscache
nfs_acl ipv6 xfrm_nalgo crypto_api autofs4 hidp rfcomm l2cap bluetooth
sunrpc dm_mirror dm_multipath scsi_dh video hwmon backlight sbs i2c_ec
i2c_core button battery asus_acpi acpi_memhotplug ac lp parport_pc
parport serio_raw e752x_edac e1000 edac_mc pcspkr sg dm_raid45
dm_message dm_region_hash dm_log dm_mod dm_mem_cache ata_piix libata
shpchp aacraid sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Apr 13 19:57:30 localhost kernel: Pid: 3188, comm: 192.168.0.104-r Not
tainted 2.6.18-128.el5 #1
Apr 13 19:57:30 localhost kernel: RIP: 0010:[<ffffffff8844c2d3>]
[<ffffffff8844c2d3>] :nfs:_nfs4_do_access+0x7/0x85
Apr 13 19:57:30 localhost kernel: RSP: 0018:ffff810032da3e28=A0 EFLAGS:=
 00000246
Apr 13 19:57:30 localhost kernel: RAX: 000000000001a002 RBX:
0000000000000000 RCX: 000000010019e262
Apr 13 19:57:30 localhost kernel: RDX: 0000000000000001 RSI:
ffff81003e9e29c0 RDI: ffff81002b198ac0
Apr 13 19:57:30 localhost kernel: RBP: ffffffff8843703e R08:
0000000000000000 R09: ffff810037ddf080
Apr 13 19:57:30 localhost kernel: R10: ffff810030850250 R11:
fffffffffffffeff R12: ffff81003f395fd8
Apr 13 19:57:30 localhost kernel: R13: ffff81002b198ac0 R14:
ffff81003f395fc0 R15: 0000000000000246
Apr 13 19:57:30 localhost kernel: FS:=A0 0000000000000000(0000)
GS:ffff810037d237c0(0000) knlGS:0000000000000000
Apr 13 19:57:30 localhost kernel: CS:=A0 0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Apr 13 19:57:30 localhost kernel: CR2: 00002aaaaacd3000 CR3:
000000003d95d000 CR4: 00000000000006e0
Apr 13 19:57:30 localhost kernel:
Apr 13 19:57:30 localhost kernel: Call Trace:
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8844d06f>]
:nfs:nfs4_open_expired+0x6c/0x16c
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff884540b5>]
:nfs:nfs4_reclaim_open_state+0x2d/0x150
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8845437c>]
:nfs:reclaimer+0x1a4/0x2ac
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff884541d8>] :nfs:reclaime=
r+0x0/0x2ac
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff80032360>] kthread+0xfe/=
0x132
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8005dfb1>] child_rip+0xa=
/0x11
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8009d909>]
keventd_create_kthread+0x0/0xc4
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff80032262>] kthread+0x0/0=
x132
Apr 13 19:57:30 localhost kernel:=A0 [<ffffffff8005dfa7>] child_rip+0x0=
/0x11
Apr 13 19:57:30 localhost kernel:

##############################


Is this the known issue and fixed in later kernel versions ?


Thank you.


Regards
Sujay
