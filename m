Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33693 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758732Ab3ANUhM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2013 15:37:12 -0500
Date: Mon, 14 Jan 2013 15:37:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@teksavvy.com>
Cc: linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130114203711.GA29982@fieldses.org>
References: <50F42F85.50907@teksavvy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50F42F85.50907@teksavvy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the report.

On Mon, Jan 14, 2013 at 11:17:09AM -0500, Mark Lord wrote:
> Since upgrading to 3.7, and now 3.7.2, my AMD-450E based server

It's acting as an NFS client, right?

What did you upgrade from?

> is getting these BUG complaints.  The .config file is gzip'd/attached.

Is this easy to reproduce?

--b.

> 
> ------------[ cut here ]------------
> kernel BUG at net/sunrpc/svc_xprt.c:921!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: nfsv4 xt_state xt_tcpudp xt_recent xt_LOG xt_limit iptable_mangle iptable_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables
> sc520_wdt btusb snd_usb_audio snd_usbmidi_lib hid_generic ftdi_sio usbserial usbhid hid
> snd_hda_codec_realtek psmouse snd_hda_codec_hdmi r8169 xhci_hcd mii snd_hda_intel snd_hda_codec
> snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq bnep
> snd_timer rfcomm snd_seq_device bluetooth snd nfsd auth_rpcgss binfmt_misc radeon nfs lockd sunrpc
> soundcore ttm snd_page_alloc drm_kms_helper drm i2c_algo_bit it87 hwmon_vid k10temp hwmon microcode
> CPU 0
> Pid: 29613, comm: nfsv4.0-svc Not tainted 3.7.2 #1 System manufacturer System Product Name/E45M1-I
> DELUXE
> RIP: 0010:[<ffffffffa01696cd>]  [<ffffffffa01696cd>] svc_delete_xprt+0x23/0xeb [sunrpc]
> RSP: 0018:ffff880234f05e38  EFLAGS: 00010286
> RAX: 00000000ffffffff RBX: ffff8801b931b000 RCX: dead000000200200
> RDX: dead000000100100 RSI: ffff8801b931b038 RDI: 0000000000000006
> RBP: ffff880049125e40 R08: 0000000000000606 R09: ffff88023ec10fc0
> R10: ffff88023ec10fc0 R11: ffff88023ec10fc0 R12: ffff880049125e40
> R13: ffff8801b931b038 R14: 0000000000000000 R15: 0000000000000000
> FS:  00007f5bef2fd700(0000) GS:ffff88023ec00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f2f1800bfa0 CR3: 000000015ba2e000 CR4: 00000000000007f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nfsv4.0-svc (pid: 29613, threadinfo ffff880234f04000, task ffff88021b51a280)
> Stack:
>  0000000000001cc7 ffff8801a5f2e000 ffff8801b931b000 ffff880049125e40
>  ffff880049125e40 ffffffffa016a56a 0000000000010fc0 ffff880234f05fd8
>  ffff880234f05fd8 ffff8801a5f2e000 ffff8801a5f2e000 ffff880234f05f08
> Call Trace:
>  [<ffffffffa016a56a>] ? svc_recv+0xcc/0x338 [sunrpc]
>  [<ffffffffa0318bfc>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
>  [<ffffffffa0318c19>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
>  [<ffffffff810407e6>] ? kthread+0x81/0x89
>  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
>  [<ffffffff812ea62c>] ? ret_from_fork+0x7c/0xb0
>  [<ffffffff81040765>] ? kthread_freezable_should_stop+0x36/0x36
> Code: c2 84 d2 74 02 eb a0 c3 41 55 4c 8d 6f 38 41 54 4c 89 ee 55 53 48 89 fb 50 48 8b 6f 40 bf 06
> 00 00 00 e8 77 fa ff ff 85 c0 74 02 <0f> 0b 48 8b 43 08 4c 8d 65 10 48 89 df ff 50 38 4c 89 e7 e8 6d
> RIP  [<ffffffffa01696cd>] svc_delete_xprt+0x23/0xeb [sunrpc]
>  RSP <ffff880234f05e38>
> ---[ end trace 916f6471c0b47e1d ]---
> 
> 
> Here's the code with the BUG() at net/sunrpc/svc_xprt.c line 921:
> 
> /*
>  * Remove a dead transport
>  */
> static void svc_delete_xprt(struct svc_xprt *xprt)
> {
>         struct svc_serv *serv = xprt->xpt_server;
>         struct svc_deferred_req *dr;
> 
>         /* Only do this once */
>         if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
>                 BUG();
> ...
> 
> 
> 
> 


