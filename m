Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:47002 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755290Ab2EUNHO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 09:07:14 -0400
Cc: osd-dev@open-osd.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Mon, 21 May 2012 15:07:11 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <4FB381CA.7090906@panasas.com>
Message-ID: <20120521130711.192480@gmx.net>
MIME-Version: 1.0
References: <20120515090332.182970@gmx.net> <4FB22658.9010909@panasas.com>
 <20120515121931.192500@gmx.net> <4FB25799.8060306@panasas.com>
 <20120516090006.192470@gmx.net> <4FB381CA.7090906@panasas.com>
Subject: Re: Questions about Exofs
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz,

sorry for my late reply. It was a public holiday in Germany. So i wasn't at work.

> Datum: Wed, 16 May 2012 13:30:34 +0300
> Von: Boaz Harrosh <bharrosh@panasas.com>
> An: Johannes Schild <JSchild@gmx.de>
> CC: linux-nfs@vger.kernel.org, osd-dev@open-osd.org
> Betreff: Re: Questions about Exofs

> On 05/16/2012 12:00 PM, Johannes Schild wrote:
> 
> > Hi Boaz,
> 
> <>
> 
> >> Do you see any prints in dmsg regarding iscsi, before the crash?
> > 
> > I see output like this. Always "registered" no unloading execpt after
> the crash.
> > 
> > [    4.713107] iscsi: registered transport (tcp)
> > #<some output removed>
> > [    4.739465] iscsi: registered transport (cxgb3i)
> > #<some output removed>
> > [    4.750756] iscsi: registered transport (cxgb4i)
> > #<some output removed>
> > [    4.771300] iscsi: registered transport (bnx2i)
> > [    4.781045] iscsi: registered transport (be2iscsi)
> > 
> 
> <>
> 
> >> could you please do:
> >> []$ gdb fs/exofs/exofs.ko
> > 
> > [root@ExB osd-repo]# gdb /root/pnfs-repo/fs/exofs/exofs.ko 
> > GNU gdb (GDB) Fedora (7.3.50.20110722-13.fc16)
> > Copyright (C) 2011 Free Software Foundation, Inc.
> > License GPLv3+: GNU GPL version 3 or later
> <http://gnu.org/licenses/gpl.html>
> > This is free software: you are free to change and redistribute it.
> > There is NO WARRANTY, to the extent permitted by law.  Type "show
> copying"
> > and "show warranty" for details.
> > This GDB was configured as "x86_64-redhat-linux-gnu".
> > For bug reporting instructions, please see:
> > <http://www.gnu.org/software/gdb/bugs/>...
> > Reading symbols from /root/pnfs-repo/fs/exofs/exofs.ko...done.
> > 
> >> Inside gdb
> >>> list *(exofs_free_sbi+0x59)
> > 
> > (gdb) list *(exofs_free_sbi+0x59)
> > 0x47a9 is in exofs_free_sbi (include/scsi/osd_ore.h:83).
> > 78	/* ore_comp_dev Recievies a logical device index */
> > 79	static inline struct osd_dev *ore_comp_dev(
> > 80		const struct ore_components *oc, unsigned i)
> > 81	{
> > 82		BUG_ON((i < oc->first_dev) || (oc->first_dev + oc->numdevs <= i));
> > 83		return oc->ods[i - oc->first_dev]->od;
> > 84	}
> > 85	
> > 86	static inline void ore_comp_set_dev(
> > 87		struct ore_components *oc, unsigned i, struct osd_dev *od)
> > 
> >> and also
> >>> list *(exofs_fill_super+0x440)
> > 
> > (gdb) list *(exofs_fill_super+0x440)
> > 0x5850 is in exofs_fill_super (fs/exofs/super.c:847).
> > 842			dput(sb->s_root);
> > 843			sb->s_root = NULL;
> > 844			goto free_sbi;
> > 845		}
> > 846	
> > 847		_exofs_print_device("Mounting", opts->dev_name,
> > 848				    ore_comp_dev(&sbi->oc, 0),
> > 849				    sbi->one_comp.obj.partition);
> > 850		return 0;
> > 851	
> > (gdb) 
> > 
> 
> 
> OK I understand we are _exofs_print_device an array that does
> not exists yet.
> 
> >>
> >> Could you enable CONFIG_EXOFS_DEBUG it's under:
> >> 	miscellaneous-filesystems/exofs in make xconfig
> > 
> > I enabled it.
> > 
> >> Then re-run everything send me the output
> >> []$ ./do-osd stop
> > 
> > [root@ExB osd-repo]# ./do-osd stop
> > /dev/osd0
> > FATAL: Module osd is builtin
> > 
> > Should it be a modul or doesn't matter?
> > 
> 
> 
> It should be fine. scripts expect it as a module.
> 
> >> []$ ls /dev/osd*
> > 
> > [root@ExB osd-repo]# ls /dev/osd*
> > ls: cannot access /dev/osd*: No such file or directory
> > 
> >> []$ ./do-osd
> > 
> > [root@ExB osd-repo]# ./do-osd
> > iscsid.service - LSB: Starts and stops login iSCSI daemon.
> > 	  Loaded: loaded (/etc/rc.d/init.d/iscsid)
> > 	  Active: inactive (dead) since Wed, 16 May 2012 10:46:23 +0200; 3min
> 11s ago
> > 	 Process: 2287 ExecStop=/etc/rc.d/init.d/iscsid stop (code=exited,
> status=0/SUCCESS)
> > 	 Process: 1168 ExecStart=/etc/rc.d/init.d/iscsid start (code=exited,
> status=0/SUCCESS)
> > 	Main PID: 1213 (code=exited, status=0/SUCCESS)
> > 	  CGroup: name=systemd:/system/iscsid.service
> > 18446744072101122080
> > login into: 192.168.0.1:3260
> > 192.168.0.1:3260,1 .root.var.osd-tgt.tgt-1.ExA
> > 
> >> []$ ls /dev/osd*
> > 
> > [root@ExB server]# ls /dev/os*
> > /dev/osd1
> > 
> 
> 
> /dev/osd1 interesting. make sure your scripts are using /dev/osd1.
> I suspect this is an artifact of the last games. On a clean reboot
> a single device should be /dev/osd0. The scripts expect that.
> 

This was my fault. I rebooted and it works fine.

> >> []$ ./do-exofs format
> >> Send me the output of that
> > 
> > ./do-exofs format
> > mkexofs_format >>> 
> 
> 
> No output from the format command? that is not good. mkfs.exofs is
> very bad in not saying anything when failing.
> 
> Probably because it was formatting /dev/osd0 and we have /dev/osd1 only
> 
> > osd stop? >>> 
> > FATAL: Module osd is builtin
> > osd start? >>> 
> > iscsid.service - LSB: Starts and stops login iSCSI daemon.
> > 	  Loaded: loaded (/etc/rc.d/init.d/iscsid)
> > 	  Active: inactive (dead) since Wed, 16 May 2012 10:46:23 +0200; 6min
> ago
> > 	 Process: 2287 ExecStop=/etc/rc.d/init.d/iscsid stop (code=exited,
> status=0/SUCCESS)
> > 	 Process: 1168 ExecStart=/etc/rc.d/init.d/iscsid start (code=exited,
> status=0/SUCCESS)
> > 	Main PID: 1213 (code=exited, status=0/SUCCESS)
> > 	  CGroup: name=systemd:/system/iscsid.service
> > 18446744072101122080
> > login into: 192.168.0.1:3260
> > 192.168.0.1:3260,1 .root.var.osd-tgt.tgt-1.ExA
> > Logging in to [iface: default, target: .root.var.osd-tgt.tgt-1.ExA,
> portal: 192.168.0.1,3260] (multiple)
> > Login to [iface: default, target: .root.var.osd-tgt.tgt-1.ExA, portal:
> 192.168.0.1,3260] successful.
> > 
> >> []$ ./do-exofs start
> >> Send me the dmesg output of this stage, or if not too big
> >> the dmesg output of from before ./do-osd <1>
> > 
> > I pushed it on nopaste:
> > http://nopaste.info/cd3c6f9141.html
> > 
> 
> 
> in the dmesg I see:
> 
> [ 2516.994781] exofs @parse_options:88: parse_options
> osdname=d2683732-c906-4ee1-9dbd-c10c27bb40df,pid=0x10000
> [ 2516.994808] osd @_mach_odi:261: found device sysid_len=0 osdname=36
> [ 2516.994816] osd @_osdv2_req_encode_common:617: OSDv2 execute opcode
> 0x8885
> [ 2516.994831] osd @_init_blk_request:1616: or=ffff880020d7ec00 has_in=1
> has_out=0 => 0, ffff88003bbf8a10
> 
> the very first read below fails. This is the first read from super-block
> object.
> Here it gets an -5 (-EIO) if it was an osd-target error you would have
> a scsi-sense printout so it means it is a communication problem.
> 
> [ 2516.996034] exofs @exofs_read_kern:245: osd_execute_request() => -5
> [ 2516.996041] exofs: Unable to mount exofs on (null) pid=0x10000 err=-5
> 
> This crash below I should fix. Code is not dealing properly with the IO
> error
> and continues to try and dmesg-print an array that does not exist yet.
> I will fix that.
> 
> [ 2516.996106] BUG: unable to handle kernel NULL pointer dereference at   
>       (null)
> [ 2516.996111] IP: [<ffffffffa033c779>] exofs_free_sbi+0x59/0xa0 [exofs] 
> 
> But the problem still remains why do we get IO errors from iscsi?
> 
> Later we have:
> [ 3241.802074]  connection1:0: detected conn error (1020)
> 
> disconnect. Do you see some prints at the otgtd side.
> If you use the ./up script it might rederect these to a log file
> do "./up log"

http://nopaste.info/04c87daf8b.html
Thats the output from ./up.
In the up-script what i use is no optione „log“ maybe its too old?

> 
> [ 3398.831629] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
> [ 3398.831919] iscsi: registered transport (cxgb3i)
> [ 3398.836776] Chelsio T4 iSCSI Driver cxgb4i v0.9.1 (Aug. 2010)
> [ 3398.836996] iscsi: registered transport (cxgb4i)
> [ 3398.841397] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.8 (Jan 3,
> 2012)
> [ 3398.845267] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.0.3 (Jun 15,
> 2011)
> [ 3398.845475] iscsi: registered transport (bnx2i)
> [ 3400.201828] scsi4 : iSCSI Initiator over TCP/IP
> [ 3400.715101] scsi 4:0:0:0: Object storage    IET      OSD             
> 0001 PQ: 0 ANSI: 5
> [ 3400.718038] osd @__detect_osd:359: start scsi_test_unit_ready
> ffff880020db3800 ffff880020dfa000 ffff88003974aca0
> 
> Right after the crash. So iscsi unloaded and loaded. There was a
> disconnect.
> We must investigate why iscsi has communication problems?
> 
> the "192.168.0.1:3260" above is that your host's IP? You are running the
> otgtd on
> the host and exofs in VM? That's good that's what I use all the time.

I have for every Server (DS, MDS, Client) a VM running.
Its only to test.

> 
> If you have time you should do two experiments.
> 
> 1. Please run the "./do-osd test" test. send me the output.
>    It runs a user mode test of the osd device and does some
>    very basic communications.
>    Note that it will wipe your OSD and you will need to ./do-exofs format
> again
>    after it.

[root@ExM osd-repo]# ./do-osd test
libosd: Detected OSD2 device
libosd: VENDOR_IDENTIFICATION  [OSC]
libosd: PRODUCT_IDENTIFICATION [OSDEMU]
libosd: PRODUCT_MODEL          [OSD2r05]
libosd: PRODUCT_REVISION_LEVEL [117]
libosd: PRODUCT_SERIAL_NUMBER  [2]
libosd: OSD_NAME               [d2683732-c906-4ee1-9dbd-c10c27bb40df]
libosd: TOTAL_CAPACITY         [0xffffffffffffffff]
libosd: USED_CAPACITY          [0xffffffffffffffff]
libosd: NUMBER_OF_PARTITIONS   [17]
libosd: CLOCK                  [0x000000000000]
libosd: OSD_SYSTEM_ID(20)
        [f181000e4f534320202020204f5344454d550000][....OSC     OSDEMU..]
libosd: format
libosd: create_partition
libosd: create_object
libosd: create_object
libosd: write
libosd: write
libosd: read
libosd: read
libosd: !!! Failed osd_req_write_sg_kern
do_test_17 returned 12: Cannot allocate memory


> 2. on the osd-target side you probably ran ./up. the otgtd also supports
>    none-osd regular disk-devices. Could you set up a regular disk
>    backbend as well. Look into "man tgtadm" on how to add a second
>    disk target.

I hope thats right what i did:

[root@ExA server]# tgtadm --lld iscsi --mode target --op new --tid=1 --targetname iqn.2012-04.ExA
[root@ExA server]# tgtadm --lld iscsi --mode logicalunit --op new --tid 1 --lun 1 -b /dev/sdb
[root@ExA server]# tgtadm --lld iscsi --mode target --op bind --tid 1 -I ALL
[root@ExA server]# tgtadm --lld iscsi --mode target --op show
Target 1: iqn.2012-04.ExA
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Readonly: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 2149 MB, Block size: 512
            Online: Yes
            Removable media: No
            Readonly: No
            Backing store type: rdwr
            Backing store path: /dev/sdb
            Backing store flags: 
    Account information:
    ACL information:
        ALL
[root@ExA server]# 

>    Once you login to the target you will see a new /dev/sdX device
>    try to dd into it, and also mkfs and mount an ext FS on it.

Yes /dev/sdd on my system.
I did if=/dev/zero of=/dev/sdd
worked well.
[root@ExM server]# /root/osd-repo/usr/mkfs.exofs –pid=0x10000 –raid=0 –mirrors=0 –stripe_apges=4 –dev=/dev/sdd
doesnt work. I got:
exofs_mkfs –pid=0x10000 returned -60: Unknown error -60
Maybe i do something wrong with the device?
> Or else investigate why there are iscsi communication problems.
> 
> > 
> > 
> >>
> >>> Just now i am using the 3.3.0 kernel from the linux-pnfs repository.
> >>>
> 
> 
> That's perfect it should have everything.
> 
> >>
> >>
> >> When compiling the Kernel, Did you enable CONFIG_PNFSD ?
> >> (That is the pNFSD Server Kernel Support)
> > 
> > No pNFSD Server support wasn't enabled,  i recompiled and activate it
> > 
> 
> 
> It's fine for this stage you don't need it
> 
> > 
> > 
> > 
> >> What platform are you using? Distro + ARCH ?
> > 
> > Iam experimenting with Fedora 16 (3.3.0 pnfs kernel) and arch x86_64
> > 
> 
> 
> I use that here too
> 
> > 
> > Thanks for your efforts
> > Johannes
> 
> 
> Hope that helps. Thanks for the report we got a bug fix
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I have some additional questions to object-layout and to the storage:

How do i add a second physical storage server to my test configuration?
The script „do-osd“ contains only one $IP, so how can i add a second one?

I read the rfc5664 (Object-Based Parallel NFS (pNFS) Operations) but iam not sure if i understand it correctly:

The client retrievs a Layout (in my case object-layout) from the MDS. Then i searched with Wireshark for GETDEVICELIST/GETDEVICEINFO but i cant find them.

Normaly the client gets a GETDEVICELIST/GETDEVICEINFO so he can determine which OSDs are available from MDS right? But how it works after receiving the list? 

Hope you can answer my (dump) questions...

Cheers 
Johannes

-- 
Empfehlen Sie GMX DSL Ihren Freunden und Bekannten und wir
belohnen Sie mit bis zu 50,- Euro! https://freundschaftswerbung.gmx.de
