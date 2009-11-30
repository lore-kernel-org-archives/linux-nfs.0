From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: 2.6.31.4: panic in rpcauth_checkverf...
Date: Mon, 30 Nov 2009 00:06:42 +0000
Message-ID: <6278d2220911291606y31c5b38bsd4c1c61ae3122fc3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:59884 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbZK3AGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Nov 2009 19:06:37 -0500
Received: by ey-out-2122.google.com with SMTP id 4so811987eyf.19
        for <linux-nfs@vger.kernel.org>; Sun, 29 Nov 2009 16:06:42 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

It looks less likely this is fixed in the NFS-related changes in
2.6.31.6, so I'm reporting this 2.6.31.4 rpcauth_checkverf oops [1].
Info from /proc/mounts included [2]. Client is 2.6.32-rc8 and seems
quite seldom to reproduce.

What info would help here, such as line numbers and disassembly?

Thanks,
  Daniel

--- [1]

BUG: unable to handle kernel paging request at 0000000400001038

IP: [<ffffffffa03c3c22>] rpcauth_checkverf+0x32/0x70 [sunrpc]

PGD 483fa067 PUD 0

Oops: 0000 [#1] SMP

last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/uevent

CPU 5

Modules linked in: pl2303 usbserial nls_iso8859_1 nls_cp437 vfat fat
ppdev kvm_intel kvm binfmt_misc bridge stp bnep btusb joydev
snd_hda_codec_atihdmi microcode snd_hda_codec_idt dm_crypt arc4 ecb
nfsd exportfs nfs lockd nfs_acl snd_hda_intel snd_seq_dummy
auth_rpcgss snd_seq_oss snd_hda_codec snd_seq_midi snd_hwdep
snd_rawmidi snd_pcm_oss iwlagn snd_seq_midi_event snd_mixer_oss
mmc_block dell_wmi sunrpc iwlcore mac80211 snd_seq snd_pcm
iptable_filter snd_seq_device snd_timer ip_tables uvcvideo x_tables lp
dell_laptop psmouse videodev v4l1_compat v4l2_compat_ioctl32 usbhid
dcdbas sdhci_pci snd sdhci cfg80211 soundcore parport serio_raw
snd_page_alloc fglrx(P) led_class r8169 mii video output

Pid: 826, comm: rpciod/5 Tainted: P           2.6.31-15-generic
#50-Ubuntu Studio 1557

RIP: 0010:[<ffffffffa03c3c22>]  [<ffffffffa03c3c22>]
rpcauth_checkverf+0x32/0x70 [sunrpc]

RSP: 0000:ffff88012e02bd50  EFLAGS: 00010246

RAX: 0000000400001000 RBX: ffff88012dc86ec8 RCX: 000000000000080f

RDX: 0000000000000000 RSI: ffff880129c141c8 RDI: ffff88012dc86ec8

RBP: ffff88012e02bd70 R08: ffff88012e02a000 R09: 0000026edec938f8

R10: 0000000000000000 R11: 00000000ffffffff R12: ffff88012692e540

R13: ffff880129c141c8 R14: ffff88012a508000 R15: ffffc90011124308

FS:  0000000000000000(0000) GS:ffff8800280b9000(0000) knlGS:0000000000000000

CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b

CR2: 0000000400001038 CR3: 000000009eaae000 CR4: 00000000000026e0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Process rpciod/5 (pid: 826, threadinfo ffff88012e02a000, task ffff88012e030000)

Stack:

 ffff8801319b4a00 ffff88012dc86ec8 ffff88013092e000 ffff88013092e000

<0> ffff88012e02bdb0 ffffffffa03bb415 0000000000000010 0000000000000202

<0> ffff88012e02bda0 ffff88012dc86ec8 ffff88013092e000 ffffffffa04d4ff0

Call Trace:

 [<ffffffffa03bb415>] rpc_verify_header+0x1b5/0x5a0 [sunrpc]

 [<ffffffffa04d4ff0>] ? nfs4_xdr_dec_read+0x0/0x80 [nfs]

 [<ffffffffa03bb930>] call_decode+0x130/0x220 [sunrpc]

 [<ffffffffa03c2e4a>] __rpc_execute+0xba/0x220 [sunrpc]

 [<ffffffffa03c2fe0>] ? rpc_async_schedule+0x0/0x20 [sunrpc]

 [<ffffffffa03c2ff0>] rpc_async_schedule+0x10/0x20 [sunrpc]

 [<ffffffff810737a5>] run_workqueue+0x95/0x170

 [<ffffffff81073924>] worker_thread+0xa4/0x120

 [<ffffffff81078b30>] ? autoremove_wake_function+0x0/0x40

 [<ffffffff81073880>] ? worker_thread+0x0/0x120

 [<ffffffff81078746>] kthread+0xa6/0xb0

 [<ffffffff810130ea>] child_rip+0xa/0x20

 [<ffffffff810786a0>] ? kthread+0x0/0xb0

 [<ffffffff810130e0>] ? child_rip+0x0/0x20

Code: 20 f6 05 51 d6 02 00 10 48 89 5d e8 4c 89 6d f8 48 89 fb 4c 89
65 f0 49 89 f5 4c 8b 67 50 75 1c 49 8b 44 24 38 4c 89 ee 48 89 df <ff>
50 38 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 49 8b 44 24

RIP  [<ffffffffa03c3c22>] rpcauth_checkverf+0x32/0x70 [sunrpc]

 RSP <ffff88012e02bd50>

CR2: 0000000400001038

---[ end trace c9ba33d8dceb9bfc ]---


--- [2]

x1:/ /net nfs4 rw,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,acregmin=30,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.10.2,addr=192.168.10.250
0 0
-- 
Daniel J Blueman
