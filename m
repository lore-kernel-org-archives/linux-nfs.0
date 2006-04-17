From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC [PATCH 1/6] VFS: Add GPL_EXPORTED function vfs_kern_mount()
Date: Mon, 17 Apr 2006 20:39:31 +0100
Message-ID: <20060417193931.GA13470@infradead.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
	<20060411180530.12579.19894.stgit@lade.trondhjem.org>
	<20060417185213.GA12542@infradead.org>
	<1145302543.10827.25.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1145302543.10827.25.camel@lade.trondhjem.org>
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

On Mon, Apr 17, 2006 at 03:35:43PM -0400, Trond Myklebust wrote:
> > all other callers of do_kern_mount except for do_new_mount should
> > probably use it directly instead of doing the name lookup.  Except
> > for simple_pin_fs() which will need a paramter change all those
> > would be trivial aswell.  So instead of adding another entry point care
> > to switch the existing one to saner prototype and the sane name?
> 
> That sounds reasonable. By 'switch to the sane name' you do mean convert
> all uses of 'do_kern_mount' to 'vfs_kern_mount'?

Yes, sorry for the odd wording.
