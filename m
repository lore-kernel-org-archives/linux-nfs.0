From: "Grigoriy A. Sitkarev" <sitkarev-OEvN4R7+z+YvJsYlp49lxw@public.gmane.org>
Subject: kernel oops in nfs4_proc_lock
Date: Wed, 22 Oct 2008 11:23:39 +0400
Message-ID: <48FED4FB.3030203@komitex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.komitex.ru ([217.24.115.21]:2467 "EHLO helga.komitex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500AbYJVHad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 03:30:33 -0400
Received: from unknown (HELO [192.168.0.123]) (sitkarev@[192.168.0.123])
          (envelope-sender <sitkarev-OEvN4R7+z+YvJsYlp49lxw@public.gmane.org>)
          by helga.komitex.ru (qmail-ldap-1.03) with SMTP
          for <linux-nfs@vger.kernel.org>; 22 Oct 2008 07:10:34 -0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, list!

We are running debian kernel 2.6.26-bpo.1-amd64 (from backports) and use
NFS4 mounted partition on this machine. Approximately once a day we get
the oops but kernel continues to work. Here is the oops message we get:

[601324.115347] BUG: unable to handle kernel NULL pointer dereference at
0000000000000030
[601324.115347] IP: [<ffffffffa02f4de2>] :nfs:nfs4_proc_lock+0x220/0x3a8
[601324.115347] PGD 8151fe067 PUD 88806d067 PMD 0
[601324.115347] Oops: 0000 [2] SMP
[601324.115347] CPU 6
[601324.115347] Modules linked in: ppdev parport_pc lp parport sbs
container battery sbshc ac wmi video output nfsd auth_rpcgss exportfs
nfs lockd nfs_acl sunrpc ipv6 nls_utf8 cifs nls_base fuse loop snd_pcm
iTCO_wdt snd_timer snd soundcore psmouse snd_page_alloc shpchp i2c_i801
button pci_hotplug rng_core serio_raw i2c_core i5000_edac evdev
edac_core pcspkr ext3 jbd mbcache sg sr_mod ses cdrom enclosure sd_mod
ata_generic ata_piix libata dock usbhid hid ff_memless ide_pci_generic
ide_core bnx2 firmware_class ehci_hcd uhci_hcd aacraid scsi_mod thermal
processor fan thermal_sys
[601324.115347] Pid: 12286, comm: soffice.bin Tainted: G      D
2.6.26-bpo.1-amd64 #1
[601324.115347] RIP: 0010:[<ffffffffa02f4de2>]  [<ffffffffa02f4de2>]
:nfs:nfs4_proc_lock+0x220/0x3a8
[601324.115347] RSP: 0018:ffff8108690ebdd8  EFLAGS: 00010246
[601324.115347] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
0000000000000000
[601324.115347] RDX: ffff810911092590 RSI: 0000000000000006 RDI:
ffff8108690ebe38
[601324.115347] RBP: ffff810819d7dd40 R08: 0000000000000000 R09:
ffff8108f418d2f8
[601324.115347] R10: 0000000000000001 R11: 0000000000000010 R12:
ffff810911092590
[601324.115347] R13: 0000000000000000 R14: ffff8108f418d1e8 R15:
0000000000000006
[601324.115347] FS:  00007f873effd6f0(0000) GS:ffff810939dced40(0000)
knlGS:0000000000000000
[601324.115347] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[601324.115347] CR2: 0000000000000030 CR3: 000000064ad7a000 CR4:
00000000000006e0
[601324.115347] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[601324.115347] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[601324.115347] Process soffice.bin (pid: 12286, threadinfo
ffff8108690ea000, task ffff81064adcd5f0)
[601324.115347] Stack:  00000000000000fa ffff8108f418d1e8
0000000000000010 ffffffffa02ee859
[601324.115347]  0000000000000010 ffff8108f418d2f8 0000000000000000
7fffffffffffffff
[601324.115347]  0000000000000006 ffffffffa02ee8d8 0000000000000000
0000000000000000
[601324.115347] Call Trace:
[601324.115347]  [<ffffffffa02ee859>] ? :nfs:__nfs_write_mapping+0x2c/0x4f
[601324.115347]  [<ffffffffa02ee8d8>] ? :nfs:nfs_write_mapping+0x5c/0x65
[601324.115347]  [<ffffffffa02e33a2>] ? :nfs:do_setlk+0x5b/0x92
[601324.115347]  [<ffffffff802aa287>] ? fcntl_setlk+0x12d/0x299
[601324.115347]  [<ffffffff802a6981>] ? sys_fcntl+0x280/0x2f7
[601324.115347]  [<ffffffff8020be9a>] ? system_call_after_swapgs+0x8a/0x8f
[601324.115347]
[601324.115347]
[601324.115347] Code: ff 48 89 df 89 c5 e8 49 84 fa ff 45 88 74 24 60 e9
8d 01 00 00 bd 00 fe ff ff e9 83 01 00 00 fc 48 8d 7c 24 50 31 c0 ab ab
ab ab <49> 8b 45 30 4c 89 e6 4c 89 ef 45 8a 74 24 60 48 8b 68 20 e8 63
[601324.115347] RIP  [<ffffffffa02f4de2>] :nfs:nfs4_proc_lock+0x220/0x3a8
[601324.115347]  RSP <ffff8108690ebdd8>
[601324.115347] CR2: 0000000000000030
[601324.116321] ---[ end trace 5b49e5ecee378e7c ]---

I tried to locate the place where this NULL pointer dereference is
happening.

This happens in _nfs4_proc_setlk at the begining of the function:

static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct
file_lock *request)
{
    struct nfs_client *clp = state->owner->so_client;

Attempt to dereference state->owner causes the oops. Disassembly shows
that 'state' is already a NULL.

     fbf:       ab                      stos   %eax,%es:(%rdi)
     fc0:       ab                      stos   %eax,%es:(%rdi)
     fc1:       ab                      stos   %eax,%es:(%rdi)
     fc2:       49 8b 45 30             mov    0x30(%r13),%rax  <== oops
here
     fc6:       4c 89 e6                mov    %r12,%rsi
     fc9:       4c 89 ef                mov    %r13,%rdi

It means that variable 'state' passed from nfs4_proc_lock into
nfs4_proc_setlk is already NULL.

It seems that checking it for NULL in nfs4_proc_lock is not enough.

