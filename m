From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC [PATCH 1/6] VFS: Add GPL_EXPORTED function vfs_kern_mount()
Date: Mon, 17 Apr 2006 19:52:13 +0100
Message-ID: <20060417185213.GA12542@infradead.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org> <20060411180530.12579.19894.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	nfsv4@linux-nfs.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20060411180530.12579.19894.stgit@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Apr 11, 2006 at 02:05:30PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> do_kern_mount() does not allow the kernel to use private mount interfaces
> without exposing the same interfaces to userland. The problem is that the
> filesystem is referenced by name, thus meaning that it and its mount
> interface must be registered in the global filesystem list.
> 
> vfs_kern_mount() passes the struct file_system_type as an explicit
> parameter in order to overcome this limitation.

Looks good.  In addition please switch kern_mount to use it instead
of converting from struct file_system_type to name and back.  Also
all other callers of do_kern_mount except for do_new_mount should
probably use it directly instead of doing the name lookup.  Except
for simple_pin_fs() which will need a paramter change all those
would be trivial aswell.  So instead of adding another entry point care
to switch the existing one to saner prototype and the sane name?

