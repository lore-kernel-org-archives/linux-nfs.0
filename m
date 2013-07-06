Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.20]:52937 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab3GFJiZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jul 2013 05:38:25 -0400
Message-ID: <51D7E589.4000409@gmx.de>
Date: Sat, 06 Jul 2013 11:38:17 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Eric Sandeen <sandeen@redhat.com>
CC: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: found a scenario for BUG at fs/ext4/super.c:804!
References: <51A79353.7030604@gmx.de> <51AA0CA1.6080600@redhat.com>
In-Reply-To: <51AA0CA1.6080600@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2013 05:00 PM, Eric Sandeen wrote:
> On 5/30/13 12:58 PM, Toralf Förster wrote:
>> With kernel 3.10-rcX there's a big likelihood to observe that issue if I do the following steps: 
>>
>>  1. create a 257 MB file /mnt/ramdisk/disk0
>>  2. create an EXT4 fs onto it
>>  3. mount it onto /mnt/ramdisk/victims/
>>  4. create files and directories in /mnt/ramdisk/victims/v1/v2
>>  5. exportfs the directory /mnt/ramdisk/victims/ via NFS 
>>  6. start a user mode linux
>>  7. within UML nfs-mount the exported directory /mnt/ramdisk/victims/ onto 3 different UML directories /mnt/nfsv[234] - just to test all 3 NFS versions
>>  8. run trinity within the UML guest using a victims directory /mnt/nfsv[234]/v1/v2 for a longer period (rather hours)
> 
> And therein lies the unknown magic.
> 
> Again, trinity's job is to try to corrupt the kernel by fuzzing syscalls.

But does trintiy corrupts the host kernel if it runs within a
cirtualized environemtn (ok, "just" a user mode linux image) ?

> 
> It could be a filesystem bug, or just as easily some other bug in a syscall that allowed trinity to corrupt memory.

I bet that it is related ot the interaction of NFS and EXT4FS, because
the  host is mostly stressed by scary file system calls calls coming
from the client over BFS (==trinity)


> I do not think these bug reports are actionable until you can figure out how to narrow down the trinity operations that cause the problem.
> 
> -Eric

I really try to get a scenario.

With the latest trinity versions at least the handling of the fuzz
testing becomes much more easier and reliable.

FWIW  with 3.10 for the host kernel that bug appears now much more often
than with 3.9.X (for the host, the UML client runs mostly latest git
tree + 3 UML patches)


>>  9. stop UML, Ctrl-C any running trinity / UML process
>> 10. try to umount mnt/ramdisk/victims/
>> 11. if that attempt fails stop the nfs service and run the umount command again - it segfaults now
>> 12. if the 1st umount is however successfully then make a :-/
>>
>>
>> 2013-05-30T19:20:28.000+02:00 n22 rpc.mountd[2921]: authenticated unmount request from 192.168.1.63:798 for /mnt/ramdisk/victims (/mnt/ramdisk/victims)
>> 2013-05-30T19:20:28.000+02:00 n22 rpc.mountd[2921]: authenticated unmount request from 192.168.1.63:799 for /mnt/ramdisk/victims (/mnt/ramdisk/victims)
>> 2013-05-30T19:20:42.569+02:00 n22 kernel: br0: port 1(tap0) entered disabled state
>> 2013-05-30T19:21:10.000+02:00 n22 rpc.mountd[2921]: Caught signal 15, un-registering and exiting.
>> 2013-05-30T19:21:10.336+02:00 n22 kernel: lockd: couldn't shutdown host module for net c161c200!
>> 2013-05-30T19:21:10.338+02:00 n22 kernel: nfsd: last server has exited, flushing export cache
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: EXT4-fs (loop0): sb orphan head is 32315
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: sb_info orphan list:
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32315 at e8702158: mode 102357, nlink 0, next 32173
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32173 at e773a860: mode 100406, nlink 0, next 32383
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32383 at e93bbd78: mode 102041, nlink 0, next 32233
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32233 at e7e742e0: mode 103267, nlink 0, next 32421
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32421 at e84fad10: mode 100102, nlink 0, next 32155
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32155 at e8700538: mode 100700, nlink 0, next 32230
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32230 at e77397f8: mode 102747, nlink 0, next 32313
>> 2013-05-30T19:21:12.227+02:00 n22 kernel: inode loop0:32313 at e8701ca8: mode 102667, nlink 0, next 32244
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32244 at e79b3670: mode 100353, nlink 0, next 32361
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32361 at e8703b20: mode 100206, nlink 0, next 32271
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32271 at e79b3b20: mode 100000, nlink 0, next 32255
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32255 at eb8ec088: mode 104657, nlink 0, next 32366
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32366 at e8701f00: mode 105711, nlink 0, next 32281
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32281 at e77382e0: mode 101637, nlink 0, next 32151
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32151 at e92cce98: mode 101557, nlink 0, next 32138
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32138 at e932a608: mode 101327, nlink 0, next 32013
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32013 at e74be158: mode 101527, nlink 0, next 32012
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32012 at e74be3b0: mode 102427, nlink 0, next 32110
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32110 at e74bdf00: mode 101303, nlink 0, next 32112
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32112 at e74beab8: mode 100000, nlink 0, next 32066
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32066 at e79f9a50: mode 104607, nlink 0, next 32148
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32148 at e9331ca8: mode 102507, nlink 0, next 32158
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32158 at e84c31c0: mode 100000, nlink 0, next 32139
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32139 at e84c1ca8: mode 101507, nlink 0, next 32115
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: inode loop0:32115 at e93310f0: mode 104037, nlink 0, next 0
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: ------------[ cut here ]------------
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: kernel BUG at fs/ext4/super.c:804!
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: invalid opcode: 0000 [#1] SMP 2013-05-30T19:21:12.228+02:00 n22 kernel: Modules linked in: loop nfsd auth_rpcgss oid_registry lockd sunrpc ip6t_REJECT ip6table_filter ip6_tables ipt_MASQUERADE xt_owner xt_LOG xt_limit xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc ipv6 tun fuse dm_mod coretemp kvm_intel kvm aesni_intel i915 xts aes_i586 lrw gf128mul ablk_helper arc4 hid_cherry hid_generic iwldvm fbcon snd_hda_codec_conexant cfbfillrect cfbimgblt cryptd i2c_algo_bit sr_mod cfbcopyarea intel_agp sdhci_pci cdrom intel_gtt evdev mac80211 sdhci bitblit mmc_core softcursor font acpi_cpufreq mperf psmouse usbhid drm_kms_helper usblp snd_hda_intel e1000e uvcvideo drm videobuf2_vmalloc hid agpgart videobuf2_memops videobuf2_core videodev fb 8250_pci snd_hda_codec ptp !
 i!
>  2c!
>>  _i801 8250
>>  pps_core processor battery fbdev iwlwifi i2c_core cfg80211 thermal wmi tpm_tis snd_pcm snd_page_alloc snd_timer tpm tpm_bios thinkpad_acpi video nvram snd soundcore ac rfkill thermal_sys button serial_core hwmon [last unloaded: microcode]
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: CPU: 1 PID: 11831 Comm: umount Not tainted 3.10.0-rc3+ #6
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: Hardware name: LENOVO 4180F65/4180F65, BIOS 83ET73WW (1.43 ) 11/30/2012
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: task: eec69aa0 ti: eb4b6000 task.ti: eb4b6000
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: EIP: 0060:[<c11ba6ec>] EFLAGS: 00010287 CPU: 1
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: EIP is at ext4_put_super+0x2dc/0x2e0
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: EAX: 0000003d EBX: eaa3d400 ECX: eaa3d550 EDX: eaa3d550
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: ESI: eaa3f000 EDI: eaa3d514 EBP: eb4b7efc ESP: eb4b7ecc
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>> 2013-05-30T19:21:12.228+02:00 n22 kernel: CR0: 80050033 CR2: b6bab000 CR3: 2edc6000 CR4: 000407f0
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: DR6: ffff0ff0 DR7: 00000400
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: Stack:
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: c1567fa0 eaa3f1bc 00007d73 e93310f0 0000881f 00000000 00000000 e93310d0
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: eaa3d550 eaa3f000 eaa3f058 c14a06e0 eb4b7f18 c111f771 eb4b7f28 eb4b7f18
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: f1d70400 00000083 eaa3f000 eb4b7f28 c111f819 eaa3f000 c15fde28 eb4b7f38
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: Call Trace:
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c111f771>] generic_shutdown_super+0x51/0xd0
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c111f819>] kill_block_super+0x29/0x70
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c111fa64>] deactivate_locked_super+0x44/0x70
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c1120437>] deactivate_super+0x47/0x60
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c11371bd>] mntput_no_expire+0xcd/0x120
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c113807e>] SyS_umount+0xae/0x330
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c113831e>] SyS_oldumount+0x1e/0x20
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: [<c1482701>] sysenter_do_call+0x12/0x22
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: Code: 24 a0 7f 56 c1 05 bc 01 00 00 89 44 24 04 e8 d2 f8 2b 00 8b 4d ec 8b 55 f0 8b 09 39 ca 75 b2 39 93 50 01 00 00 0f 84 9a fe ff ff <0f> 0b 66 90 55 89 e5 83 ec 20 66 66 66 66 90 8d 45 18 c7 04 24
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: EIP: [<c11ba6ec>] ext4_put_super+0x2dc/0x2e0 SS:ESP 0068:eb4b7ecc
>> 2013-05-30T19:21:12.229+02:00 n22 kernel: ---[ end trace 2a52a524ae176def ]---
>>
>>
> 
> 


-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
