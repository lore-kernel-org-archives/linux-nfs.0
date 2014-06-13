Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.aixigo.de ([80.149.209.52]:53237 "EHLO mail.aixigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577AbaFMOed (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2014 10:34:33 -0400
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11])
	by mail.aixigo.com (8.14.3/8.14.3) with ESMTP id s5DEBG96030859
	for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2014 16:11:16 +0200 (CEST)
Message-ID: <539B0683.3020605@aixigo.de>
Date: Fri, 13 Jun 2014 16:11:15 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
MIME-Version: 1.0
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFS service inside a container
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I would like to run an NFServer inside a container. The idea
is to mirror the whole NFS service container to a fallback
host using drbd, and to provide preconfigured NFS containers
to whoever needs it.

Unfortunately the kernel (3.14 of Debian Jessie, backported to
Wheezy) did not share my enthusiasm:

Jun 13 15:33:55 srvl011a kernel: [  725.372466] WARNING: CPU: 6 PID: 11134 at /build/linux-v1L7fI/linux-3.14.4/fs/nfsd/nfs4recover.c:1195 nfsd4_umh_cltrack_init+0x42/0x50 [nfsd]()
Jun 13 15:33:55 srvl011a kernel: [  725.372468] NFSD: attempt to initialize umh client tracking in a container!
Jun 13 15:33:55 srvl011a kernel: [  725.376800] Modules linked in: veth sha256_ssse3 sha256_generic hmac drbd lru_cache libcrc32c nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc bonding bridge stp llc dm_crypt ioatdma radeon iTCO_wdt iTCO_vendor_support i5400_edac lpc_ich mfd_core rng_core ttm edac_core i2c_i801 i5k_amb coretemp drm_kms_helper psmouse shpchp serio_raw joydev pcspkr evdev drm parport_pc parport processor button kvm tpm_tis tpm thermal_sys ext4 crc16 mbcache jbd2 crc32c btrfs xor raid6_pq dm_mod hid_generic usbhid hid sd_mod crct10dif_generic crc_t10dif crct10dif_common sg sr_mod cdrom ata_generic ehci_pci ata_piix uhci_hcd ehci_hcd libata usbcore e1000e usb_common igb i2c_algo_bit i2c_core dca ptp pps_core 3w_9xxx scsi_mod
Jun 13 15:33:55 srvl011a kernel: [  725.376868] CPU: 6 PID: 11134 Comm: rpc.nfsd Tainted: G        W I  3.14-0.bpo.1-amd64 #1 Debian 3.14.4-1~bpo70+1
Jun 13 15:33:55 srvl011a kernel: [  725.376870] Hardware name: Supermicro X7DW3/X7DWN+, BIOS  1.2 11/04/2008
Jun 13 15:33:55 srvl011a kernel: [  725.376872]  0000000000000000 ffffffffa0740758 ffffffff814eb7c7 ffff8810278cbd78
Jun 13 15:33:55 srvl011a kernel: [  725.376875]  ffffffff81064cc7 ffff880fecbeac00 ffff880febfc0100 ffff880febfc0100
Jun 13 15:33:55 srvl011a kernel: [  725.376878]  ffff880fecbeac00 0000000000000000 ffffffff81064db5 ffffffffa0740710
Jun 13 15:33:55 srvl011a kernel: [  725.376881] Call Trace:
Jun 13 15:33:55 srvl011a kernel: [  725.376889]  [<ffffffff814eb7c7>] ? dump_stack+0x41/0x51
Jun 13 15:33:55 srvl011a kernel: [  725.376894]  [<ffffffff81064cc7>] ? warn_slowpath_common+0x87/0xc0
Jun 13 15:33:55 srvl011a kernel: [  725.376896]  [<ffffffff81064db5>] ? warn_slowpath_fmt+0x45/0x50
Jun 13 15:33:55 srvl011a kernel: [  725.376902]  [<ffffffffa073a652>] ? nfsd4_umh_cltrack_init+0x42/0x50 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376907]  [<ffffffffa073b5b1>] ? nfsd4_client_tracking_init+0x91/0x130 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376914]  [<ffffffffa073590d>] ? nfs4_state_start_net+0x27d/0x320 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376919]  [<ffffffffa070fae3>] ? nfsd_svc+0x1b3/0x360 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376924]  [<ffffffffa07108b0>] ? write_filehandle+0x230/0x230 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376927]  [<ffffffff812a008b>] ? simple_strtoull+0x2b/0x50
Jun 13 15:33:55 srvl011a kernel: [  725.376932]  [<ffffffffa07108b0>] ? write_filehandle+0x230/0x230 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376936]  [<ffffffffa0710925>] ? write_threads+0x75/0xc0 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376941]  [<ffffffff81131fa9>] ? __get_free_pages+0x9/0x50
Jun 13 15:33:55 srvl011a kernel: [  725.376946]  [<ffffffff811bd061>] ? simple_transaction_get+0xc1/0xe0
Jun 13 15:33:55 srvl011a kernel: [  725.376951]  [<ffffffffa07108b0>] ? write_filehandle+0x230/0x230 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376955]  [<ffffffffa0710116>] ? nfsctl_transaction_write+0x56/0x80 [nfsd]
Jun 13 15:33:55 srvl011a kernel: [  725.376959]  [<ffffffff81198026>] ? vfs_write+0xc6/0x1f0
Jun 13 15:33:55 srvl011a kernel: [  725.376962]  [<ffffffff8119851b>] ? SyS_write+0x4b/0xb0
Jun 13 15:33:55 srvl011a kernel: [  725.376965]  [<ffffffff814f9779>] ? system_call_fastpath+0x16/0x1b
Jun 13 15:33:55 srvl011a kernel: [  725.376967] ---[ end trace a408a046f76bfc25 ]---
Jun 13 15:33:55 srvl011a kernel: [  725.377001] ------------[ cut here ]------------


I have found a thread on lkml about this (http://lkml.org/lkml/2013/3/1/78),
but it seems there was no conclusion.

Is this something that could be supported?


Regards
Harri
-- 
aixigo AG, Karl-Friedrich-Strasse 68, 52072 Aachen, Germany
phone: +49 241 559709-79, fax: +49 241 559709-99
eMail: harald.dunkel@aixigo.de, web: http://www.aixigo.de
Amtsgericht Aachen - HRB 8057, Vorstand: Erich Borsch, Christian Friedrich, Tobias Haustein, Vors. des Aufsichtsrates: Prof. Dr. Ruediger von Nitzsch
