Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36710 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbG0EIN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 00:08:13 -0400
Received: by ykay190 with SMTP id y190so59987041yka.3
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 21:08:12 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 27 Jul 2015 12:08:12 +0800
Message-ID: <CAB6yy34dK0zPTB=FyEGb=Ljc7jAc_xi7ci17LU3JA=nEeXdkUA@mail.gmail.com>
Subject: Re: client oops in xdr_reserve_space in 4.0.0-rc4
From: Kinglong Mee <kinglongmee@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeffrey Layton <jeff.layton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 24, 2015 at 4:19 AM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> On Mon, 23 Mar 2015 16:16:01 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> Hi Jeff,
>>
>> On Sun, 2015-03-22 at 11:27 -0400, Jeff Layton wrote:
>> > While trying to track down the use-after-free in nfsd in v4.0-rc
>> > kernels, I hit this oops on the client. At the time, I had just
>> > rebooted the server while xfstests generic/011 was running against it.
>> > It oopsed just after the server came back up.
>> >
>> > Kernel is a stock fedora kernel. Looks like xdr_reserve_space failed,
>> > which triggered a BUG:
>> >
>> > [ 9410.321698] run fstests generic/011 at 2015-03-22 11:13:50
>> > [ 9737.567073] nfs: server rawhide not responding, still trying
>> > [ 9839.007187] ------------[ cut here ]------------
>> > [ 9839.007923] kernel BUG at fs/nfs/nfs4xdr.c:910!
>> > [ 9839.008069] invalid opcode: 0000 [#1] SMP
>> > [ 9839.008069] Modules linked in: blocklayoutdriver rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm joydev iosf_mbi crct10dif_pclmul snd_timer crc32_pclmul crc32c_intel ghash_clmulni_intel snd soundcore ppdev pvpanic parport_pc i2c_piix4 serio_raw virtio_balloon parport acpi_cpufreq nfsd nfs_acl lockd grace auth_rpcgss sunrpc qxl drm_kms_helper virtio_net virtio_console virtio_blk ttm drm virtio_pci virtio_ring virtio ata_generic pata_acpi
>> > [ 9839.008069] CPU: 0 PID: 308 Comm: kworker/0:1H Not tainted 4.0.0-0.rc4.git1.3.fc23.x86_64 #1
>> > [ 9839.008069] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> > [ 9839.008069] Workqueue: rpciod rpc_async_schedule [sunrpc]
>> > [ 9839.008069] task: ffff8800d8b4d8e0 ti: ffff880036678000 task.ti: ffff880036678000
>> > [ 9839.008069] RIP: 0010:[<ffffffffa0339cc9>]  [<ffffffffa0339cc9>] reserve_space.part.73+0x9/0x10 [nfsv4]
>> > [ 9839.008069] RSP: 0018:ffff88003667ba58  EFLAGS: 00010246
>> > [ 9839.008069] RAX: 0000000000000000 RBX: 000000001fc15e18 RCX: ffff8800c0193800
>> > [ 9839.008069] RDX: ffff8800e4ae3f24 RSI: 000000001fc15e2c RDI: ffff88003667bcd0
>> > [ 9839.008069] RBP: ffff88003667ba58 R08: ffff8800d9173008 R09: 0000000000000003
>> > [ 9839.008069] R10: ffff88003667bcd0 R11: 000000000000000c R12: 0000000000010000
>> > [ 9839.008069] R13: ffff8800d9173350 R14: 0000000000000000 R15: ffff8800c0067b98
>> > [ 9839.008069] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000) knlGS:0000000000000000
>> > [ 9839.008069] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > [ 9839.008069] CR2: 00007f988c9c8bb0 CR3: 00000000d99b6000 CR4: 00000000000407f0
>> > [ 9839.008069] Stack:
>> > [ 9839.008069]  ffff88003667bbc8 ffffffffa03412c5 00000000c6c55680 ffff880000000003
>> > [ 9839.008069]  0000000000000088 00000010c6c55680 0001000000000002 ffffffff816e87e9
>> > [ 9839.008069]  0000000000000000 00000000477290e2 ffff88003667bab8 ffffffff81327ba3
>> > [ 9839.008069] Call Trace:
>> > [ 9839.008069]  [<ffffffffa03412c5>] encode_attrs+0x435/0x530 [nfsv4]
>> > [ 9839.008069]  [<ffffffff816e87e9>] ? inet_sendmsg+0x69/0xb0
>> > [ 9839.008069]  [<ffffffff81327ba3>] ? selinux_socket_sendmsg+0x23/0x30
>> > [ 9839.008069]  [<ffffffff8164c1df>] ? do_sock_sendmsg+0x9f/0xc0
>> > [ 9839.008069]  [<ffffffff8164c278>] ? kernel_sendmsg+0x58/0x70
>> > [ 9839.008069]  [<ffffffffa011acc0>] ? xdr_reserve_space+0x20/0x170 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa011acc0>] ? xdr_reserve_space+0x20/0x170 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa0341b40>] ? nfs4_xdr_enc_open_noattr+0x130/0x130 [nfsv4]
>> > [ 9839.008069]  [<ffffffffa03419a5>] encode_open+0x2d5/0x340 [nfsv4]
>> > [ 9839.008069]  [<ffffffffa0341b40>] ? nfs4_xdr_enc_open_noattr+0x130/0x130 [nfsv4]
>> > [ 9839.008069]  [<ffffffffa011ab89>] ? xdr_encode_opaque+0x19/0x20 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa0339cfb>] ? encode_string+0x2b/0x40 [nfsv4]
>> > [ 9839.008069]  [<ffffffffa0341bf3>] nfs4_xdr_enc_open+0xb3/0x140 [nfsv4]
>> > [ 9839.008069]  [<ffffffffa0110a4c>] rpcauth_wrap_req+0xac/0xf0 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa01017db>] call_transmit+0x18b/0x2d0 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa0101650>] ? call_decode+0x860/0x860 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa0101650>] ? call_decode+0x860/0x860 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa010caa0>] __rpc_execute+0x90/0x460 [sunrpc]
>> > [ 9839.008069]  [<ffffffffa010ce85>] rpc_async_schedule+0x15/0x20 [sunrpc]
>> > [ 9839.008069]  [<ffffffff810b452b>] process_one_work+0x1bb/0x410
>> > [ 9839.008069]  [<ffffffff810b47d3>] worker_thread+0x53/0x470
>> > [ 9839.008069]  [<ffffffff810b4780>] ? process_one_work+0x410/0x410
>> > [ 9839.008069]  [<ffffffff810b4780>] ? process_one_work+0x410/0x410
>> > [ 9839.008069]  [<ffffffff810ba7b8>] kthread+0xd8/0xf0
>> > [ 9839.008069]  [<ffffffff810ba6e0>] ? kthread_worker_fn+0x180/0x180
>> > [ 9839.008069]  [<ffffffff81786418>] ret_from_fork+0x58/0x90
>> > [ 9839.008069]  [<ffffffff810ba6e0>] ? kthread_worker_fn+0x180/0x180
>> > [ 9839.008069] Code: 00 00 48 c7 c7 21 fa 37 a0 e8 94 1c d6 e0 c6 05 d2 17 05 00 01 8b 03 eb d7 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 <0f> 0b 0f 1f 44 00 00 66 66 66 66 90 55 48 89 e5 41 54 53 89 f3
>> > [ 9839.008069] RIP  [<ffffffffa0339cc9>] reserve_space.part.73+0x9/0x10 [nfsv4]
>> > [ 9839.008069]  RSP <ffff88003667ba58>
>> > [ 9839.071114] ---[ end trace cc14c03adb522e94 ]---
>> >
>>
>> Could you please check if the following fixes it for you?
>>
>> Cheers
>>   Trond
>
> Sure, I'll test it when I get some time. Unfortunately, I don't have a
> way to reproduce this reliably. I just had it pop up a couple of times,
> mostly when the server crashed and came back up.
>
> The fix looks plausible though...

With the following patch of 4.2.0-rc4 also oops here.

p = reserve_space(xdr, 4 + (bmval_len << 2) + 4 + len);
the bmval_len is so lager that reserve_space failed, and BUG_ON!

I found, it is caused by the sunrpc async sending method,
For the open of CRATE,  in nfs4_atomic_open(), a nfs4_label in stack is used!

static struct inode *
nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx,
                int open_flags, struct iattr *attr, int *opened)
{
        struct nfs4_state *state;
        struct nfs4_label l = {0, 0, 0, NULL}, *label = NULL;

        label = nfs4_label_init_security(dir, ctx->dentry, attr, &l);

        /* Protect against concurrent sillydeletes */
        state = nfs4_do_open(dir, ctx, open_flags, attr, label, opened);

        nfs4_label_release_security(label);

        if (IS_ERR(state))
                return ERR_CAST(state);
        return state->inode;
}

and will be set to p->o_arg.label of nfs4_opendata in nfs4_opendata_alloc().
nfs4_opendata will passed to the sunrpc async thread.

But if before the async thread encoding the request, the nfs request
break by Ctrl+C
and nfs4_label_release_security, the async will call an invalidate nfs4_label.

Oops!!!

I have make a draft setting the nfs4_label in a malloced memory will
solve this test,
But I don't think it's safe for other async calling.

thanks,
Kinglong Mee
