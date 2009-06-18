From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] VFS: Add VFS helper functions for setting up
	private namespaces
Date: Thu, 18 Jun 2009 16:55:47 -0400
Message-ID: <20090618205547.GA10932@infradead.org>
References: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org> <20090618192500.19433.90622.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090618192500.19433.90622.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2009 at 12:25:01PM -0700, Trond Myklebust wrote:
>  /* spinlock for vfsmount related operations, inplace of dcache_lock */
>  __cacheline_aligned_in_smp DEFINE_SPINLOCK(vfsmount_lock);
> +EXPORT_SYMBOL(vfsmount_lock);

This is not mentioned in the patch description and also doesn't seem
to be used in the following patches.

Exporting it is a really bad idea anyway as it protects data structures
that should not be exposed to filesystems.

