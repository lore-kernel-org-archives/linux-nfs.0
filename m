Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36499 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbbANPsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 10:48:39 -0500
Date: Wed, 14 Jan 2015 07:48:38 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfs: fix dio deadlock when O_DIRECT flag is flipped
Message-ID: <20150114154838.GA15323@infradead.org>
References: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 10:09:03PM +0800, Peng Tao wrote:
> Running xfstest generic/036, we'll get following VM_BUG_ON in
> nfs_direct_IO(). 036 toggles O_DIRECT flag while IO is going on.
> So the VM_BUG_ON should not exist there. However, we have a deadlock
> in the code path as well, because inode->i_mutex is taken when calling
> into ->direct_IO. And nfs_file_direct_write() would grab inode->i_mutex
> again.
> 
> Meanwhile, nfs_file_direct_write() does a lot of things that is already
> done by vfs before ->direct_IO is called. So skip those duplicates. One
> exception is i_size_write. vfs does not take i_lock when setting i_size.
> But nfs appears to need i_lock when setting i_size.

But given that NFS implements direct I/O without ->direct_IO (except for
the horrible swap over NFS hack that is on it's way out) it shold
never be called.

The right fix is to determine the O_DIRECT flag in one place when
entering a write, and then pass it down on the stack.  We already do
this in XFS for example, it just needs to be expanded to filemap.c
so that more filesystems benefit from it.
