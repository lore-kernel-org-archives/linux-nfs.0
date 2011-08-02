Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54781 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754071Ab1HBM25 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 08:28:57 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Peng Tao <bergwolf@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Tue, 02 Aug 2011 08:28:54 -0400
In-Reply-To: <20110802032320.GA18296@merit.edu>
References: <20110729185415.GA23061@merit.edu>
	 <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu>
	 <1311988172.16078.15.camel@lade.trondhjem.org>
	 <20110730032621.GB25188@merit.edu>
	 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
	 <1312233006.23392.17.camel@lade.trondhjem.org>
	 <1312238117.23392.19.camel@lade.trondhjem.org>
	 <20110802022144.GA18157@merit.edu>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
	 <20110802032320.GA18296@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312288134.4616.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-01 at 23:23 -0400, Jim Rees wrote: 
> Myklebust, Trond wrote:
> 
>   That's a different issue. If you do an 'echo t >/proc/sysrq-trigger',
>   then do you see any other process that is stuck in the nfs layer and
>   that might be holding the inode->i_mutex?
> 
> Hard to tell.  There are a couple of possibilities.  I've put the console
> output here, and will investigate more in the morning:
> 
> http://www.citi.umich.edu/projects/nfsv4/pnfs/block/download/console.txt


Hmm... You don't seem to have all the mutex debugging options enabled,
but I strongly suspect that this thread is the culprit.


> t_mtab          D 0000000000000000     0  1833   1698 0x00000080
>  ffff880072f73ac8 0000000000000086 ffff880072f73a98 ffffffff00000000
>  ffff880072f72010 ffff8800698fdc00 0000000000012c80 ffff880072f73fd8
>  ffff880072f73fd8 0000000000012c80 ffffffff81a0c020 ffff8800698fdc00
> Call Trace:
>  [<ffffffffa01f5a52>] ? rpc_queue_empty+0x29/0x29 [sunrpc]
>  [<ffffffffa01f5a81>] rpc_wait_bit_killable+0x2f/0x33 [sunrpc]
>  [<ffffffff81453eec>] __wait_on_bit+0x43/0x76
>  [<ffffffff81453f88>] out_of_line_wait_on_bit+0x69/0x74
>  [<ffffffffa01f5a52>] ? rpc_queue_empty+0x29/0x29 [sunrpc]
>  [<ffffffff81069213>] ? autoremove_wake_function+0x38/0x38
>  [<ffffffffa01f5f0a>] __rpc_execute+0xed/0x249 [sunrpc]
>  [<ffffffffa01f60a3>] rpc_execute+0x3d/0x42 [sunrpc]
>  [<ffffffffa01efbca>] rpc_run_task+0x79/0x81 [sunrpc]
>  [<ffffffffa028c3b7>] nfs4_call_sync_sequence+0x60/0x81 [nfs]
>  [<ffffffff810fe4af>] ? kmem_cache_alloc_trace+0xab/0xbd
>  [<ffffffffa028c55e>] _nfs4_call_sync_session+0x14/0x16 [nfs]
>  [<ffffffffa0279b7d>] ? nfs_alloc_fattr+0x24/0x57 [nfs]
>  [<ffffffffa028ecd1>] _nfs4_proc_remove+0xcd/0x110 [nfs]
>  [<ffffffffa028ed43>] nfs4_proc_remove+0x2f/0x55 [nfs]
>  [<ffffffffa027524f>] nfs_unlink+0xf5/0x1a3 [nfs]
>  [<ffffffff81114c66>] vfs_unlink+0x70/0xd1
>  [<ffffffff8111714d>] do_unlinkat+0xd5/0x161
>  [<ffffffff8112247e>] ? mntput+0x21/0x23
>  [<ffffffff8111381d>] ? path_put+0x1d/0x21
>  [<ffffffff8109932e>] ? audit_syscall_entry+0x119/0x145
>  [<ffffffff811171ea>] sys_unlink+0x11/0x13
>  [<ffffffff8145b612>] system_call_fastpath+0x16/0x1b

Any idea which file that thread is deleting, and why that might be
hanging?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

