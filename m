Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab3KLQU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 11:20:28 -0500
Date: Tue, 12 Nov 2013 11:20:21 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>, chuck.lever@oracle.com
Subject: Re: Thread overran stack, or stack corrupted BUG on mount
Message-ID: <20131112112021.1a0a60ca@tlielax.poochiereds.net>
In-Reply-To: <20131112105539.4f804fc6@tlielax.poochiereds.net>
References: <2C73011F-0939-434C-9E4D-13A1EB1403D7@netapp.com>
	<20131112105539.4f804fc6@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Nov 2013 10:55:39 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 12 Nov 2013 15:31:34 +0000
> Weston Andros Adamson <dros@netapp.com> wrote:
> 
> > I got this oops yesterday running the “test_sec_options.sh” script I recently posted as a patch to Anna’s nfs-ordeal repo (tons of mount/umount).
> > 
> > At this point GSSD had died (I was tracking down a fd leak).  I haven’t been able to reproduce this yet.
> > 
> > Any idea if I should trust the stack trace? Could this be related to the issue Jeff just posted?
> > 
> > -dros
> > 
> > BUG: unable to handle kernel paging request at ffff88017a604030
> > IP: [<ffffffff81063089>] __wake_up+0x22/0x4d
> > PGD 2651067 PUD 0 
> > Thread overran stack, or stack corrupted
> > Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > Modules linked in: nfsv4 cts rpcsec_gss_krb5 nfsv3 nfs fscache crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ppdev ablk_helper cryptd serio_raw i2c_piix4 i2c_core e1000 nfsd parport_pc parport shpchp auth_rpcgss oid_registry exportfs nfs_acl lockd floppy freq_table sunrpc autofs4 mptspi scsi_transport_spi mptscsih mptbase ata_generic
> > CPU: 0 PID: 10547 Comm: mount.nfs Not tainted 3.12.0-rc3-branch-dros_testing+ #1
> > Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > task: ffff8800798f2100 ti: ffff88007a604000 task.ti: ffff88007a604000
> > RIP: 0010:[<ffffffff81063089>]  [<ffffffff81063089>] __wake_up+0x22/0x4d
> > RSP: 0018:ffff88007a604028  EFLAGS: 00010092
> > RAX: 0000000000000296 RBX: ffffffffa006a980 RCX: 000000009a519a50
> > RDX: 000000009a509a50 RSI: 000000000000038a RDI: ffffffffa006a980
> > RBP: ffff88017a604058 R08: 0000000000000003 R09: 0000000000000001
> > R10: ffff88006d41d7c0 R11: ffff88007f20b000 R12: ffff88007a6058e0
> > R13: ffff8800645d8018 R14: ffff88007a6058f8 R15: ffff8800798f2100
> > FS:  00007fb2765b3880(0000) GS:ffff88007f200000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: ffff88017a604030 CR3: 000000007a6ba000 CR4: 00000000001407f0
> > Stack:
> >  ffff88007a604038 0000000000000000 ffff880000000001 0000000000000003
> >  ffff88006453a0d0 ffff88007a6058e0 ffff88007a604078 ffffffffa0045de2
> >  ffff88006453dbe0 ffff88006453dbe0 ffff88007a604098 ffffffffa0045d27
> > Call Trace:
> >  [<ffffffffa0045de2>] ? rpc_release_client+0x4a/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045d27>] ? rpc_free_client+0x56/0xc7 [sunrpc]
> >  [<ffffffffa0045e00>] ? rpc_release_client+0x68/0x9a [sunrpc]
> >  [<ffffffffa0045f39>] ? rpc_shutdown_client+0x107/0x116 [sunrpc]
> >  [<ffffffffa02a6456>] ? __fscache_cookie_put+0x43/0x4f [fscache]
> >  [<ffffffffa02a65ca>] ? __fscache_relinquish_cookie+0x168/0x16d [fscache]
> >  [<ffffffffa02bdc2b>] ? nfs_free_client+0x4c/0xaf [nfs]
> >  [<ffffffffa0340e4a>] ? nfs4_free_client+0x97/0x9b [nfsv4]
> >  [<ffffffffa02bcfd9>] ? nfs_put_client+0xe8/0xed [nfs]
> >  [<ffffffffa0341126>] ? nfs4_init_client+0x22e/0x29d [nfsv4]
> >  [<ffffffffa02bc95f>] ? nfs_probe_fsinfo+0x2c7/0x2c7 [nfs]
> >  [<ffffffffa02bd1af>] ? nfs_get_client+0x8a/0x2bf [nfs]
> >  [<ffffffffa02bd37f>] ? nfs_get_client+0x25a/0x2bf [nfs]
> >  [<ffffffffa034059c>] ? nfs4_set_client+0x9f/0xf1 [nfsv4]
> >  [<ffffffffa004e917>] ? __rpc_init_priority_wait_queue+0x98/0xcf [sunrpc]
> >  [<ffffffffa0341999>] ? nfs4_create_server+0xfe/0x264 [nfsv4]
> >  [<ffffffffa033ac59>] ? nfs4_remote_mount+0x2f/0x57 [nfsv4]
> >  [<ffffffff8112a846>] ? mount_fs+0x69/0x157
> >  [<ffffffff810fb79b>] ? __alloc_percpu+0x10/0x12
> >  [<ffffffff8113fcbd>] ? vfs_kern_mount+0x62/0xd9
> >  [<ffffffffa033ac02>] ? nfs_do_root_mount+0x8c/0xb4 [nfsv4]
> >  [<ffffffffa033aea9>] ? nfs4_try_mount+0x60/0xbb [nfsv4]
> >  [<ffffffffa02c80eb>] ? nfs_fs_mount+0x88f/0x97a [nfs]
> >  [<ffffffffa02c8620>] ? nfs_clone_super+0x6b/0x6b [nfs]
> >  [<ffffffffa02c59ce>] ? nfs_set_super+0x53/0x53 [nfs]
> >  [<ffffffff8112a846>] ? mount_fs+0x69/0x157
> >  [<ffffffff810fb79b>] ? __alloc_percpu+0x10/0x12
> >  [<ffffffff8113fcbd>] ? vfs_kern_mount+0x62/0xd9
> >  [<ffffffff81141fa6>] ? do_mount+0x6ce/0x871
> >  [<ffffffff81141833>] ? copy_mount_options+0xc2/0x12f
> >  [<ffffffff811421ce>] ? SyS_mount+0x85/0xbe
> >  [<ffffffff814a4292>] ? system_call_fastpath+0x16/0x1b
> > Code: 89 e5 e8 98 ff ff ff 5d c3 0f 1f 44 00 00 55 48 89 e5 41 54 53 48 89 fb 48 83 ec 20 89 55 e0 89 75 e8 48 89 4d d8 e8 0c 99 43 00 <4c> 8b 45 d8 48 89 df 8b 55 e0 49 89 c4 31 c9 8b 75 e8 e8 b4 d0 
> > RIP  [<ffffffff81063089>] __wake_up+0x22/0x4d
> >  RSP <ffff88007a604028>
> > CR2: ffff88017a604030
> > ---[ end trace 1122f3f8cf98e4c2 ]---
> > 
> 
> Yep, I think this is the same problem I reported earlier. I ran the
> reproducer with rpc_debug turned up and ended up seeing a very similar
> stack trace. Basically the server is returning NFS4ERR_CLID_IN_USE but
> the client keeps retrying the call over and over.
> 
> I suspect that leads to some sort of recursion, but I haven't quite
> spotted it yet.
> 

(cc'ing Chuck since I think the problem is in the new detect_trunking code)

Ok, I think I see the problem. The looping comes from this block in
nfs4_discover_server_trunking:

-----------------[snip]-----------------
        case -NFS4ERR_CLID_INUSE:
        case -NFS4ERR_WRONGSEC:
                clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
                if (IS_ERR(clnt)) {
                        status = PTR_ERR(clnt);
                        break;
                }
                /* Note: this is safe because we haven't yet marked the
                 * client as ready, so we are the only user of
                 * clp->cl_rpcclient
                 */
                clnt = xchg(&clp->cl_rpcclient, clnt);
                rpc_shutdown_client(clnt);
                clnt = clp->cl_rpcclient;
                goto again;
-----------------[snip]-----------------

...so in the case of the reproducer, we get back -NFS4ERR_CLID_IN_USE,
at that point we call rpc_clone_client_set_auth(), which creates a new
rpc_clnt, but it's created as a child of the original.

When rpc_shutdown_client is called, the original clnt is not destroyed
because the child still holds a reference to it. So, we go and try the
call again and it fails with the same error over and over again, and we
end up with a long chain of rpc_clnt's.

How that ends up smashing the stack, I'm not sure though. I'm also not
sure of the remedy. It seems like we might ought to have some upper
bound on the number of SETCLIENTID attempts?

-- 
Jeff Layton <jlayton@redhat.com>
