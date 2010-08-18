Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53245 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750708Ab0HRCNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 22:13:53 -0400
Message-ID: <4C6B4181.50100@cn.fujitsu.com>
Date: Wed, 18 Aug 2010 10:12:17 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Adam Lackorzynski <adam@os.inf.tu-dresden.de>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        stable@kernel.org
Subject: Re: 2.6.35.2: NFS related Oops
References: <20100816215056.GA5376@os.inf.tu-dresden.de>	 <4C6A5FF1.3070209@cn.fujitsu.com>	 <20100817171454.GB11366@os.inf.tu-dresden.de> <1282084985.18385.24.camel@heimdal.trondhjem.org>
In-Reply-To: <1282084985.18385.24.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> On Tue, 2010-08-17 at 19:14 +0200, Adam Lackorzynski wrote:
>> On Tue Aug 17, 2010 at 18:09:53 +0800, Bian Naimeng wrote:
>>>   Please try to apply the followed patch.
>> Thanks, this fixes the Oops. Patch is required for both 2.6.35 and
>> 2.6.36 trees.

  ... snip ...

>>  	/* We can't create new files, or truncate existing ones here */
>>  	openflags &= ~(O_CREAT|O_TRUNC);
>> -- 
> 
> Nope. The problem is the recent switch to LOOKUP_EXCL as the authority
> for whether or not we're doing an exclusive create.
> 
> Does the following patch work?
> 

  Hi Trond, i guess it's not work.

  As i see, if we want get LOOKUP_EXCL at nd->flags,  we must open file with 
  O_CREAT and O_EXCL, "nd->flags & LOOKUP_EXCL" have the same effect with
  "(openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)", so i think the kernel
  still crash, right?

-- 
Regards
Bian Naimeng

> -----------------------------------------------------------------------------------------------
> NFS: Fix an Oops in the NFSv4 atomic open code
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Adam Lackorzynski reports:
> 
> with 2.6.35.2 I'm getting this reproducible Oops:
> 
> [  110.825396] BUG: unable to handle kernel NULL pointer dereference at
> (null)
> [  110.828638] IP: [<ffffffff811247b7>] encode_attrs+0x1a/0x2a4
> [  110.828638] PGD be89f067 PUD bf18f067 PMD 0
> [  110.828638] Oops: 0000 [#1] SMP
> [  110.828638] last sysfs file: /sys/class/net/lo/operstate
> [  110.828638] CPU 2
> [  110.828638] Modules linked in: rtc_cmos rtc_core rtc_lib amd64_edac_mod
> i2c_amd756 edac_core i2c_core dm_mirror dm_region_hash dm_log dm_snapshot
> sg sr_mod usb_storage ohci_hcd mptspi tg3 mptscsih mptbase usbcore nls_base
> [last unloaded: scsi_wait_scan] 
> [  110.828638] 
> [  110.828638] Pid: 11264, comm: setchecksum Not tainted 2.6.35.2 #1
> [  110.828638] RIP: 0010:[<ffffffff811247b7>]  [<ffffffff811247b7>]
> encode_attrs+0x1a/0x2a4
> [  110.828638] RSP: 0000:ffff88003bf5b878  EFLAGS: 00010296
> [  110.828638] RAX: ffff8800bddb48a8 RBX: ffff88003bf5bb18 RCX:
> 0000000000000000
> [  110.828638] RDX: ffff8800be258800 RSI: 0000000000000000 RDI:
> ffff88003bf5b9f8
> [  110.828638] RBP: 0000000000000000 R08: ffff8800bddb48a8 R09:
> 0000000000000004
> [  110.828638] R10: 0000000000000003 R11: ffff8800be779000 R12:
> ffff8800be258800
> [  110.828638] R13: ffff88003bf5b9f8 R14: ffff88003bf5bb20 R15:
> ffff8800be258800
> [  110.828638] FS:  0000000000000000(0000) GS:ffff880041e00000(0063)
> knlGS:00000000556bd6b0
> [  110.828638] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> [  110.828638] CR2: 0000000000000000 CR3: 00000000be8ef000 CR4:
> 00000000000006e0
> [  110.828638] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  110.828638] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  110.828638] Process setchecksum (pid: 11264, threadinfo
> ffff88003bf5a000, task ffff88003f232210)
> [  110.828638] Stack:
> [  110.828638]  0000000000000000 ffff8800bfbcf920 0000000000000000
> 0000000000000ffe
> [  110.828638] <0> 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  110.828638] <0> 0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  110.828638] Call Trace:
> [  110.828638]  [<ffffffff81124c1f>] ? nfs4_xdr_enc_setattr+0x90/0xb4
> [  110.828638]  [<ffffffff81371161>] ? call_transmit+0x1c3/0x24a
> [  110.828638]  [<ffffffff813774d9>] ? __rpc_execute+0x78/0x22a
> [  110.828638]  [<ffffffff81371a91>] ? rpc_run_task+0x21/0x2b
> [  110.828638]  [<ffffffff81371b7e>] ? rpc_call_sync+0x3d/0x5d
> [  110.828638]  [<ffffffff8111e284>] ? _nfs4_do_setattr+0x11b/0x147
> [  110.828638]  [<ffffffff81109466>] ? nfs_init_locked+0x0/0x32
> [  110.828638]  [<ffffffff810ac521>] ? ifind+0x4e/0x90
> [  110.828638]  [<ffffffff8111e2fb>] ? nfs4_do_setattr+0x4b/0x6e
> [  110.828638]  [<ffffffff8111e634>] ? nfs4_do_open+0x291/0x3a6
> [  110.828638]  [<ffffffff8111ed81>] ? nfs4_open_revalidate+0x63/0x14a
> [  110.828638]  [<ffffffff811056c4>] ? nfs_open_revalidate+0xd7/0x161
> [  110.828638]  [<ffffffff810a2de4>] ? do_lookup+0x1a4/0x201
> [  110.828638]  [<ffffffff810a4733>] ? link_path_walk+0x6a/0x9d5
> [  110.828638]  [<ffffffff810a42b6>] ? do_last+0x17b/0x58e
> [  110.828638]  [<ffffffff810a5fbe>] ? do_filp_open+0x1bd/0x56e
> [  110.828638]  [<ffffffff811cd5e0>] ? _atomic_dec_and_lock+0x30/0x48
> [  110.828638]  [<ffffffff810a9b1b>] ? dput+0x37/0x152
> [  110.828638]  [<ffffffff810ae063>] ? alloc_fd+0x69/0x10a
> [  110.828638]  [<ffffffff81099f39>] ? do_sys_open+0x56/0x100
> [  110.828638]  [<ffffffff81027a22>] ? ia32_sysret+0x0/0x5
> [  110.828638] Code: 83 f1 01 e8 f5 ca ff ff 48 83 c4 50 5b 5d 41 5c c3 41
> 57 41 56 41 55 49 89 fd 41 54 49 89 d4 55 48 89 f5 53 48 81 ec 18 01 00 00
> <8b> 06 89 c2 83 e2 08 83 fa 01 19 db 83 e3 f8 83 c3 18 a8 01 8d
> [  110.828638] RIP  [<ffffffff811247b7>] encode_attrs+0x1a/0x2a4
> [  110.828638]  RSP <ffff88003bf5b878>
> [  110.828638] CR2: 0000000000000000
> [  112.840396] ---[ end trace 95282e83fd77358f ]---
> 
> It looks as if Al Viro's commit 3516586a424ea5727be089da6541cbd5644f0497
> (make O_EXCL in nd->intent.flags visible in nd->flags) missed a case.
> 
> Cc: stable@kernel.org
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/dir.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index bd91b27..275efac 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1107,7 +1107,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
>  		goto no_open_dput;
>  	openflags = nd->intent.open.flags;
>  	/* We cannot do exclusive creation on a positive dentry */
> -	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
> +	if (nd->flags & LOOKUP_EXCL)
>  		goto no_open_dput;
>  	/* We can't create new files, or truncate existing ones here */
>  	openflags &= ~(O_CREAT|O_TRUNC);
> 

