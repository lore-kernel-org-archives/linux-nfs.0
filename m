Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46148 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbHRLdT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 07:33:19 -0400
Date: Tue, 18 Aug 2015 04:33:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] NFSv4.1/pnfs: Don't prevent layoutgets when doing
 return-on-close
Message-ID: <20150818113318.GA20461@infradead.org>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
 <20150817144256.GA30167@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150817144256.GA30167@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 17, 2015 at 07:42:56AM -0700, Christoph Hellwig wrote:
> This break the block layout client badly.  With this patch applied
> it silently hangs in xfstests generic/001.  I'll see if I can
> get more details out of my test setup.

Seems like it's waiting either forever or frequently in this
callchain:

[<ffffffff81d30f24>] rpc_wait_bit_killable+0x34/0x80
[<ffffffff81d30ee8>] __rpc_wait_for_completion_task+0x28/0x30
[<ffffffff8138a7cc>] nfs4_do_close+0x1dc/0x2d0
[<ffffffff8139a429>] __nfs4_close+0xd9/0x180
[<ffffffff8139a503>] nfs4_close_sync+0x13/0x20
[<ffffffff81380035>] nfs4_close_context+0x25/0x30
[<ffffffff81363a43>] __put_nfs_open_context+0xc3/0x110
[<ffffffff8136588c>] nfs_release+0x9c/0xb0
[<ffffffff81362581>] nfs_file_release+0x41/0x60
[<ffffffff811dca02>] __fput+0xa2/0x1e0
[<ffffffff811dcb79>] ____fput+0x9/0x10
[<ffffffff810e52b6>] task_work_run+0x96/0xb0
[<ffffffff810c89dc>] do_exit+0x2cc/0xa10
[<ffffffff810c91f7>] do_group_exit+0x47/0xc0
[<ffffffff810c9282>] SyS_exit_group+0x12/0x20
[<ffffffff81d80eae>] entry_SYSCALL_64_fastpath+0x12/0x76
[<ffffffffffffffff>] 0xffffffffffffffff

Trond, does this pass xfstests generic/001 fine with whatever Server
you're testing against?
