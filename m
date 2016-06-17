Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35780 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbcFQKCG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 06:02:06 -0400
Received: by mail-oi0-f52.google.com with SMTP id w5so109981231oib.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2016 03:02:05 -0700 (PDT)
MIME-Version: 1.0
From: Damjan Georgievski <gdamjan@gmail.com>
Date: Fri, 17 Jun 2016 12:02:04 +0200
Message-ID: <CAEk1YH658ajK5Dz-T0=_EEP-zS5KUD+Awm0AsAQyjqMDjKLraw@mail.gmail.com>
Subject: nfsd crash with 4.6 and 4.7 (bisected)
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,
I'm experiencing a kernel crash with the kernel nfs daemon in 4.6.1,
4.6.2 and 4.7.0-rc3-g5edb564
4.5.4 is ok.

My server is ArchLinux, nothing special, nfs-server.service enabled,
this in exports:
/home/nfs/archlinux-rpi
192.168.15.0/24(rw,no_subtree_check,nohide,insecure,no_root_squash,async)

The client is a raspberrypi with 4.4.13-2-ARCH kernel, a nfs root,
ArchLinuxArm and this kernel cmdline:
nfsroot=192.168.15.103:/home/nfs/archlinux-rpi,vers=4.2,proto=tcp,rsize=1048576,wsize=1048576

the crash happens every time I *reboot* the raspberrypi. just booting
it in the first place doesn't crash the server.
please cc me for other info, since I'm not subscribed.



I'm fairly inexperienced about bisecting kernel crashes, but what it
turned out for me was:
# first bad commit: [ad01b2c68d0ac5f3d4a3f807bec77b720b1c62a0] SUNRPC:
Make rpc_clnt store the multipath iterators


kernel dump from netconsole:
$ nc -u -l -p 6666
[ 3816.099155] general protection fault: 0000 [#1] PREEMPT SMP
[ 3816.099185] Modules linked in: netconsole rpcsec_gss_krb5
ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter
sha256_ssse3 sha256_generic hmac drbg ansi_cprng ctr ccm bridge stp
llc tun arc4 joydev mousedev ir_rc6_decoder snd_hda_codec_hdmi
ath9k_htc ath9k_common ath9k_hw ath mac80211 cfg80211 rfkill
intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
kvm snd_hda_codec_realtek snd_hda_codec_generic irqbypass i915 ppdev
iTCO_wdt iTCO_vendor_support snd_hda_intel crct10dif_pclmul
crc32_pclmul crc32c_intel ghash_clmulni_intel snd_hda_codec evdev
input_leds snd_hda_core drm_kms_helper cryptd snd_hwdep snd_pcm
mac_hid r8169 pcspkr ir_lirc_codec mii lirc_dev drm snd_timer
serio_raw rc_rc6_mce i2c_i801 ite_cir lpc_ich wmi snd rc_core mei_me
mei parport_pc soundcore parport fan battery intel_gtt syscopyarea
sysfillrect thermal sysimgblt fb_sys_fops video tpm_crb fjes button
i2c_algo_bit shpchp tpm_tis tpm processor sch_fq_codel vfat fat nfsd
auth_rpcgss oid_registry nfs nfs_acl lockd grace sunrpc fscache
ip_tables x_tables ext4 crc16 jbd2 mbcache hid_lenovo led_class usbhid
hid sd_mod sr_mod cdrom atkbd libps2 ahci libahci libata scsi_mod
ehci_pci ehci_hcd i8042 serio xhci_pci xhci_hcd usbcore usb_common
[ 3816.099822] CPU: 1 PID: 962 Comm: kworker/u4:1 Not tainted 4.6.2-1-ARCH #1
[ 3816.099842] Hardware name: ECS Z87H3-A4/Z87H3-A4, BIOS 4.6.5 05/29/2014
[ 3816.099868] Workqueue: nfsd4_callbacks nfsd4_run_cb_work [nfsd]
[ 3816.099948] task: ffff880211013500 ti: ffff8800d35b4000 task.ti:
ffff8800d35b4000
[ 3816.099969] RIP: 0010:[<ffffffffa025fbf0>]  [<ffffffffa025fbf0>]
xprt_switch_put+0x70/0xc0 [sunrpc]
[ 3816.100001] RSP: 0018:ffff8800d35b7bb8  EFLAGS: 00010286
[ 3816.100016] RAX: ffff880212847420 RBX: ffff88020e6b7f40 RCX: ffff8802102de110
[ 3816.100037] RDX: dead000000000200 RSI: 0000000000000000 RDI: ffff88020e6b7f40
[ 3816.100057] RBP: ffff8800d35b7bd8 R08: 0000000000000001 R09: 0000000000000000
[ 3816.100076] R10: ffff880215195800 R11: 00000000000009cb R12: ffff880212847000
[ 3816.100096] R13: ffff88020e6b7f50 R14: dead000000000200 R15: ffff880212843b08
[ 3816.100116] FS:  0000000000000000(0000) GS:ffff88021fb00000(0000)
knlGS:0000000000000000
[ 3816.100139] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3816.100155] CR2: 00000000006c0c78 CR3: 0000000001806000 CR4: 00000000000406e0
[ 3816.100175] Stack:
[ 3816.100182]  ffff880215194600 0000000000000000 ffffffff818b7bc0
0000000000000000
[ 3816.100209]  ffff8800d35b7be8 ffffffffa025fd86 ffff8800d35b7c10
ffffffffa023bc99
[ 3816.100235]  ffff880215194600 ffffffffa026e060 ffff8800d35b7c58
ffff8800d35b7c30
[ 3816.100261] Call Trace:
[ 3816.100274]  [<ffffffffa025fd86>] xprt_iter_destroy+0x16/0x20 [sunrpc]
[ 3816.100295]  [<ffffffffa023bc99>] rpc_free_client+0x99/0xf0 [sunrpc]
[ 3816.100316]  [<ffffffffa023bef0>] rpc_release_client+0x60/0xa0 [sunrpc]
[ 3816.100337]  [<ffffffffa023c142>] rpc_shutdown_client+0x62/0x150 [sunrpc]
[ 3816.100358]  [<ffffffff810b2e22>] ? enqueue_task_fair+0xa2/0x930
[ 3816.100379]  [<ffffffffa032806d>]
nfsd4_process_cb_update.isra.6+0x3d/0x1e0 [nfsd]
[ 3816.100402]  [<ffffffff810b02fb>] ? dequeue_entity+0x24b/0xb20
[ 3816.100421]  [<ffffffff810a3c2d>] ? ttwu_do_activate.constprop.40+0x5d/0x70
[ 3816.100441]  [<ffffffff810b1753>] ? put_prev_entity+0x33/0x8b0
[ 3816.100459]  [<ffffffff810b0c92>] ? dequeue_task_fair+0xc2/0x960
[ 3816.100477]  [<ffffffff810a4ad2>] ? default_wake_function+0x12/0x20
[ 3816.100495]  [<ffffffff8102d76d>] ? __switch_to+0x29d/0x430
[ 3816.100512]  [<ffffffff810a0f48>] ? finish_task_switch+0x78/0x210
[ 3816.100534]  [<ffffffffa03282a6>] nfsd4_run_cb_work+0x96/0x100 [nfsd]
[ 3816.100553]  [<ffffffff81093a05>] process_one_work+0x1e5/0x480
[ 3816.100571]  [<ffffffff81093ce8>] worker_thread+0x48/0x4e0
[ 3816.100587]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.100666]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.100684]  [<ffffffff81099998>] kthread+0xd8/0xf0
[ 3816.100700]  [<ffffffff815c7482>] ret_from_fork+0x22/0x40
[ 3816.100717]  [<ffffffff810998c0>] ? kthread_worker_fn+0x170/0x170
[ 3816.100734] Code: 89 c4 49 81 ec 20 04 00 00 74 27 8b 73 08 8d 56
ff 85 d2 89 53 08 75 08 48 c7 43 20 00 00 00 00 48 8b 50 08 48 8b 08
48 89 51 08 <48> 89 0a 4c 89 70 08 48 89 df e8 11 70 36 e1 4c 89 e7 e8
19 01
[ 3816.100935] RIP  [<ffffffffa025fbf0>] xprt_switch_put+0x70/0xc0 [sunrpc]
[ 3816.100959]  RSP <ffff8800d35b7bb8>
[ 3816.108555] ---[ end trace 7725cc220c7bda54 ]---
[ 3816.108572] note: kworker/u4:1[962] exited with preempt_count 1
[ 3816.108607] BUG: unable to handle kernel paging request at ffffffffffffffd8
[ 3816.108631] IP: [<ffffffff81099ee0>] kthread_data+0x10/0x20
[ 3816.108652] PGD 1809067 PUD 180b067 PMD 0
[ 3816.108670] Oops: 0000 [#2] PREEMPT SMP
[ 3816.108689] Modules linked in: netconsole rpcsec_gss_krb5
ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter
sha256_ssse3 sha256_generic hmac drbg ansi_cprng ctr ccm bridge stp
llc tun arc4 joydev mousedev ir_rc6_decoder snd_hda_codec_hdmi
ath9k_htc ath9k_common ath9k_hw ath mac80211 cfg80211 rfkill
intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
kvm snd_hda_codec_realtek snd_hda_codec_generic irqbypass i915 ppdev
iTCO_wdt iTCO_vendor_support snd_hda_intel crct10dif_pclmul
crc32_pclmul crc32c_intel ghash_clmulni_intel snd_hda_codec evdev
input_leds snd_hda_core drm_kms_helper cryptd snd_hwdep snd_pcm
mac_hid r8169 pcspkr ir_lirc_codec mii lirc_dev drm snd_timer
serio_raw rc_rc6_mce i2c_i801 ite_cir lpc_ich wmi snd rc_core mei_me
mei parport_pc soundcore parport fan battery intel_gtt syscopyarea
sysfillrect thermal sysimgblt fb_sys_fops video tpm_crb fjes button
i2c_algo_bit shpchp tpm_tis tpm processor sch_fq_codel vfat fat nfsd
auth_rpcgss oid_registry nfs nfs_acl lockd grace sunrpc fscache
ip_tables x_tables ext4 crc16 jbd2 mbcache hid_lenovo led_class usbhid
hid sd_mod sr_mod cdrom atkbd libps2 ahci libahci libata scsi_mod
ehci_pci ehci_hcd i8042 serio xhci_pci xhci_hcd usbcore usb_common
[ 3816.109242] CPU: 1 PID: 962 Comm: kworker/u4:1 Tainted: G      D
     4.6.2-1-ARCH #1
[ 3816.109265] Hardware name: ECS Z87H3-A4/Z87H3-A4, BIOS 4.6.5 05/29/2014
[ 3816.109292] task: ffff880211013500 ti: ffff8800d35b4000 task.ti:
ffff8800d35b4000
[ 3816.109313] RIP: 0010:[<ffffffff81099ee0>]  [<ffffffff81099ee0>]
kthread_data+0x10/0x20
[ 3816.109339] RSP: 0018:ffff8800d35b7990  EFLAGS: 00010002
[ 3816.109355] RAX: 0000000000000000 RBX: ffff88021fb15940 RCX: 0000000000000001
[ 3816.109376] RDX: ffff880217004080 RSI: ffff880211013580 RDI: ffff880211013500
[ 3816.109396] RBP: ffff8800d35b7990 R08: 00000000ffffffff R09: 0000000000000000
[ 3816.110775] R10: 0000000000000001 R11: ffff880211013580 R12: ffff880211013ac0
[ 3816.112158] R13: ffff880211013500 R14: ffff88021fb15940 R15: 0000000000015940
[ 3816.113544] FS:  0000000000000000(0000) GS:ffff88021fb00000(0000)
knlGS:0000000000000000
[ 3816.114931] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3816.116309] CR2: 0000000000000028 CR3: 0000000001806000 CR4: 00000000000406e0
[ 3816.117689] Stack:
[ 3816.119025]  ffff8800d35b79a0 ffffffff810945ce ffff8800d35b79f0
ffffffff815c3361
[ 3816.120351]  00ffffff8107d160 0000000000000000 ffff880211013500
ffff8800d35b8000
[ 3816.121640]  ffff880211013c08 ffff8800d35b7550 0000000000000000
ffff880212843b08
[ 3816.122893] Call Trace:
[ 3816.124096]  [<ffffffff810945ce>] wq_worker_sleeping+0xe/0x90
[ 3816.125272]  [<ffffffff815c3361>] __schedule+0x671/0xad0
[ 3816.126440]  [<ffffffff815c37fc>] schedule+0x3c/0x90
[ 3816.127600]  [<ffffffff8107ea86>] do_exit+0x7d6/0xb60
[ 3816.128754]  [<ffffffff8103196c>] oops_end+0x9c/0xd0
[ 3816.129898]  [<ffffffff81031e2b>] die+0x4b/0x70
[ 3816.131027]  [<ffffffff8102ef2c>] do_general_protection+0xcc/0x150
[ 3816.132214]  [<ffffffff815c9218>] general_protection+0x28/0x30
[ 3816.133337]  [<ffffffffa025fbf0>] ? xprt_switch_put+0x70/0xc0 [sunrpc]
[ 3816.134461]  [<ffffffffa025fc0f>] ? xprt_switch_put+0x8f/0xc0 [sunrpc]
[ 3816.135579]  [<ffffffffa025fd86>] xprt_iter_destroy+0x16/0x20 [sunrpc]
[ 3816.136694]  [<ffffffffa023bc99>] rpc_free_client+0x99/0xf0 [sunrpc]
[ 3816.137813]  [<ffffffffa023bef0>] rpc_release_client+0x60/0xa0 [sunrpc]
[ 3816.138925]  [<ffffffffa023c142>] rpc_shutdown_client+0x62/0x150 [sunrpc]
[ 3816.140032]  [<ffffffff810b2e22>] ? enqueue_task_fair+0xa2/0x930
[ 3816.141136]  [<ffffffffa032806d>]
nfsd4_process_cb_update.isra.6+0x3d/0x1e0 [nfsd]
[ 3816.142241]  [<ffffffff810b02fb>] ? dequeue_entity+0x24b/0xb20
[ 3816.143341]  [<ffffffff810a3c2d>] ? ttwu_do_activate.constprop.40+0x5d/0x70
[ 3816.144441]  [<ffffffff810b1753>] ? put_prev_entity+0x33/0x8b0
[ 3816.145539]  [<ffffffff810b0c92>] ? dequeue_task_fair+0xc2/0x960
[ 3816.146633]  [<ffffffff810a4ad2>] ? default_wake_function+0x12/0x20
[ 3816.147721]  [<ffffffff8102d76d>] ? __switch_to+0x29d/0x430
[ 3816.148808]  [<ffffffff810a0f48>] ? finish_task_switch+0x78/0x210
[ 3816.149899]  [<ffffffffa03282a6>] nfsd4_run_cb_work+0x96/0x100 [nfsd]
[ 3816.150989]  [<ffffffff81093a05>] process_one_work+0x1e5/0x480
[ 3816.152078]  [<ffffffff81093ce8>] worker_thread+0x48/0x4e0
[ 3816.153161]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.154240]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.155311]  [<ffffffff81099998>] kthread+0xd8/0xf0
[ 3816.156378]  [<ffffffff815c7482>] ret_from_fork+0x22/0x40
[ 3816.157446]  [<ffffffff810998c0>] ? kthread_worker_fn+0x170/0x170
[ 3816.158516] Code: 5c 5d c3 e8 5b 91 f6 ff e9 e2 fe ff ff 0f 1f 40
00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 8b 87 60 05 00 00
55 48 89 e5 <48> 8b 40 d8 5d c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44
00 00
[ 3816.159824] RIP  [<ffffffff81099ee0>] kthread_data+0x10/0x20
[ 3816.160960]  RSP <ffff8800d35b7990>
[ 3816.162087] CR2: ffffffffffffffd8
[ 3816.163271] ---[ end trace 7725cc220c7bda55 ]---
[ 3816.164399] Fixing recursive fault but reboot is needed!
[ 3816.165531] BUG: scheduling while atomic: kworker/u4:1/962/0x00000003
[ 3816.166677] Modules linked in: netconsole rpcsec_gss_krb5
ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter
sha256_ssse3 sha256_generic hmac drbg ansi_cprng ctr ccm bridge stp
llc tun arc4 joydev mousedev ir_rc6_decoder snd_hda_codec_hdmi
ath9k_htc ath9k_common ath9k_hw ath mac80211 cfg80211 rfkill
intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
kvm snd_hda_codec_realtek snd_hda_codec_generic irqbypass i915 ppdev
iTCO_wdt iTCO_vendor_support snd_hda_intel crct10dif_pclmul
crc32_pclmul crc32c_intel ghash_clmulni_intel snd_hda_codec evdev
input_leds snd_hda_core drm_kms_helper cryptd snd_hwdep snd_pcm
mac_hid r8169 pcspkr ir_lirc_codec mii lirc_dev drm snd_timer
serio_raw rc_rc6_mce i2c_i801 ite_cir lpc_ich wmi snd rc_core mei_me
mei parport_pc soundcore parport fan battery intel_gtt syscopyarea
sysfillrect thermal sysimgblt fb_sys_fops video tpm_crb fjes button
i2c_algo_bit shpchp tpm_tis tpm processor sch_fq_codel vfat fat nfsd
auth_rpcgss oid_registry nfs nfs_acl lockd grace sunrpc fscache
ip_tables x_tables ext4 crc16 jbd2 mbcache hid_lenovo led_class usbhid
hid sd_mod sr_mod cdrom atkbd libps2 ahci libahci libata scsi_mod
ehci_pci ehci_hcd i8042 serio xhci_pci xhci_hcd usbcore usb_common
[ 3816.174755] CPU: 1 PID: 962 Comm: kworker/u4:1 Tainted: G      D
     4.6.2-1-ARCH #1
[ 3816.176077] Hardware name: ECS Z87H3-A4/Z87H3-A4, BIOS 4.6.5 05/29/2014
[ 3816.177408]  0000000000000086 000000008d322409 ffff8800d35b7670
ffffffff812e5492
[ 3816.178801]  ffff88021fb15940 0000000000000009 ffff8800d35b7680
ffffffff810a112b
[ 3816.180130]  ffff8800d35b76d0 ffffffff815c3589 0000000000000008
ffff8800d35b76f8
[ 3816.181459] Call Trace:
[ 3816.182781]  [<ffffffff812e5492>] dump_stack+0x63/0x81
[ 3816.184072]  [<ffffffff810a112b>] __schedule_bug+0x4b/0x60
[ 3816.185326]  [<ffffffff815c3589>] __schedule+0x899/0xad0
[ 3816.186535]  [<ffffffff815c37fc>] schedule+0x3c/0x90
[ 3816.187704]  [<ffffffff8107ec1f>] do_exit+0x96f/0xb60
[ 3816.188831]  [<ffffffff8103196c>] oops_end+0x9c/0xd0
[ 3816.189919]  [<ffffffff81066cb6>] no_context+0x176/0x3a0
[ 3816.190998]  [<ffffffff81067013>] __bad_area_nosemaphore+0x133/0x250
[ 3816.192072]  [<ffffffff812ed8bd>] ? number+0x2ed/0x300
[ 3816.193139]  [<ffffffff81067144>] bad_area_nosemaphore+0x14/0x20
[ 3816.194200]  [<ffffffff81067514>] __do_page_fault+0xd4/0x510
[ 3816.195253]  [<ffffffff81067972>] do_page_fault+0x22/0x30
[ 3816.196300]  [<ffffffff815c9278>] page_fault+0x28/0x30
[ 3816.197345]  [<ffffffff81099ee0>] ? kthread_data+0x10/0x20
[ 3816.198387]  [<ffffffff810945ce>] wq_worker_sleeping+0xe/0x90
[ 3816.199426]  [<ffffffff815c3361>] __schedule+0x671/0xad0
[ 3816.200461]  [<ffffffff815c37fc>] schedule+0x3c/0x90
[ 3816.201488]  [<ffffffff8107ea86>] do_exit+0x7d6/0xb60
[ 3816.202506]  [<ffffffff8103196c>] oops_end+0x9c/0xd0
[ 3816.203519]  [<ffffffff81031e2b>] die+0x4b/0x70
[ 3816.204521]  [<ffffffff8102ef2c>] do_general_protection+0xcc/0x150
[ 3816.205521]  [<ffffffff815c9218>] general_protection+0x28/0x30
[ 3816.206520]  [<ffffffffa025fbf0>] ? xprt_switch_put+0x70/0xc0 [sunrpc]
[ 3816.207519]  [<ffffffffa025fc0f>] ? xprt_switch_put+0x8f/0xc0 [sunrpc]
[ 3816.208507]  [<ffffffffa025fd86>] xprt_iter_destroy+0x16/0x20 [sunrpc]
[ 3816.209489]  [<ffffffffa023bc99>] rpc_free_client+0x99/0xf0 [sunrpc]
[ 3816.210470]  [<ffffffffa023bef0>] rpc_release_client+0x60/0xa0 [sunrpc]
[ 3816.211456]  [<ffffffffa023c142>] rpc_shutdown_client+0x62/0x150 [sunrpc]
[ 3816.212444]  [<ffffffff810b2e22>] ? enqueue_task_fair+0xa2/0x930
[ 3816.213436]  [<ffffffffa032806d>]
nfsd4_process_cb_update.isra.6+0x3d/0x1e0 [nfsd]
[ 3816.214437]  [<ffffffff810b02fb>] ? dequeue_entity+0x24b/0xb20
[ 3816.215437]  [<ffffffff810a3c2d>] ? ttwu_do_activate.constprop.40+0x5d/0x70
[ 3816.216499]  [<ffffffff810b1753>] ? put_prev_entity+0x33/0x8b0
[ 3816.217500]  [<ffffffff810b0c92>] ? dequeue_task_fair+0xc2/0x960
[ 3816.218507]  [<ffffffff810a4ad2>] ? default_wake_function+0x12/0x20
[ 3816.219514]  [<ffffffff8102d76d>] ? __switch_to+0x29d/0x430
[ 3816.220519]  [<ffffffff810a0f48>] ? finish_task_switch+0x78/0x210
[ 3816.221528]  [<ffffffffa03282a6>] nfsd4_run_cb_work+0x96/0x100 [nfsd]
[ 3816.222536]  [<ffffffff81093a05>] process_one_work+0x1e5/0x480
[ 3816.223543]  [<ffffffff81093ce8>] worker_thread+0x48/0x4e0
[ 3816.224543]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.225539]  [<ffffffff81093ca0>] ? process_one_work+0x480/0x480
[ 3816.226527]  [<ffffffff81099998>] kthread+0xd8/0xf0
[ 3816.227510]  [<ffffffff815c7482>] ret_from_fork+0x22/0x40
[ 3816.228495]  [<ffffffff810998c0>] ? kthread_worker_fn+0x170/0x170


-- 
damjan
