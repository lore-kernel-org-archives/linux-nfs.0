Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.chillheid.nl ([195.189.117.195]:56573 "EHLO
	mail.chillheid.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab2BCWoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 17:44:16 -0500
From: koen@chillheid.nl
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: oops when copying a file from a nfs mount
Date: Fri, 03 Feb 2012 23:36:04 +0100
Message-Id: <20120203223604.98C91405DC@mail.chillheid.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Since updating from kernel 3.2.1 to 3.2.2, copying a file from a nfs mount
using `cp` results in a kernel oops. Copying the same file with `cat
/nfsmount/file > /local/file` gives no problems.

I can reliably trigger the oops with a simple:

    cp /nfsmount/file /local/dir

System information:

    % cat /proc/version
    Linux version 3.2.2-1-vanilla (koen@pino) (gcc version 4.6.2 20120120 (prerelease) (GCC) ) #1 SMP PREEMPT Fri Feb 3 01:51:55 CET 2012

    % zgrep '^CONFIG_NFS' /proc/config.gz
    CONFIG_NFS_FS=m
    CONFIG_NFS_V3=y
    CONFIG_NFS_V3_ACL=y
    CONFIG_NFS_V4=y
    CONFIG_NFS_FSCACHE=y
    CONFIG_NFS_USE_KERNEL_DNS=y
    CONFIG_NFSD=m
    CONFIG_NFSD_V2_ACL=y
    CONFIG_NFSD_V3=y
    CONFIG_NFSD_V3_ACL=y
    CONFIG_NFSD_V4=y
    CONFIG_NFS_ACL_SUPPORT=m
    CONFIG_NFS_COMMON=y

    % ./ver_linux
    Linux pino 3.2.2-1-vanilla #1 SMP PREEMPT Fri Feb 3 01:51:55 CET 2012 i686 Intel(R) Celeron(R) CPU E1200 @ 1.60GHz GenuineIntel GNU/Linux
     
    Gnu C                  4.6.2
    Gnu make               3.82
    binutils               2.22.0.20111227
    util-linux             2.20.1
    mount                  support
    module-init-tools      4
    e2fsprogs              1.42
    jfsutils               1.1.15
    reiserfsprogs          3.6.21
    xfsprogs               3.1.7
    pcmciautils            018
    PPP                    2.4.5
    Linux C Library        2.15
    Dynamic linker (ldd)   2.15
    Linux C++ Library      6.0.16
    Procps                 3.2.8
    Net-tools              1.60
    Kbd                    1.15.3
    Sh-utils               8.15
    Modules Loaded         ipv6 ext3 jbd joydev snd_usb_audio snd_usbmidi_lib snd_rawmidi snd_seq_device usbhid hid wacom snd_hda_codec_hdmi btusb bluetooth rfkill ppdev evdev snd_hda_codec_realtek radeon snd_hda_intel snd_hda_codec drm_kms_helper snd_pcm atl1 iTCO_wdt iTCO_vendor_support pcspkr ttm i2c_i801 serio_raw snd_page_alloc snd_hwdep snd_timer snd drm soundcore mii i2c_algo_bit i2c_core intel_agp intel_gtt agpgart floppy parport_pc parport asus_atk0110 nfs button nfs_acl lockd auth_rpcgss sunrpc fscache cpufreq_ondemand acpi_cpufreq mperf processor freq_table ext4 crc16 jbd2 mbcache dm_mod sd_mod pata_acpi ata_piix libata uhci_hcd scsi_mod ehci_hcd usbcore usb_common

    % grep nfs /proc/mounts
    servername:/data /data nfs4 rw,nosuid,nodev,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=172.16.1.84,minorversion=0,local_lock=none,addr=172.16.1.1 0 0

Trace:

    Feb  3 03:45:23 pino kernel: [ 2931.910546] *pde = 00000000 
    Feb  3 03:45:23 pino kernel: [ 2931.910626] Modules linked in: ipv6 ext3 jbd joydev snd_usb_audio snd_usbmidi_lib usbhid snd_rawmidi snd_seq_device hid wacom btusb bluetooth rfkill snd_hda_codec_hdmi ppdev radeon evdev snd_hda_codec_realtek drm_kms_helper ttm snd_hda_intel iTCO_wdt iTCO_vendor_support drm pcspkr snd_hda_codec serio_raw i2c_i801 snd_pcm snd_page_alloc snd_hwdep i2c_algo_bit i2c_core snd_timer intel_agp atl1 intel_gtt snd agpgart mii soundcore floppy parport_pc parport asus_atk0110 button nfs nfs_acl lockd auth_rpcgss sunrpc fscache cpufreq_ondemand acpi_cpufreq mperf processor freq_table ext4 crc16 jbd2 mbcache dm_mod sd_mod pata_acpi ata_piix libata scsi_mod uhci_hcd ehci_hcd usbcore usb_common
    Feb  3 03:45:23 pino kernel: [ 2931.911382] 
    Feb  3 03:45:23 pino kernel: [ 2931.911400] Pid: 2003, comm: cp Not tainted 3.2.2-1-vanilla #1 System manufacturer System Product Name/P5B-MX
    Feb  3 03:45:23 pino kernel: [ 2931.911500] EIP: 0060:[<c01f3c00>] EFLAGS: 00010282 CPU: 1
    Feb  3 03:45:23 pino kernel: [ 2931.911552] EIP is at page_address+0x10/0xe0
    Feb  3 03:45:23 pino kernel: [ 2931.911592] EAX: 00000000 EBX: c6699dd8 ECX: f2c6b1e4 EDX: 00000038
    Feb  3 03:45:23 pino kernel: [ 2931.911648] ESI: 00000000 EDI: 00000000 EBP: c6699c18 ESP: c6699c08
    Feb  3 03:45:23 pino kernel: [ 2931.911704]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
    Feb  3 03:45:23 pino kernel: [ 2931.911839]  00001000 c6699dd8 00000000 c6699c78 c6699c54 f8666b45 00000000 00001000
    Feb  3 03:45:23 pino kernel: [ 2931.911934]  0000000e 00000000 00000002 f2c6b084 00000000 00000000 0000006e 00000000
    Feb  3 03:45:23 pino kernel: [ 2931.912028]  f584c700 f59cde00 f8666ab0 c6699ca0 f855c4a5 f2c6b020 c6699c7c f855ca07
    Feb  3 03:45:23 pino kernel: [ 2931.912161]  [<f8666b45>] nfs4_xdr_enc_getacl+0x95/0xc0 [nfs]
    Feb  3 03:45:23 pino kernel: [ 2931.912224]  [<f8666ab0>] ? nfs4_xdr_enc_fs_locations+0xf0/0xf0 [nfs]
    Feb  3 03:45:23 pino kernel: [ 2931.912292]  [<f855c4a5>] rpcauth_wrap_req+0x75/0xc0 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912351]  [<f855ca07>] ? unx_marshal+0x47/0xc0 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912404]  [<c01d9513>] ? mempool_alloc_slab+0x13/0x20
    Feb  3 03:45:23 pino kernel: [ 2931.912460]  [<f8553b6e>] call_transmit+0x14e/0x250 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912513]  [<c01d978b>] ? mempool_alloc+0x3b/0xf0
    Feb  3 03:45:23 pino kernel: [ 2931.912565]  [<f855ad12>] __rpc_execute+0x52/0x2a0 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912618]  [<c0167c23>] ? wake_up_bit+0x23/0x30
    Feb  3 03:45:23 pino kernel: [ 2931.912668]  [<f855b3b8>] rpc_execute+0x38/0x40 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912724]  [<f8553fe9>] rpc_run_task+0x59/0x70 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912778]  [<f85540fc>] rpc_call_sync+0x3c/0x60 [sunrpc]
    Feb  3 03:45:23 pino kernel: [ 2931.912840]  [<f865e283>] _nfs4_call_sync+0x23/0x30 [nfs]
    Feb  3 03:45:23 pino kernel: [ 2931.912899]  [<f865d0a6>] __nfs4_get_acl_uncached+0x186/0x290 [nfs]
    Feb  3 03:45:23 pino kernel: [ 2931.912968]  [<f865f6e4>] nfs4_xattr_get_nfs4_acl+0xe4/0x150 [nfs]
    Feb  3 03:45:23 pino kernel: [ 2931.913028]  [<c0240f96>] generic_getxattr+0x46/0x60
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c0240f50>] ? xattr_resolve_name+0x80/0x80
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c02414f0>] vfs_getxattr+0x80/0xb0
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c02415ac>] getxattr+0x8c/0x110
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c0230cda>] ? path_openat+0xca/0x350
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c01f7a01>] ? handle_pte_fault+0xe1/0x8e0
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c0231071>] ? do_filp_open+0x31/0x80
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c022d39b>] ? putname+0x2b/0x40
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c022d39b>] ? putname+0x2b/0x40
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c022d39b>] ? putname+0x2b/0x40
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c0222531>] ? do_sys_open+0x161/0x1b0
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c02416fb>] ? listxattr+0x5b/0xb0
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c0241e76>] sys_fgetxattr+0x46/0x70
    Feb  3 03:45:23 pino kernel: [ 2931.913057]  [<c047c39f>] sysenter_do_call+0x12/0x28
    Feb  3 03:45:23 pino kernel: [ 2931.932919] ---[ end trace 2749b252593ffc7f ]---

Please let me know if you need any other information, or if I can do anything else to help (I'm not a programmer).

Regards,
Koen Wilde
