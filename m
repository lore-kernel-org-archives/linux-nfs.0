From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: 2.6.31.4: panic in rpcauth_checkverf...
Date: Mon, 30 Nov 2009 17:41:54 +0000
Message-ID: <6278d2220911300941x2b3e1a88o847f8fbdd44a86e@mail.gmail.com>
References: <6278d2220911291606y31c5b38bsd4c1c61ae3122fc3@mail.gmail.com>
	 <1259588493.3419.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:49587 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZK3Rlt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2009 12:41:49 -0500
Received: by ewy19 with SMTP id 19so3988388ewy.21
        for <linux-nfs@vger.kernel.org>; Mon, 30 Nov 2009 09:41:54 -0800 (PST)
In-Reply-To: <1259588493.3419.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2009 at 1:41 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2009-11-30 at 00:06 +0000, Daniel J Blueman wrote:
>> Hi Trond,
>>
>> It looks less likely this is fixed in the NFS-related changes in
>> 2.6.31.6, so I'm reporting this 2.6.31.4 rpcauth_checkverf oops [1].
>> Info from /proc/mounts included [2]. Client is 2.6.32-rc8 and seems
>> quite seldom to reproduce.
>>
>> What info would help here, such as line numbers and disassembly?
>>
>> Thanks,
>> =A0 Daniel
>>
>> --- [1]
>>
>> BUG: unable to handle kernel paging request at 0000000400001038
>>
>> IP: [<ffffffffa03c3c22>] rpcauth_checkverf+0x32/0x70 [sunrpc]
>>
>> PGD 483fa067 PUD 0
>>
>> Oops: 0000 [#1] SMP
>>
>> last sysfs file:
>> /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block=
/sda/uevent
>>
>> CPU 5
>>
>> Modules linked in: pl2303 usbserial nls_iso8859_1 nls_cp437 vfat fat
>> ppdev kvm_intel kvm binfmt_misc bridge stp bnep btusb joydev
>> snd_hda_codec_atihdmi microcode snd_hda_codec_idt dm_crypt arc4 ecb
>> nfsd exportfs nfs lockd nfs_acl snd_hda_intel snd_seq_dummy
>> auth_rpcgss snd_seq_oss snd_hda_codec snd_seq_midi snd_hwdep
>> snd_rawmidi snd_pcm_oss iwlagn snd_seq_midi_event snd_mixer_oss
>> mmc_block dell_wmi sunrpc iwlcore mac80211 snd_seq snd_pcm
>> iptable_filter snd_seq_device snd_timer ip_tables uvcvideo x_tables =
lp
>> dell_laptop psmouse videodev v4l1_compat v4l2_compat_ioctl32 usbhid
>> dcdbas sdhci_pci snd sdhci cfg80211 soundcore parport serio_raw
>> snd_page_alloc fglrx(P) led_class r8169 mii video output
>>
>> Pid: 826, comm: rpciod/5 Tainted: P =A0 =A0 =A0 =A0 =A0 2.6.31-15-ge=
neric
>> #50-Ubuntu Studio 1557
>>
>> RIP: 0010:[<ffffffffa03c3c22>] =A0[<ffffffffa03c3c22>]
>> rpcauth_checkverf+0x32/0x70 [sunrpc]
>>
>> RSP: 0000:ffff88012e02bd50 =A0EFLAGS: 00010246
>>
>> RAX: 0000000400001000 RBX: ffff88012dc86ec8 RCX: 000000000000080f
>>
>> RDX: 0000000000000000 RSI: ffff880129c141c8 RDI: ffff88012dc86ec8
>>
>> RBP: ffff88012e02bd70 R08: ffff88012e02a000 R09: 0000026edec938f8
>>
>> R10: 0000000000000000 R11: 00000000ffffffff R12: ffff88012692e540
>>
>> R13: ffff880129c141c8 R14: ffff88012a508000 R15: ffffc90011124308
>>
>> FS: =A00000000000000000(0000) GS:ffff8800280b9000(0000) knlGS:000000=
0000000000
>>
>> CS: =A00010 DS: 0018 ES: 0018 CR0: 000000008005003b
>>
>> CR2: 0000000400001038 CR3: 000000009eaae000 CR4: 00000000000026e0
>>
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>
>> Process rpciod/5 (pid: 826, threadinfo ffff88012e02a000, task ffff88=
012e030000)
>>
>> Stack:
>>
>> =A0ffff8801319b4a00 ffff88012dc86ec8 ffff88013092e000 ffff88013092e0=
00
>>
>> <0> ffff88012e02bdb0 ffffffffa03bb415 0000000000000010 0000000000000=
202
>>
>> <0> ffff88012e02bda0 ffff88012dc86ec8 ffff88013092e000 ffffffffa04d4=
ff0
>>
>> Call Trace:
>>
>> =A0[<ffffffffa03bb415>] rpc_verify_header+0x1b5/0x5a0 [sunrpc]
>>
>> =A0[<ffffffffa04d4ff0>] ? nfs4_xdr_dec_read+0x0/0x80 [nfs]
>>
>> =A0[<ffffffffa03bb930>] call_decode+0x130/0x220 [sunrpc]
>>
>> =A0[<ffffffffa03c2e4a>] __rpc_execute+0xba/0x220 [sunrpc]
>>
>> =A0[<ffffffffa03c2fe0>] ? rpc_async_schedule+0x0/0x20 [sunrpc]
>>
>> =A0[<ffffffffa03c2ff0>] rpc_async_schedule+0x10/0x20 [sunrpc]
>>
>> =A0[<ffffffff810737a5>] run_workqueue+0x95/0x170
>>
>> =A0[<ffffffff81073924>] worker_thread+0xa4/0x120
>>
>> =A0[<ffffffff81078b30>] ? autoremove_wake_function+0x0/0x40
>>
>> =A0[<ffffffff81073880>] ? worker_thread+0x0/0x120
>>
>> =A0[<ffffffff81078746>] kthread+0xa6/0xb0
>>
>> =A0[<ffffffff810130ea>] child_rip+0xa/0x20
>>
>> =A0[<ffffffff810786a0>] ? kthread+0x0/0xb0
>>
>> =A0[<ffffffff810130e0>] ? child_rip+0x0/0x20
>>
>> Code: 20 f6 05 51 d6 02 00 10 48 89 5d e8 4c 89 6d f8 48 89 fb 4c 89
>> 65 f0 49 89 f5 4c 8b 67 50 75 1c 49 8b 44 24 38 4c 89 ee 48 89 df <f=
f>
>> 50 38 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 49 8b 44 24
>>
>> RIP =A0[<ffffffffa03c3c22>] rpcauth_checkverf+0x32/0x70 [sunrpc]
>>
>> =A0RSP <ffff88012e02bd50>
>>
>> CR2: 0000000400001038
>>
>> ---[ end trace c9ba33d8dceb9bfc ]---
>>
>>
>> --- [2]
>>
>> x1:/ /net nfs4 rw,relatime,vers=3D4,rsize=3D262144,wsize=3D262144,na=
mlen=3D255,acregmin=3D30,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3D=
sys,clientaddr=3D192.168.10.2,addr=3D192.168.10.250
>> 0 0

> ...and it is reproducible without the fglrx module? Sorry, but I do h=
ave
> to check that...

Ok, an entirely not-unfair request.

> The other question is, whether this always happens in the read and wr=
ite
> code? If so, does it go away when you reduce the rsize/wsize to 128k?

This is the first occurrence I've got of this after considerable
workload with these kernels over some weeks, so I expect it to take
some time to reproduce, and I'll follow up when it does with my
different configuration.

Thanks again,
  Daniel
--=20
Daniel J Blueman
