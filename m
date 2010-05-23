From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS, race in writeback?
Date: Sun, 23 May 2010 14:56:16 -0400
Message-ID: <1274640976.4860.97.camel@heimdal.trondhjem.org>
References: <11621.1274548448@jrobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755206Ab0EWS4S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 May 2010 14:56:18 -0400
In-Reply-To: <11621.1274548448@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-05-23 at 02:14 +0900, J. R. Okajima wrote: 
> I got "task xxx blocked for more than 120 seconds" in 2.6.34 NFS, which
> didn't happen in 2.6.33. The four call-traces are attached.
<snip> 
> INFO: task dd:4230 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> dd            D 0000000000000001     0  4230  23641 0x00000000
>  ffff880010857b28 0000000000000046 0000000000000000 ffff880010856000
>  ffff880010857fd8 ffff880010856000 ffff880010857fd8 ffff880010857fd8
>  ffff880010507040 0000000000014d00 0000000000000001 ffff880010507040
> Call Trace:
>  [<ffffffff8147f962>] io_schedule+0x52/0x70
>  [<ffffffff810dc66d>] sync_page+0x6d/0xb0
>  [<ffffffff8147ff4a>] __wait_on_bit_lock+0x5a/0xb0
>  [<ffffffff810dc600>] ? sync_page+0x0/0xb0
>  [<ffffffff810dc5d9>] __lock_page+0x69/0x70
>  [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
>  [<ffffffff810e68a0>] write_cache_pages+0x2c0/0x420
>  [<ffffffff811dfd30>] ? nfs_writepages_callback+0x0/0x80
>  [<ffffffff811df126>] nfs_writepages+0xd6/0x170
>  [<ffffffff811df660>] ? nfs_flush_one+0x0/0x100
>  [<ffffffff810e6a54>] do_writepages+0x24/0x40
>  [<ffffffff81143d30>] writeback_single_inode+0x180/0x360
>  [<ffffffff81143f43>] sync_inode+0x33/0x50
>  [<ffffffff811de955>] nfs_wb_all+0x45/0x50
>  [<ffffffff811cfb3d>] nfs_do_fsync+0x2d/0x60
>  [<ffffffff811cfdf2>] nfs_file_flush+0x82/0xc0
>  [<ffffffff8111c0b2>] filp_close+0x42/0x90
>  [<ffffffff8111c1be>] sys_close+0xbe/0x160
>  [<ffffffff8100aa82>] system_call_fastpath+0x16/0x1b
> no locks held by dd/4230.
> 
> 
> INFO: task dd:4250 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> dd            D 0000000000000000     0  4250  23590 0x00000000
>  ffff88001249b988 0000000000000046 0000000000000001 ffff88001249a000
>  ffff88001249bfd8 ffff88001249a000 ffff88001249bfd8 ffff88001249bfd8
>  ffff88000da7e040 0000000000014d00 0000000000000000 ffff88000da7e040
> Call Trace:
>  [<ffffffff81136f8e>] inode_wait+0xe/0x20
>  [<ffffffff81480092>] __wait_on_bit+0x62/0x90
>  [<ffffffff81136f80>] ? inode_wait+0x0/0x20
>  [<ffffffff81143b83>] inode_wait_for_writeback+0x93/0xc0
>  [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
>  [<ffffffff81143cc8>] writeback_single_inode+0x118/0x360
>  [<ffffffff81143f43>] sync_inode+0x33/0x50
>  [<ffffffff811dfc36>] nfs_wb_page+0x76/0xc0
>  [<ffffffff811dfcc4>] nfs_flush_incompatible+0x44/0x70
>  [<ffffffff811cf8b5>] nfs_write_begin+0xb5/0x210
>  [<ffffffff810dba50>] generic_file_buffered_write+0x190/0x2e0
>  [<ffffffff810df224>] __generic_file_aio_write+0x484/0x540
>  [<ffffffff810df344>] ? generic_file_aio_write+0x64/0xd0
>  [<ffffffff810df358>] generic_file_aio_write+0x78/0xd0
>  [<ffffffff811d07cb>] nfs_file_write+0x10b/0x210
>  [<ffffffff8111e6e9>] do_sync_write+0xd9/0x120
>  [<ffffffff812070f6>] ? security_file_permission+0x16/0x20
>  [<ffffffff8111e93a>] ? rw_verify_area+0xea/0x160
>  [<ffffffff8111eac6>] vfs_write+0x116/0x230
>  [<ffffffff8111f477>] sys_write+0x57/0xb0
>  [<ffffffff8100aa82>] system_call_fastpath+0x16/0x1b
> 1 lock held by dd/4250:
>  #0:  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff810df344>] generic_file_aio_write+0x64/0xd0

Urgh. Yes, this looks like it is a consequence of commit
ba8b06e67ed7a560b0e7c80091bcadda4f4727a5. We need to revert the part
that calls sync_inode().

Does the following fix it for you?

Cheers
  Trond
--------------------------------------------------------------------------------------------- 
