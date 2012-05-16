Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:58508 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S966389Ab2EPJAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 05:00:09 -0400
Cc: linux-nfs@vger.kernel.org, osd-dev@open-osd.org
Content-Type: text/plain; charset="utf-8"
Date: Wed, 16 May 2012 11:00:06 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <4FB25799.8060306@panasas.com>
Message-ID: <20120516090006.192470@gmx.net>
MIME-Version: 1.0
References: <20120515090332.182970@gmx.net> <4FB22658.9010909@panasas.com>
 <20120515121931.192500@gmx.net> <4FB25799.8060306@panasas.com>
Subject: Re: Questions about Exofs
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz,


> Datum: Tue, 15 May 2012 16:18:17 +0300
> Von: Boaz Harrosh <bharrosh@panasas.com>
> An: Johannes Schild <JSchild@gmx.de>
> CC: osd-dev@open-osd.org, linux-nfs@vger.kernel.org
> Betreff: Re: Questions about Exofs

> On 05/15/2012 03:19 PM, Johannes Schild wrote:
> 
> > Hi,
> > 
> > thanks for your fast reply.
> > 
> > But now i run into a nullpointer exception while mounting /dev/osd0
> > 
> > 
> 
> > [ 329.919112] Modules linked in: raid456 async_raid6_recov async_pq
> > 		raid6_pq async_memcpy bnx2i cnic cxgb4i cxgb3i iscsi_tcp be2iscsi
> > 		iscsi_boot_sysfs uio cxgb4 libcxgbi cxgb3 mdio libiscsi_tcp libiscsi
> > 		scsi_transport_iscsi fuse ip6t_REJECT nf_conntrack_ipv6
> > 		nf_defrag_ipv6 xt_state nf_conntrack 8021q ip6table_filter ip6_tables
> > 		garp stp llc fcoe libfcoe libfc scsi_transport_fc scsi_tgt
> > 		snd_ens1371 gameport snd_rawmidi snd_ac97_codec ac97_bus joydev
> > 		snd_seq snd_seq_device snd_pcm ppdev vmw_balloon floppy parport_pc
> > 		snd_timer snd pcnet32 microcode parport pcspkr mii snd_page_alloc
> > 		i2c_piix4 i2c_core shpchp uinput mptspi mptscsih mptbase
> > 		scsi_transport_spi [last unloaded: iscsi_tcp] [ 329.919133]
> 
> 
> One thing that worries me here is this: [last unloaded: iscsi_tcp]
> 
> Actually it should be in the loaded bunch not unloaded. I have no idea how
> can that happen.
> Do you see any prints in dmsg regarding iscsi, before the crash?

I see output like this. Always "registered" no unloading execpt after the crash.

[    4.713107] iscsi: registered transport (tcp)
#<some output removed>
[    4.739465] iscsi: registered transport (cxgb3i)
#<some output removed>
[    4.750756] iscsi: registered transport (cxgb4i)
#<some output removed>
[    4.771300] iscsi: registered transport (bnx2i)
[    4.781045] iscsi: registered transport (be2iscsi)



> 
> > [  329.919134] Pid: 2234, comm: mount Not tainted 3.3.0-pnfs #1 VMware,
> Inc. VMware Virtual Platform/440BX Desktop Reference Platform
> > [  329.919137] RIP: 0010:[<ffffffff81259799>]  [<ffffffff81259799>]
> exofs_free_sbi+0x59/0xa0
> > [  329.919139] RSP: 0018:ffff88003c4e5bc8  EFLAGS: 00010246
> > [  329.919141] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
> 0000000000001795
> > [  329.919142] RDX: 0000000000000000 RSI: 0000000000000046 RDI:
> ffff88003c4f5000
> > [  329.919143] RBP: ffff88003c4e5bd8 R08: 0000000000000000 R09:
> 0000000000000000
> > [  329.919144] R10: 0000000000000000 R11: 0000000000000001 R12:
> ffff88003c4f5000
> > [  329.919145] R13: ffff88003c4e5d58 R14: 00000000fffffffb R15:
> ffff88003bd4e360
> > [  329.919146] FS:  00007f68ce81d800(0000) GS:ffff88003fc00000(0000)
> knlGS:0000000000000000
> > [  329.919148] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  329.919149] CR2: 0000000000000000 CR3: 000000003cbfd000 CR4:
> 00000000000406f0
> > [  329.919152] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> > [  329.919155] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> > [  329.919156] Process mount (pid: 2234, threadinfo ffff88003c4e4000,
> task ffff88003aa42e40)
> > [  329.919157] Stack:
> > [  329.919158]  ffff88003c4f5000 ffff88003c4f5800 ffff88003c4e5d18
> ffffffff8125a780
> > [  329.919160]  ffff88003c4e5c84 0000000081f27618 ffffffff81f27600
> ffff88003f80c288
> > [  329.919162]  ffff88003ddbeee0 0000000000000000 ffff88003c4e5c48
> ffffffff812c8433
> > [  329.919164] Call Trace:
> > [  329.919166]  [<ffffffff8125a780>] exofs_fill_super+0x440/0x6e0
> > [  329.919171]  [<ffffffff812c8433>] ? idr_pre_get+0x53/0x90
> > [  329.919173]  [<ffffffff8125a340>] ?
> exofs_read_lookup_dev_table+0x480/0x480
> > [  329.919176]  [<ffffffff81180e18>] mount_nodev+0x58/0xb0
> > [  329.919178]  [<ffffffff812594ff>] exofs_mount+0x4f/0x80
> > [  329.919179]  [<ffffffff81181e13>] mount_fs+0x43/0x1b0
> > [  329.919182]  [<ffffffff8119b56a>] vfs_kern_mount+0x6a/0xf0
> > [  329.919183]  [<ffffffff8119bd44>] do_kern_mount+0x54/0x110
> > [  329.919185]  [<ffffffff8119d4b4>] do_mount+0x1a4/0x830
> > [  329.919188]  [<ffffffff8115da33>] ? alloc_pages_current+0xa3/0x110
> > [  329.919191]  [<ffffffff811229e4>] ? __get_free_pages+0x14/0x50
> > [  329.919193]  [<ffffffff8119d18a>] ? copy_mount_options+0x3a/0x170
> > [  329.919194]  [<ffffffff8119dc80>] sys_mount+0x90/0xe0
> > [  329.919199]  [<ffffffff81605aa9>] system_call_fastpath+0x16/0x1b
> > [  329.919200] Code: 66 90 41 8b 84 24 70 03 00 00 83 eb 01 39 c3 72 50
> 41 8b 94 24 74 03 00 00 01 c2 39 d3 73 42 89 da 29 c2 49 8b 84 24 88 03 00
> 00 <48> 8b 04 d0 48 8b 38 48 85 ff 74 0c 48 c7 00 00 00 00 00 e8 6f 
> > [  329.919214] RIP  [<ffffffff81259799>] exofs_free_sbi+0x59/0xa0
> > [  329.919216]  RSP <ffff88003c4e5bc8>
> > [  329.919217] CR2: 0000000000000000
> > [  329.919220] ---[ end trace e5a3b1124e42d9e3 ]---
> > 
> > 
> 
> 
> could you please do:
> []$ gdb fs/exofs/exofs.ko

[root@ExB osd-repo]# gdb /root/pnfs-repo/fs/exofs/exofs.ko 
GNU gdb (GDB) Fedora (7.3.50.20110722-13.fc16)
Copyright (C) 2011 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /root/pnfs-repo/fs/exofs/exofs.ko...done.

> Inside gdb
> > list *(exofs_free_sbi+0x59)

(gdb) list *(exofs_free_sbi+0x59)
0x47a9 is in exofs_free_sbi (include/scsi/osd_ore.h:83).
78	/* ore_comp_dev Recievies a logical device index */
79	static inline struct osd_dev *ore_comp_dev(
80		const struct ore_components *oc, unsigned i)
81	{
82		BUG_ON((i < oc->first_dev) || (oc->first_dev + oc->numdevs <= i));
83		return oc->ods[i - oc->first_dev]->od;
84	}
85	
86	static inline void ore_comp_set_dev(
87		struct ore_components *oc, unsigned i, struct osd_dev *od)

> and also
> > list *(exofs_fill_super+0x440)

(gdb) list *(exofs_fill_super+0x440)
0x5850 is in exofs_fill_super (fs/exofs/super.c:847).
842			dput(sb->s_root);
843			sb->s_root = NULL;
844			goto free_sbi;
845		}
846	
847		_exofs_print_device("Mounting", opts->dev_name,
848				    ore_comp_dev(&sbi->oc, 0),
849				    sbi->one_comp.obj.partition);
850		return 0;
851	
(gdb) 


i build exofs into the kernel, not as a module. 
So i recompiled the kernel and got the output seen above

> 
> > Is there any possibility to avoid these failure?
> > 
> 
> 
> I've never had it lets try to resolve it.
> 
> Could you enable CONFIG_EXOFS_DEBUG it's under:
> 	miscellaneous-filesystems/exofs in make xconfig

I enabled it.

> Then re-run everything send me the output
> []$ ./do-osd stop

[root@ExB osd-repo]# ./do-osd stop
/dev/osd0
FATAL: Module osd is builtin

Should it be a modul or doesn't matter?

> []$ ls /dev/osd*

[root@ExB osd-repo]# ls /dev/osd*
ls: cannot access /dev/osd*: No such file or directory

> []$ ./do-osd

[root@ExB osd-repo]# ./do-osd
iscsid.service - LSB: Starts and stops login iSCSI daemon.
	  Loaded: loaded (/etc/rc.d/init.d/iscsid)
	  Active: inactive (dead) since Wed, 16 May 2012 10:46:23 +0200; 3min 11s ago
	 Process: 2287 ExecStop=/etc/rc.d/init.d/iscsid stop (code=exited, status=0/SUCCESS)
	 Process: 1168 ExecStart=/etc/rc.d/init.d/iscsid start (code=exited, status=0/SUCCESS)
	Main PID: 1213 (code=exited, status=0/SUCCESS)
	  CGroup: name=systemd:/system/iscsid.service
18446744072101122080
login into: 192.168.0.1:3260
192.168.0.1:3260,1 .root.var.osd-tgt.tgt-1.ExA

> []$ ls /dev/osd*

[root@ExB server]# ls /dev/os*
/dev/osd1

> []$ ./do-exofs format
> Send me the output of that

./do-exofs format
mkexofs_format >>> 
osd stop? >>> 
FATAL: Module osd is builtin
osd start? >>> 
iscsid.service - LSB: Starts and stops login iSCSI daemon.
	  Loaded: loaded (/etc/rc.d/init.d/iscsid)
	  Active: inactive (dead) since Wed, 16 May 2012 10:46:23 +0200; 6min ago
	 Process: 2287 ExecStop=/etc/rc.d/init.d/iscsid stop (code=exited, status=0/SUCCESS)
	 Process: 1168 ExecStart=/etc/rc.d/init.d/iscsid start (code=exited, status=0/SUCCESS)
	Main PID: 1213 (code=exited, status=0/SUCCESS)
	  CGroup: name=systemd:/system/iscsid.service
18446744072101122080
login into: 192.168.0.1:3260
192.168.0.1:3260,1 .root.var.osd-tgt.tgt-1.ExA
Logging in to [iface: default, target: .root.var.osd-tgt.tgt-1.ExA, portal: 192.168.0.1,3260] (multiple)
Login to [iface: default, target: .root.var.osd-tgt.tgt-1.ExA, portal: 192.168.0.1,3260] successful.

> []$ ./do-exofs start
> Send me the dmesg output of this stage, or if not too big
> the dmesg output of from before ./do-osd <1>

I pushed it on nopaste:
http://nopaste.info/cd3c6f9141.html



> 
> > Just now i am using the 3.3.0 kernel from the linux-pnfs repository.
> > 
> 
> 
> When compiling the Kernel, Did you enable CONFIG_PNFSD ?
> (That is the pNFSD Server Kernel Support)

No pNFSD Server support wasn't enabled,  i recompiled and activate it




> What platform are you using? Distro + ARCH ?

Iam experimenting with Fedora 16 (3.3.0 pnfs kernel) and arch x86_64

> 
> This should be a good tree. Though usually I use an
> open-osd.org/linux-open-osd.git based tree. But I don't see much
> difference. Let me have a look if there is something grossly
> missing.
> 
> > 
> > Thanks in adavance
> > 
> 
> 
> Sorry for your trouble I have neglected the public trees for a
> while. Let me see if I can push a more tested tree up on
> open-osd.org.
> 
> > Cheers
> > Johannes 
> > 
> 
> 
> Thanks
> Boaz
> 
> > -------- Original-Nachricht --------
> >> Datum: Tue, 15 May 2012 12:48:08 +0300
> >> Von: Boaz Harrosh <bharrosh@panasas.com>
> >> An: Johannes Schild <JSchild@gmx.de>
> >> CC: linux-nfs@vger.kernel.org, open-osd <osd-dev@open-osd.org>
> >> Betreff: Re: Questions about Exofs
> > 
> >> On 05/15/2012 12:03 PM, Johannes Schild wrote:
> >>
> >>> Hi,
> >>>
> >>> i try to set up the object-based layout with pnfs.
> >>> I am using the OSC-OSD as target. It works well and i can login.
> >>> Trying the scripts "do-*" from git://git.open-osd.org/open-osd.git the
> >> do-osd script works for me. The do-exofs doesnt, here i have some
> question:
> >>>
> >>> 1. Is the UUID in the do-exofs script optional?
> >>>
> >>
> >>
> >> No it is not optional
> >>
> >>> 2. If no how can i get it for my device?
> >>>
> >>
> >>
> >> Exactly! the ./do-exofs format command will set this for you, as well
> as
> >> mkfs.exofs the
> >> FS for you.
> >>
> >>> 3. It is mandatory to use raid-driver (raid456) in the script? Why?
> >>>
> >>
> >>
> >> What? where? Rrrr you are right. this is a very old tree. Let me see
> >> if I have something newer to push. It should all load automatically
> now.
> >>
> >> But yes the dependency on raid456.ko is built in. Though if you use
> >> raid=0 on the format command line it will not be used in run time.
> >>
> >>>
> >>> The error is: 
> >>> mount -t exofs -o
> >> osdname=d2683732-c906-4ee1-9dbd-c10c27bb40df,pid=0x10000,_netdev
> /dev/osd0 /mnt/osd0/
> >>> mount: wrong fs type, bad option, bad superblock on /dev/osd0,
> >>>        missing codepage or helper program, or other error
> >>>        In some cases useful info is found in syslog - try
> >>>        dmesg | tail  or so
> >>>
> >>> dmesg says:
> >>> exofs: Unable to mount exofs on (null) pid=0x0 err=-22
> >>>
> >>
> >>
> >> Probably you forgot the "./do-exofs format" stage. Please read the
> script
> >> before, you might need to edit it. It is the stage that calls
> mkfs.exofs
> >> to make a new filesystem for you. (An OSD is a raw device that can host
> >> many filesystems each in it's own osd-partition.
> >>
> >>>
> >>> Thanks for answering my questions.
> >>
> >>
> >>> Regards
> >>> Johannes
> >>>
> >>
> >>
> >> Cheers
> >> Boaz
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 


Thanks for your efforts


Johannes
-- 
Empfehlen Sie GMX DSL Ihren Freunden und Bekannten und wir
belohnen Sie mit bis zu 50,- Euro! https://freundschaftswerbung.gmx.de
