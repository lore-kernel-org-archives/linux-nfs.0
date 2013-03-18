Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:58114 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215Ab3CRPsg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 11:48:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs: clear NFS_INO_LAYOUTCOMMIT* flags on
 destroy_layout
Date: Mon, 18 Mar 2013 15:48:28 +0000
Message-ID: <1363621707.4351.11.camel@leira.trondhjem.org>
References: <1363617514-24102-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1363617514-24102-1-git-send-email-bhalevy@tonian.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny,

On Mon, 2013-03-18 at 16:38 +0200, Benny Halevy wrote:
> When writing a large file over pNFS, the MDS rebooted and then the client crashed with the following stack trace over RHEL 2.6.32-358.el6.x86_64
> 

You might want to note that this Oops applies to upstream too. :-)

> <4>RIP: 0010:[<ffffffffa0474f35>]  [<ffffffffa0474f35>] pnfs_layoutcommit_inode+0x115/0x310 [nfs]
> <4>RSP: 0018:ffff8801bab4db60  EFLAGS: 00010286
> <4>RAX: ffff8802290755a8 RBX: ffff8802297756a0 RCX: 0000000000000000
> <4>RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880229775750
> <4>RBP: ffff8801bab4dba0 R08: 0000000000000000 R09: 0000000000000000
> <4>R10: 0000000000000003 R11: 0000000000000000 R12: ffff8802297754d8
> <4>R13: ffff880229075400 R14: 0000000000000000 R15: ffff880229775568
> <4>FS:  0000000000000000(0000) GS:ffff880028380000(0000) knlGS:0000000000000000
> <4>CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> <4>CR2: 0000000000000028 CR3: 000000020158a000 CR4: 00000000000027e0
> <4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> <4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> <4>Process flush-0:30 (pid: 3806, threadinfo ffff8801bab4c000, task ffff880228c76ae0)
> <4>Stack:
> <4> ffff8802290755a8 ffff880229775750 ffffffffa047ae20 ffff8802297756a0
> <4><d> ffff8801bab4dd20 0000000000000000 ffff8801bab4dd20 ffff8802297757c0
> <4><d> ffff8801bab4dbd0 ffffffffa0451217 ffff8801bab4dd20 ffff8802297757c0
> <4>Call Trace:
> <4> [<ffffffffa0451217>] nfs_write_inode+0x87/0x100 [nfs]
> <4> [<ffffffff811ac81c>] writeback_single_inode+0x20c/0x290
> <4> [<ffffffff811acafe>] writeback_sb_inodes+0xce/0x180
> <4> [<ffffffff811acc5b>] writeback_inodes_wb+0xab/0x1b0
> <4> [<ffffffff811acffb>] wb_writeback+0x29b/0x3f0
> <4> [<ffffffff8150d6e0>] ? thread_return+0x4e/0x76e
> <4> [<ffffffff81081ac2>] ? del_timer_sync+0x22/0x30
> <4> [<ffffffff811ad2e9>] wb_do_writeback+0x199/0x240
> <4> [<ffffffff811ad3f3>] bdi_writeback_task+0x63/0x1b0
> <4> [<ffffffff81096b47>] ? bit_waitqueue+0x17/0xd0
> <4> [<ffffffff8113ca40>] ? bdi_start_fn+0x0/0x100
> <4> [<ffffffff8113cac6>] bdi_start_fn+0x86/0x100
> <4> [<ffffffff8113ca40>] ? bdi_start_fn+0x0/0x100
> <4> [<ffffffff81096916>] kthread+0x96/0xa0
> <4> [<ffffffff8100c0ca>] child_rip+0xa/0x20
> <4> [<ffffffff81096880>] ? kthread+0x0/0xa0
> <4> [<ffffffff8100c0c0>] ? child_rip+0x0/0x20
> <4>Code: 01 00 00 48 89 d7 48 89 55 c8 48 89 45 c0 e8 93 b0 09 e1 f0 41 0f ba 37 09 19 d2 85 d2 48 8b 45 c0 0f 84 af 01 00 00 48 8b 53 f0 <4c> 8b 7a 28 48 8d 4a 28 49 39 cf 75 26 e9 e1 00 00 00 66 0f 1f
> <1>RIP  [<ffffffffa0474f35>] pnfs_layoutcommit_inode+0x115/0x310 [nfs]
> <4> RSP <ffff8801bab4db60>
> <4>CR2: 0000000000000028
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/pnfs.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 48ac5aa..483bd94 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -497,6 +497,8 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
>  		pnfs_get_layout_hdr(lo);
>  		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RO_FAILED);
>  		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
> +		clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
> +		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
>  		spin_unlock(&nfsi->vfs_inode.i_lock);
>  		pnfs_free_lseg_list(&tmp_list);
>  		pnfs_put_layout_hdr(lo);
> @@ -1813,11 +1815,16 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
>  	loff_t end_pos;
>  	int status = 0;
>  
> -	dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
> +	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
> +		dprintk("%s: inode %lu: not required\n", __func__, inode->i_ino);
> +		return 0;
> +	}
>  
> -	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
> +	if (WARN_ON(!nfsi->layout))
>  		return 0;


This looks like the wrong thing to do. We know how the system got here:
someone called fsync() or sync(), and NFS_INO_LAYOUTCOMMIT was set.
What we don't know is why the layout was freed before
pnfs_layoutcommit_inode() was called.

I suggest that we rather put a

	WARN_ON_ONCE(test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
	WARN_ON_ONCE(test_and_clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags));

inside pnfs_detach_layout_hdr(). That should stand a better chance of
catching the sort of bug you found above.

BTW: shouldn't pnfs_return_layout() always call
pnfs_layoutcommit_inode()?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
