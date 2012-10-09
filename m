Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59340 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab2JIHyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 03:54:50 -0400
Date: Tue, 9 Oct 2012 09:54:47 +0200
From: Jan Kara <jack@suse.cz>
To: Neil Salstrom <salstrom@paintedocean.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: PROBLEM: 3.6.0 kernel BUG at fs/dcache.c:967 during shutdown /
 restart
Message-ID: <20121009075447.GA15790@quack.suse.cz>
References: <CA+W8ZyK4NYGUtXce-dP69J8L6WJ81_fOOXWrMebK3BO_K7FozA@mail.gmail.com>
 <5070685A.1060605@paintedocean.com>
 <20121008171424.GA14767@quack.suse.cz>
 <50736B8C.3010902@paintedocean.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50736B8C.3010902@paintedocean.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 08-10-12 17:10:52, Neil Salstrom wrote:
> On 10/08/2012 10:14 AM, Jan Kara wrote:
> >On Sat 06-10-12 10:20:26, Neil Salstrom wrote:
> >>I've not submitted a kernel bug before but I've read the bug
> >>reporting pages.  I'll try to do my best and if you need more
> >>information please let me know.  Please feel free to cc me on the
> >>answer or if you have questions.
> >>
> >>I'm using Linux Mint 13 (64 bit) on AMD hardware with a self
> >>compiled 3.6.0 kernel for my MythTV HTPC.
> >>
> >>Kernel version: Linux version 3.6.0 (gcc version 4.6.3
> >>(Ubuntu/Linaro 4.6.3-1ubuntu5) ) #1 SMP Tue Oct 2 15:34:46 PDT 2012
> >>
> >>CPU: model name      : AMD A6-3500 APU with Radeon(tm) HD Graphics
> >>
> >>If you need any other system variables please let me know and I can
> >>get those as well.
> >>
> >>Upon shutdown or restart (from either the hard button on the case or
> >>a "sudo shutdown -r now" the system crashes and does not actually
> >>shut down.  I can ssh in to the system and a dmesg shows the
> >>following:
> >   There should be a line like:
> >BUG: Dentry ... still in use (%d) [unmount of %s %s]
> >
> >just before the oops. Can you please post that one as well? Also I see that
> >you are using nvidia module which taints the kernel. Can you try
> >reproducing the issue without the module loaded?
> >
> >								Honza
> 
> Here is the full output with no nvidia module.  I also have the full
> dmeg from start to finish if you would like it.
  Thanks for the new report. Since the use count of the problematic dentry
is 1, I guess this is really some bug in rpc_pipefs. Bruce, any idea?

								Honza

> [  237.186167] BUG: Dentry ffff880118772540{i=6e,n=info} still in
> use (1) [unmount of rpc_pipefs rpc_pipefs]
> [  237.186179] ------------[ cut here ]------------
> [  237.186181] kernel BUG at fs/dcache.c:967!
> [  237.186182] invalid opcode: 0000 [#1] SMP
> [  237.186185] Modules linked in: nls_utf8 udf crc_itu_t nfsv4
> binfmt_misc nfsd nfs_acl auth_rpcgss nfs fscache lockd sunrpc
> snd_hda_codec_hdmi snd_hda_codec_realtek xfs snd_hda_intel
> snd_hda_codec snd_seq_midi snd_hwdep snd_rawmidi snd_pcm psmouse
> snd_seq_midi_event rc_imon_mce serio_raw snd_seq imon rc_core
> snd_timer snd_seq_device snd soundcore snd_page_alloc f71882fg r8169
> ahci libahci
> [  237.186203] CPU 2
> [  237.186206] Pid: 3063, comm: umount Not tainted 3.6.0 #1 System
> manufacturer System Product Name/F1A55-M LX PLUS
> [  237.186208] RIP: 0010:[<ffffffff8116c606>] [<ffffffff8116c606>]
> shrink_dcache_for_umount_subtree+0x1e6/0x1f0
> [  237.186214] RSP: 0018:ffff8801181afd98  EFLAGS: 00010296
> [  237.186215] RAX: 000000000000005d RBX: ffff880118772540 RCX:
> 00000000000014bd
> [  237.186217] RDX: 0000000000003256 RSI: 0000000000000046 RDI:
> ffffffff81bbf9bc
> [  237.186218] RBP: ffff8801181afdb8 R08: 000000000000000a R09:
> 0000000000000000
> [  237.186219] R10: 0000000000000383 R11: 0000000000000382 R12:
> ffff88011873b9c0
> [  237.186220] R13: ffff8801177a2b80 R14: ffff8801177a2bb0 R15:
> ffff88011287d800
> [  237.186222] FS:  00007f67049b1800(0000) GS:ffff88011ed00000(0000)
> knlGS:0000000000000000
> [  237.186223] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  237.186225] CR2: 00007f3e1de80000 CR3: 0000000118a18000 CR4:
> 00000000000007e0
> [  237.186226] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  237.186227] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  237.186229] Process umount (pid: 3063, threadinfo
> ffff8801181ae000, task ffff880110fbc440)
> [  237.186230] Stack:
> [  237.186231]  ffff88011287db50 ffff88011873b780 ffff88011287d800
> ffffffffa021d3c0
> [  237.186233]  ffff8801181afdd8 ffffffff8116de93 0000000000000001
> ffff88011287d800
> [  237.186235]  ffff8801181afe08 ffffffff811583bc ffff88011873b820
> 0000000000000015
> [  237.186238] Call Trace:
> [  237.186241]  [<ffffffff8116de93>] shrink_dcache_for_umount+0x33/0x60
> [  237.186244]  [<ffffffff811583bc>] generic_shutdown_super+0x2c/0xf0
> [  237.186247]  [<ffffffff81158516>] kill_anon_super+0x16/0x30
> [  237.186249]  [<ffffffff81158557>] kill_litter_super+0x27/0x30
> [  237.186265]  [<ffffffffa02174a9>] rpc_kill_sb+0x99/0xc0 [sunrpc]
> [  237.186268]  [<ffffffff8115877c>] deactivate_locked_super+0x3c/0xa0
> [  237.186270]  [<ffffffff8115938e>] deactivate_super+0x4e/0x70
> [  237.186273]  [<ffffffff81174416>] mntput_no_expire+0x106/0x160
> [  237.186276]  [<ffffffff8117543e>] sys_umount+0x6e/0x3b0
> [  237.186279]  [<ffffffff81583d96>] system_call_fastpath+0x1a/0x1f
> [  237.186280] Code: 00 00 48 8b 40 28 4c 8b 08 48 8b 43 30 48 85 c0
> 74 04 48 8b 50 40 48 89 34 24 48 c7 c7 48 69 7c 81 48 89 de 31 c0 e8
> 09 62 40 00 <0f> 0b 0f 0b 66 0f 1f 44 00 00 55 48 89 e5 41 54 53 66
> 66 66 66
> [  237.186301] RIP  [<ffffffff8116c606>]
> shrink_dcache_for_umount_subtree+0x1e6/0x1f0
> [  237.186303]  RSP <ffff8801181afd98>
> [  237.186320] ---[ end trace 74629a120592ec3c ]---
> [  238.707925] mtrr: no MTRR for f9000000,e00000 found
> [  245.162939] imon:send_packet: task interrupted
> [  245.218338] nfsd: last server has exited, flushing export cache
