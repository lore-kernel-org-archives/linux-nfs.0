From: Vince Busam <vbusam@google.com>
Subject: oops in rpc_pipe_release
Date: Mon, 07 Nov 2005 16:04:43 -0800
Message-ID: <436FEB9B.3010007@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZGyt-0006Sb-Kq
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 16:04:55 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZGyt-0003rk-Dm
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 16:04:55 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jA804lcj031511
	for <nfs@lists.sourceforge.net>; Mon, 7 Nov 2005 16:04:47 -0800
Received: from [172.29.52.29] (block.smo.corp.google.com [172.29.52.29])
	by mail2.smo.corp.google.com with ESMTP id jA804hak007651
	for <nfs@lists.sourceforge.net>; Mon, 7 Nov 2005 16:04:43 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm using NFS3 with kerberos authentication, and 25 hour tickets that refresh when
unlocking the screensaver.  Over the weekend, it'll hang with one of the following stack
traces.  Any ideas what could cause this?

Thanks,
Vince

Unable to handle kernel NULL pointer dereference at virtual address 00000004
  printing eip:
f890c6ca
*pde = 00000000
Oops: 0002 [#1]
PREEMPT SMP
Modules linked in: des binfmt_misc cpufreq_userspace cpufreq_ondemand cpufreq_powersave
autofs4 video sony_acpi pcc_acpi dev_acpi i2c_acpi_ec i2c_core button battery container ac
capability commoncap nfs lockd af_packet tg3 piix snd_intel8x0 snd_usb_audio
snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_usb_lib snd_rawmidi snd_seq_device
snd_hwdep snd_timer snd soundcore snd_page_alloc pwc videodev v4l2_common uhci_hcd
pci_hotplug floppy pcspkr rtc md dm_mod nvidia agpgart psmouse tsdev evdev mousedev usbhid
parport_pc lp parport ide_generic ide_disk ide_cd cdrom rpcsec_gss_krb5 auth_rpcgss sunrpc
ehci_hcd ext3 jbd mbcache ahci sd_mod ata_piix libata usb_storage usbcore scsi_mod
ide_core unix thermal processor fan
CPU:    1
EIP:    0060:[<f890c6ca>]    Tainted: P      VLI
EFLAGS: 00010203   (2.6.12-gg3)
EIP is at __gss_unhash_msg+0x1a/0x60 [auth_rpcgss]
eax: 00000000   ebx: ef789200   ecx: ef789220   edx: 00000000
esi: efe1dbe4   edi: ffffffe0   ebp: f0368500   esp: efbb5f00
ds: 007b   es: 007b   ss: 0068
Process rpc.gssd (pid: 7760, threadinfo=efbb4000 task=efb56a60)
Stack: c02c3726 ef789200 ef789200 f890c734 ef789200 ef789208 ef789200 f890ccca
        ef789200 f0368684 f0368500 f0368684 f8acbfae ef789208 f0368500 ef3a6a80
        f0368500 f8acc33b f0368500 ffffffe0 00000008 ef3a6a80 f0369380 c01667fa
Call Trace:
  [<c02c3726>] _spin_lock+0x16/0x90
  [<f890c734>] gss_unhash_msg+0x24/0x40 [auth_rpcgss]
  [<f890ccca>] gss_pipe_destroy_msg+0x3a/0xa0 [auth_rpcgss]
  [<f8acbfae>] __rpc_purge_upcall+0x3e/0xb0 [sunrpc]
  [<f8acc33b>] rpc_pipe_release+0xcb/0xf0 [sunrpc]
  [<c01667fa>] __fput+0x18a/0x1d0
  [<c0164b72>] filp_close+0x52/0xa0
  [<c0164c2a>] sys_close+0x6a/0xa0
  [<c010343b>] sysenter_past_esp+0x54/0x75
Code: e8 ac 2d 81 c7 eb bb 8d 76 00 8d bc 27 00 00 00 00 53 83 ec 08 8b 5c 24 10 8b 53 20
8d 4b 20 39 ca 75 05 83 c4 08 5b c3 8b 41 04 <89> 42 04 89 10 89 49 04 8b 43 1c 89 4b 20
89 44 24 04 8d 43 2c


------------[ cut here ]------------
kernel BUG at <bad filename>:53227!
invalid operand: 0000 [#1]
PREEMPT SMP
Modules linked in: des binfmt_misc cpufreq_userspace cpufreq_ondemand cpufreq_powersave
autofs4 video button battery container ac nfs lockd af_packet tg3 generic snd_intel8x0
snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc
hw_random uhci_hcd pci_hotplug floppy pcspkr rtc evdev md_mod dm_mod nvidia agpgart
psmouse mousedev parport_pc lp parport ide_generic ide_disk ide_cd ide_core
rpcsec_gss_krb5 auth_rpcgss sunrpc ehci_hcd usbcore ext3 jbd mbcache ahci sr_mod cdrom
sd_mod sg ata_piix libata scsi_mod unix thermal processor fan
CPU:    0
EIP:    0060:[<f88d0637>]    Tainted: P      VLI
EFLAGS: 00010203   (2.6.13.4-gg4)
EIP is at gss_release_msg+0x47/0x50 [auth_rpcgss]
eax: f72a6420   ebx: f72a6400   ecx: f72a6420   edx: 00000000
esi: f6c5ed04   edi: ffffffe0   ebp: f6c5eb80   esp: f71cdf28
ds: 007b   es: 007b   ss: 0068
Process rpc.gssd (pid: 5183, threadinfo=f71cc000 task=f7af0020)
Stack: f6c5eb80 f6c5eb80 f8a93dae f72a6400 f6c5eb80 d5ce9180 f6c5eb80 f8a9413b
       f6c5eb80 ffffffe0 00000008 d5ce9180 f74b7700 c0166caa f6c5eb80 d5ce9180
       00000000 00000000 dff47290 d5ce9180 c2b3f180 00000000 d5ce9180 c0164fb6
Call Trace:
[<f8a93dae>] __rpc_purge_upcall+0x3e/0xb0 [sunrpc]
[<f8a9413b>] rpc_pipe_release+0xcb/0xf0 [sunrpc]
[<c0166caa>] __fput+0x18a/0x1d0
[<c0164fb6>] filp_close+0x46/0x90
[<c016506a>] sys_close+0x6a/0xa0
[<c010316b>] sysenter_past_esp+0x54/0x75
Code: 68 85 d2 75 12 89 5c 24 0c 58 5b e9 84 df 87 c7 8d 74 26 00 58 5b c3 f0 ff 0a 0f 94
c0 84 c0 74 e4 89 14 24 e8 fb 0a 00 00 eb da <0f> 0b eb cf 90 8d 74 26 00 56 53 83 ec 08
8b 4c 24 14 8b 74 24
-------------------------------------------------------------------




-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
