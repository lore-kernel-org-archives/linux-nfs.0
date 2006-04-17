From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RFC [PATCH 1/6] VFS: Add GPL_EXPORTED function vfs_kern_mount()
Date: Mon, 17 Apr 2006 15:35:43 -0400
Message-ID: <1145302543.10827.25.camel@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
	<20060411180530.12579.19894.stgit@lade.trondhjem.org>
	<20060417185213.GA12542@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060417185213.GA12542@infradead.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2006-04-17 at 19:52 +0100, Christoph Hellwig wrote:
> On Tue, Apr 11, 2006 at 02:05:30PM -0400, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > do_kern_mount() does not allow the kernel to use private mount interfaces
> > without exposing the same interfaces to userland. The problem is that the
> > filesystem is referenced by name, thus meaning that it and its mount
> > interface must be registered in the global filesystem list.
> > 
> > vfs_kern_mount() passes the struct file_system_type as an explicit
> > parameter in order to overcome this limitation.
> 
> Looks good.  In addition please switch kern_mount to use it instead
> of converting from struct file_system_type to name and back.  Also
> all other callers of do_kern_mount except for do_new_mount should
> probably use it directly instead of doing the name lookup.  Except
> for simple_pin_fs() which will need a paramter change all those
> would be trivial aswell.  So instead of adding another entry point care
> to switch the existing one to saner prototype and the sane name?

That sounds reasonable. By 'switch to the sane name' you do mean convert
all uses of 'do_kern_mount' to 'vfs_kern_mount'?

Cheers,
  Trond
