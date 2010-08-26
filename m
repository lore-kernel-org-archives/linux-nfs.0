From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: hang in writeback code on nfsv4 mount
Date: Thu, 26 Aug 2010 14:24:11 +0300
Message-ID: <1282821851.24044.284.camel@localhost>
References: <20100825023425.GA24591@fieldses.org>
	 <1282717945.24044.187.camel@localhost>
	 <20100825154451.GB14440@fieldses.org>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <jaxboe@fusionio.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57157 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab0HZLZe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 07:25:34 -0400
Received: by mail-fx0-f46.google.com with SMTP id 13so1175018fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Aug 2010 04:25:34 -0700 (PDT)
In-Reply-To: <20100825154451.GB14440@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-08-25 at 11:44 -0400, J. Bruce Fields wrote:
> > sudo mount -t nfs4 sauron:/home/dedekind/ /mnt/sauron_home/
> >=20
> > works fine. Any hints about how to reproduce this are welcome.
>=20
> Huh.  The simple mount hits it every time for me.  I'll investigate s=
ome
> more.

Ok, I can reproduce something which looks like memory corruption for me=
:

=46S-Cache: Netfs 'nfs' registered for caching
------------[ cut here ]------------
WARNING: at lib/list_debug.c:51 list_del+0x5e/0x8b()
Hardware name:        =20
list_del corruption. next->prev should be ffff880234e4c320, but was
ffff880234293290
Modules linked in: nfs lockd fscache nfs_acl auth_rpcgss sunrpc ioatdma
iTCO_wdt i2c_i801 dca iTCO_vendor_support i5k_amb i2c_core [last
unloaded: scsi_wait_scan]
Pid: 1094, comm: mount.nfs4 Not tainted 2.6.35+ #6
Call Trace:
 [<ffffffff810466be>] warn_slowpath_common+0x80/0x98
 [<ffffffff811e29c5>] ? percpu_counter_destroy+0x21/0x4b
 [<ffffffff8104676a>] warn_slowpath_fmt+0x41/0x43
 [<ffffffff811e0412>] list_del+0x5e/0x8b
 [<ffffffff811e29ce>] percpu_counter_destroy+0x2a/0x4b
 [<ffffffff810b8280>] bdi_destroy+0x105/0x122
 [<ffffffffa00c4a96>] nfs_free_server+0xa1/0xca [nfs]
 [<ffffffffa00ce6f2>] nfs4_kill_super+0x4f/0x72 [nfs]
 [<ffffffff810e7584>] deactivate_locked_super+0x21/0x41
 [<ffffffff810e79f2>] deactivate_super+0x40/0x45
 [<ffffffff810fc088>] mntput_no_expire+0xb8/0xed
 [<ffffffff810fc157>] release_mounts+0x9a/0xb0
 [<ffffffff810fc1d7>] put_mnt_ns+0x6a/0x7b
 [<ffffffffa00cf2bf>] nfs_follow_remote_path+0x19a/0x296 [nfs]
 [<ffffffffa00cf4d7>] nfs4_try_mount+0x75/0xaf [nfs]
 [<ffffffffa00cf787>] nfs4_get_sb+0x276/0x2ff [nfs]
 [<ffffffff810e77d6>] vfs_kern_mount+0xb8/0x196
 [<ffffffff810e7912>] do_kern_mount+0x48/0xe8
 [<ffffffff810fd984>] do_mount+0x771/0x7e8
 [<ffffffff810fda7e>] sys_mount+0x83/0xbd
 [<ffffffff810089c2>] system_call_fastpath+0x16/0x1b
---[ end trace df91999b0b9e95b4 ]---

--=20
Best Regards,
Artem Bityutskiy (=D0=90=D1=80=D1=82=D1=91=D0=BC =D0=91=D0=B8=D1=82=D1=8E=
=D1=86=D0=BA=D0=B8=D0=B9)

